SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 03/19/2021
-- Description:	This stored procedure imports the ASPIRE trainings from
-- the AspireTraining table into the normal Training table
-- =============================================
CREATE PROC [dbo].[spImportAspireTrainings]
	@AspireID INT NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	--========= De-duplicate the AspireTraining table ==========

    --To hold any duplicate ASPIRE trainings
    DECLARE @tblDuplicateAspireTrainings TABLE
    (
        AspireTrainingPKToSave INT NOT NULL,
        EventAttendeeID INT NULL,
        CourseID INT NULL,
        EventID INT NULL,
        AspireID INT NULL
    );

	--Get the duplicate ASPIRE trainings
    INSERT INTO @tblDuplicateAspireTrainings
    (
        AspireTrainingPKToSave,
        EventAttendeeID,
        CourseID,
        EventID,
        AspireID
    )
    SELECT MAX(at.AspireTrainingPK),
           at.EventAttendeeID,
           at.CourseID,
           at.EventID,
           at.AspireID
    FROM dbo.AspireTraining at
	WHERE (@AspireID IS NULL OR at.AspireID = @AspireID)
    GROUP BY at.EventAttendeeID,
             at.CourseID,
             at.EventID,
             at.AspireID
    HAVING COUNT(at.AspireTrainingPK) > 1;

    --Delete the duplicates in the ASPIRE training table (keeping the newest record)
    DELETE at
    FROM dbo.AspireTraining at
        INNER JOIN @tblDuplicateAspireTrainings tdat
            ON tdat.EventAttendeeID = at.EventAttendeeID
               AND tdat.CourseID = at.CourseID
               AND tdat.EventID = at.EventID
               AND ((tdat.AspireID IS NULL AND at.AspireID IS NULL) OR (tdat.AspireID = at.AspireID))
    WHERE at.AspireTrainingPK <> tdat.AspireTrainingPKToSave;


	--========= Insert/update the Training table from the AspireTraining table ==========

    --Get the matching trainings that aren't already in the table
    --NOTE: A NULL value for the training code FK in the crosswalk table means that the training is ignored
    INSERT INTO dbo.Training
    (
        AspireEventAttendeeID,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		IsAspireTraining,
        TrainingDate,
        EmployeeFK,
        TrainingCodeFK
    )
    SELECT at.EventAttendeeID,
           'ASPIRE API',
           GETDATE(),
           NULL,
           NULL,
		   1,
           at.EventCompletionDate,
           e.EmployeePK,
           atc.CodeTrainingFK
    FROM dbo.AspireTraining at
        INNER JOIN dbo.AspireTrainingCrosswalk atc
            ON atc.AspireCourseID = at.CourseID
        INNER JOIN dbo.Employee e
            ON e.AspireID = at.AspireID
        LEFT JOIN dbo.Training t
            ON t.AspireEventAttendeeID = at.EventAttendeeID
				AND t.EmployeeFK = e.EmployeePK
    WHERE (@AspireID IS NULL OR at.AspireID = @AspireID)  --The optional ASPIRE ID parameter
		  AND t.TrainingPK IS NULL					--The training doesn't exist in the system yet
          AND atc.CodeTrainingFK IS NOT NULL	--There is a matched PIDS CodeTraining row
		  AND at.Attended = 1					--The employee attended the training
		  AND at.EventCompletionDate IS NOT NULL;  --The training date is valid			

    --Update matched trainings that have changed
    UPDATE t
    SET t.TrainingDate = at.EventCompletionDate,
        t.TrainingCodeFK = atc.CodeTrainingFK,
        t.Editor = 'ASPIRE API',
        t.EditDate = GETDATE()
    FROM dbo.AspireTraining at
        INNER JOIN dbo.AspireTrainingCrosswalk atc
            ON atc.AspireCourseID = at.CourseID
        INNER JOIN dbo.Employee e
            ON e.AspireID = at.AspireID
        INNER JOIN dbo.Training t
            ON t.AspireEventAttendeeID = at.EventAttendeeID
				AND t.EmployeeFK = e.EmployeePK
    WHERE (@AspireID IS NULL OR at.AspireID = @AspireID)  --The optional ASPIRE ID parameter
		  AND atc.CodeTrainingFK IS NOT NULL	--There is a matched PIDS CodeTraining row
		  AND at.Attended = 1				--The employee attended the training
		  AND at.EventCompletionDate IS NOT NULL  --The training date is valid
          AND								--Either the date or training type changed
          (
              t.TrainingDate <> at.EventCompletionDate
              OR t.TrainingCodeFK <> atc.CodeTrainingFK
          );


	--========= Get the unmatched rows from the AspireTraining table ==========

    --Get the unmatched trainings that are unmatched because of the 
	--crosswalk table.
    INSERT INTO dbo.UnmatchedAspireTraining
    (
        CreateDate,
        Creator,
        EventAttendeeID,
        CourseID,
        CourseTitle,
        EventID,
        EventTitle,
        EventStartDate,
        EventCompletionDate,
        AspireID,
        FullName,
        Attended,
        TPOTReliability,
        TPOTReliabilityExpirationDate,
        TPITOSReliability,
        TPITOSReliabilityExpirationDate
    )
    SELECT GETDATE(),
           'ASPIRE API',
           at.EventAttendeeID,
           at.CourseID,
           at.CourseTitle,
           at.EventID,
           at.EventTitle,
           at.EventStartDate,
           at.EventCompletionDate,
           at.AspireID,
           at.FullName,
           at.Attended,
           at.TPOTReliability,
           at.TPOTReliabilityExpirationDate,
           at.TPITOSReliability,
           at.TPITOSReliabilityExpirationDate
    FROM dbo.AspireTraining at
        LEFT JOIN dbo.AspireTrainingCrosswalk atc
            ON atc.AspireCourseID = at.CourseID
    WHERE (@AspireID IS NULL OR at.AspireID = @AspireID)  --The optional ASPIRE ID parameter
		AND atc.AspireTrainingCrosswalkPK IS NULL;


	--========= De-duplicate the Training table ==========

    --To hold any duplicate PIDS trainings that came from ASPIRE
    DECLARE @tblDuplicateTrainings TABLE
    (
        TrainingPKToSave INT NOT NULL,
        EmployeeFK INT NOT NULL,
        TrainingCodeFK INT NOT NULL,
        TrainingDate DATETIME NOT NULL,
        EventAttendeeID INT NULL
    );

    --Get any duplicate PIDS trainings that came from ASPIRE
    INSERT INTO @tblDuplicateTrainings
    (
        TrainingPKToSave,
        EmployeeFK,
        TrainingCodeFK,
        TrainingDate,
        EventAttendeeID
    )
    SELECT MIN(t.TrainingPK),
           t.EmployeeFK,
           t.TrainingCodeFK,
           t.TrainingDate,
           t.AspireEventAttendeeID
    FROM dbo.Training t
		INNER JOIN dbo.Employee e 
			ON e.EmployeePK = t.EmployeeFK
	WHERE (@AspireID IS NULL OR e.AspireID = @AspireID)  --The optional ASPIRE ID parameter 
		AND t.AspireEventAttendeeID IS NOT NULL
    GROUP BY t.EmployeeFK,
             t.TrainingCodeFK,
             t.TrainingDate,
             t.AspireEventAttendeeID
    HAVING COUNT(t.TrainingPK) > 1;

    --Delete the duplicates in the training table (keeping the oldest record)
    DELETE t
    FROM dbo.Training t
        INNER JOIN @tblDuplicateTrainings tdt
            ON tdt.EmployeeFK = t.EmployeeFK
               AND tdt.TrainingCodeFK = t.TrainingCodeFK
               AND tdt.TrainingDate = t.TrainingDate
               AND tdt.EventAttendeeID = t.AspireEventAttendeeID
    WHERE t.TrainingPK <> tdt.TrainingPKToSave;

	--Update the deleted rows
	UPDATE tc SET tc.Deleter = 'spImportAspireTrainings'
	FROM dbo.TrainingChanged tc
		INNER JOIN @tblDuplicateTrainings tdt
			ON tdt.EmployeeFK = tc.EmployeeFK
				AND tdt.TrainingCodeFK = tc.TrainingCodeFK
				AND tdt.TrainingDate = tc.TrainingDate
				AND tdt.EventAttendeeID = tc.AspireEventAttendeeID
	WHERE tc.TrainingPK <> tdt.TrainingPKToSave;


	--========= De-duplicate the UnmatchedAspireTraining table ==========

    --To hold any duplicate unmatched trainings
    DECLARE @tblDuplicateUnmatchedTrainings TABLE
    (
        UnmatchedTrainingPKToSave INT NOT NULL,
        EventAttendeeID INT NULL,
        CourseID INT NULL,
        EventID INT NULL,
        AspireID INT NULL
    );

	--Get the duplicate unmatched trainings
    INSERT INTO @tblDuplicateUnmatchedTrainings
    (
        UnmatchedTrainingPKToSave,
        EventAttendeeID,
        CourseID,
        EventID,
        AspireID
    )
    SELECT MAX(uat.UnmatchedAspireTrainingPK),
           uat.EventAttendeeID,
           uat.CourseID,
           uat.EventID,
           uat.AspireID
    FROM dbo.UnmatchedAspireTraining uat
	WHERE (@AspireID IS NULL OR uat.AspireID = @AspireID)  --The optional ASPIRE ID parameter
    GROUP BY uat.EventAttendeeID,
             uat.CourseID,
             uat.EventID,
             uat.AspireID
    HAVING COUNT(uat.UnmatchedAspireTrainingPK) > 1;

    --Delete the duplicates in the unmatched training table (keeping the newest record)
    DELETE uat
    FROM dbo.UnmatchedAspireTraining uat
        INNER JOIN @tblDuplicateUnmatchedTrainings tdut
            ON tdut.EventAttendeeID = uat.EventAttendeeID
               AND tdut.CourseID = uat.CourseID
               AND tdut.EventID = uat.EventID
               AND tdut.AspireID = uat.AspireID
    WHERE uat.UnmatchedAspireTrainingPK <> tdut.UnmatchedTrainingPKToSave;

	--========= Return the number of unmatched trainings ==========

    --Return the number of unmatched trainings
    SELECT COUNT(uat.UnmatchedAspireTrainingPK) NumUnmatchedTrainings
    FROM dbo.UnmatchedAspireTraining uat
    WHERE uat.UnmatchedAspireTrainingPK IS NOT NULL;

END;
GO

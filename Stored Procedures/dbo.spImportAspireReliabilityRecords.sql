SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/06/2022
-- Description:	This stored procedure imports the ASPIRE reliablity
-- information from the AspireReliability table.
-- =============================================
CREATE PROC [dbo].[spImportAspireReliabilityRecords]
	@AspireID INT NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Declare necessary variables
	DECLARE @TPOTTrainingPK INT = 3, @TPITOSTrainingPK INT = 4
	
	--========= De-duplicate the AspireReliability table ==========

    --To hold any duplicate rows
    DECLARE @tblDuplicateAspireReliabilityRows TABLE
    (
        AspireReliabilityPKToSave INT NOT NULL,
        AspireID INT NULL,
		EligibilityDate DATETIME NULL,
		ReliabilityType VARCHAR(20) NULL
    );

	--Get the duplicate rows
    INSERT INTO @tblDuplicateAspireReliabilityRows
    (
        AspireReliabilityPKToSave,
        AspireID,
        EligibilityDate,
        ReliabilityType
    )
    SELECT MAX(ar.AspireReliabilityPK),
           ar.AspireID,
		   ar.EligibilityDate,
		   ar.ReliabilityType
    FROM dbo.AspireReliability ar
	WHERE (@AspireID IS NULL OR ar.AspireID = @AspireID)
    GROUP BY ar.AspireID,
             ar.ReliabilityType,
             ar.EligibilityDate
    HAVING COUNT(ar.AspireReliabilityPK) > 1;

    --Delete the duplicates (keeping the newest record)
    DELETE ar
    FROM dbo.AspireReliability ar
        INNER JOIN @tblDuplicateAspireReliabilityRows tdarr
            ON tdarr.ReliabilityType = ar.ReliabilityType
               AND tdarr.EligibilityDate = ar.EligibilityDate
               AND ((tdarr.AspireID IS NULL AND ar.AspireID IS NULL) OR (tdarr.AspireID = ar.AspireID))
    WHERE ar.AspireReliabilityPK <> tdarr.AspireReliabilityPKToSave;


	--========= Insert into the Training table from the AspireReliability table ==========

    --Insert the matching TPOT trainings that aren't already in the table
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
    SELECT NULL,
           'ASPIRE RELIABILITY API',
           GETDATE(),
           NULL,
           NULL,
		   1,
           ar.EligibilityDate,
           e.EmployeePK,
           @TPOTTrainingPK
    FROM dbo.AspireReliability ar
        INNER JOIN dbo.Employee e
            ON e.AspireID = ar.AspireID
        LEFT JOIN dbo.Training t
            ON t.TrainingCodeFK = @TPOTTrainingPK
				AND t.TrainingDate = ar.EligibilityDate
				AND t.EmployeeFK = e.EmployeePK
				AND t.IsAspireTraining = 1
    WHERE (@AspireID IS NULL OR ar.AspireID = @AspireID)  --The optional ASPIRE ID parameter
		  AND ar.ReliabilityType = 'TPOT'     --The type is TPOT
		  AND t.TrainingPK IS NULL					--The training doesn't exist in the system yet
		  AND ar.EligibilityDate IS NOT NULL;  --The training date is valid


    --Insert the matching TPITOS trainings that aren't already in the table
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
    SELECT NULL,
           'ASPIRE RELIABILITY API',
           GETDATE(),
           NULL,
           NULL,
		   1,
           ar.EligibilityDate,
           e.EmployeePK,
           @TPITOSTrainingPK
    FROM dbo.AspireReliability ar
        INNER JOIN dbo.Employee e
            ON e.AspireID = ar.AspireID
        LEFT JOIN dbo.Training t
            ON t.TrainingCodeFK = @TPITOSTrainingPK
				AND t.TrainingDate = ar.EligibilityDate
				AND t.EmployeeFK = e.EmployeePK
				AND t.IsAspireTraining = 1
    WHERE (@AspireID IS NULL OR ar.AspireID = @AspireID)  --The optional ASPIRE ID parameter
		  AND ar.ReliabilityType = 'TPITOS'     --The type is TPITOS
		  AND t.TrainingPK IS NULL					--The training doesn't exist in the system yet
		  AND ar.EligibilityDate IS NOT NULL;  --The training date is valid


	--========= De-duplicate the Training table ==========

    --To hold any duplicate PIDS trainings that came from ASPIRE
    DECLARE @tblDuplicateTrainings TABLE
    (
        TrainingPKToSave INT NOT NULL,
        EmployeeFK INT NOT NULL,
        TrainingCodeFK INT NOT NULL,
        TrainingDate DATETIME NOT NULL
    );

    --Get any duplicate PIDS trainings that came from the ASPIRE reliability api
    INSERT INTO @tblDuplicateTrainings
    (
        TrainingPKToSave,
        EmployeeFK,
        TrainingCodeFK,
        TrainingDate
    )
    SELECT MIN(t.TrainingPK),
           t.EmployeeFK,
           t.TrainingCodeFK,
           t.TrainingDate
    FROM dbo.Training t
		INNER JOIN dbo.Employee e 
			ON e.EmployeePK = t.EmployeeFK
	WHERE (@AspireID IS NULL OR e.AspireID = @AspireID)  --The optional ASPIRE ID parameter 
		AND t.AspireEventAttendeeID IS NULL
		AND t.IsAspireTraining = 1
    GROUP BY t.EmployeeFK,
             t.TrainingCodeFK,
             t.TrainingDate
    HAVING COUNT(t.TrainingPK) > 1;

    --Delete the duplicates in the training table (keeping the oldest record)
    DELETE t
    FROM dbo.Training t
        INNER JOIN @tblDuplicateTrainings tdt
            ON tdt.EmployeeFK = t.EmployeeFK
               AND tdt.TrainingCodeFK = t.TrainingCodeFK
               AND tdt.TrainingDate = t.TrainingDate
    WHERE t.TrainingPK <> tdt.TrainingPKToSave 
		AND t.IsAspireTraining = 1;

	--Update the deleted rows
	UPDATE tc SET tc.Deleter = 'spImportAspireReliabilityRecords'
	FROM dbo.TrainingChanged tc
		INNER JOIN @tblDuplicateTrainings tdt
			ON tdt.EmployeeFK = tc.EmployeeFK
				AND tdt.TrainingCodeFK = tc.TrainingCodeFK
				AND tdt.TrainingDate = tc.TrainingDate
	WHERE tc.TrainingPK <> tdt.TrainingPKToSave
		AND tc.IsAspireTraining = 1;

    --Return 1 to indicate success
    SELECT 1;

END;
GO

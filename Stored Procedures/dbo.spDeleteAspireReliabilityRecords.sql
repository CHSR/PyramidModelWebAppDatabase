SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/06/2022
-- Description:	This stored procedure deletes the reliability records that match
-- the supplied criteria.
-- =============================================
CREATE PROC [dbo].[spDeleteAspireReliabilityRecords]
    @AspireID INT NULL,
    @Deleter VARCHAR(256) NULL,
    @StartDate DATETIME NULL,
    @EndDate DATETIME NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Delete from the AspireReliability table
    DELETE ar
    FROM dbo.AspireReliability ar
    WHERE (ar.EligibilityDate BETWEEN @StartDate AND @EndDate)
          AND (@AspireID IS NULL OR ar.AspireID = @AspireID);

    --To hold the trainings to delete
    DECLARE @tblTrainingsToDelete TABLE
    (
        TrainingPK INT NOT NULL
    );

    --Get the trainings to delete
    INSERT INTO @tblTrainingsToDelete
    (
        TrainingPK
    )
    SELECT t.TrainingPK
    FROM dbo.Training t
        INNER JOIN dbo.Employee e
			ON e.EmployeePK = t.EmployeeFK
    WHERE t.AspireEventAttendeeID IS NULL  --If marked as an ASPIRE training, and the ID is null, this is a reliability record
		  AND t.IsAspireTraining = 1
          AND t.TrainingDate BETWEEN @StartDate AND @EndDate
          AND (@AspireID IS NULL OR e.AspireID = @AspireID);

    --Delete the trainings
    DELETE t
    FROM dbo.Training t
        INNER JOIN @tblTrainingsToDelete tttd
            ON tttd.TrainingPK = t.TrainingPK
    WHERE tttd.TrainingPK IS NOT NULL;

    --Update the deleted rows
    UPDATE tc
    SET tc.Deleter = @Deleter
    FROM dbo.TrainingChanged tc
        INNER JOIN @tblTrainingsToDelete tttd
            ON tttd.TrainingPK = tc.TrainingPK
    WHERE tttd.TrainingPK IS NOT NULL;

END;
GO

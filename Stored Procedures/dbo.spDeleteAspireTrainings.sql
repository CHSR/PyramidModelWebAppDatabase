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
CREATE PROC [dbo].[spDeleteAspireTrainings]
    @AspireID INT NULL,
    @Deleter VARCHAR(256) NULL,
    @StartDate DATETIME NULL,
    @EndDate DATETIME NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Delete from the AspireTraining table
    DELETE at
    FROM dbo.AspireTraining at
    WHERE at.EventCompletionDate BETWEEN @StartDate AND @EndDate
          AND (@AspireID IS NULL OR at.AspireID = @AspireID);

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
    WHERE t.AspireEventAttendeeID IS NOT NULL
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

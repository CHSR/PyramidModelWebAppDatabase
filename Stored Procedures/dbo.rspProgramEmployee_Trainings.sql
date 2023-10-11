SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/11/2020
-- Description:	This stored procedure returns the necessary information for the
-- training section of the Program Employee report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployee_Trainings] 
	@ProgramEmployeePK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the training information
    SELECT t.TrainingDate,
           ct.Description TrainingType,
           t.ExpirationDate
    FROM dbo.Training t
        INNER JOIN dbo.CodeTraining ct
            ON ct.CodeTrainingPK = t.TrainingCodeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = t.EmployeeFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.EmployeeFK = e.EmployeePK
    WHERE pe.ProgramEmployeePK = @ProgramEmployeePK
    ORDER BY t.TrainingDate ASC;

END;
GO

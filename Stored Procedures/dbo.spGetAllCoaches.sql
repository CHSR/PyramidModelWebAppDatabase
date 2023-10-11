SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/16/2019
-- Description:	This stored procedure returns the coaches
-- for the specified program that have had their trainings
-- before the event date
-- =============================================
CREATE PROC [dbo].[spGetAllCoaches]
    @ProgramFK INT = NULL,
    @EventDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the coaches
    SELECT DISTINCT
           pe.ProgramEmployeePK,
           pe.HireDate,
           pe.ProgramSpecificID CoachID,
		   CONCAT(e.FirstName, ' ', e.LastName) CoachName,
           pe.TermDate,
           pe.TermReasonSpecify,
           pe.ProgramFK,
           pe.TermReasonCodeFK
    FROM dbo.ProgramEmployee pe
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.Training t
            ON t.EmployeeFK = e.EmployeePK
               AND t.TrainingCodeFK IN (1, 2, 16)
               AND t.TrainingDate <= @EventDate
    WHERE pe.ProgramFK = @ProgramFK
          AND pe.HireDate <= @EventDate
          AND ISNULL(pe.TermDate, GETDATE()) >= @EventDate
    ORDER BY CoachName ASC;
END;
GO

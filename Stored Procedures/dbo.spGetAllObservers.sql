SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/18/2019
-- Description:	This stored procedure returns the observers
-- for the specified program that have had their trainings
-- before the event date
-- =============================================
CREATE PROC [dbo].[spGetAllObservers]
    @ProgramFK INT = NULL,
    @EventDate DATETIME = NULL,
    @IncludedTrainings VARCHAR(150) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the observers
    SELECT DISTINCT
           pe.ProgramEmployeePK,
           pe.HireDate,
           pe.ProgramSpecificID ObserverID,
		   CONCAT(e.FirstName, ' ', e.LastName) ObserverName,
           pe.TermDate,
           pe.TermReasonSpecify,
           pe.ProgramFK,
           pe.TermReasonCodeFK
    FROM dbo.ProgramEmployee pe
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK 
        INNER JOIN dbo.Training t
            ON t.EmployeeFK = e.EmployeePK
        INNER JOIN dbo.SplitStringToInt(@IncludedTrainings, ',') trainings
            ON t.TrainingCodeFK = trainings.ListItem
               AND t.TrainingDate <= @EventDate
			   AND (t.ExpirationDate IS NULL OR t.ExpirationDate >= @EventDate)
    WHERE pe.ProgramFK = @ProgramFK
          AND pe.HireDate <= @EventDate
          AND ISNULL(pe.TermDate, GETDATE()) >= @EventDate
    ORDER BY ObserverName ASC;
END;
GO

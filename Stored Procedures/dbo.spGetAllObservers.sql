SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/18/2019
-- Description:	This stored procedure returns the observers
-- for the specified program that have had their trainings
-- before the event date and are active in their job during the event date
-- =============================================
CREATE PROC [dbo].[spGetAllObservers]
	@ProgramFK INT = NULL,
	@EventDate DATETIME = NULL,
	@IncludedTrainings VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the coaches
	SELECT DISTINCT pe.ProgramEmployeePK, pe.HireDate, pe.FirstName + ' ' + pe.LastName AS ObserverName, 
		pe.TermDate, pe.TermReasonSpecify, pe.ProgramFK, pe.TermReasonCodeFK
	FROM dbo.ProgramEmployee pe
	INNER JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK
	INNER JOIN dbo.Training t ON t.ProgramEmployeeFK = pe.ProgramEmployeePK
	INNER JOIN dbo.SplitStringToInt(@IncludedTrainings, ',') ssti ON t.TrainingCodeFK = ssti.ListItem
	WHERE pe.ProgramFK = @ProgramFK 
	AND pe.HireDate <= @EventDate
	AND ISNULL(pe.TermDate, GETDATE()) >= @EventDate
	AND (jf.JobTypeCodeFK = 5 OR jf.JobTypeCodeFK = 6)
	AND jf.StartDate <= @EventDate
	AND ISNULL(jf.EndDate, GETDATE()) >= @EventDate
	AND t.TrainingDate <= @EventDate
END
GO

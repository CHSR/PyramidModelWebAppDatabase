SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/16/2019
-- Description:	This stored procedure returns the coaches
-- for the specified program that have had their trainings
-- before the event date and are active in their job during the event date
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
	SELECT DISTINCT pe.ProgramEmployeePK, pe.HireDate, pe.FirstName + ' ' + pe.LastName AS Name, 
		pe.TermDate, pe.TermReasonSpecify, pe.ProgramFK, pe.TermReasonCodeFK
	FROM dbo.ProgramEmployee pe
	INNER JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK
	INNER JOIN dbo.Training t ON t.ProgramEmployeeFK = pe.ProgramEmployeePK
	WHERE pe.ProgramFK = @ProgramFK 
	AND pe.HireDate <= @EventDate
	AND ISNULL(pe.TermDate, GETDATE()) >= @EventDate
	AND jf.JobTypeCodeFK = 4
	AND jf.StartDate <= @EventDate
	AND ISNULL(jf.EndDate, GETDATE()) >= @EventDate
	AND (t.TrainingCodeFK = 1 OR t.TrainingCodeFK = 2)
	AND t.TrainingDate <= @EventDate
END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Derek Cacciotti
-- Create date: 09/12/19
-- Description:	This stored procedure returns employees who have completed training
-- Edit Date: 12/5/2019 (Ben Simmons)
-- Bug Fix - Employees with multiple of the same training were not showing properly
-- =============================================
CREATE PROC [dbo].[rspEmployeeTrainingReport] 
	@StartDate DATETIME, 
	@EndDate DATETIME, 
	@ProgramFKs VARCHAR(max) 
AS
BEGIN

	--This table holds information for the final select 
	DECLARE @tblFinalSelect table
	(
		TrainingDate datetime, 
		TrainingTitle varchar(250),
		ProgramEmployeePK INT,
		EmployeeName VARCHAR(max),
		ProgramFK INT, 
		ProgramName VARCHAR(400),
		NumofActiveEmployees INT
	)

	--This table holds the employee cohort
	DECLARE @tblEmployeeCohort TABLE
	(
		ProgramEmployeePK INT, 
		EmployeeName VARCHAR(max), 
		ProgramFK INT, 
		ProgramName VARCHAR(250)
	)

	--This table holds the most recent trainings for the employee
	DECLARE @tblEmployeeTrainings TABLE 
	(
		ProgramEmployeePK INT,
		TrainingDate DATETIME,
		TrainingCodeFK INT
	)

	--Get the employee cohort
	INSERT INTO @tblEmployeeCohort
	(
		ProgramEmployeePK,
		EmployeeName,
		ProgramFK,
		ProgramName
	)
	SELECT pe.ProgramEmployeePK, CONCAT(pe.FirstName,' ', pe.LastName), p.ProgramPK, p.ProgramName 
	FROM dbo.ProgramEmployee pe
	INNER JOIN dbo.Program p ON p.ProgramPK = pe.ProgramFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON pe.ProgramFK = ssti.ListItem
	WHERE pe.HireDate <= @EndDate AND (pe.TermDate IS NULL OR pe.TermDate > @StartDate)

	--Get the most recent employee trainings
	INSERT INTO @tblEmployeeTrainings
	(
	    ProgramEmployeePK,
	    TrainingDate,
		TrainingCodeFK
	)
	SELECT tec.ProgramEmployeePK, MAX(t.TrainingDate), t.TrainingCodeFK
	FROM @tblEmployeeCohort tec
	INNER JOIN dbo.Training t ON t.ProgramEmployeeFK = tec.ProgramEmployeePK
	GROUP BY tec.ProgramEmployeePK, t.TrainingCodeFK

	--Get the final select
	INSERT INTO @tblFinalSelect
	(
		TrainingDate,
		TrainingTitle,
		ProgramEmployeePK,
		EmployeeName,
		ProgramFK,
		ProgramName
	)
	SELECT tet.TrainingDate, ct.Description, tet.ProgramEmployeePK, tec.EmployeeName, tec.ProgramFK, tec.ProgramName 
	FROM dbo.CodeTraining ct
	LEFT JOIN @tblEmployeeTrainings tet ON ct.CodeTrainingPK = tet.TrainingCodeFK
	LEFT JOIN @tblEmployeeCohort tec ON tec.ProgramEmployeePK = tet.ProgramEmployeePK

	--Update the final select table with the number of active employees
	UPDATE @tblFinalSelect SET NumofActiveEmployees = (SELECT COUNT(DISTINCT tec.ProgramEmployeePK) FROM @tblEmployeeCohort tec) 

	--Perform the final select
	SELECT * FROM @tblFinalSelect

END

GO

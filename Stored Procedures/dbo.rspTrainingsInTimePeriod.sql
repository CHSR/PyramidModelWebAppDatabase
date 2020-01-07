SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/24/19
-- Description:	This stored procedure returns employees who have completed training
-- between the designated start and end dates
-- =============================================
CREATE PROC [dbo].[rspTrainingsInTimePeriod] 
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the training and employee info
	DECLARE @tblTrainingsAndEmployees TABLE 
	(
		TrainingPK INT NOT NULL,
		TrainingDate DATETIME NOT NULL,
		TrainingCodeFK INT NOT NULL,
		EmployeePK INT NOT NULL, 
		EmployeeName VARCHAR(MAX) NOT NULL, 
		ProgramPK INT NOT NULL, 
		ProgramName VARCHAR(250) NOT NULL
	)

	--Get all the trainings between the start and end dates in addition to the employee info
	INSERT INTO @tblTrainingsAndEmployees
	(
	    TrainingPK,
	    TrainingDate,
		TrainingCodeFK,
	    EmployeePK,
	    EmployeeName,
	    ProgramPK,
	    ProgramName
	)
	SELECT t.TrainingPK, t.TrainingDate, t.TrainingCodeFK,
		pe.ProgramEmployeePK, CONCAT(pe.FirstName, ' ', pe.LastName) AS EmployeeName,
		p.ProgramPK, p.ProgramName
	FROM dbo.Training t
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = t.ProgramEmployeeFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON pe.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = pe.ProgramFK
	WHERE t.TrainingDate BETWEEN @StartDate AND @EndDate

	--Final select
	SELECT ct.Description AS TrainingType, 
		ttae.TrainingPK, ttae.TrainingDate, ttae.TrainingCodeFK, ttae.EmployeePK, 
		ttae.EmployeeName, ttae.ProgramPK, ttae.ProgramName
	FROM dbo.CodeTraining ct
	LEFT JOIN @tblTrainingsAndEmployees ttae ON ttae.TrainingCodeFK = ct.CodeTrainingPK

END

GO

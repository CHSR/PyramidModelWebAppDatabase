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
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--This table holds the trainings authorized for the programs
	DECLARE @tblTrainingCohort TABLE 
	(
		CodeTrainingPK INT,
		TrainingAbbreviation VARCHAR(50),
		TrainingDescription VARCHAR(250)
	);

    --To hold the training and employee info
    DECLARE @tblTrainingsAndEmployees TABLE
    (
        TrainingPK INT NOT NULL,
        TrainingDate DATETIME NOT NULL,
        TrainingCodeFK INT NOT NULL,
        EmployeePK INT NOT NULL,
        EmployeeID VARCHAR(100) NOT NULL,
        EmployeeName VARCHAR(MAX) NOT NULL,
        ProgramPK INT NOT NULL,
        ProgramName VARCHAR(250) NOT NULL
    );

	--Get the training cohort
	INSERT INTO @tblTrainingCohort
	(
	    CodeTrainingPK,
	    TrainingAbbreviation,
	    TrainingDescription
	)
	SELECT DISTINCT ct.CodeTrainingPK, 
		   ct.Abbreviation,
		   ct.[Description]
	FROM dbo.CodeTraining ct
		INNER JOIN dbo.CodeTrainingAccess cta
			ON cta.TrainingCodeFK = ct.CodeTrainingPK
        INNER JOIN dbo.Program p
            ON p.StateFK = cta.StateFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = p.ProgramPK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
		cta.AllowedAccess = 1

    --Get all the trainings between the start and end dates in addition to the employee info
    INSERT INTO @tblTrainingsAndEmployees
    (
        TrainingPK,
        TrainingDate,
        TrainingCodeFK,
        EmployeePK,
        EmployeeID,
        EmployeeName,
        ProgramPK,
        ProgramName
    )
    SELECT t.TrainingPK,
           t.TrainingDate,
           t.TrainingCodeFK,
           pe.ProgramEmployeePK,
		   pe.ProgramSpecificID,
           CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
           p.ProgramPK,
           p.ProgramName
    FROM dbo.Training t
        INNER JOIN dbo.Employee e
			ON e.EmployeePK = t.EmployeeFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.EmployeeFK = e.EmployeePK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = pe.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = pe.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
		t.TrainingDate BETWEEN @StartDate AND @EndDate;

    --Final select
    SELECT ttc.TrainingDescription AS TrainingType,
           ttae.TrainingPK,
           ttae.TrainingDate,
           ttae.TrainingCodeFK,
           ttae.EmployeePK,
		   ttae.EmployeeID,
           ttae.EmployeeName,
           ttae.ProgramPK,
           ttae.ProgramName
    FROM @tblTrainingCohort ttc
        LEFT JOIN @tblTrainingsAndEmployees ttae
            ON ttae.TrainingCodeFK = ttc.CodeTrainingPK;

END;
GO

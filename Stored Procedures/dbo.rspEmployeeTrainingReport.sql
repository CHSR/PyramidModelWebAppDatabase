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
    @ProgramFKs VARCHAR(8000),
	@HubFKs VARCHAR(8000),
	@CohortFKs VARCHAR(8000),
	@StateFKs VARCHAR(8000)
AS
BEGIN

    --This table holds information for the final select 
    DECLARE @tblFinalSelect TABLE
    (
        TrainingDate DATETIME,
        TrainingTitle VARCHAR(250),
        ProgramEmployeePK INT,
		EmployeePK INT,
        EmployeeID VARCHAR(100),
        EmployeeName VARCHAR(MAX),
        ProgramFK INT,
        ProgramName VARCHAR(400),
		StateFK INT,
        NumofActiveEmployees INT
    );

	DECLARE @tblTrainingCohort TABLE 
	(
		CodeTrainingPK INT,
		TrainingAbbreviation VARCHAR(50),
		TrainingDescription VARCHAR(250)
	);

    --This table holds the employee cohort
    DECLARE @tblEmployeeCohort TABLE
    (
        ProgramEmployeePK INT,
		EmployeePK INT,
        EmployeeID VARCHAR(100),
        EmployeeName VARCHAR(MAX),
        ProgramFK INT,
        ProgramName VARCHAR(250),
		StateFK INT
    );

    --This table holds the most recent trainings for the employee
    DECLARE @tblEmployeeTrainings TABLE
    (
		EmployeePK INT,
        TrainingDate DATETIME,
        TrainingCodeFK INT
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

    --Get the employee cohort
    INSERT INTO @tblEmployeeCohort
    (
        ProgramEmployeePK,
		EmployeePK,
        EmployeeID,
        EmployeeName,
        ProgramFK,
        ProgramName,
		StateFK
    )
    SELECT pe.ProgramEmployeePK,
		   e.EmployeePK,
           pe.ProgramSpecificID,
           CONCAT(e.FirstName, ' ', e.LastName),
           p.ProgramPK,
           p.ProgramName,
		   p.StateFK
    FROM dbo.ProgramEmployee pe
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
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
		  pe.HireDate <= @EndDate AND
          (pe.TermDate IS NULL OR pe.TermDate > @StartDate);

    --Get the most recent employee trainings
    INSERT INTO @tblEmployeeTrainings
    (
        EmployeePK,
        TrainingDate,
        TrainingCodeFK
    )
    SELECT tec.EmployeePK,
           MAX(t.TrainingDate),
           t.TrainingCodeFK
    FROM @tblEmployeeCohort tec
        INNER JOIN dbo.Training t
            ON t.EmployeeFK = tec.EmployeePK
    GROUP BY tec.EmployeePK,
             t.TrainingCodeFK;

    --Get the final select
    INSERT INTO @tblFinalSelect
    (
        TrainingDate,
        TrainingTitle,
        ProgramEmployeePK,
		EmployeePK,
        EmployeeID,
        EmployeeName,
        ProgramFK,
        ProgramName,
		StateFK
    )
    SELECT tet.TrainingDate,
           ttc.TrainingDescription,
           tec.ProgramEmployeePK,
		   tet.EmployeePK,
           tec.EmployeeID,
           tec.EmployeeName,
           tec.ProgramFK,
           tec.ProgramName,
		   tec.StateFK
    FROM @tblTrainingCohort ttc
        LEFT JOIN @tblEmployeeTrainings tet
            ON ttc.CodeTrainingPK = tet.TrainingCodeFK
        LEFT JOIN @tblEmployeeCohort tec
            ON tec.EmployeePK = tet.EmployeePK;

    --Update the final select table with the number of active employees
    UPDATE @tblFinalSelect
    SET NumofActiveEmployees =
        (
            SELECT COUNT(DISTINCT tec.ProgramEmployeePK) FROM @tblEmployeeCohort tec
        );

    --Perform the final select
    SELECT *
    FROM @tblFinalSelect;

END;
GO

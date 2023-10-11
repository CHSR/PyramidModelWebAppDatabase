SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/16/2022
-- Description:	This stored procedure returns the necessary information for the
-- Trainings section of the Employee Data Dump report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployeeDataDump_Trainings]
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

	--Get all the necessary information
    SELECT t.TrainingPK,
           t.AspireEventAttendeeID,
           t.Creator,
           t.CreateDate,
           t.Editor,
           t.EditDate,
           t.IsAspireTraining,
           t.TrainingDate,
		   t.ExpirationDate,
		   ct.CodeTrainingPK,
		   ct.[Description] TrainingTypeText,
		   pe.ProgramEmployeePK,
           e.FirstName,
           e.LastName,
           pe.ProgramSpecificID EmployeeIDNumber,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.Training t
		INNER JOIN dbo.CodeTraining ct
			ON ct.CodeTrainingPK = t.TrainingCodeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = t.EmployeeFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.EmployeeFK = e.EmployeePK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = pe.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = pe.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = p.HubFK
        LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList
            ON cohortList.ListItem = p.CohortFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR hubList.ListItem IS NOT NULL
              OR cohortList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND pe.HireDate <= @EndDate
		AND (pe.TermDate IS NULL OR pe.TermDate >= @StartDate);

END;
GO

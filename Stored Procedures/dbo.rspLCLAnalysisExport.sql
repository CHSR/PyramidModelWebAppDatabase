SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 04/07/2023
-- Description:	This stored procedure returns the necessary information for the
-- Leadership Coach Log Analysis Export Report
-- =============================================
CREATE PROC [dbo].[rspLCLAnalysisExport]
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

	--Get all the info for active programs
    SELECT p.ProgramPK, 
		   p.ProgramName, 
		   p.IDNumber ProgramIDNumber,
		   c.CohortPK, 
		   c.CohortName,
		   h.HubPK, 
		   h.[Name] HubName,
		   s.StatePK, 
		   s.[Name] StateName,
		   lcl.LeadershipCoachLogPK,
		   lcl.LeadershipCoachUsername,
		   lcl.CreateDate LCLCreateDate,
		   lcl.IsMonthly,
		   lcl.DateCompleted LCLDateCompleted,
		   lcl.GoalCompletionLikelihoodCodeFK LCLGoalCompletionLikelihoodCodeFK,
		   lcl.CyclePhase LCLCyclePhase
	FROM dbo.Program p
		INNER JOIN dbo.Hub h
			ON h.HubPK = p.HubFK
		INNER JOIN dbo.Cohort c
			ON c.CohortPK = p.CohortFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.LeadershipCoachLog lcl
			ON lcl.ProgramFK = p.ProgramPK
				AND lcl.DateCompleted BETWEEN @StartDate AND @EndDate
				AND lcl.IsComplete = 1 --Only include complete forms
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
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
		AND p.ProgramStartDate <= @EndDate
		AND (p.ProgramEndDate IS NULL OR p.ProgramEndDate >= @StartDate)

END;
GO

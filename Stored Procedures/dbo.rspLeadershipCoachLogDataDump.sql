SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 04/11/2023
-- Description:	This stored procedure returns the necessary information for the
-- Leadership Coach Log Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachLogDataDump]
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

	-- Declare tables
	DECLARE @tblCohort TABLE
	(
		LeadershipCoachLogPK INT NOT NULL,
		ActNarrative VARCHAR(5000) NULL,
		Creator VARCHAR(256) NOT NULL,
		CreateDate DATETIME NOT NULL,
		CyclePhase INT NULL,
		DateCompleted DATETIME NULL,
		Editor VARCHAR(256) NULL,
		EditDate DATETIME NULL,
		HighlightsNarrative VARCHAR(5000) NULL,
		IsComplete BIT NOT NULL,
		IsMonthly BIT NULL,
		NumberOfAttemptedEngagements INT NULL,
		NumberOfEngagements INT NULL,
		OtherDomainTwoSpecify VARCHAR(250) NULL,
		OtherEngagementSpecify VARCHAR(250) NULL,
		OtherSiteResourcesSpecify VARCHAR(250) NULL,
		OtherTopicsDiscussedSpecify VARCHAR(250) NULL,
		OtherTrainingsCoveredSpecify VARCHAR(250) NULL,
		TargetedTrainingHours INT NULL,
		TargetedTrainingMinutes INT NULL,
		ThinkNarrative VARCHAR(5000) NULL,
		TotalDurationHours INT NULL,
		TotalDurationMinutes INT NULL,
		GoalCompletionLikelihood VARCHAR(256) NULL,
		LeadershipCoachUsername VARCHAR(256) NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL,
		ProgramIDNumber VARCHAR(100) NULL,
		StateFK INT NOT NULL,
		StateName VARCHAR(400) NOT NULL,
		TimelyProgressionLikelihood VARCHAR(256) NULL
	)

	DECLARE @tblDistinctProgramsIncluded TABLE 
	(
		ProgramFK INT NOT NULL
	)
	   
	--Program Types
	DECLARE @tblProgramTypes TABLE
	(
		ProgramFK INT,
		ProgramTypes VARCHAR(8000)
	)
	   
	INSERT INTO @tblCohort
	(
	    LeadershipCoachLogPK,
	    ActNarrative,
	    Creator,
	    CreateDate,
	    CyclePhase,
	    DateCompleted,
	    Editor,
	    EditDate,
	    HighlightsNarrative,
	    IsComplete,
	    IsMonthly,
	    NumberOfAttemptedEngagements,
	    NumberOfEngagements,
	    OtherDomainTwoSpecify,
	    OtherEngagementSpecify,
	    OtherSiteResourcesSpecify,
	    OtherTopicsDiscussedSpecify,
	    OtherTrainingsCoveredSpecify,
	    TargetedTrainingHours,
	    TargetedTrainingMinutes,
	    ThinkNarrative,
	    TotalDurationHours,
	    TotalDurationMinutes,
	    GoalCompletionLikelihood,
	    LeadershipCoachUsername,
	    ProgramFK,
		ProgramName,
		ProgramIDNumber,
		StateFK,
		StateName,
	    TimelyProgressionLikelihood
	)
	--Get all the necessary information
    SELECT lcl.LeadershipCoachLogPK,
		   lcl.ActNarrative,
		   lcl.Creator,
		   lcl.CreateDate,
		   lcl.CyclePhase,
		   lcl.DateCompleted,
		   lcl.Editor,
		   lcl.EditDate,
		   lcl.HighlightsNarrative,
		   lcl.IsComplete,
		   lcl.IsMonthly,
		   lcl.NumberOfAttemptedEngagements,
		   lcl.NumberOfEngagements,
		   lcl.OtherDomainTwoSpecify,
		   lcl.OtherEngagementSpecify,
		   lcl.OtherSiteResourcesSpecify,
		   lcl.OtherTopicsDiscussedSpecify,
		   lcl.OtherTrainingsCoveredSpecify,
		   lcl.TargetedTrainingHours,
		   lcl.TargetedTrainingMinutes,
		   lcl.ThinkNarrative,
		   lcl.TotalDurationHours,
		   lcl.TotalDurationMinutes,
		   clr.[Description] GoalCompletion,
		   lcl.LeadershipCoachUsername,
		   p.ProgramPK,
		   p.ProgramName,
		   p.IDNumber,
		   s.StatePK,
		   s.[Name],
		   clrr.[Description] TimelyProgression
    FROM dbo.LeadershipCoachLog lcl
        INNER JOIN dbo.Program p 
			ON p.ProgramPK = lcl.ProgramFK
		INNER JOIN dbo.[State] s 
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.CodeLCLResponse clr
			ON clr.CodeLCLResponsePK = lcl.GoalCompletionLikelihoodCodeFK
		LEFT JOIN dbo.CodeLCLResponse clrr
			ON clrr.CodeLCLResponsePK = lcl.TimelyProgressionLikelihoodCodeFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = lcl.ProgramFK
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
          AND lcl.DateCompleted BETWEEN @StartDate AND @EndDate
	ORDER BY lcl.LeadershipCoachLogPK;

	INSERT INTO @tblDistinctProgramsIncluded
	(
	    ProgramFK
	)
	SELECT DISTINCT tc.ProgramFK
	FROM @tblCohort tc

	--Comma separated list of Program Types
	INSERT INTO @tblProgramTypes
	(
	    ProgramFK,
	    ProgramTypes
	)
	SELECT p.ProgramPK, STRING_AGG(cpt.[Description], ', ') WITHIN GROUP (ORDER BY cpt.OrderBy) ProgramTypes
	FROM @tblDistinctProgramsIncluded tdpi
	INNER JOIN dbo.Program p
		ON p.ProgramPK = tdpi.ProgramFK
	INNER JOIN dbo.ProgramType pt
		ON pt.ProgramFK = p.ProgramPK
	INNER JOIN dbo.CodeProgramType cpt
		ON cpt.CodeProgramTypePK = pt.TypeCodeFK
	GROUP BY p.ProgramPK

	--Final select
	SELECT tc.LeadershipCoachLogPK,
		   tc.ActNarrative,
		   tc.Creator,
		   tc.CreateDate,
		   tc.CyclePhase,
		   tc.DateCompleted,
		   tc.Editor,
		   tc.EditDate,
		   tc.HighlightsNarrative,
		   tc.IsComplete,
		   tc.IsMonthly,
		   tc.NumberOfAttemptedEngagements,
		   tc.NumberOfEngagements,
		   tc.OtherDomainTwoSpecify,
		   tc.OtherEngagementSpecify,
		   tc.OtherSiteResourcesSpecify,
		   tc.OtherTopicsDiscussedSpecify,
		   tc.OtherTrainingsCoveredSpecify,
		   tc.TargetedTrainingHours,
		   tc.TargetedTrainingMinutes,
		   tc.ThinkNarrative,
		   tc.TotalDurationHours,
		   tc.TotalDurationMinutes,
		   tc.GoalCompletionLikelihood,
		   tc.LeadershipCoachUsername,
		   tc.ProgramFK,
		   tc.ProgramName,
		   tc.ProgramIDNumber,
		   tc.StateFK,
		   tc.StateName,
		   tc.TimelyProgressionLikelihood,
		   tpt.ProgramTypes
	FROM @tblCohort tc
	LEFT JOIN @tblProgramTypes tpt ON tpt.ProgramFK = tc.ProgramFK


END;
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/09/2019
-- Description:	CCL Duration Report
-- Edit Date: 03/27/2020
-- Edited by: Ben Simmons
-- Edit Reason: Change teacher parameter to employee parameter
-- =============================================
CREATE PROC [dbo].[rspCCLDuration]
	@EmployeeFKs VARCHAR(8000) = NULL,
	@CoachFKs varchar(8000) = NULL,
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

	DECLARE @tblCohort TABLE (
		CoachingLogPK INT NOT NULL,
		LogDate DATETIME NOT NULL,
		DurationMinutes INT NOT NULL
	)

	DECLARE @tblCoacheeFilter TABLE (
		CoachingLogFK INT
	)	

	INSERT INTO @tblCohort
	(
	    CoachingLogPK,
	    LogDate,
	    DurationMinutes
	)
	SELECT 
		  cl.CoachingLogPK
		, cl.LogDate
		, cl.DurationMinutes
	FROM dbo.CoachingLog cl
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = cl.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = cl.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	LEFT JOIN dbo.SplitStringToInt(@CoachFKs, ',') coachList 
		ON cl.CoachFK = coachList.ListItem
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
		cl.LogDate BETWEEN @StartDate AND @EndDate AND
		(@CoachFKs IS NULL OR @CoachFKs = '' OR coachList.ListItem IS NOT NULL); --Optional coach criteria

	--Get all the coaching logs from the cohort that match the coachee criteria (if used)
	INSERT INTO @tblCoacheeFilter
	(
	    CoachingLogFK
	)
	SELECT tc.CoachingLogPK
	FROM @tblCohort tc
		LEFT JOIN dbo.CoachingLogCoachees clc
			ON clc.CoachingLogFK = tc.CoachingLogPK
        LEFT JOIN dbo.SplitStringToInt(@EmployeeFKs, ',') employeeList
            ON clc.CoacheeFK = employeeList.ListItem
	WHERE (@EmployeeFKs IS NULL OR @EmployeeFKs = '' OR employeeList.ListItem IS NOT NULL) --Optional employee criteria

	--Remove any coaching logs from the cohort if they don't match the coachee criteria (if used)
	DELETE tc 
	FROM @tblCohort tc
		LEFT JOIN @tblCoacheeFilter cf
			ON tc.CoachingLogPK = cf.CoachingLogFK
	WHERE cf.CoachingLogFK IS NULL

	--Final select
	SELECT tc.CoachingLogPK,
           tc.LogDate,
           tc.DurationMinutes
	FROM @tblCohort tc

END
GO

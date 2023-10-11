SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/27/2019
-- Description:	This stored procedure returns the necessary information for the
-- ASQSE Trend report
-- =============================================
CREATE PROC [dbo].[rspASQSETrend]
	@ChildFKs VARCHAR(8000) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000),
    @HubFKs VARCHAR(8000),
    @CohortFKs VARCHAR(8000),
    @StateFKs VARCHAR(8000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblCohort TABLE (
		ChildPK INT NOT NULL,
		ChildProgramID VARCHAR(100) NOT NULL,
		ChildFirstName VARCHAR(256) NOT NULL,
		ChildLastName VARCHAR(256) NOT NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL
	)
	
	--To hold the ASQSEs
	DECLARE @tblCohortDetails TABLE (
		ASQSEPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
		HasDemographicInfoSheet BIT NOT NULL,
		HasPhysicianInfoLetter BIT NOT NULL,
		TotalScore INT NOT NULL,
		ScoreTypeCode INT NOT NULL, -- 1 = Above Cutoff, 2 = Monitor, 3 = Well Below
		ScoreType VARCHAR(100) NOT NULL,
		ChildFK INT NOT NULL,
		IntervalCodeFK INT NOT NULL,
		IntervalMonth INT NOT NULL,
		IntervalDescription VARCHAR(400) NOT NULL,
		ProgramFK INT NOT NULL,
		Version INT NOT NULL,
		ChildProgramID VARCHAR(100) NOT NULL,
		ChildFirstName VARCHAR(256) NOT NULL,
		ChildLastName VARCHAR(256) NOT NULL,
		ProgramName VARCHAR(400) NOT NULL
	)

	INSERT INTO @tblCohort
	(
	    ChildPK,
		ChildProgramID,
		ChildFirstName,
		ChildLastName,
		ProgramFK,
		ProgramName
	)
	SELECT DISTINCT c.ChildPK, cp.ProgramSpecificID, c.FirstName, 
		c.LastName, cp.ProgramFK, p.ProgramName
	FROM dbo.Child c
		INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
		INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ChildFKs, ',') childList ON c.ChildPK = childList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = cp.ProgramFK
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
		cp.EnrollmentDate <= @EndDate 
		AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate)
		AND (@ChildFKs IS NULL OR @ChildFKs = '' OR childList.ListItem IS NOT NULL); --Optional child criteria

	--Get all the ASQSEs
	INSERT INTO @tblCohortDetails
	(
	    ASQSEPK,
	    FormDate,
	    HasDemographicInfoSheet,
	    HasPhysicianInfoLetter,
	    TotalScore,
		ScoreTypeCode,
		ScoreType,
	    ChildFK,
	    IntervalCodeFK,
		IntervalMonth,
		IntervalDescription,
	    ProgramFK,
	    Version,
		ChildProgramID,
		ChildFirstName,
		ChildLastName,
		ProgramName
	)
	SELECT a.ASQSEPK, a.FormDate, a.HasDemographicInfoSheet, a.HasPhysicianInfoLetter, 
		   a.TotalScore,
		   CASE WHEN a.TotalScore > sa.CutoffScore THEN 3
			 WHEN a.TotalScore BETWEEN sa.MonitoringScoreStart AND sa.MonitoringScoreEnd THEN 2 
			 ELSE 1 END AS ScoreTypeCode,
		   CASE WHEN a.TotalScore > sa.CutoffScore THEN 'Above Cutoff'
			 WHEN a.TotalScore BETWEEN sa.MonitoringScoreStart AND sa.MonitoringScoreEnd THEN 'Monitor' 
			 ELSE 'Well Below' END AS ScoreType,
		   a.ChildFK, a.IntervalCodeFK, cai.IntervalMonth, cai.Description,
		   tc.ProgramFK, a.Version,
		   tc.ChildProgramID, tc.ChildFirstName, tc.ChildLastName,
		   tc.ProgramName
	FROM @tblCohort tc
	INNER JOIN dbo.ASQSE a ON a.ChildFK = tc.ChildPK
	INNER JOIN dbo.ScoreASQSE sa ON sa.IntervalCodeFK = a.IntervalCodeFK AND sa.Version = a.Version
	INNER JOIN dbo.CodeASQSEInterval cai ON cai.CodeASQSEIntervalPK = a.IntervalCodeFK
	
	--Final select
	SELECT *
	FROM @tblCohortDetails tcd
	ORDER BY tcd.IntervalMonth ASC, tcd.ScoreType ASC

END
GO

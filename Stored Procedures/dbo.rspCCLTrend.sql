SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/26/2019
-- Description:	Count of 'Yes' for each Coaching Log item.
-- Edit Date: 03/27/2020
-- Edited by: Ben Simmons
-- Edit Reason: Change teacher parameter to employee parameter
-- =============================================
CREATE PROC [dbo].[rspCCLTrend]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @EmployeeFKs VARCHAR(8000),
    @CoachFKs VARCHAR(8000),
    @ProgramFKs VARCHAR(8000),
    @HubFKs VARCHAR(8000),
    @CohortFKs VARCHAR(8000),
    @StateFKs VARCHAR(8000)
AS
BEGIN

    DECLARE @tblCohort AS TABLE
    (
		CoachingLogPK INT,
        LogDate DATETIME,
        FUEmail BIT,
        FUInPerson BIT,
        FUNone BIT,
        FUPhone BIT,
        MEETDemonstration BIT,
        MEETEnvironment BIT,
        MEETGoalSetting BIT,
        MEETGraphic BIT,
        MEETMaterial BIT,
        MEETOther BIT,
        MEETPerformance BIT,
        MEETProblemSolving BIT,
        MEETReflectiveConversation BIT,
        MEETRoleplay BIT,
        MEETVideo BIT,
        OBSConductTPITOS BIT,
        OBSConductTPOT BIT,
        OBSEnvironment BIT,
        OBSModeling BIT,
        OBSObserving BIT,
        OBSOther BIT,
        OBSOtherHelp BIT,
        OBSProblemSolving BIT,
        OBSReflectiveConversation BIT,
        OBSSideBySide BIT,
        OBSVerbalSupport BIT
    );

	DECLARE @tblCoacheeFilter TABLE (
		CoachingLogFK INT
	)

    INSERT INTO @tblCohort
    (
		CoachingLogPK,
        LogDate,
        FUEmail,
        FUInPerson,
        FUNone,
        FUPhone,
        MEETDemonstration,
        MEETEnvironment,
        MEETGoalSetting,
        MEETGraphic,
        MEETMaterial,
        MEETOther,
        MEETPerformance,
        MEETProblemSolving,
        MEETReflectiveConversation,
        MEETRoleplay,
        MEETVideo,
        OBSConductTPITOS,
        OBSConductTPOT,
        OBSEnvironment,
        OBSModeling,
        OBSObserving,
        OBSOther,
        OBSOtherHelp,
        OBSProblemSolving,
        OBSReflectiveConversation,
        OBSSideBySide,
        OBSVerbalSupport
    )
    SELECT cl.CoachingLogPK,
		   cl.LogDate,
           cl.FUEmail,
           cl.FUInPerson,
           cl.FUNone,
           cl.FUPhone,
           cl.MEETDemonstration,
           cl.MEETEnvironment,
           cl.MEETGoalSetting,
           cl.MEETGraphic,
           cl.MEETMaterial,
           cl.MEETOther,
           cl.MEETPerformance,
           cl.MEETProblemSolving,
           cl.MEETReflectiveConversation,
           cl.MEETRoleplay,
           cl.MEETVideo,
           cl.OBSConductTPITOS,
           cl.OBSConductTPOT,
           cl.OBSEnvironment,
           cl.OBSModeling,
           cl.OBSObserving,
           cl.OBSOther,
           cl.OBSOtherHelp,
           cl.OBSProblemSolving,
           cl.OBSReflectiveConversation,
           cl.OBSSideBySide,
           cl.OBSVerbalSupport
    FROM dbo.CoachingLog cl
		INNER JOIN dbo.Program p
			ON p.ProgramPK = cl.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@CoachFKs, ',') coachList
            ON cl.CoachFK = coachList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = cl.ProgramFK
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
		cl.LogDate BETWEEN @StartDate AND @EndDate
		AND (@CoachFKs IS NULL OR @CoachFKs = '' OR coachList.ListItem IS NOT NULL); --Optional coach criteria;

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

    DECLARE @tblResults AS TABLE
    (
        CodeCoachingLogFK INT,
        MonthYear VARCHAR(8),
        CntItem INT,
        CntCCL INT,
        MinDate DATETIME,
        MaxDate DATETIME
    );

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 1,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSObserving
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 2,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSModeling
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 3,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSVerbalSupport
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 4,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSSideBySide
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 5,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSProblemSolving
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 6,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSReflectiveConversation
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 7,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSEnvironment
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 8,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSOtherHelp
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 9,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSConductTPOT
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 10,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSConductTPITOS
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 11,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.OBSOther
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 12,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETProblemSolving
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 13,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETReflectiveConversation
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 14,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETEnvironment
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 15,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETRoleplay
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 16,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETVideo
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 17,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETGraphic
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 18,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETGoalSetting
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 19,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETPerformance
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 20,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETMaterial
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 21,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETDemonstration
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 22,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.MEETOther
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 23,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.FUEmail
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 24,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.FUPhone
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 25,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.FUInPerson
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        MonthYear,
        CntItem
    )
    SELECT 26,
           FORMAT(LogDate, 'yyyy-MM'),
           tc.FUNone
    FROM @tblCohort tc;

    UPDATE @tblResults
    SET CntCCL =
        (
            SELECT COUNT(*) FROM @tblCohort
        );
    UPDATE @tblResults
    SET MinDate =
        (
            SELECT MIN(LogDate) FROM @tblCohort
        );
    UPDATE @tblResults
    SET MaxDate =
        (
            SELECT MAX(LogDate) FROM @tblCohort
        );

    SELECT ccl.Description,
           ccl.Category,
           ccl.OrderBy,
           tr.MonthYear,
           SUM(ISNULL(tr.CntItem, 0)) AS CntItem,
           tr.CntCCL,
           tr.MinDate,
           tr.MaxDate
    FROM @tblResults tr
        INNER JOIN dbo.CodeCoachingLog ccl
            ON ccl.CodeCoachingLogPK = tr.CodeCoachingLogFK
    GROUP BY ccl.Description,
             ccl.Category,
             tr.MonthYear,
             tr.CntCCL,
             tr.MinDate,
             tr.MaxDate,
             ccl.OrderBy;
END;
GO

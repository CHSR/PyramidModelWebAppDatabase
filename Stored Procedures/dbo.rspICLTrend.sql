SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/26/2019
-- Description:	Count of 'Yes' for each Coaching Log item.
-- Edit Date: 09/27/2019
-- Edited by: Ben Simmons
-- Edit Reason: Change classroom parameter to teacher and coach parameter
-- =============================================
CREATE PROC [dbo].[rspICLTrend]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ProgramFKs VARCHAR(MAX),
    @TeacherFKs VARCHAR(MAX),
    @CoachFKs VARCHAR(MAX)
AS
BEGIN

    DECLARE @tblCohort AS TABLE
    (
        [LogDate] [DATETIME],
        [FUEmail] [BIT],
        [FUInPerson] [BIT],
        [FUNone] [BIT],
        [FUPhone] [BIT],
        [MEETDemonstration] [BIT],
        [MEETEnvironment] [BIT],
        [MEETGoalSetting] [BIT],
        [MEETGraphic] [BIT],
        [MEETMaterial] [BIT],
        [MEETOther] [BIT],
        [MEETPerformance] [BIT],
        [MEETProblemSolving] [BIT],
        [MEETReflectiveConversation] [BIT],
        [MEETRoleplay] [BIT],
        [MEETVideo] [BIT],
        [OBSConductTPITOS] [BIT],
        [OBSConductTPOT] [BIT],
        [OBSEnvironment] [BIT],
        [OBSModeling] [BIT],
        [OBSObserving] [BIT],
        [OBSOther] [BIT],
        [OBSOtherHelp] [BIT],
        [OBSProblemSolving] [BIT],
        [OBSReflectiveConversation] [BIT],
        [OBSSideBySide] [BIT],
        [OBSVerbalSupport] [BIT]
    );
    INSERT INTO @tblCohort
    (
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
    SELECT cl.LogDate,
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
        INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON cl.ProgramFK = programList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@TeacherFKs, ',') teacherList
            ON cl.TeacherFK = teacherList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@CoachFKs, ',') coachList
            ON cl.CoachFK = coachList.ListItem
    WHERE cl.LogDate
    BETWEEN @StartDate AND @EndDate
		AND (@TeacherFKs IS NULL OR @TeacherFKs = '' OR teacherList.ListItem IS NOT NULL) --Optional teacher criteria
		AND (@CoachFKs IS NULL OR @CoachFKs = '' OR coachList.ListItem IS NOT NULL); --Optional coach criteria;



    DECLARE @tblResults AS TABLE
    (
        CodeCoachingLogFK INT,
        MonthYear VARCHAR(8),
        CntItem INT,
        CntICL INT,
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
    SET CntICL =
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
           tr.CntICL,
           tr.MinDate,
           tr.MaxDate
    FROM @tblResults tr
        INNER JOIN dbo.CodeCoachingLog ccl
            ON ccl.CodeCoachingLogPK = tr.CodeCoachingLogFK
    GROUP BY ccl.Description,
             ccl.Category,
             tr.MonthYear,
             tr.CntICL,
             tr.MinDate,
             tr.MaxDate,
             ccl.OrderBy;
END;

GO

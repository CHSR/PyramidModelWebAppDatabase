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
CREATE PROC [dbo].[rspICLCounts]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ProgramFKs VARCHAR(MAX),
	@TeacherFKs VARCHAR(MAX) = NULL,
	@CoachFKs varchar(MAX) = null
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
        OBSVerbalSupport BIT,
        TeacherFK INT,
        CoachFK INT,
        ProgramFK INT
    );

    DECLARE @tblResults AS TABLE
    (
        CodeCoachingLogFK INT,
        CntItem INT,
        CntICL INT,
        MinDate DATETIME,
        MaxDate DATETIME
    );
	

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
        OBSVerbalSupport,
        TeacherFK,
        CoachFK,
        ProgramFK
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
           cl.OBSVerbalSupport,
           cl.TeacherFK,
           cl.CoachFK,
           cl.ProgramFK
    FROM dbo.CoachingLog cl
        INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON cl.ProgramFK = programList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@TeacherFKs, ',') teacherList
            ON cl.TeacherFK = teacherList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@CoachFKs, ',') coachList
            ON cl.CoachFK = coachList.ListItem
    WHERE cl.LogDate BETWEEN @StartDate AND @EndDate
		AND (@TeacherFKs IS NULL OR @TeacherFKs = '' OR teacherList.ListItem IS NOT NULL) --Optional teacher criteria
		AND (@CoachFKs IS NULL OR @CoachFKs = '' OR coachList.ListItem IS NOT NULL); --Optional coach criteria


    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 1,
           SUM(CONVERT(INT, tc.OBSObserving))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 2,
           SUM(CONVERT(INT, tc.OBSModeling))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 3,
           SUM(CONVERT(INT, tc.OBSVerbalSupport))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 4,
           SUM(CONVERT(INT, tc.OBSSideBySide))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 5,
           SUM(CONVERT(INT, tc.OBSProblemSolving))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 6,
           SUM(CONVERT(INT, tc.OBSReflectiveConversation))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 7,
           SUM(CONVERT(INT, tc.OBSEnvironment))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 8,
           SUM(CONVERT(INT, tc.OBSOtherHelp))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 9,
           SUM(CONVERT(INT, tc.OBSConductTPOT))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 10,
           SUM(CONVERT(INT, tc.OBSConductTPITOS))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 11,
           SUM(CONVERT(INT, tc.OBSOther))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 12,
           SUM(CONVERT(INT, tc.MEETProblemSolving))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 13,
           SUM(CONVERT(INT, tc.MEETReflectiveConversation))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 14,
           SUM(CONVERT(INT, tc.MEETEnvironment))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 15,
           SUM(CONVERT(INT, tc.MEETRoleplay))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 16,
           SUM(CONVERT(INT, tc.MEETVideo))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 17,
           SUM(CONVERT(INT, tc.MEETGraphic))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 18,
           SUM(CONVERT(INT, tc.MEETGoalSetting))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 19,
           SUM(CONVERT(INT, tc.MEETPerformance))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 20,
           SUM(CONVERT(INT, tc.MEETMaterial))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 21,
           SUM(CONVERT(INT, tc.MEETDemonstration))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 22,
           SUM(CONVERT(INT, tc.MEETOther))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 23,
           SUM(CONVERT(INT, tc.FUEmail))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 24,
           SUM(CONVERT(INT, tc.FUPhone))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 25,
           SUM(CONVERT(INT, tc.FUInPerson))
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeCoachingLogFK,
        CntItem
    )
    SELECT 26,
           SUM(CONVERT(INT, tc.FUNone))
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
           ISNULL(tr.CntItem, 0) AS CntItem,
           tr.CntICL,
           tr.MinDate,
           tr.MaxDate
    FROM @tblResults tr
        INNER JOIN dbo.CodeCoachingLog ccl
            ON ccl.CodeCoachingLogPK = tr.CodeCoachingLogFK;
END;

GO

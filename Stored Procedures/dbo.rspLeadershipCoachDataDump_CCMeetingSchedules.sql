SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/30/2022
-- Description:	This stored procedure returns the necessary information for the
-- coaching circle leadership team meeting schedule section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_CCMeetingSchedules]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT cclms.CoachingCircleLCMeetingSchedulePK,
           cclms.CoachingCircleName,
           cclms.Creator,
           cclms.CreateDate,
           cclms.Editor,
           cclms.EditDate,
           cclms.MeetingInJan,
           cclms.MeetingInFeb,
           cclms.MeetingInMar,
           cclms.MeetingInApr,
           cclms.MeetingInMay,
           cclms.MeetingInJun,
           cclms.MeetingInJul,
           cclms.MeetingInAug,
           cclms.MeetingInSep,
           cclms.MeetingInOct,
           cclms.MeetingInNov,
           cclms.MeetingInDec,
           cclms.MeetingYear,
           cclms.TargetAudience,
           cclms.TotalMeetings,
           cclms.LeadershipCoachUsername,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.CoachingCircleLCMeetingSchedule cclms
        INNER JOIN dbo.[State] s
            ON s.StatePK = cclms.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = cclms.StateFK
    WHERE cclms.MeetingYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

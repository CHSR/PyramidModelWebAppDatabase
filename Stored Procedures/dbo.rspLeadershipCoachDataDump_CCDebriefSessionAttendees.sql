SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/30/2022
-- Description:	This stored procedure returns the necessary information for the
-- coaching circle debrief session attendees section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_CCDebriefSessionAttendees]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT cclmdsa.CoachingCircleLCMeetingDebriefSessionAttendeePK,
           cclmdsa.Creator,
           cclmdsa.CreateDate,
           cclmdsa.Editor,
           cclmdsa.EditDate,
		   cclmdtm.CoachingCircleLCMeetingDebriefTeamMemberPK,
           cclmdtm.FirstName,
           cclmdtm.LastName,
		   cclmds.CoachingCircleLCMeetingDebriefSessionPK,
		   cclmds.SessionStartDateTime,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.CoachingCircleLCMeetingDebriefSessionAttendee cclmdsa
		INNER JOIN dbo.CoachingCircleLCMeetingDebriefTeamMember cclmdtm
			ON cclmdtm.CoachingCircleLCMeetingDebriefTeamMemberPK = cclmdsa.CoachingCircleLCMeetingDebriefTeamMemberFK
		INNER JOIN dbo.CoachingCircleLCMeetingDebriefSession cclmds
			ON cclmds.CoachingCircleLCMeetingDebriefSessionPK = cclmdsa.CoachingCircleLCMeetingDebriefSessionFK
		INNER JOIN dbo.CoachingCircleLCMeetingDebrief cclmd
			ON cclmd.CoachingCircleLCMeetingDebriefPK = cclmds.CoachingCircleLCMeetingDebriefFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = cclmd.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = cclmd.StateFK
    WHERE cclmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

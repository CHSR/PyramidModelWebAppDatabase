SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/30/2022
-- Description:	This stored procedure returns the necessary information for the
-- hub debrief session attendees section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_HubDebriefSessionAttendees]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT hlmdsa.HubLCMeetingDebriefSessionAttendeePK,
           hlmdsa.Creator,
           hlmdsa.CreateDate,
           hlmdsa.Editor,
           hlmdsa.EditDate,
		   cm.CWLTMemberPK,
		   cm.IDNumber,
		   cm.FirstName,
		   cm.LastName,
		   hlmds.HubLCMeetingDebriefSessionPK,
		   hlmds.SessionStartDateTime,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.HubLCMeetingDebriefSessionAttendee hlmdsa
		INNER JOIN dbo.CWLTMember cm
			ON cm.CWLTMemberPK = hlmdsa.CWLTMemberFK
		INNER JOIN dbo.HubLCMeetingDebriefSession hlmds
			ON hlmds.HubLCMeetingDebriefSessionPK = hlmdsa.HubLCMeetingDebriefSessionFK
		INNER JOIN dbo.HubLCMeetingDebrief hlmd
			ON hlmd.HubLCMeetingDebriefPK = hlmds.HubLCMeetingDebriefFK
		INNER JOIN dbo.Hub h
			ON h.HubPK = hlmd.HubFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = h.StateFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = hlmd.HubFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = h.StateFK
    WHERE (
              hubList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND hlmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

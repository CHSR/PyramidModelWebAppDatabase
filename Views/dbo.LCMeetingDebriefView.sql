SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[LCMeetingDebriefView]
AS

SELECT CONCAT('Program', plmd.ProgramLCMeetingDebriefPK) CustomViewPK,
	   plmd.ProgramLCMeetingDebriefPK MeetingDebriefPK,
	   'Program' MeetingDebriefType,
	   CONCAT(p.ProgramName, ' (Program)') TeamDescription,
	   c.CohortName,
       plmd.DebriefYear,
       plmd.LocationAddress,
       plmd.PrimaryContactEmail,
       plmd.PrimaryContactPhone,
       plmd.LeadershipCoachUsername,
       plmd.ProgramFK,
	   NULL HubFK,
	   p.StateFK,
	   s.[Name] StateName
FROM dbo.ProgramLCMeetingDebrief plmd
INNER JOIN dbo.Program p ON p.ProgramPK = plmd.ProgramFK
INNER JOIN dbo.Cohort c ON c.CohortPK = p.CohortFK
INNER JOIN dbo.[State] s ON s.StatePK = c.StateFK
UNION
SELECT CONCAT('Hub', hlmd.HubLCMeetingDebriefPK) CustomViewPK,
	   hlmd.HubLCMeetingDebriefPK MeetingDebriefPK,
	   'Hub' MeetingDebriefType,
	   CONCAT(h.[Name], ' (Hub)') TeamDescription,
	   'N/A' CohortName,
       hlmd.DebriefYear,
       hlmd.LocationAddress,
       hlmd.PrimaryContactEmail,
       hlmd.PrimaryContactPhone,
       hlmd.LeadershipCoachUsername,
	   NULL ProgramFK,
       hlmd.HubFK,
	   h.StateFK,
	   s.[Name] StateName
FROM dbo.HubLCMeetingDebrief hlmd
INNER JOIN dbo.Hub h ON h.HubPK = hlmd.HubFK
INNER JOIN dbo.[State] s ON s.StatePK = h.StateFK

GO

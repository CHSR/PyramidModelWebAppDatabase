SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[LCMeetingScheduleView]
AS

SELECT CONCAT('Program', plms.ProgramLCMeetingSchedulePK) CustomViewPK,
	   plms.ProgramLCMeetingSchedulePK MeetingSchedulePK,
	   'Program' MeetingScheduleType,
	   CONCAT(p.ProgramName, ' (Program)') TeamDescription,
	   c.CohortName,
       plms.MeetingInJan,
       plms.MeetingInFeb,
       plms.MeetingInMar,
       plms.MeetingInApr,
       plms.MeetingInMay,
       plms.MeetingInJun,
       plms.MeetingInJul,
       plms.MeetingInAug,
       plms.MeetingInSep,
       plms.MeetingInOct,
       plms.MeetingInNov,
       plms.MeetingInDec,
       plms.MeetingYear,
       plms.TotalMeetings,
       plms.LeadershipCoachUsername,
       plms.ProgramFK,
	   NULL HubFK,
	   p.StateFK,
	   s.[Name] StateName
FROM dbo.ProgramLCMeetingSchedule plms
INNER JOIN dbo.Program p ON p.ProgramPK = plms.ProgramFK
INNER JOIN dbo.Cohort c ON c.CohortPK = p.CohortFK
INNER JOIN dbo.[State] s ON s.StatePK = c.StateFK
UNION
SELECT CONCAT('Hub', hlms.HubLCMeetingSchedulePK) CustomViewPK,
	   hlms.HubLCMeetingSchedulePK MeetingSchedulePK,
	   'Hub' MeetingScheduleType,
	   CONCAT(h.[Name], ' (Hub)') TeamDescription,
	   'N/A' CohortName,
       hlms.MeetingInJan,
       hlms.MeetingInFeb,
       hlms.MeetingInMar,
       hlms.MeetingInApr,
       hlms.MeetingInMay,
       hlms.MeetingInJun,
       hlms.MeetingInJul,
       hlms.MeetingInAug,
       hlms.MeetingInSep,
       hlms.MeetingInOct,
       hlms.MeetingInNov,
       hlms.MeetingInDec,
       hlms.MeetingYear,
       hlms.TotalMeetings,
       hlms.LeadershipCoachUsername,
	   NULL ProgramFK,
       hlms.HubFK,
	   h.StateFK,
	   s.[Name] StateName
FROM dbo.HubLCMeetingSchedule hlms
INNER JOIN dbo.Hub h ON h.HubPK = hlms.HubFK
INNER JOIN dbo.[State] s ON s.StatePK = h.StateFK

GO

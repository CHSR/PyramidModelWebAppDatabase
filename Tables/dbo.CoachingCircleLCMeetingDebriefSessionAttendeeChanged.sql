CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendeeChanged]
(
[CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingCircleLCMeetingDebriefSessionAttendeePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[CoachingCircleLCMeetingDebriefSessionFK] [int] NOT NULL,
[CoachingCircleLCMeetingDebriefTeamMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendeeChanged] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefSessionAttendeeChanged] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK]) ON [PRIMARY]
GO

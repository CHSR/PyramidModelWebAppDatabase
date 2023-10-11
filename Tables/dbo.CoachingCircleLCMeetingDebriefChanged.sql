CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefChanged]
(
[CoachingCircleLCMeetingDebriefChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingCircleLCMeetingDebriefPK] [int] NOT NULL,
[CoachingCircleName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DebriefYear] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[TargetAudience] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefChanged] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefChanged] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionChanged]
(
[CoachingCircleLCMeetingDebriefSessionChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingCircleLCMeetingDebriefSessionPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[SessionEndDateTime] [datetime] NOT NULL,
[SessionStartDateTime] [datetime] NOT NULL,
[SessionSummary] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CoachingCircleLCMeetingDebriefFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionChanged] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefSessionChanged] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefSessionChangedPK]) ON [PRIMARY]
GO

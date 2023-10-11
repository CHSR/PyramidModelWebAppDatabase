CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMemberChanged]
(
[CoachingCircleLCMeetingDebriefTeamMemberChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingCircleLCMeetingDebriefTeamMemberPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeamPositionCodeFK] [int] NOT NULL,
[CoachingCircleLCMeetingDebriefFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMemberChanged] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefTeamMemberChanged] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefTeamMemberChangedPK]) ON [PRIMARY]
GO

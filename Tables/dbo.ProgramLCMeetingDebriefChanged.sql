CREATE TABLE [dbo].[ProgramLCMeetingDebriefChanged]
(
[ProgramLCMeetingDebriefChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramLCMeetingDebriefPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DebriefYear] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LocationAddress] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactEmail] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactPhone] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefChanged] ADD CONSTRAINT [PK_ProgramLCMeetingDebriefChanged] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefChangedPK]) ON [PRIMARY]
GO

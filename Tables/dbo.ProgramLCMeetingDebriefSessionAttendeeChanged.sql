CREATE TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendeeChanged]
(
[ProgramLCMeetingDebriefSessionAttendeeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramLCMeetingDebriefSessionAttendeePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ProgramLCMeetingDebriefSessionFK] [int] NOT NULL,
[PLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendeeChanged] ADD CONSTRAINT [PK_ProgramLCMeetingDebriefSessionAttendeeChanged] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefSessionAttendeeChangedPK]) ON [PRIMARY]
GO

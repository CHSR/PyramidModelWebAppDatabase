CREATE TABLE [dbo].[HubLCMeetingDebriefSessionAttendeeChanged]
(
[HubLCMeetingDebriefSessionAttendeeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HubLCMeetingDebriefSessionAttendeePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[CWLTMemberFK] [int] NOT NULL,
[HubLCMeetingDebriefSessionFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSessionAttendeeChanged] ADD CONSTRAINT [PK_HubLCMeetingDebriefSessionAttendeeChanged] PRIMARY KEY CLUSTERED ([HubLCMeetingDebriefSessionAttendeeChangedPK]) ON [PRIMARY]
GO

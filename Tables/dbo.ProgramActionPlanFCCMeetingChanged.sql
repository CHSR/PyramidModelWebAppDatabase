CREATE TABLE [dbo].[ProgramActionPlanFCCMeetingChanged]
(
[ProgramActionPlanFCCMeetingChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCMeetingPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeadershipCoachAttendance] [bit] NOT NULL,
[MeetingDate] [datetime] NOT NULL,
[MeetingNotes] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCMeetingChanged] ADD CONSTRAINT [PK_ProgramActionPlanFCCMeetingChanged] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCMeetingChangedPK]) ON [PRIMARY]
GO

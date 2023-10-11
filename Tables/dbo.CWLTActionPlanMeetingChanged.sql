CREATE TABLE [dbo].[CWLTActionPlanMeetingChanged]
(
[CWLTActionPlanMeetingChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTActionPlanMeetingPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeadershipCoachAttendance] [bit] NOT NULL,
[MeetingDate] [datetime] NOT NULL,
[MeetingNotes] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTActionPlanFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanMeetingChanged] ADD CONSTRAINT [PK_CWLTActionPlanMeetingChanged] PRIMARY KEY CLUSTERED ([CWLTActionPlanMeetingChangedPK]) ON [PRIMARY]
GO

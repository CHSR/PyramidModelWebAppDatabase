CREATE TABLE [dbo].[ProgramLCMeetingDebriefSessionChanged]
(
[ProgramLCMeetingDebriefSessionChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramLCMeetingDebriefSessionPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[NextSessionEndDateTime] [datetime] NOT NULL,
[NextSessionStartDateTime] [datetime] NOT NULL,
[ReviewedActionPlan] [bit] NOT NULL,
[ReviewedBOQ] [bit] NOT NULL,
[ReviewedOtherItem] [bit] NOT NULL,
[ReviewedOtherItemSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReviewedTPITOS] [bit] NOT NULL,
[ReviewedTPOT] [bit] NOT NULL,
[SessionEndDateTime] [datetime] NOT NULL,
[SessionNextSteps] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SessionStartDateTime] [datetime] NOT NULL,
[SessionSummary] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramLCMeetingDebriefFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSessionChanged] ADD CONSTRAINT [PK_ProgramLCMeetingDebriefSessionChanged] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefSessionChangedPK]) ON [PRIMARY]
GO

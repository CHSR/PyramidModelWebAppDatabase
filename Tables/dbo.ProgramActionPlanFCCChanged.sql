CREATE TABLE [dbo].[ProgramActionPlanFCCChanged]
(
[ProgramActionPlanFCCChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCPK] [int] NOT NULL,
[ActionPlanEndDate] [datetime] NOT NULL,
[ActionPlanStartDate] [datetime] NOT NULL,
[AdditionalNotes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsLeadershipCoachInvolved] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlanFCCChanged_IsLeadershipCoachInvolved] DEFAULT ((0)),
[IsPrefilled] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlanFCCChanged_IsPrefilled] DEFAULT ((0)),
[MissionStatement] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewedActionSteps] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlanFCCChanged_ReviewedActionSteps] DEFAULT ((0)),
[ReviewedBasicInfo] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlanFCCChanged_ReviewedBasicInfo] DEFAULT ((0)),
[ReviewedGroundRules] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlanFCCChanged_ReviewedGroundRules] DEFAULT ((0)),
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCChanged] ADD CONSTRAINT [PK_ProgramActionPlanFCCChanged] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCChangedPK]) ON [PRIMARY]
GO

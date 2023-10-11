CREATE TABLE [dbo].[CWLTActionPlanActionStepChanged]
(
[CWLTActionPlanActionStepChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTActionPlanActionStepPK] [int] NOT NULL,
[ActionStepActivity] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[PersonsResponsible] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProblemIssueTask] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetDate] [datetime] NOT NULL,
[BOQIndicatorCodeFK] [int] NOT NULL,
[CWLTActionPlanFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStepChanged] ADD CONSTRAINT [PK_CWLTActionPlanActionStepChanged] PRIMARY KEY CLUSTERED ([CWLTActionPlanActionStepChangedPK]) ON [PRIMARY]
GO

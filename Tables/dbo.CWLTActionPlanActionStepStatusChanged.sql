CREATE TABLE [dbo].[CWLTActionPlanActionStepStatusChanged]
(
[CWLTActionPlanActionStepStatusChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTActionPlanActionStepStatusPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[CWLTActionPlanActionStepFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStepStatusChanged] ADD CONSTRAINT [PK_CWLTActionPlanActionStepStatusChanged] PRIMARY KEY CLUSTERED ([CWLTActionPlanActionStepStatusChangedPK]) ON [PRIMARY]
GO

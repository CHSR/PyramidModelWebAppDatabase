CREATE TABLE [dbo].[ProgramActionPlanFCCActionStepStatusChanged]
(
[ProgramActionPlanFCCActionStepStatusChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCActionStepStatusPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[ProgramActionPlanFCCActionStepFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStepStatusChanged] ADD CONSTRAINT [PK_ProgramActionPlanFCCActionStepStatusChanged] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCActionStepStatusChangedPK]) ON [PRIMARY]
GO

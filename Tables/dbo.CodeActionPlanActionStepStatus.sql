CREATE TABLE [dbo].[CodeActionPlanActionStepStatus]
(
[CodeActionPlanActionStepStatusPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeActionPlanActionStepStatus] ADD CONSTRAINT [PK_CodeActionPlanActionStepStatus] PRIMARY KEY CLUSTERED ([CodeActionPlanActionStepStatusPK]) ON [PRIMARY]
GO

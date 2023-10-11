CREATE TABLE [dbo].[ProgramActionPlanFCCGroundRuleChanged]
(
[ProgramActionPlanFCCGroundRuleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCGroundRulePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[GroundRuleDescription] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroundRuleNumber] [int] NOT NULL,
[ProgramActionPlanFCCFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCGroundRuleChanged] ADD CONSTRAINT [PK_ProgramActionPlanFCCGroundRuleChanged] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCGroundRuleChangedPK]) ON [PRIMARY]
GO

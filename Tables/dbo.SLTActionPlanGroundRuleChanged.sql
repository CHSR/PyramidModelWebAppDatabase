CREATE TABLE [dbo].[SLTActionPlanGroundRuleChanged]
(
[SLTActionPlanGroundRuleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTActionPlanGroundRulePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[GroundRuleDescription] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroundRuleNumber] [int] NOT NULL,
[SLTActionPlanFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlanGroundRuleChanged] ADD CONSTRAINT [PK_SLTActionPlanGroundRuleChanged] PRIMARY KEY CLUSTERED ([SLTActionPlanGroundRuleChangedPK]) ON [PRIMARY]
GO

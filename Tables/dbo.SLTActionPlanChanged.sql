CREATE TABLE [dbo].[SLTActionPlanChanged]
(
[SLTActionPlanChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTActionPlanPK] [int] NOT NULL,
[ActionPlanEndDate] [datetime] NOT NULL,
[ActionPlanStartDate] [datetime] NOT NULL,
[AdditionalNotes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsPrefilled] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlanChanged_IsPrefilled] DEFAULT ((0)),
[MissionStatement] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewedActionSteps] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlanChanged_ReviewedActionSteps] DEFAULT ((0)),
[ReviewedBasicInfo] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlanChanged_ReviewedBasicInfo] DEFAULT ((0)),
[ReviewedGroundRules] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlanChanged_ReviewedGroundRules] DEFAULT ((0)),
[StateFK] [int] NOT NULL,
[WorkGroupFK] [int] NOT NULL,
[WorkGroupLeadFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlanChanged] ADD CONSTRAINT [PK_SLTActionPlanChanged] PRIMARY KEY CLUSTERED ([SLTActionPlanChangedPK]) ON [PRIMARY]
GO

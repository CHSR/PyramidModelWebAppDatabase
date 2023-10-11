CREATE TABLE [dbo].[BehaviorIncidentChanged]
(
[BehaviorIncidentChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BehaviorIncidentPK] [int] NOT NULL,
[ActivitySpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminFollowUpSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BehaviorDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IncidentDatetime] [datetime] NOT NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OthersInvolvedSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PossibleMotivationSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProblemBehaviorSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StrategyResponseSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActivityCodeFK] [int] NOT NULL,
[AdminFollowUpCodeFK] [int] NOT NULL,
[OthersInvolvedCodeFK] [int] NOT NULL,
[PossibleMotivationCodeFK] [int] NOT NULL,
[ProblemBehaviorCodeFK] [int] NOT NULL,
[StrategyResponseCodeFK] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ClassroomFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BehaviorIncidentChanged] ADD CONSTRAINT [PK_BehaviorIncidentChanged] PRIMARY KEY CLUSTERED  ([BehaviorIncidentChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BehaviorIncidentChanged_BehaviorIncidentPK_ChangeDatetime] ON [dbo].[BehaviorIncidentChanged] ([BehaviorIncidentPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

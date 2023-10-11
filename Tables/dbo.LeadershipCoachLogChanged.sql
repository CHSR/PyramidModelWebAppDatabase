CREATE TABLE [dbo].[LeadershipCoachLogChanged]
(
[LeadershipCoachLogChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadershipCoachLogPK] [int] NOT NULL,
[ActNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[CyclePhase] [int] NULL,
[DateCompleted] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[HighlightsNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsComplete] [bit] NOT NULL,
[IsMonthly] [bit] NULL,
[NumberOfAttemptedEngagements] [int] NULL,
[NumberOfEngagements] [int] NULL,
[OtherDomainTwoSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherEngagementSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherSiteResourcesSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherTopicsDiscussedSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherTrainingsCoveredSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetedTrainingHours] [int] NULL,
[TargetedTrainingMinutes] [int] NULL,
[ThinkNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDurationHours] [int] NULL,
[TotalDurationMinutes] [int] NULL,
[GoalCompletionLikelihoodCodeFK] [int] NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[TimelyProgressionLikelihoodCodeFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadershipCoachLogChanged] ADD CONSTRAINT [PK_LeadershipCoachLogChanged] PRIMARY KEY CLUSTERED ([LeadershipCoachLogChangedPK]) ON [PRIMARY]
GO

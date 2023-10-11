CREATE TABLE [dbo].[CoachingLogCoacheesChanged]
(
[CoachingLogCoacheesChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingLogCoacheesPK] [int] NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoacheeFK] [int] NOT NULL,
[CoachingLogFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingLogCoacheesChanged] ADD CONSTRAINT [PK_CoachingLogCoacheesChanged] PRIMARY KEY CLUSTERED ([CoachingLogCoacheesChangedPK]) ON [PRIMARY]
GO

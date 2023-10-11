CREATE TABLE [dbo].[TPOTBehaviorResponsesChanged]
(
[TPOTBehaviorResponsesChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPOTBehaviorResponsesPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPOTFK] [int] NOT NULL,
[BehaviorResponseCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTBehaviorResponsesChanged] ADD CONSTRAINT [PK_TPOTBehaviorResponsesChanged] PRIMARY KEY CLUSTERED  ([TPOTBehaviorResponsesChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[TPOTRedFlagsChanged]
(
[TPOTRedFlagsChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPOTRedFlagsPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPOTFK] [int] NOT NULL,
[RedFlagCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTRedFlagsChanged] ADD CONSTRAINT [PK_TPOTRedFlagsChanged] PRIMARY KEY CLUSTERED  ([TPOTRedFlagsChangedPK]) ON [PRIMARY]
GO

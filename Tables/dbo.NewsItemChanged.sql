CREATE TABLE [dbo].[NewsItemChanged]
(
[NewsItemChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewsItemPK] [int] NOT NULL,
[Contents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ItemNum] [int] NOT NULL,
[NewsEntryFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsItemChanged] ADD CONSTRAINT [PK_NewsItemChanged] PRIMARY KEY CLUSTERED  ([NewsItemChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NewsItemChanged_NewsItemPK_ChangeDatetime] ON [dbo].[NewsItemChanged] ([NewsItemPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

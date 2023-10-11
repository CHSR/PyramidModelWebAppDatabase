CREATE TABLE [dbo].[NewsEntryChanged]
(
[NewsEntryChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewsEntryPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EntryDate] [datetime] NOT NULL,
[NewsEntryTypeCodeFK] [int] NOT NULL,
[ProgramFK] [int] NULL,
[HubFK] [int] NULL,
[StateFK] [int] NULL,
[CohortFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsEntryChanged] ADD CONSTRAINT [PK_NewsEntryChanged] PRIMARY KEY CLUSTERED  ([NewsEntryChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NewsEntryChanged_NewsEntryPK_ChangeDatetime] ON [dbo].[NewsEntryChanged] ([NewsEntryPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

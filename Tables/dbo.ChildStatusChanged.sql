CREATE TABLE [dbo].[ChildStatusChanged]
(
[ChildStatusChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildStatusPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ChildStatusCodeFK] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildStatusChanged] ADD CONSTRAINT [PK_ChildStatusChanged] PRIMARY KEY CLUSTERED  ([ChildStatusChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChildStatusChanged_ChildStatusPK_ChangeDatetime] ON [dbo].[ChildStatusChanged] ([ChildStatusPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ChildNoteChanged]
(
[ChildNoteChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildNotePK] [int] NOT NULL,
[Contents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[NoteDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ChildFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildNoteChanged] ADD CONSTRAINT [PK_ChildNoteChanged] PRIMARY KEY CLUSTERED  ([ChildNoteChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChildNoteChanged_ChildNotePK_ChangeDatetime] ON [dbo].[ChildNoteChanged] ([ChildNotePK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

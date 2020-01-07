CREATE TABLE [dbo].[OtherSEScreenChanged]
(
[OtherSEScreenChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherSEScreenPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ScreenDate] [datetime] NOT NULL,
[Score] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ScoreTypeCodeFK] [int] NOT NULL,
[ScreenTypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OtherSEScreenChanged] ADD CONSTRAINT [PK_OtherSEScreenChanged] PRIMARY KEY CLUSTERED  ([OtherSEScreenChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OtherSEScreenChanged_OtherSEScreenPK_ChangeDatetime] ON [dbo].[OtherSEScreenChanged] ([OtherSEScreenPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ChildChanged]
(
[ChildChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildPK] [int] NOT NULL,
[BirthDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EthnicitySpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RaceSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicityCodeFK] [int] NOT NULL,
[GenderCodeFK] [int] NOT NULL,
[RaceCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildChanged] ADD CONSTRAINT [PK_ChildChanged] PRIMARY KEY CLUSTERED ([ChildChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChildChanged_ChildPK_ChangeDatetime] ON [dbo].[ChildChanged] ([ChildPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

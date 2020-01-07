CREATE TABLE [dbo].[State]
(
[StatePK] [int] NOT NULL IDENTITY(1, 1),
[Abbreviation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Catchphrase] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Disclaimer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LogoFilename] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[State] ADD CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED  ([StatePK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StateAbbreviationUnique] ON [dbo].[State] ([Abbreviation]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StateNameUnique] ON [dbo].[State] ([Name]) ON [PRIMARY]
GO

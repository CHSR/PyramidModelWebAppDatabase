CREATE TABLE [dbo].[CodeTPOTKeyPractice]
(
[CodeTPOTKeyPracticePK] [int] NOT NULL,
[Abbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTPOTKeyPractice] ADD CONSTRAINT [PK_CodeTPOTKeyPractice] PRIMARY KEY CLUSTERED  ([CodeTPOTKeyPracticePK]) ON [PRIMARY]
GO

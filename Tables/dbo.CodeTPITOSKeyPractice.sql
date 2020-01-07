CREATE TABLE [dbo].[CodeTPITOSKeyPractice]
(
[CodeTPITOSKeyPracticePK] [int] NOT NULL,
[Abbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTPITOSKeyPractice] ADD CONSTRAINT [PK_CodeTPITOSKeyPractice] PRIMARY KEY CLUSTERED  ([CodeTPITOSKeyPracticePK]) ON [PRIMARY]
GO

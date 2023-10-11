CREATE TABLE [dbo].[CodeBOQType]
(
[CodeBOQTypePK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQType] ADD CONSTRAINT [PK_CodeBOQType] PRIMARY KEY CLUSTERED ([CodeBOQTypePK]) ON [PRIMARY]
GO

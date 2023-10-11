CREATE TABLE [dbo].[CodeLCLResponse]
(
[CodeLCLResponsePK] [int] NOT NULL,
[Abbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeLCLResponse_FieldName] DEFAULT ('NA'),
[Group] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeLCLResponse] ADD CONSTRAINT [PK_CodeLCLResponse] PRIMARY KEY CLUSTERED ([CodeLCLResponsePK]) ON [PRIMARY]
GO

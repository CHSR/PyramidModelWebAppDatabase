CREATE TABLE [dbo].[CodeBOQCriticalElement]
(
[CodeBOQCriticalElementPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL,
[BOQTypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQCriticalElement] ADD CONSTRAINT [PK_CodeBOQCriticalElement] PRIMARY KEY CLUSTERED ([CodeBOQCriticalElementPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQCriticalElement] ADD CONSTRAINT [FK_CodeBOQCriticalElement_CodeBOQType] FOREIGN KEY ([BOQTypeCodeFK]) REFERENCES [dbo].[CodeBOQType] ([CodeBOQTypePK])
GO

CREATE TABLE [dbo].[CodeBOQIndicatorValue]
(
[CodeBOQIndicatorValuePK] [int] NOT NULL,
[IndicatorValue] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL,
[BOQTypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQIndicatorValue] ADD CONSTRAINT [PK_CodeBOQIndicatorValue] PRIMARY KEY CLUSTERED ([CodeBOQIndicatorValuePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQIndicatorValue] ADD CONSTRAINT [FK_CodeBOQIndicatorValue_CodeBOQType] FOREIGN KEY ([BOQTypeCodeFK]) REFERENCES [dbo].[CodeBOQType] ([CodeBOQTypePK])
GO

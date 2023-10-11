CREATE TABLE [dbo].[CodeBOQIndicator]
(
[CodeBOQIndicatorPK] [int] NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IndicatorNumber] [int] NOT NULL,
[OrderBy] [int] NOT NULL,
[BOQCriticalElementCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQIndicator] ADD CONSTRAINT [PK_CodeBOQIndicator] PRIMARY KEY CLUSTERED ([CodeBOQIndicatorPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeBOQIndicator] ADD CONSTRAINT [FK_CodeBOQIndicator_CodeBOQCriticalElement] FOREIGN KEY ([BOQCriticalElementCodeFK]) REFERENCES [dbo].[CodeBOQCriticalElement] ([CodeBOQCriticalElementPK])
GO

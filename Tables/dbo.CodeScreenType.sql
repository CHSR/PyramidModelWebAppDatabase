CREATE TABLE [dbo].[CodeScreenType]
(
[CodeScreenTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeScreenType] ADD CONSTRAINT [PK_CodeOtherScreenType] PRIMARY KEY CLUSTERED  ([CodeScreenTypePK]) ON [PRIMARY]
GO

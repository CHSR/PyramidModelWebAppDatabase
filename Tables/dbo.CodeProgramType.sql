CREATE TABLE [dbo].[CodeProgramType]
(
[CodeProgramTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeProgramType] ADD CONSTRAINT [PK_CodeProgramType] PRIMARY KEY CLUSTERED  ([CodeProgramTypePK]) ON [PRIMARY]
GO

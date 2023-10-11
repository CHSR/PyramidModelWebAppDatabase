CREATE TABLE [dbo].[CodeMasterCadreActivity]
(
[CodeMasterCadreActivityPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RequireCourseID] [bit] NOT NULL,
[RequireEventID] [bit] NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeMasterCadreActivity] ADD CONSTRAINT [PK_CodeMasterCadreActivity] PRIMARY KEY CLUSTERED ([CodeMasterCadreActivityPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CodeTraining]
(
[CodeTrainingPK] [int] NOT NULL,
[Abbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTraining] ADD CONSTRAINT [PK_CodeTrainingType] PRIMARY KEY CLUSTERED  ([CodeTrainingPK]) ON [PRIMARY]
GO

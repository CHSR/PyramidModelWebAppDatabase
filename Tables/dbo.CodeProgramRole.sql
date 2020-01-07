CREATE TABLE [dbo].[CodeProgramRole]
(
[CodeProgramRolePK] [int] NOT NULL,
[RoleName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllowedToEdit] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeProgramRole] ADD CONSTRAINT [PK_ApplicationRole] PRIMARY KEY CLUSTERED  ([CodeProgramRolePK]) ON [PRIMARY]
GO

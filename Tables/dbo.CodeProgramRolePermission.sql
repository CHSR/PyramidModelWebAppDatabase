CREATE TABLE [dbo].[CodeProgramRolePermission]
(
[CodeProgramRolePermissionPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedToAdd] [bit] NOT NULL CONSTRAINT [DF_CodeProgramRolePermission_AllowedToAdd] DEFAULT ((0)),
[AllowedToDelete] [bit] NOT NULL,
[AllowedToEdit] [bit] NOT NULL,
[AllowedToView] [bit] NOT NULL,
[AllowedToViewDashboard] [bit] NOT NULL,
[CodeFormFK] [int] NOT NULL,
[CodeProgramRoleFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeProgramRolePermission] ADD CONSTRAINT [PK_CodeProgramRolePermission] PRIMARY KEY CLUSTERED  ([CodeProgramRolePermissionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeProgramRolePermission] ADD CONSTRAINT [FK_CodeProgramRolePermission_CodeForm] FOREIGN KEY ([CodeFormFK]) REFERENCES [dbo].[CodeForm] ([CodeFormPK])
GO
ALTER TABLE [dbo].[CodeProgramRolePermission] ADD CONSTRAINT [FK_CodeProgramRolePermission_CodeProgramRole] FOREIGN KEY ([CodeProgramRoleFK]) REFERENCES [dbo].[CodeProgramRole] ([CodeProgramRolePK])
GO

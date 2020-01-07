CREATE TABLE [dbo].[UserProgramRole]
(
[UserProgramRolePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Username] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProgramRoleCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [PK_UserProgramRole] PRIMARY KEY CLUSTERED  ([UserProgramRolePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [FK_UserProgramRole_CodeProgramRole] FOREIGN KEY ([ProgramRoleCodeFK]) REFERENCES [dbo].[CodeProgramRole] ([CodeProgramRolePK])
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [FK_UserProgramRole_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

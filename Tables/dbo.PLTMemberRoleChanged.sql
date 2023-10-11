CREATE TABLE [dbo].[PLTMemberRoleChanged]
(
[PLTMemberRoleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PLTMemberRolePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[PLTMemberFK] [int] NOT NULL,
[TeamPositionCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PLTMemberRoleChanged] ADD CONSTRAINT [PK_PLTMemberRoleChanged] PRIMARY KEY CLUSTERED ([PLTMemberRoleChangedPK]) ON [PRIMARY]
GO

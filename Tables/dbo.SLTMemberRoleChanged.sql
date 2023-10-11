CREATE TABLE [dbo].[SLTMemberRoleChanged]
(
[SLTMemberRoleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTMemberRolePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[SLTMemberFK] [int] NOT NULL,
[TeamPositionCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMemberRoleChanged] ADD CONSTRAINT [PK_SLTMemberRoleChanged] PRIMARY KEY CLUSTERED ([SLTMemberRoleChangedPK]) ON [PRIMARY]
GO

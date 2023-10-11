CREATE TABLE [dbo].[CWLTMemberRoleChanged]
(
[CWLTMemberRoleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTMemberRolePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[CWLTMemberFK] [int] NOT NULL,
[TeamPositionCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMemberRoleChanged] ADD CONSTRAINT [PK_CWLTMemberRoleChanged] PRIMARY KEY CLUSTERED ([CWLTMemberRoleChangedPK]) ON [PRIMARY]
GO

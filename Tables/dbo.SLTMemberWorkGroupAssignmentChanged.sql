CREATE TABLE [dbo].[SLTMemberWorkGroupAssignmentChanged]
(
[SLTMemberWorkGroupAssignmentChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTMemberWorkGroupAssignmentPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[SLTWorkGroupFK] [int] NOT NULL,
[SLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMemberWorkGroupAssignmentChanged] ADD CONSTRAINT [PK_SLTMemberWorkGroupAssignmentChanged] PRIMARY KEY CLUSTERED ([SLTMemberWorkGroupAssignmentChangedPK]) ON [PRIMARY]
GO

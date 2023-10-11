CREATE TABLE [dbo].[LCLTeamMemberEngagementChanged]
(
[LCLTeamMemberEngagementChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LCLTeamMemberEngagementPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL,
[PLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLTeamMemberEngagementChanged] ADD CONSTRAINT [PK_LCLTeamMemberEngagementChanged] PRIMARY KEY CLUSTERED ([LCLTeamMemberEngagementChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CWLTMemberAgencyAssignmentChanged]
(
[CWLTMemberAgencyAssignmentChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTMemberAgencyAssignmentPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[CWLTAgencyFK] [int] NOT NULL,
[CWLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMemberAgencyAssignmentChanged] ADD CONSTRAINT [PK_CWLTMemberAgencyAssignmentChanged] PRIMARY KEY CLUSTERED ([CWLTMemberAgencyAssignmentChangedPK]) ON [PRIMARY]
GO

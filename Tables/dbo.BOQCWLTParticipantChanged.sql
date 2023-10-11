CREATE TABLE [dbo].[BOQCWLTParticipantChanged]
(
[BOQCWLTParticipantChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOQCWLTParticipantPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[BenchmarksOfQualityCWLTFK] [int] NOT NULL,
[CWLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOQCWLTParticipantChanged] ADD CONSTRAINT [PK_BOQCWLTParticipantChanged] PRIMARY KEY CLUSTERED ([BOQCWLTParticipantChangedPK]) ON [PRIMARY]
GO

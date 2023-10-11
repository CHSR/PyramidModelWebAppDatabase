CREATE TABLE [dbo].[BOQSLTParticipantChanged]
(
[BOQSLTParticipantChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BOQSLTParticipantPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[BenchmarksOfQualitySLTFK] [int] NOT NULL,
[SLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOQSLTParticipantChanged] ADD CONSTRAINT [PK_BOQSLTParticipantChanged] PRIMARY KEY CLUSTERED ([BOQSLTParticipantChangedPK]) ON [PRIMARY]
GO

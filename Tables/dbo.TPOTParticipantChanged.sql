CREATE TABLE [dbo].[TPOTParticipantChanged]
(
[TPOTParticipantChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPOTParticipantPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ParticipantTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL,
[TPOTFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTParticipantChanged] ADD CONSTRAINT [PK_TPOTParticipantChanged] PRIMARY KEY CLUSTERED  ([TPOTParticipantChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TPOTParticipantChanged_TPOTParticipantPK_ChangeDatetime] ON [dbo].[TPOTParticipantChanged] ([TPOTParticipantPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

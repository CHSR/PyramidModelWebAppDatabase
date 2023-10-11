CREATE TABLE [dbo].[TPITOSParticipantChanged]
(
[TPITOSParticipantChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPITOSParticipantPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ParticipantTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL,
[TPITOSFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPITOSParticipantChanged] ADD CONSTRAINT [PK_TPITOSParticipantChanged] PRIMARY KEY CLUSTERED  ([TPITOSParticipantChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TPITOSParticipantChanged_TPITOSParticipantPK_ChangeDatetime] ON [dbo].[TPITOSParticipantChanged] ([TPITOSParticipantPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

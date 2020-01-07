CREATE TABLE [dbo].[ProgramChanged]
(
[ProgramChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Location] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramEndDate] [datetime] NULL,
[ProgramName] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramStartDate] [datetime] NULL,
[CohortFK] [int] NOT NULL,
[HubFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramChanged] ADD CONSTRAINT [PK_ProgramChanged] PRIMARY KEY CLUSTERED  ([ProgramChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProgramChanged_ProgramPK_ChangeDatetime] ON [dbo].[ProgramChanged] ([ProgramPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

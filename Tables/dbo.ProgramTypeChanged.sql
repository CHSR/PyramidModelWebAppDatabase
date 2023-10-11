CREATE TABLE [dbo].[ProgramTypeChanged]
(
[ProgramTypeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramTypeChanged] ADD CONSTRAINT [PK_ProgramTypeChanged] PRIMARY KEY CLUSTERED  ([ProgramTypeChangedPK]) ON [PRIMARY]
GO

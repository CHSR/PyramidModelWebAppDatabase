CREATE TABLE [dbo].[ClassroomChanged]
(
[ClassroomChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClassroomPK] [int] NOT NULL,
[BeingServedSubstitute] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsInfantToddler] [bit] NOT NULL,
[IsPreschool] [bit] NOT NULL,
[Location] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramSpecificID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassroomChanged] ADD CONSTRAINT [PK_ClassroomChanged] PRIMARY KEY CLUSTERED  ([ClassroomChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClassroomChanged_ClassroomPK_ChangeDatetime] ON [dbo].[ClassroomChanged] ([ClassroomPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

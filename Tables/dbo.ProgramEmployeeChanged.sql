CREATE TABLE [dbo].[ProgramEmployeeChanged]
(
[ProgramEmployeeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramEmployeePK] [int] NOT NULL,
[AspireID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HireDate] [datetime] NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TermDate] [datetime] NULL,
[TermReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[TermReasonCodeFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramEmployeeChanged] ADD CONSTRAINT [PK_ProgramEmployeeChanged] PRIMARY KEY CLUSTERED  ([ProgramEmployeeChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProgramEmployeeChanged_ProgramEmployeePK_ChangeDatetime] ON [dbo].[ProgramEmployeeChanged] ([ProgramEmployeePK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

CREATE TABLE [dbo].[JobFunctionChanged]
(
[JobFunctionChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobFunctionPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[JobTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JobFunctionChanged] ADD CONSTRAINT [PK_JobFunctionChanged] PRIMARY KEY CLUSTERED  ([JobFunctionChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_JobFunctionChanged_JobFunctionPK_ChangeDatetime] ON [dbo].[JobFunctionChanged] ([JobFunctionPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

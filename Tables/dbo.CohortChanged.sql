CREATE TABLE [dbo].[CohortChanged]
(
[CohortChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CohortPK] [int] NOT NULL,
[CohortName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CohortChanged] ADD CONSTRAINT [PK_CohortChanged] PRIMARY KEY CLUSTERED  ([CohortChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CohortChanged_CohortPK_ChangeDatetime] ON [dbo].[CohortChanged] ([CohortPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

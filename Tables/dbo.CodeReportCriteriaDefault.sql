CREATE TABLE [dbo].[CodeReportCriteriaDefault]
(
[CodeReportCriteriaDefaultPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeReportCriteriaDefault] ADD CONSTRAINT [PK_CodeReportCriteriaDefault] PRIMARY KEY CLUSTERED  ([CodeReportCriteriaDefaultPK]) ON [PRIMARY]
GO

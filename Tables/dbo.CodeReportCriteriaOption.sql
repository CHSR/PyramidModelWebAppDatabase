CREATE TABLE [dbo].[CodeReportCriteriaOption]
(
[CodeReportCriteriaOptionPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CanBeOptional] [bit] NOT NULL CONSTRAINT [DF_CodeReportCriteriaOption_CanBeOptional] DEFAULT ((0)),
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeReportCriteriaOption] ADD CONSTRAINT [PK_CodeReportCriteria] PRIMARY KEY CLUSTERED ([CodeReportCriteriaOptionPK]) ON [PRIMARY]
GO

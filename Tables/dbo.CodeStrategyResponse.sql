CREATE TABLE [dbo].[CodeStrategyResponse]
(
[CodeStrategyResponsePK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeStrategyResponse_Abbreviation] DEFAULT ('Abbr'),
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeStrategyResponse] ADD CONSTRAINT [PK_CodeStrategyResponse] PRIMARY KEY CLUSTERED  ([CodeStrategyResponsePK]) ON [PRIMARY]
GO

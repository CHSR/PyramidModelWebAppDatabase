CREATE TABLE [dbo].[CodeASQSEInterval]
(
[CodeASQSEIntervalPK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[IntervalMonth] [int] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeASQSEInterval] ADD CONSTRAINT [PK_CodeASQSEInterval] PRIMARY KEY CLUSTERED  ([CodeASQSEIntervalPK]) ON [PRIMARY]
GO

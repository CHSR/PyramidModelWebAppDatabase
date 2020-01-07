CREATE TABLE [dbo].[CodeCoachingLog]
(
[CodeCoachingLogPK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeCoachingLog] ADD CONSTRAINT [PK_CodeCoachingLog] PRIMARY KEY CLUSTERED  ([CodeCoachingLogPK]) ON [PRIMARY]
GO

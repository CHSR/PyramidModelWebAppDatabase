CREATE TABLE [dbo].[ScoreASQSE]
(
[ScoreASQSEPK] [int] NOT NULL,
[CutoffScore] [int] NOT NULL,
[MaxScore] [int] NOT NULL,
[MonitoringScoreStart] [int] NOT NULL,
[MonitoringScoreEnd] [int] NOT NULL,
[Version] [int] NOT NULL,
[IntervalCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScoreASQSE] ADD CONSTRAINT [PK_ScoreASQSE] PRIMARY KEY CLUSTERED  ([ScoreASQSEPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ScoreASQSE] ADD CONSTRAINT [FK_ScoreASQSE_CodeASQSEInterval] FOREIGN KEY ([IntervalCodeFK]) REFERENCES [dbo].[CodeASQSEInterval] ([CodeASQSEIntervalPK])
GO

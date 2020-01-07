SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/12/2019
-- Description:	This stored procedure returns the number of ASQSE
-- forms by the score type (above, matching, below)
-- =============================================
CREATE PROC [dbo].[spGetASQSEsByScoreType] 
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the count of the ASQSEs in each score type
    SELECT CASE WHEN a.TotalScore > sa.CutoffScore THEN 'Above Cutoff' 
				WHEN a.TotalScore >= sa.MonitoringScoreStart AND a.TotalScore <= sa.MonitoringScoreEnd THEN 'Monitor'
				WHEN a.TotalScore >= 0 AND a.TotalScore < sa.MonitoringScoreStart THEN 'Well Below' 
				ELSE 'Error!' END ScoreType, 
			COUNT(a.ASQSEPK) NumASQSEs 
	FROM dbo.ASQSE a 
	INNER JOIN dbo.ScoreASQSE sa ON sa.IntervalCodeFK = a.IntervalCodeFK AND sa.Version = a.Version
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON a.ProgramFK = ssti.ListItem
	WHERE a.FormDate BETWEEN @StartDate AND @EndDate
	GROUP BY CASE WHEN a.TotalScore > sa.CutoffScore THEN 'Above Cutoff' 
					WHEN a.TotalScore >= sa.MonitoringScoreStart AND a.TotalScore <= sa.MonitoringScoreEnd THEN 'Monitor'
					WHEN a.TotalScore >= 0 AND a.TotalScore < sa.MonitoringScoreStart THEN 'Well Below' 
					ELSE 'Error!' END
END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/13/2022
-- Description:	This stored procedure returns the necessary information for the
-- CWLT BOQ section of the Community Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspCWLTDataDump_BOQs]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT boqc.BenchmarkOfQualityCWLTPK,
           boqc.Creator,
           boqc.CreateDate,
           boqc.Editor,
           boqc.EditDate,
           boqc.FormDate,
           CASE WHEN boqc.Indicator1 = 0 THEN 'Not In Place' WHEN boqc.Indicator1 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator1 = 2 THEN 'In Place' ELSE 'Error!' END Indicator1,
           CASE WHEN boqc.Indicator2 = 0 THEN 'Not In Place' WHEN boqc.Indicator2 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator2 = 2 THEN 'In Place' ELSE 'Error!' END Indicator2,
           CASE WHEN boqc.Indicator3 = 0 THEN 'Not In Place' WHEN boqc.Indicator3 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator3 = 2 THEN 'In Place' ELSE 'Error!' END Indicator3,
           CASE WHEN boqc.Indicator4 = 0 THEN 'Not In Place' WHEN boqc.Indicator4 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator4 = 2 THEN 'In Place' ELSE 'Error!' END Indicator4,
           CASE WHEN boqc.Indicator5 = 0 THEN 'Not In Place' WHEN boqc.Indicator5 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator5 = 2 THEN 'In Place' ELSE 'Error!' END Indicator5,
           CASE WHEN boqc.Indicator6 = 0 THEN 'Not In Place' WHEN boqc.Indicator6 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator6 = 2 THEN 'In Place' ELSE 'Error!' END Indicator6,
           CASE WHEN boqc.Indicator7 = 0 THEN 'Not In Place' WHEN boqc.Indicator7 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator7 = 2 THEN 'In Place' ELSE 'Error!' END Indicator7,
           CASE WHEN boqc.Indicator8 = 0 THEN 'Not In Place' WHEN boqc.Indicator8 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator8 = 2 THEN 'In Place' ELSE 'Error!' END Indicator8,
           CASE WHEN boqc.Indicator9 = 0 THEN 'Not In Place' WHEN boqc.Indicator9 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator9 = 2 THEN 'In Place' ELSE 'Error!' END Indicator9,
           CASE WHEN boqc.Indicator10 = 0 THEN 'Not In Place' WHEN boqc.Indicator10 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator10 = 2 THEN 'In Place' ELSE 'Error!' END Indicator10,
           CASE WHEN boqc.Indicator11 = 0 THEN 'Not In Place' WHEN boqc.Indicator11 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator11 = 2 THEN 'In Place' ELSE 'Error!' END Indicator11,
           CASE WHEN boqc.Indicator12 = 0 THEN 'Not In Place' WHEN boqc.Indicator12 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator12 = 2 THEN 'In Place' ELSE 'Error!' END Indicator12,
           CASE WHEN boqc.Indicator13 = 0 THEN 'Not In Place' WHEN boqc.Indicator13 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator13 = 2 THEN 'In Place' ELSE 'Error!' END Indicator13,
           CASE WHEN boqc.Indicator14 = 0 THEN 'Not In Place' WHEN boqc.Indicator14 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator14 = 2 THEN 'In Place' ELSE 'Error!' END Indicator14,
           CASE WHEN boqc.Indicator15 = 0 THEN 'Not In Place' WHEN boqc.Indicator15 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator15 = 2 THEN 'In Place' ELSE 'Error!' END Indicator15,
           CASE WHEN boqc.Indicator16 = 0 THEN 'Not In Place' WHEN boqc.Indicator16 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator16 = 2 THEN 'In Place' ELSE 'Error!' END Indicator16,
           CASE WHEN boqc.Indicator17 = 0 THEN 'Not In Place' WHEN boqc.Indicator17 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator17 = 2 THEN 'In Place' WHEN boqc.Indicator17 = 99 THEN 'NA' ELSE 'Error!' END Indicator17,
           CASE WHEN boqc.Indicator18 = 0 THEN 'Not In Place' WHEN boqc.Indicator18 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator18 = 2 THEN 'In Place' WHEN boqc.Indicator18 = 99 THEN 'NA' ELSE 'Error!' END Indicator18,
           CASE WHEN boqc.Indicator19 = 0 THEN 'Not In Place' WHEN boqc.Indicator19 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator19 = 2 THEN 'In Place' WHEN boqc.Indicator19 = 99 THEN 'NA' ELSE 'Error!' END Indicator19,
           CASE WHEN boqc.Indicator20 = 0 THEN 'Not In Place' WHEN boqc.Indicator20 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator20 = 2 THEN 'In Place' WHEN boqc.Indicator20 = 99 THEN 'NA' ELSE 'Error!' END Indicator20,
           CASE WHEN boqc.Indicator21 = 0 THEN 'Not In Place' WHEN boqc.Indicator21 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator21 = 2 THEN 'In Place' ELSE 'Error!' END Indicator21,
           CASE WHEN boqc.Indicator22 = 0 THEN 'Not In Place' WHEN boqc.Indicator22 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator22 = 2 THEN 'In Place' ELSE 'Error!' END Indicator22,
           CASE WHEN boqc.Indicator23 = 0 THEN 'Not In Place' WHEN boqc.Indicator23 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator23 = 2 THEN 'In Place' ELSE 'Error!' END Indicator23,
           CASE WHEN boqc.Indicator24 = 0 THEN 'Not In Place' WHEN boqc.Indicator24 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator24 = 2 THEN 'In Place' ELSE 'Error!' END Indicator24,
           CASE WHEN boqc.Indicator25 = 0 THEN 'Not In Place' WHEN boqc.Indicator25 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator25 = 2 THEN 'In Place' ELSE 'Error!' END Indicator25,
           CASE WHEN boqc.Indicator26 = 0 THEN 'Not In Place' WHEN boqc.Indicator26 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator26 = 2 THEN 'In Place' ELSE 'Error!' END Indicator26,
           CASE WHEN boqc.Indicator27 = 0 THEN 'Not In Place' WHEN boqc.Indicator27 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator27 = 2 THEN 'In Place' ELSE 'Error!' END Indicator27,
           CASE WHEN boqc.Indicator28 = 0 THEN 'Not In Place' WHEN boqc.Indicator28 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator28 = 2 THEN 'In Place' ELSE 'Error!' END Indicator28,
           CASE WHEN boqc.Indicator29 = 0 THEN 'Not In Place' WHEN boqc.Indicator29 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator29 = 2 THEN 'In Place' ELSE 'Error!' END Indicator29,
           CASE WHEN boqc.Indicator30 = 0 THEN 'Not In Place' WHEN boqc.Indicator30 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator30 = 2 THEN 'In Place' ELSE 'Error!' END Indicator30,
           CASE WHEN boqc.Indicator31 = 0 THEN 'Not In Place' WHEN boqc.Indicator31 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator31 = 2 THEN 'In Place' ELSE 'Error!' END Indicator31,
           CASE WHEN boqc.Indicator32 = 0 THEN 'Not In Place' WHEN boqc.Indicator32 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator32 = 2 THEN 'In Place' ELSE 'Error!' END Indicator32,
           CASE WHEN boqc.Indicator33 = 0 THEN 'Not In Place' WHEN boqc.Indicator33 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator33 = 2 THEN 'In Place' ELSE 'Error!' END Indicator33,
           CASE WHEN boqc.Indicator34 = 0 THEN 'Not In Place' WHEN boqc.Indicator34 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator34 = 2 THEN 'In Place' ELSE 'Error!' END Indicator34,
           CASE WHEN boqc.Indicator35 = 0 THEN 'Not In Place' WHEN boqc.Indicator35 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator35 = 2 THEN 'In Place' ELSE 'Error!' END Indicator35,
           CASE WHEN boqc.Indicator36 = 0 THEN 'Not In Place' WHEN boqc.Indicator36 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator36 = 2 THEN 'In Place' ELSE 'Error!' END Indicator36,
           CASE WHEN boqc.Indicator37 = 0 THEN 'Not In Place' WHEN boqc.Indicator37 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator37 = 2 THEN 'In Place' ELSE 'Error!' END Indicator37,
           CASE WHEN boqc.Indicator38 = 0 THEN 'Not In Place' WHEN boqc.Indicator38 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator38 = 2 THEN 'In Place' ELSE 'Error!' END Indicator38,
           CASE WHEN boqc.Indicator39 = 0 THEN 'Not In Place' WHEN boqc.Indicator39 = 1 THEN 'Needs Improvement' WHEN boqc.Indicator39 = 2 THEN 'In Place' ELSE 'Error!' END Indicator39,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.BenchmarkOfQualityCWLT boqc
		INNER JOIN dbo.Hub h
			ON h.HubPK = boqc.HubFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = h.StateFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = h.HubPK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
			AND boqc.FormDate BETWEEN @StartDate AND @EndDate;

END;
GO

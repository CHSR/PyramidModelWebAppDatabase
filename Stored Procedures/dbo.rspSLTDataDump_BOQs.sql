SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- SLT BOQ section of the State Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspSLTDataDump_BOQs]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT boqs.BenchmarkOfQualitySLTPK,
           boqs.Creator,
           boqs.CreateDate,
           boqs.Editor,
           boqs.EditDate,
           boqs.FormDate,
           CASE WHEN boqs.Indicator1 = 0 THEN 'Not In Place' WHEN boqs.Indicator1 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator1 = 2 THEN 'In Place' ELSE 'Error!' END Indicator1,
           CASE WHEN boqs.Indicator2 = 0 THEN 'Not In Place' WHEN boqs.Indicator2 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator2 = 2 THEN 'In Place' ELSE 'Error!' END Indicator2,
           CASE WHEN boqs.Indicator3 = 0 THEN 'Not In Place' WHEN boqs.Indicator3 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator3 = 2 THEN 'In Place' ELSE 'Error!' END Indicator3,
           CASE WHEN boqs.Indicator4 = 0 THEN 'Not In Place' WHEN boqs.Indicator4 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator4 = 2 THEN 'In Place' ELSE 'Error!' END Indicator4,
           CASE WHEN boqs.Indicator5 = 0 THEN 'Not In Place' WHEN boqs.Indicator5 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator5 = 2 THEN 'In Place' ELSE 'Error!' END Indicator5,
           CASE WHEN boqs.Indicator6 = 0 THEN 'Not In Place' WHEN boqs.Indicator6 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator6 = 2 THEN 'In Place' ELSE 'Error!' END Indicator6,
           CASE WHEN boqs.Indicator7 = 0 THEN 'Not In Place' WHEN boqs.Indicator7 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator7 = 2 THEN 'In Place' ELSE 'Error!' END Indicator7,
           CASE WHEN boqs.Indicator8 = 0 THEN 'Not In Place' WHEN boqs.Indicator8 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator8 = 2 THEN 'In Place' ELSE 'Error!' END Indicator8,
           CASE WHEN boqs.Indicator9 = 0 THEN 'Not In Place' WHEN boqs.Indicator9 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator9 = 2 THEN 'In Place' ELSE 'Error!' END Indicator9,
           CASE WHEN boqs.Indicator10 = 0 THEN 'Not In Place' WHEN boqs.Indicator10 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator10 = 2 THEN 'In Place' ELSE 'Error!' END Indicator10,
           CASE WHEN boqs.Indicator11 = 0 THEN 'Not In Place' WHEN boqs.Indicator11 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator11 = 2 THEN 'In Place' ELSE 'Error!' END Indicator11,
           CASE WHEN boqs.Indicator12 = 0 THEN 'Not In Place' WHEN boqs.Indicator12 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator12 = 2 THEN 'In Place' ELSE 'Error!' END Indicator12,
           CASE WHEN boqs.Indicator13 = 0 THEN 'Not In Place' WHEN boqs.Indicator13 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator13 = 2 THEN 'In Place' ELSE 'Error!' END Indicator13,
           CASE WHEN boqs.Indicator14 = 0 THEN 'Not In Place' WHEN boqs.Indicator14 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator14 = 2 THEN 'In Place' ELSE 'Error!' END Indicator14,
           CASE WHEN boqs.Indicator15 = 0 THEN 'Not In Place' WHEN boqs.Indicator15 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator15 = 2 THEN 'In Place' ELSE 'Error!' END Indicator15,
           CASE WHEN boqs.Indicator16 = 0 THEN 'Not In Place' WHEN boqs.Indicator16 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator16 = 2 THEN 'In Place' ELSE 'Error!' END Indicator16,
           CASE WHEN boqs.Indicator17 = 0 THEN 'Not In Place' WHEN boqs.Indicator17 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator17 = 2 THEN 'In Place' ELSE 'Error!' END Indicator17,
           CASE WHEN boqs.Indicator18 = 0 THEN 'Not In Place' WHEN boqs.Indicator18 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator18 = 2 THEN 'In Place' ELSE 'Error!' END Indicator18,
           CASE WHEN boqs.Indicator19 = 0 THEN 'Not In Place' WHEN boqs.Indicator19 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator19 = 2 THEN 'In Place' ELSE 'Error!' END Indicator19,
           CASE WHEN boqs.Indicator20 = 0 THEN 'Not In Place' WHEN boqs.Indicator20 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator20 = 2 THEN 'In Place' ELSE 'Error!' END Indicator20,
           CASE WHEN boqs.Indicator21 = 0 THEN 'Not In Place' WHEN boqs.Indicator21 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator21 = 2 THEN 'In Place' ELSE 'Error!' END Indicator21,
           CASE WHEN boqs.Indicator22 = 0 THEN 'Not In Place' WHEN boqs.Indicator22 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator22 = 2 THEN 'In Place' ELSE 'Error!' END Indicator22,
           CASE WHEN boqs.Indicator23 = 0 THEN 'Not In Place' WHEN boqs.Indicator23 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator23 = 2 THEN 'In Place' ELSE 'Error!' END Indicator23,
           CASE WHEN boqs.Indicator24 = 0 THEN 'Not In Place' WHEN boqs.Indicator24 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator24 = 2 THEN 'In Place' ELSE 'Error!' END Indicator24,
           CASE WHEN boqs.Indicator25 = 0 THEN 'Not In Place' WHEN boqs.Indicator25 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator25 = 2 THEN 'In Place' ELSE 'Error!' END Indicator25,
           CASE WHEN boqs.Indicator26 = 0 THEN 'Not In Place' WHEN boqs.Indicator26 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator26 = 2 THEN 'In Place' ELSE 'Error!' END Indicator26,
           CASE WHEN boqs.Indicator27 = 0 THEN 'Not In Place' WHEN boqs.Indicator27 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator27 = 2 THEN 'In Place' ELSE 'Error!' END Indicator27,
           CASE WHEN boqs.Indicator28 = 0 THEN 'Not In Place' WHEN boqs.Indicator28 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator28 = 2 THEN 'In Place' ELSE 'Error!' END Indicator28,
           CASE WHEN boqs.Indicator29 = 0 THEN 'Not In Place' WHEN boqs.Indicator29 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator29 = 2 THEN 'In Place' ELSE 'Error!' END Indicator29,
           CASE WHEN boqs.Indicator30 = 0 THEN 'Not In Place' WHEN boqs.Indicator30 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator30 = 2 THEN 'In Place' ELSE 'Error!' END Indicator30,
           CASE WHEN boqs.Indicator31 = 0 THEN 'Not In Place' WHEN boqs.Indicator31 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator31 = 2 THEN 'In Place' ELSE 'Error!' END Indicator31,
           CASE WHEN boqs.Indicator32 = 0 THEN 'Not In Place' WHEN boqs.Indicator32 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator32 = 2 THEN 'In Place' ELSE 'Error!' END Indicator32,
           CASE WHEN boqs.Indicator33 = 0 THEN 'Not In Place' WHEN boqs.Indicator33 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator33 = 2 THEN 'In Place' ELSE 'Error!' END Indicator33,
           CASE WHEN boqs.Indicator34 = 0 THEN 'Not In Place' WHEN boqs.Indicator34 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator34 = 2 THEN 'In Place' ELSE 'Error!' END Indicator34,
           CASE WHEN boqs.Indicator35 = 0 THEN 'Not In Place' WHEN boqs.Indicator35 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator35 = 2 THEN 'In Place' ELSE 'Error!' END Indicator35,
           CASE WHEN boqs.Indicator36 = 0 THEN 'Not In Place' WHEN boqs.Indicator36 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator36 = 2 THEN 'In Place' ELSE 'Error!' END Indicator36,
           CASE WHEN boqs.Indicator37 = 0 THEN 'Not In Place' WHEN boqs.Indicator37 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator37 = 2 THEN 'In Place' ELSE 'Error!' END Indicator37,
           CASE WHEN boqs.Indicator38 = 0 THEN 'Not In Place' WHEN boqs.Indicator38 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator38 = 2 THEN 'In Place' ELSE 'Error!' END Indicator38,
           CASE WHEN boqs.Indicator39 = 0 THEN 'Not In Place' WHEN boqs.Indicator39 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator39 = 2 THEN 'In Place' ELSE 'Error!' END Indicator39,
           CASE WHEN boqs.Indicator40 = 0 THEN 'Not In Place' WHEN boqs.Indicator40 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator40 = 2 THEN 'In Place' ELSE 'Error!' END Indicator40,
           CASE WHEN boqs.Indicator41 = 0 THEN 'Not In Place' WHEN boqs.Indicator41 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator41 = 2 THEN 'In Place' ELSE 'Error!' END Indicator41,
		   CASE WHEN boqs.Indicator42 = 0 THEN 'Not In Place' WHEN boqs.Indicator42 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator42 = 2 THEN 'In Place' ELSE 'Error!' END Indicator42,
		   CASE WHEN boqs.Indicator43 = 0 THEN 'Not In Place' WHEN boqs.Indicator43 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator43 = 2 THEN 'In Place' ELSE 'Error!' END Indicator43,
		   CASE WHEN boqs.Indicator44 = 0 THEN 'Not In Place' WHEN boqs.Indicator44 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator44 = 2 THEN 'In Place' ELSE 'Error!' END Indicator44,
		   CASE WHEN boqs.Indicator45 = 0 THEN 'Not In Place' WHEN boqs.Indicator45 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator45 = 2 THEN 'In Place' ELSE 'Error!' END Indicator45,
		   CASE WHEN boqs.Indicator46 = 0 THEN 'Not In Place' WHEN boqs.Indicator46 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator46 = 2 THEN 'In Place' ELSE 'Error!' END Indicator46,
		   CASE WHEN boqs.Indicator47 = 0 THEN 'Not In Place' WHEN boqs.Indicator47 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator47 = 2 THEN 'In Place' ELSE 'Error!' END Indicator47,
		   CASE WHEN boqs.Indicator48 = 0 THEN 'Not In Place' WHEN boqs.Indicator48 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator48 = 2 THEN 'In Place' ELSE 'Error!' END Indicator48,
		   CASE WHEN boqs.Indicator49 = 0 THEN 'Not In Place' WHEN boqs.Indicator49 = 1 THEN 'Emerging/Needs Improvement' WHEN boqs.Indicator49 = 2 THEN 'In Place' ELSE 'Error!' END Indicator49,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.BenchmarkOfQualitySLT boqs
		INNER JOIN dbo.[State] s
			ON s.StatePK = boqs.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = boqs.StateFK
	WHERE boqs.FormDate BETWEEN @StartDate AND @EndDate;

END;
GO

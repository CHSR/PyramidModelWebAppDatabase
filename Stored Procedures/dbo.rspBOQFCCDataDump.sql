SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 09/07/2022
-- Description:	This stored procedure returns the necessary information for the
-- BOQFCC Data Dump report
-- =============================================
CREATE PROC [dbo].[rspBOQFCCDataDump]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT boqf.BenchmarkOfQualityfccPK,
		   boqf.Creator,
           boqf.CreateDate,
           boqf.Editor,
           boqf.EditDate,
           boqf.FormDate,
		   boqf.ProgramFK,
		   boqf.TeamMembers,
		   CASE WHEN boqf.Indicator1 = 0 THEN 'Not In Place' WHEN boqf.Indicator1 = 1 THEN 'Partially In Place' WHEN boqf.Indicator1 = 2 THEN 'In Place' WHEN boqf.Indicator1 = 99 THEN 'NA' ELSE 'Error!' END Indicator1,
           CASE WHEN boqf.Indicator2 = 0 THEN 'Not In Place' WHEN boqf.Indicator2 = 1 THEN 'Partially In Place' WHEN boqf.Indicator2 = 2 THEN 'In Place' WHEN boqf.Indicator2 = 99 THEN 'NA' ELSE 'Error!' END Indicator2,
           CASE WHEN boqf.Indicator3 = 0 THEN 'Not In Place' WHEN boqf.Indicator3 = 1 THEN 'Partially In Place' WHEN boqf.Indicator3 = 2 THEN 'In Place' WHEN boqf.Indicator3 = 99 THEN 'NA' ELSE 'Error!' END Indicator3,
           CASE WHEN boqf.Indicator4 = 0 THEN 'Not In Place' WHEN boqf.Indicator4 = 1 THEN 'Partially In Place' WHEN boqf.Indicator4 = 2 THEN 'In Place' WHEN boqf.Indicator4 = 99 THEN 'NA' ELSE 'Error!' END Indicator4,
           CASE WHEN boqf.Indicator5 = 0 THEN 'Not In Place' WHEN boqf.Indicator5 = 1 THEN 'Partially In Place' WHEN boqf.Indicator5 = 2 THEN 'In Place' WHEN boqf.Indicator5 = 99 THEN 'NA' ELSE 'Error!' END Indicator5,
           CASE WHEN boqf.Indicator6 = 0 THEN 'Not In Place' WHEN boqf.Indicator6 = 1 THEN 'Partially In Place' WHEN boqf.Indicator6 = 2 THEN 'In Place' WHEN boqf.Indicator6 = 99 THEN 'NA' ELSE 'Error!' END Indicator6,
           CASE WHEN boqf.Indicator7 = 0 THEN 'Not In Place' WHEN boqf.Indicator7 = 1 THEN 'Partially In Place' WHEN boqf.Indicator7 = 2 THEN 'In Place' WHEN boqf.Indicator7 = 99 THEN 'NA' ELSE 'Error!' END Indicator7,
           CASE WHEN boqf.Indicator8 = 0 THEN 'Not In Place' WHEN boqf.Indicator8 = 1 THEN 'Partially In Place' WHEN boqf.Indicator8 = 2 THEN 'In Place' WHEN boqf.Indicator8 = 99 THEN 'NA' ELSE 'Error!' END Indicator8,
           CASE WHEN boqf.Indicator9 = 0 THEN 'Not In Place' WHEN boqf.Indicator9 = 1 THEN 'Partially In Place' WHEN boqf.Indicator9 = 2 THEN 'In Place' WHEN boqf.Indicator9 = 99 THEN 'NA' ELSE 'Error!' END Indicator9,
           CASE WHEN boqf.Indicator10 = 0 THEN 'Not In Place' WHEN boqf.Indicator10 = 1 THEN 'Partially In Place' WHEN boqf.Indicator10 = 2 THEN 'In Place' WHEN boqf.Indicator10 = 99 THEN 'NA' ELSE 'Error!' END Indicator10,
           CASE WHEN boqf.Indicator11 = 0 THEN 'Not In Place' WHEN boqf.Indicator11 = 1 THEN 'Partially In Place' WHEN boqf.Indicator11 = 2 THEN 'In Place' WHEN boqf.Indicator11 = 99 THEN 'NA' ELSE 'Error!' END Indicator11,
           CASE WHEN boqf.Indicator12 = 0 THEN 'Not In Place' WHEN boqf.Indicator12 = 1 THEN 'Partially In Place' WHEN boqf.Indicator12 = 2 THEN 'In Place' WHEN boqf.Indicator12 = 99 THEN 'NA' ELSE 'Error!' END Indicator12,
           CASE WHEN boqf.Indicator13 = 0 THEN 'Not In Place' WHEN boqf.Indicator13 = 1 THEN 'Partially In Place' WHEN boqf.Indicator13 = 2 THEN 'In Place' WHEN boqf.Indicator13 = 99 THEN 'NA' ELSE 'Error!' END Indicator13,
           CASE WHEN boqf.Indicator14 = 0 THEN 'Not In Place' WHEN boqf.Indicator14 = 1 THEN 'Partially In Place' WHEN boqf.Indicator14 = 2 THEN 'In Place' WHEN boqf.Indicator14 = 99 THEN 'NA' ELSE 'Error!' END Indicator14,
           CASE WHEN boqf.Indicator15 = 0 THEN 'Not In Place' WHEN boqf.Indicator15 = 1 THEN 'Partially In Place' WHEN boqf.Indicator15 = 2 THEN 'In Place' WHEN boqf.Indicator15 = 99 THEN 'NA' ELSE 'Error!' END Indicator15,
           CASE WHEN boqf.Indicator16 = 0 THEN 'Not In Place' WHEN boqf.Indicator16 = 1 THEN 'Partially In Place' WHEN boqf.Indicator16 = 2 THEN 'In Place' WHEN boqf.Indicator16 = 99 THEN 'NA' ELSE 'Error!' END Indicator16,
           CASE WHEN boqf.Indicator17 = 0 THEN 'Not In Place' WHEN boqf.Indicator17 = 1 THEN 'Partially In Place' WHEN boqf.Indicator17 = 2 THEN 'In Place' WHEN boqf.Indicator17 = 99 THEN 'NA' ELSE 'Error!' END Indicator17,
           CASE WHEN boqf.Indicator18 = 0 THEN 'Not In Place' WHEN boqf.Indicator18 = 1 THEN 'Partially In Place' WHEN boqf.Indicator18 = 2 THEN 'In Place' WHEN boqf.Indicator18 = 99 THEN 'NA' ELSE 'Error!' END Indicator18,
           CASE WHEN boqf.Indicator19 = 0 THEN 'Not In Place' WHEN boqf.Indicator19 = 1 THEN 'Partially In Place' WHEN boqf.Indicator19 = 2 THEN 'In Place' WHEN boqf.Indicator19 = 99 THEN 'NA' ELSE 'Error!' END Indicator19,
           CASE WHEN boqf.Indicator20 = 0 THEN 'Not In Place' WHEN boqf.Indicator20 = 1 THEN 'Partially In Place' WHEN boqf.Indicator20 = 2 THEN 'In Place' WHEN boqf.Indicator20 = 99 THEN 'NA' ELSE 'Error!' END Indicator20,
           CASE WHEN boqf.Indicator21 = 0 THEN 'Not In Place' WHEN boqf.Indicator21 = 1 THEN 'Partially In Place' WHEN boqf.Indicator21 = 2 THEN 'In Place' WHEN boqf.Indicator21 = 99 THEN 'NA' ELSE 'Error!' END Indicator21,
           CASE WHEN boqf.Indicator22 = 0 THEN 'Not In Place' WHEN boqf.Indicator22 = 1 THEN 'Partially In Place' WHEN boqf.Indicator22 = 2 THEN 'In Place' WHEN boqf.Indicator22 = 99 THEN 'NA' ELSE 'Error!' END Indicator22,
           CASE WHEN boqf.Indicator23 = 0 THEN 'Not In Place' WHEN boqf.Indicator23 = 1 THEN 'Partially In Place' WHEN boqf.Indicator23 = 2 THEN 'In Place' WHEN boqf.Indicator23 = 99 THEN 'NA' ELSE 'Error!' END Indicator23,
           CASE WHEN boqf.Indicator24 = 0 THEN 'Not In Place' WHEN boqf.Indicator24 = 1 THEN 'Partially In Place' WHEN boqf.Indicator24 = 2 THEN 'In Place' WHEN boqf.Indicator24 = 99 THEN 'NA' ELSE 'Error!' END Indicator24,
           CASE WHEN boqf.Indicator25 = 0 THEN 'Not In Place' WHEN boqf.Indicator25 = 1 THEN 'Partially In Place' WHEN boqf.Indicator25 = 2 THEN 'In Place' WHEN boqf.Indicator25 = 99 THEN 'NA' ELSE 'Error!' END Indicator25,
           CASE WHEN boqf.Indicator26 = 0 THEN 'Not In Place' WHEN boqf.Indicator26 = 1 THEN 'Partially In Place' WHEN boqf.Indicator26 = 2 THEN 'In Place' WHEN boqf.Indicator26 = 99 THEN 'NA' ELSE 'Error!' END Indicator26,
           CASE WHEN boqf.Indicator27 = 0 THEN 'Not In Place' WHEN boqf.Indicator27 = 1 THEN 'Partially In Place' WHEN boqf.Indicator27 = 2 THEN 'In Place' WHEN boqf.Indicator27 = 99 THEN 'NA' ELSE 'Error!' END Indicator27,
           CASE WHEN boqf.Indicator28 = 0 THEN 'Not In Place' WHEN boqf.Indicator28 = 1 THEN 'Partially In Place' WHEN boqf.Indicator28 = 2 THEN 'In Place' WHEN boqf.Indicator28 = 99 THEN 'NA' ELSE 'Error!' END Indicator28,
           CASE WHEN boqf.Indicator29 = 0 THEN 'Not In Place' WHEN boqf.Indicator29 = 1 THEN 'Partially In Place' WHEN boqf.Indicator29 = 2 THEN 'In Place' WHEN boqf.Indicator29 = 99 THEN 'NA' ELSE 'Error!' END Indicator29,
           CASE WHEN boqf.Indicator30 = 0 THEN 'Not In Place' WHEN boqf.Indicator30 = 1 THEN 'Partially In Place' WHEN boqf.Indicator30 = 2 THEN 'In Place' WHEN boqf.Indicator30 = 99 THEN 'NA' ELSE 'Error!' END Indicator30,
           CASE WHEN boqf.Indicator31 = 0 THEN 'Not In Place' WHEN boqf.Indicator31 = 1 THEN 'Partially In Place' WHEN boqf.Indicator31 = 2 THEN 'In Place' WHEN boqf.Indicator31 = 99 THEN 'NA' ELSE 'Error!' END Indicator31,
           CASE WHEN boqf.Indicator32 = 0 THEN 'Not In Place' WHEN boqf.Indicator32 = 1 THEN 'Partially In Place' WHEN boqf.Indicator32 = 2 THEN 'In Place' WHEN boqf.Indicator32 = 99 THEN 'NA' ELSE 'Error!' END Indicator32,
           CASE WHEN boqf.Indicator33 = 0 THEN 'Not In Place' WHEN boqf.Indicator33 = 1 THEN 'Partially In Place' WHEN boqf.Indicator33 = 2 THEN 'In Place' WHEN boqf.Indicator33 = 99 THEN 'NA' ELSE 'Error!' END Indicator33,
           CASE WHEN boqf.Indicator34 = 0 THEN 'Not In Place' WHEN boqf.Indicator34 = 1 THEN 'Partially In Place' WHEN boqf.Indicator34 = 2 THEN 'In Place' WHEN boqf.Indicator34 = 99 THEN 'NA' ELSE 'Error!' END Indicator34,
           CASE WHEN boqf.Indicator35 = 0 THEN 'Not In Place' WHEN boqf.Indicator35 = 1 THEN 'Partially In Place' WHEN boqf.Indicator35 = 2 THEN 'In Place' WHEN boqf.Indicator35 = 99 THEN 'NA' ELSE 'Error!' END Indicator35,
           CASE WHEN boqf.Indicator36 = 0 THEN 'Not In Place' WHEN boqf.Indicator36 = 1 THEN 'Partially In Place' WHEN boqf.Indicator36 = 2 THEN 'In Place' WHEN boqf.Indicator36 = 99 THEN 'NA' ELSE 'Error!' END Indicator36,
           CASE WHEN boqf.Indicator37 = 0 THEN 'Not In Place' WHEN boqf.Indicator37 = 1 THEN 'Partially In Place' WHEN boqf.Indicator37 = 2 THEN 'In Place' WHEN boqf.Indicator37 = 99 THEN 'NA' ELSE 'Error!' END Indicator37,
           CASE WHEN boqf.Indicator38 = 0 THEN 'Not In Place' WHEN boqf.Indicator38 = 1 THEN 'Partially In Place' WHEN boqf.Indicator38 = 2 THEN 'In Place' WHEN boqf.Indicator38 = 99 THEN 'NA' ELSE 'Error!' END Indicator38,
           CASE WHEN boqf.Indicator39 = 0 THEN 'Not In Place' WHEN boqf.Indicator39 = 1 THEN 'Partially In Place' WHEN boqf.Indicator39 = 2 THEN 'In Place' WHEN boqf.Indicator39 = 99 THEN 'NA' ELSE 'Error!' END Indicator39,
           CASE WHEN boqf.Indicator40 = 0 THEN 'Not In Place' WHEN boqf.Indicator40 = 1 THEN 'Partially In Place' WHEN boqf.Indicator40 = 2 THEN 'In Place' WHEN boqf.Indicator40 = 99 THEN 'NA' ELSE 'Error!' END Indicator40,
           CASE WHEN boqf.Indicator41 = 0 THEN 'Not In Place' WHEN boqf.Indicator41 = 1 THEN 'Partially In Place' WHEN boqf.Indicator41 = 2 THEN 'In Place' WHEN boqf.Indicator41 = 99 THEN 'NA' ELSE 'Error!' END Indicator41,
           CASE WHEN boqf.Indicator42 = 0 THEN 'Not In Place' WHEN boqf.Indicator42 = 1 THEN 'Partially In Place' WHEN boqf.Indicator42 = 2 THEN 'In Place' WHEN boqf.Indicator42 = 99 THEN 'NA' ELSE 'Error!' END Indicator42,
           CASE WHEN boqf.Indicator43 = 0 THEN 'Not In Place' WHEN boqf.Indicator43 = 1 THEN 'Partially In Place' WHEN boqf.Indicator43 = 2 THEN 'In Place' WHEN boqf.Indicator43 = 99 THEN 'NA' ELSE 'Error!' END Indicator43,
           CASE WHEN boqf.Indicator44 = 0 THEN 'Not In Place' WHEN boqf.Indicator44 = 1 THEN 'Partially In Place' WHEN boqf.Indicator44 = 2 THEN 'In Place' WHEN boqf.Indicator44 = 99 THEN 'NA' ELSE 'Error!' END Indicator44,
           CASE WHEN boqf.Indicator45 = 0 THEN 'Not In Place' WHEN boqf.Indicator45 = 1 THEN 'Partially In Place' WHEN boqf.Indicator45 = 2 THEN 'In Place' WHEN boqf.Indicator45 = 99 THEN 'NA' ELSE 'Error!' END Indicator45,
           CASE WHEN boqf.Indicator46 = 0 THEN 'Not In Place' WHEN boqf.Indicator46 = 1 THEN 'Partially In Place' WHEN boqf.Indicator46 = 2 THEN 'In Place' WHEN boqf.Indicator46 = 99 THEN 'NA' ELSE 'Error!' END Indicator46,
           CASE WHEN boqf.Indicator47 = 0 THEN 'Not In Place' WHEN boqf.Indicator47 = 1 THEN 'Partially In Place' WHEN boqf.Indicator47 = 2 THEN 'In Place' WHEN boqf.Indicator47 = 99 THEN 'NA' ELSE 'Error!' END Indicator47,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.BenchmarkOfQualityFCC boqf
        INNER JOIN dbo.Program p 
			ON p.ProgramPK = boqf.ProgramFK
        INNER JOIN dbo.[State] s 
			ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = boqf.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = p.HubFK
        LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList
            ON cohortList.ListItem = p.CohortFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR hubList.ListItem IS NOT NULL
              OR cohortList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
          AND boqf.FormDate BETWEEN @StartDate AND @EndDate
		  AND boqf.VersionNumber = 1
		  AND boqf.IsComplete = 1
	ORDER BY boqf.benchmarkofqualityfccpk;

END;

GO

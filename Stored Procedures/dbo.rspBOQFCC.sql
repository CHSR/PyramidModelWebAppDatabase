SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/06/2020
-- Description:	This stored procedure returns the necessary information for the
-- BOQFCC report
-- =============================================
CREATE PROC [dbo].[rspBOQFCC]
	@BenchmarkOfQualityFCCPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the BOQFCC information
    SELECT boqfcc.BenchmarkOfQualityFCCPK,
           boqfcc.FormDate,
           CASE WHEN boqfcc.Indicator1 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator1 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator1 = 2 THEN 'In Place' WHEN boqfcc.Indicator1 = 99 THEN 'NA' ELSE 'Error!' END Indicator1,
           CASE WHEN boqfcc.Indicator2 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator2 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator2 = 2 THEN 'In Place' WHEN boqfcc.Indicator2 = 99 THEN 'NA' ELSE 'Error!' END Indicator2,
           CASE WHEN boqfcc.Indicator3 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator3 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator3 = 2 THEN 'In Place' WHEN boqfcc.Indicator3 = 99 THEN 'NA' ELSE 'Error!' END Indicator3,
           CASE WHEN boqfcc.Indicator4 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator4 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator4 = 2 THEN 'In Place' WHEN boqfcc.Indicator4 = 99 THEN 'NA' ELSE 'Error!' END Indicator4,
           CASE WHEN boqfcc.Indicator5 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator5 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator5 = 2 THEN 'In Place' WHEN boqfcc.Indicator5 = 99 THEN 'NA' ELSE 'Error!' END Indicator5,
           CASE WHEN boqfcc.Indicator6 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator6 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator6 = 2 THEN 'In Place' WHEN boqfcc.Indicator6 = 99 THEN 'NA' ELSE 'Error!' END Indicator6,
           CASE WHEN boqfcc.Indicator7 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator7 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator7 = 2 THEN 'In Place' WHEN boqfcc.Indicator7 = 99 THEN 'NA' ELSE 'Error!' END Indicator7,
           CASE WHEN boqfcc.Indicator8 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator8 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator8 = 2 THEN 'In Place' WHEN boqfcc.Indicator8 = 99 THEN 'NA' ELSE 'Error!' END Indicator8,
           CASE WHEN boqfcc.Indicator9 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator9 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator9 = 2 THEN 'In Place' WHEN boqfcc.Indicator9 = 99 THEN 'NA' ELSE 'Error!' END Indicator9,
           CASE WHEN boqfcc.Indicator10 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator10 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator10 = 2 THEN 'In Place' WHEN boqfcc.Indicator10 = 99 THEN 'NA' ELSE 'Error!' END Indicator10,
           CASE WHEN boqfcc.Indicator11 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator11 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator11 = 2 THEN 'In Place' WHEN boqfcc.Indicator11 = 99 THEN 'NA' ELSE 'Error!' END Indicator11,
           CASE WHEN boqfcc.Indicator12 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator12 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator12 = 2 THEN 'In Place' WHEN boqfcc.Indicator12 = 99 THEN 'NA' ELSE 'Error!' END Indicator12,
           CASE WHEN boqfcc.Indicator13 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator13 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator13 = 2 THEN 'In Place' WHEN boqfcc.Indicator13 = 99 THEN 'NA' ELSE 'Error!' END Indicator13,
           CASE WHEN boqfcc.Indicator14 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator14 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator14 = 2 THEN 'In Place' WHEN boqfcc.Indicator14 = 99 THEN 'NA' ELSE 'Error!' END Indicator14,
           CASE WHEN boqfcc.Indicator15 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator15 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator15 = 2 THEN 'In Place' WHEN boqfcc.Indicator15 = 99 THEN 'NA' ELSE 'Error!' END Indicator15,
           CASE WHEN boqfcc.Indicator16 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator16 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator16 = 2 THEN 'In Place' WHEN boqfcc.Indicator16 = 99 THEN 'NA' ELSE 'Error!' END Indicator16,
           CASE WHEN boqfcc.Indicator17 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator17 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator17 = 2 THEN 'In Place' WHEN boqfcc.Indicator17 = 99 THEN 'NA' ELSE 'Error!' END Indicator17,
           CASE WHEN boqfcc.Indicator18 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator18 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator18 = 2 THEN 'In Place' WHEN boqfcc.Indicator18 = 99 THEN 'NA' ELSE 'Error!' END Indicator18,
           CASE WHEN boqfcc.Indicator19 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator19 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator19 = 2 THEN 'In Place' WHEN boqfcc.Indicator19 = 99 THEN 'NA' ELSE 'Error!' END Indicator19,
           CASE WHEN boqfcc.Indicator20 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator20 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator20 = 2 THEN 'In Place' WHEN boqfcc.Indicator20 = 99 THEN 'NA' ELSE 'Error!' END Indicator20,
           CASE WHEN boqfcc.Indicator21 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator21 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator21 = 2 THEN 'In Place' WHEN boqfcc.Indicator21 = 99 THEN 'NA' ELSE 'Error!' END Indicator21,
           CASE WHEN boqfcc.Indicator22 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator22 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator22 = 2 THEN 'In Place' WHEN boqfcc.Indicator22 = 99 THEN 'NA' ELSE 'Error!' END Indicator22,
           CASE WHEN boqfcc.Indicator23 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator23 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator23 = 2 THEN 'In Place' WHEN boqfcc.Indicator23 = 99 THEN 'NA' ELSE 'Error!' END Indicator23,
           CASE WHEN boqfcc.Indicator24 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator24 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator24 = 2 THEN 'In Place' WHEN boqfcc.Indicator24 = 99 THEN 'NA' ELSE 'Error!' END Indicator24,
           CASE WHEN boqfcc.Indicator25 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator25 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator25 = 2 THEN 'In Place' WHEN boqfcc.Indicator25 = 99 THEN 'NA' ELSE 'Error!' END Indicator25,
           CASE WHEN boqfcc.Indicator26 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator26 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator26 = 2 THEN 'In Place' WHEN boqfcc.Indicator26 = 99 THEN 'NA' ELSE 'Error!' END Indicator26,
           CASE WHEN boqfcc.Indicator27 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator27 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator27 = 2 THEN 'In Place' WHEN boqfcc.Indicator27 = 99 THEN 'NA' ELSE 'Error!' END Indicator27,
           CASE WHEN boqfcc.Indicator28 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator28 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator28 = 2 THEN 'In Place' WHEN boqfcc.Indicator28 = 99 THEN 'NA' ELSE 'Error!' END Indicator28,
           CASE WHEN boqfcc.Indicator29 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator29 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator29 = 2 THEN 'In Place' WHEN boqfcc.Indicator29 = 99 THEN 'NA' ELSE 'Error!' END Indicator29,
           CASE WHEN boqfcc.Indicator30 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator30 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator30 = 2 THEN 'In Place' WHEN boqfcc.Indicator30 = 99 THEN 'NA' ELSE 'Error!' END Indicator30,
           CASE WHEN boqfcc.Indicator31 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator31 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator31 = 2 THEN 'In Place' WHEN boqfcc.Indicator31 = 99 THEN 'NA' ELSE 'Error!' END Indicator31,
           CASE WHEN boqfcc.Indicator32 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator32 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator32 = 2 THEN 'In Place' WHEN boqfcc.Indicator32 = 99 THEN 'NA' ELSE 'Error!' END Indicator32,
           CASE WHEN boqfcc.Indicator33 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator33 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator33 = 2 THEN 'In Place' WHEN boqfcc.Indicator33 = 99 THEN 'NA' ELSE 'Error!' END Indicator33,
           CASE WHEN boqfcc.Indicator34 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator34 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator34 = 2 THEN 'In Place' WHEN boqfcc.Indicator34 = 99 THEN 'NA' ELSE 'Error!' END Indicator34,
           CASE WHEN boqfcc.Indicator35 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator35 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator35 = 2 THEN 'In Place' WHEN boqfcc.Indicator35 = 99 THEN 'NA' ELSE 'Error!' END Indicator35,
           CASE WHEN boqfcc.Indicator36 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator36 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator36 = 2 THEN 'In Place' WHEN boqfcc.Indicator36 = 99 THEN 'NA' ELSE 'Error!' END Indicator36,
           CASE WHEN boqfcc.Indicator37 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator37 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator37 = 2 THEN 'In Place' WHEN boqfcc.Indicator37 = 99 THEN 'NA' ELSE 'Error!' END Indicator37,
           CASE WHEN boqfcc.Indicator38 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator38 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator38 = 2 THEN 'In Place' WHEN boqfcc.Indicator38 = 99 THEN 'NA' ELSE 'Error!' END Indicator38,
           CASE WHEN boqfcc.Indicator39 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator39 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator39 = 2 THEN 'In Place' WHEN boqfcc.Indicator39 = 99 THEN 'NA' ELSE 'Error!' END Indicator39,
           CASE WHEN boqfcc.Indicator40 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator40 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator40 = 2 THEN 'In Place' WHEN boqfcc.Indicator40 = 99 THEN 'NA' ELSE 'Error!' END Indicator40,
           CASE WHEN boqfcc.Indicator41 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator41 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator41 = 2 THEN 'In Place' WHEN boqfcc.Indicator41 = 99 THEN 'NA' ELSE 'Error!' END Indicator41,
           CASE WHEN boqfcc.Indicator42 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator42 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator42 = 2 THEN 'In Place' WHEN boqfcc.Indicator42 = 99 THEN 'NA' ELSE 'Error!' END Indicator42,
           CASE WHEN boqfcc.Indicator43 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator43 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator43 = 2 THEN 'In Place' WHEN boqfcc.Indicator43 = 99 THEN 'NA' ELSE 'Error!' END Indicator43,
           CASE WHEN boqfcc.Indicator44 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator44 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator44 = 2 THEN 'In Place' WHEN boqfcc.Indicator44 = 99 THEN 'NA' ELSE 'Error!' END Indicator44,
           CASE WHEN boqfcc.Indicator45 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator45 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator45 = 2 THEN 'In Place' WHEN boqfcc.Indicator45 = 99 THEN 'NA' ELSE 'Error!' END Indicator45,
           CASE WHEN boqfcc.Indicator46 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator46 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator46 = 2 THEN 'In Place' WHEN boqfcc.Indicator46 = 99 THEN 'NA' ELSE 'Error!' END Indicator46,
           CASE WHEN boqfcc.Indicator47 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator47 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator47 = 2 THEN 'In Place' WHEN boqfcc.Indicator47 = 99 THEN 'NA' ELSE 'Error!' END Indicator47,
           boqfcc.TeamMembers,
           p.Location ProgramLocation,
           p.ProgramName
    FROM dbo.BenchmarkOfQualityFCC boqfcc
    INNER JOIN dbo.Program p ON p.ProgramPK = boqfcc.ProgramFK
    WHERE boqfcc.BenchmarkOfQualityFCCPK = @BenchmarkOfQualityFCCPK;

END;
GO

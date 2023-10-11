SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/17/2023
-- Description:	This stored procedure returns the necessary information for the
-- BOQFCC V2 report
-- =============================================
CREATE PROC [dbo].[rspBOQFCCV2]
	@BenchmarkOfQualityFCCPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the BOQFCC information
    SELECT boqfcc.BenchmarkOfQualityFCCPK,
           boqfcc.FormDate,
           CASE WHEN boqfcc.Indicator1 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator1 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator1 = 2 THEN 'In Place' ELSE NULL END Indicator1,
           CASE WHEN boqfcc.Indicator2 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator2 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator2 = 2 THEN 'In Place' ELSE NULL END Indicator2,
           CASE WHEN boqfcc.Indicator3 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator3 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator3 = 2 THEN 'In Place' ELSE NULL END Indicator3,
           CASE WHEN boqfcc.Indicator4 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator4 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator4 = 2 THEN 'In Place' ELSE NULL END Indicator4,
           CASE WHEN boqfcc.Indicator5 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator5 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator5 = 2 THEN 'In Place' ELSE NULL END Indicator5,
           CASE WHEN boqfcc.Indicator6 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator6 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator6 = 2 THEN 'In Place' ELSE NULL END Indicator6,
           CASE WHEN boqfcc.Indicator7 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator7 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator7 = 2 THEN 'In Place' ELSE NULL END Indicator7,
           CASE WHEN boqfcc.Indicator8 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator8 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator8 = 2 THEN 'In Place' ELSE NULL END Indicator8,
           CASE WHEN boqfcc.Indicator9 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator9 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator9 = 2 THEN 'In Place' ELSE NULL END Indicator9,
           CASE WHEN boqfcc.Indicator10 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator10 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator10 = 2 THEN 'In Place' ELSE NULL END Indicator10,
           CASE WHEN boqfcc.Indicator11 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator11 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator11 = 2 THEN 'In Place' ELSE NULL END Indicator11,
           CASE WHEN boqfcc.Indicator12 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator12 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator12 = 2 THEN 'In Place' ELSE NULL END Indicator12,
           CASE WHEN boqfcc.Indicator13 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator13 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator13 = 2 THEN 'In Place' ELSE NULL END Indicator13,
           CASE WHEN boqfcc.Indicator14 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator14 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator14 = 2 THEN 'In Place' ELSE NULL END Indicator14,
           CASE WHEN boqfcc.Indicator15 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator15 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator15 = 2 THEN 'In Place' ELSE NULL END Indicator15,
           CASE WHEN boqfcc.Indicator16 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator16 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator16 = 2 THEN 'In Place' ELSE NULL END Indicator16,
           CASE WHEN boqfcc.Indicator17 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator17 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator17 = 2 THEN 'In Place' ELSE NULL END Indicator17,
           CASE WHEN boqfcc.Indicator18 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator18 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator18 = 2 THEN 'In Place' ELSE NULL END Indicator18,
           CASE WHEN boqfcc.Indicator19 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator19 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator19 = 2 THEN 'In Place' ELSE NULL END Indicator19,
           CASE WHEN boqfcc.Indicator20 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator20 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator20 = 2 THEN 'In Place' ELSE NULL END Indicator20,
           CASE WHEN boqfcc.Indicator21 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator21 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator21 = 2 THEN 'In Place' ELSE NULL END Indicator21,
           CASE WHEN boqfcc.Indicator22 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator22 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator22 = 2 THEN 'In Place' ELSE NULL END Indicator22,
           CASE WHEN boqfcc.Indicator23 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator23 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator23 = 2 THEN 'In Place' ELSE NULL END Indicator23,
           CASE WHEN boqfcc.Indicator24 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator24 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator24 = 2 THEN 'In Place' ELSE NULL END Indicator24,
           CASE WHEN boqfcc.Indicator25 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator25 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator25 = 2 THEN 'In Place' ELSE NULL END Indicator25,
           CASE WHEN boqfcc.Indicator26 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator26 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator26 = 2 THEN 'In Place' ELSE NULL END Indicator26,
           CASE WHEN boqfcc.Indicator27 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator27 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator27 = 2 THEN 'In Place' ELSE NULL END Indicator27,
           CASE WHEN boqfcc.Indicator28 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator28 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator28 = 2 THEN 'In Place' ELSE NULL END Indicator28,
           CASE WHEN boqfcc.Indicator29 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator29 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator29 = 2 THEN 'In Place' ELSE NULL END Indicator29,
           CASE WHEN boqfcc.Indicator30 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator30 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator30 = 2 THEN 'In Place' ELSE NULL END Indicator30,
           CASE WHEN boqfcc.Indicator31 = 0 THEN 'Not In Place' WHEN boqfcc.Indicator31 = 1 THEN 'Partially In Place' WHEN boqfcc.Indicator31 = 2 THEN 'In Place' ELSE NULL END Indicator31,
           boqfcc.TeamMembers,
           p.[Location] ProgramLocation,
           p.ProgramName
    FROM dbo.BenchmarkOfQualityFCC boqfcc
		INNER JOIN dbo.Program p ON p.ProgramPK = boqfcc.ProgramFK
    WHERE boqfcc.BenchmarkOfQualityFCCPK = @BenchmarkOfQualityFCCPK;

END;
GO

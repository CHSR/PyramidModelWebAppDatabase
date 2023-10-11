SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/05/2020
-- Description:	This stored procedure returns the necessary information for the
-- BOQ report
-- =============================================
CREATE PROC [dbo].[rspBOQ] 
	@BenchmarkOfQualityPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the BOQ information
    SELECT boq.BenchmarkOfQualityPK,
           boq.FormDate,
           CASE WHEN boq.Indicator1 = 0 THEN 'Not In Place' WHEN boq.Indicator1 = 1 THEN 'Partially In Place' WHEN boq.Indicator1 = 2 THEN 'In Place' ELSE 'Error!' END Indicator1,
           CASE WHEN boq.Indicator2 = 0 THEN 'Not In Place' WHEN boq.Indicator2 = 1 THEN 'Partially In Place' WHEN boq.Indicator2 = 2 THEN 'In Place' ELSE 'Error!' END Indicator2,
           CASE WHEN boq.Indicator3 = 0 THEN 'Not In Place' WHEN boq.Indicator3 = 1 THEN 'Partially In Place' WHEN boq.Indicator3 = 2 THEN 'In Place' ELSE 'Error!' END Indicator3,
           CASE WHEN boq.Indicator4 = 0 THEN 'Not In Place' WHEN boq.Indicator4 = 1 THEN 'Partially In Place' WHEN boq.Indicator4 = 2 THEN 'In Place' ELSE 'Error!' END Indicator4,
           CASE WHEN boq.Indicator5 = 0 THEN 'Not In Place' WHEN boq.Indicator5 = 1 THEN 'Partially In Place' WHEN boq.Indicator5 = 2 THEN 'In Place' ELSE 'Error!' END Indicator5,
           CASE WHEN boq.Indicator6 = 0 THEN 'Not In Place' WHEN boq.Indicator6 = 1 THEN 'Partially In Place' WHEN boq.Indicator6 = 2 THEN 'In Place' ELSE 'Error!' END Indicator6,
           CASE WHEN boq.Indicator7 = 0 THEN 'Not In Place' WHEN boq.Indicator7 = 1 THEN 'Partially In Place' WHEN boq.Indicator7 = 2 THEN 'In Place' ELSE 'Error!' END Indicator7,
           CASE WHEN boq.Indicator8 = 0 THEN 'Not In Place' WHEN boq.Indicator8 = 1 THEN 'Partially In Place' WHEN boq.Indicator8 = 2 THEN 'In Place' ELSE 'Error!' END Indicator8,
           CASE WHEN boq.Indicator9 = 0 THEN 'Not In Place' WHEN boq.Indicator9 = 1 THEN 'Partially In Place' WHEN boq.Indicator9 = 2 THEN 'In Place' ELSE 'Error!' END Indicator9,
           CASE WHEN boq.Indicator10 = 0 THEN 'Not In Place' WHEN boq.Indicator10 = 1 THEN 'Partially In Place' WHEN boq.Indicator10 = 2 THEN 'In Place' ELSE 'Error!' END Indicator10,
           CASE WHEN boq.Indicator11 = 0 THEN 'Not In Place' WHEN boq.Indicator11 = 1 THEN 'Partially In Place' WHEN boq.Indicator11 = 2 THEN 'In Place' ELSE 'Error!' END Indicator11,
           CASE WHEN boq.Indicator12 = 0 THEN 'Not In Place' WHEN boq.Indicator12 = 1 THEN 'Partially In Place' WHEN boq.Indicator12 = 2 THEN 'In Place' ELSE 'Error!' END Indicator12,
           CASE WHEN boq.Indicator13 = 0 THEN 'Not In Place' WHEN boq.Indicator13 = 1 THEN 'Partially In Place' WHEN boq.Indicator13 = 2 THEN 'In Place' ELSE 'Error!' END Indicator13,
           CASE WHEN boq.Indicator14 = 0 THEN 'Not In Place' WHEN boq.Indicator14 = 1 THEN 'Partially In Place' WHEN boq.Indicator14 = 2 THEN 'In Place' ELSE 'Error!' END Indicator14,
           CASE WHEN boq.Indicator15 = 0 THEN 'Not In Place' WHEN boq.Indicator15 = 1 THEN 'Partially In Place' WHEN boq.Indicator15 = 2 THEN 'In Place' ELSE 'Error!' END Indicator15,
           CASE WHEN boq.Indicator16 = 0 THEN 'Not In Place' WHEN boq.Indicator16 = 1 THEN 'Partially In Place' WHEN boq.Indicator16 = 2 THEN 'In Place' ELSE 'Error!' END Indicator16,
           CASE WHEN boq.Indicator17 = 0 THEN 'Not In Place' WHEN boq.Indicator17 = 1 THEN 'Partially In Place' WHEN boq.Indicator17 = 2 THEN 'In Place' ELSE 'Error!' END Indicator17,
           CASE WHEN boq.Indicator18 = 0 THEN 'Not In Place' WHEN boq.Indicator18 = 1 THEN 'Partially In Place' WHEN boq.Indicator18 = 2 THEN 'In Place' ELSE 'Error!' END Indicator18,
           CASE WHEN boq.Indicator19 = 0 THEN 'Not In Place' WHEN boq.Indicator19 = 1 THEN 'Partially In Place' WHEN boq.Indicator19 = 2 THEN 'In Place' ELSE 'Error!' END Indicator19,
           CASE WHEN boq.Indicator20 = 0 THEN 'Not In Place' WHEN boq.Indicator20 = 1 THEN 'Partially In Place' WHEN boq.Indicator20 = 2 THEN 'In Place' ELSE 'Error!' END Indicator20,
           CASE WHEN boq.Indicator21 = 0 THEN 'Not In Place' WHEN boq.Indicator21 = 1 THEN 'Partially In Place' WHEN boq.Indicator21 = 2 THEN 'In Place' ELSE 'Error!' END Indicator21,
           CASE WHEN boq.Indicator22 = 0 THEN 'Not In Place' WHEN boq.Indicator22 = 1 THEN 'Partially In Place' WHEN boq.Indicator22 = 2 THEN 'In Place' ELSE 'Error!' END Indicator22,
           CASE WHEN boq.Indicator23 = 0 THEN 'Not In Place' WHEN boq.Indicator23 = 1 THEN 'Partially In Place' WHEN boq.Indicator23 = 2 THEN 'In Place' ELSE 'Error!' END Indicator23,
           CASE WHEN boq.Indicator24 = 0 THEN 'Not In Place' WHEN boq.Indicator24 = 1 THEN 'Partially In Place' WHEN boq.Indicator24 = 2 THEN 'In Place' ELSE 'Error!' END Indicator24,
           CASE WHEN boq.Indicator25 = 0 THEN 'Not In Place' WHEN boq.Indicator25 = 1 THEN 'Partially In Place' WHEN boq.Indicator25 = 2 THEN 'In Place' ELSE 'Error!' END Indicator25,
           CASE WHEN boq.Indicator26 = 0 THEN 'Not In Place' WHEN boq.Indicator26 = 1 THEN 'Partially In Place' WHEN boq.Indicator26 = 2 THEN 'In Place' ELSE 'Error!' END Indicator26,
           CASE WHEN boq.Indicator27 = 0 THEN 'Not In Place' WHEN boq.Indicator27 = 1 THEN 'Partially In Place' WHEN boq.Indicator27 = 2 THEN 'In Place' ELSE 'Error!' END Indicator27,
           CASE WHEN boq.Indicator28 = 0 THEN 'Not In Place' WHEN boq.Indicator28 = 1 THEN 'Partially In Place' WHEN boq.Indicator28 = 2 THEN 'In Place' ELSE 'Error!' END Indicator28,
           CASE WHEN boq.Indicator29 = 0 THEN 'Not In Place' WHEN boq.Indicator29 = 1 THEN 'Partially In Place' WHEN boq.Indicator29 = 2 THEN 'In Place' ELSE 'Error!' END Indicator29,
           CASE WHEN boq.Indicator30 = 0 THEN 'Not In Place' WHEN boq.Indicator30 = 1 THEN 'Partially In Place' WHEN boq.Indicator30 = 2 THEN 'In Place' ELSE 'Error!' END Indicator30,
           CASE WHEN boq.Indicator31 = 0 THEN 'Not In Place' WHEN boq.Indicator31 = 1 THEN 'Partially In Place' WHEN boq.Indicator31 = 2 THEN 'In Place' ELSE 'Error!' END Indicator31,
           CASE WHEN boq.Indicator32 = 0 THEN 'Not In Place' WHEN boq.Indicator32 = 1 THEN 'Partially In Place' WHEN boq.Indicator32 = 2 THEN 'In Place' ELSE 'Error!' END Indicator32,
           CASE WHEN boq.Indicator33 = 0 THEN 'Not In Place' WHEN boq.Indicator33 = 1 THEN 'Partially In Place' WHEN boq.Indicator33 = 2 THEN 'In Place' ELSE 'Error!' END Indicator33,
           CASE WHEN boq.Indicator34 = 0 THEN 'Not In Place' WHEN boq.Indicator34 = 1 THEN 'Partially In Place' WHEN boq.Indicator34 = 2 THEN 'In Place' ELSE 'Error!' END Indicator34,
           CASE WHEN boq.Indicator35 = 0 THEN 'Not In Place' WHEN boq.Indicator35 = 1 THEN 'Partially In Place' WHEN boq.Indicator35 = 2 THEN 'In Place' ELSE 'Error!' END Indicator35,
           CASE WHEN boq.Indicator36 = 0 THEN 'Not In Place' WHEN boq.Indicator36 = 1 THEN 'Partially In Place' WHEN boq.Indicator36 = 2 THEN 'In Place' ELSE 'Error!' END Indicator36,
           CASE WHEN boq.Indicator37 = 0 THEN 'Not In Place' WHEN boq.Indicator37 = 1 THEN 'Partially In Place' WHEN boq.Indicator37 = 2 THEN 'In Place' ELSE 'Error!' END Indicator37,
           CASE WHEN boq.Indicator38 = 0 THEN 'Not In Place' WHEN boq.Indicator38 = 1 THEN 'Partially In Place' WHEN boq.Indicator38 = 2 THEN 'In Place' ELSE 'Error!' END Indicator38,
           CASE WHEN boq.Indicator39 = 0 THEN 'Not In Place' WHEN boq.Indicator39 = 1 THEN 'Partially In Place' WHEN boq.Indicator39 = 2 THEN 'In Place' ELSE 'Error!' END Indicator39,
           CASE WHEN boq.Indicator40 = 0 THEN 'Not In Place' WHEN boq.Indicator40 = 1 THEN 'Partially In Place' WHEN boq.Indicator40 = 2 THEN 'In Place' ELSE 'Error!' END Indicator40,
           CASE WHEN boq.Indicator41 = 0 THEN 'Not In Place' WHEN boq.Indicator41 = 1 THEN 'Partially In Place' WHEN boq.Indicator41 = 2 THEN 'In Place' ELSE 'Error!' END Indicator41,
           boq.TeamMembers,
           p.Location ProgramLocation,
           p.ProgramName
    FROM dbo.BenchmarkOfQuality boq
    INNER JOIN dbo.Program p ON p.ProgramPK = boq.ProgramFK
    WHERE boq.BenchmarkOfQualityPK = @BenchmarkOfQualityPK;

END;
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 09/09/2019
-- Description:	Benchmarks of Quality Change report
-- Edit: Ben Simmons (09/16/19) Need to get last 5 for each program
-- =============================================
CREATE PROC [dbo].[rspBOQChange]
(
    @ProgramFKs VARCHAR(MAX) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @tblFormsInRange TABLE
    (
        BenchmarkOfQualityPK INT NOT NULL,
        FormDate DATETIME NOT NULL,
        TeamMembers VARCHAR(2000) NOT NULL,
        ProgramFK INT NOT NULL,
        ProgramName VARCHAR(400) NOT NULL,
        Indicator1 VARCHAR(100) NOT NULL,
        Indicator2 VARCHAR(100) NOT NULL,
        Indicator3 VARCHAR(100) NOT NULL,
        Indicator4 VARCHAR(100) NOT NULL,
        Indicator5 VARCHAR(100) NOT NULL,
        Indicator6 VARCHAR(100) NOT NULL,
        Indicator7 VARCHAR(100) NOT NULL,
        Indicator8 VARCHAR(100) NOT NULL,
        Indicator9 VARCHAR(100) NOT NULL,
        Indicator10 VARCHAR(100) NOT NULL,
        Indicator11 VARCHAR(100) NOT NULL,
        Indicator12 VARCHAR(100) NOT NULL,
        Indicator13 VARCHAR(100) NOT NULL,
        Indicator14 VARCHAR(100) NOT NULL,
        Indicator15 VARCHAR(100) NOT NULL,
        Indicator16 VARCHAR(100) NOT NULL,
        Indicator17 VARCHAR(100) NOT NULL,
        Indicator18 VARCHAR(100) NOT NULL,
        Indicator19 VARCHAR(100) NOT NULL,
        Indicator20 VARCHAR(100) NOT NULL,
        Indicator21 VARCHAR(100) NOT NULL,
        Indicator22 VARCHAR(100) NOT NULL,
        Indicator23 VARCHAR(100) NOT NULL,
        Indicator24 VARCHAR(100) NOT NULL,
        Indicator25 VARCHAR(100) NOT NULL,
        Indicator26 VARCHAR(100) NOT NULL,
        Indicator27 VARCHAR(100) NOT NULL,
        Indicator28 VARCHAR(100) NOT NULL,
        Indicator29 VARCHAR(100) NOT NULL,
        Indicator30 VARCHAR(100) NOT NULL,
        Indicator31 VARCHAR(100) NOT NULL,
        Indicator32 VARCHAR(100) NOT NULL,
        Indicator33 VARCHAR(100) NOT NULL,
        Indicator34 VARCHAR(100) NOT NULL,
        Indicator35 VARCHAR(100) NOT NULL,
        Indicator36 VARCHAR(100) NOT NULL,
        Indicator37 VARCHAR(100) NOT NULL,
        Indicator38 VARCHAR(100) NOT NULL,
        Indicator39 VARCHAR(100) NOT NULL,
        Indicator40 VARCHAR(100) NOT NULL,
        Indicator41 VARCHAR(100) NOT NULL,
        RowNumber INT NOT NULL
    );


    INSERT INTO @tblFormsInRange
    (
        BenchmarkOfQualityPK,
        FormDate,
        TeamMembers,
        ProgramFK,
        ProgramName,
        Indicator1,
        Indicator2,
        Indicator3,
        Indicator4,
        Indicator5,
        Indicator6,
        Indicator7,
        Indicator8,
        Indicator9,
        Indicator10,
        Indicator11,
        Indicator12,
        Indicator13,
        Indicator14,
        Indicator15,
        Indicator16,
        Indicator17,
        Indicator18,
        Indicator19,
        Indicator20,
        Indicator21,
        Indicator22,
        Indicator23,
        Indicator24,
        Indicator25,
        Indicator26,
        Indicator27,
        Indicator28,
        Indicator29,
        Indicator30,
        Indicator31,
        Indicator32,
        Indicator33,
        Indicator34,
        Indicator35,
        Indicator36,
        Indicator37,
        Indicator38,
        Indicator39,
        Indicator40,
        Indicator41,
        RowNumber
    )
    SELECT boq.BenchmarkOfQualityPK,
           boq.FormDate,
           boq.TeamMembers,
           boq.ProgramFK,
           p.ProgramName,
           CASE boq.Indicator1
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator1,
           CASE boq.Indicator2
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator2,
           CASE boq.Indicator3
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator3,
           CASE boq.Indicator4
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator4,
           CASE boq.Indicator5
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator5,
           CASE boq.Indicator6
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator6,
           CASE boq.Indicator7
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator7,
           CASE boq.Indicator8
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator8,
           CASE boq.Indicator9
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator9,
           CASE boq.Indicator10
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator10,
           CASE boq.Indicator11
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator11,
           CASE boq.Indicator12
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator12,
           CASE boq.Indicator13
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator13,
           CASE boq.Indicator14
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator14,
           CASE boq.Indicator15
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator15,
           CASE boq.Indicator16
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator16,
           CASE boq.Indicator17
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator17,
           CASE boq.Indicator18
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator18,
           CASE boq.Indicator19
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator19,
           CASE boq.Indicator20
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator20,
           CASE boq.Indicator21
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator21,
           CASE boq.Indicator22
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator22,
           CASE boq.Indicator23
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator23,
           CASE boq.Indicator24
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator24,
           CASE boq.Indicator25
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator25,
           CASE boq.Indicator26
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator26,
           CASE boq.Indicator27
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator27,
           CASE boq.Indicator28
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator28,
           CASE boq.Indicator29
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator29,
           CASE boq.Indicator30
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator30,
           CASE boq.Indicator31
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator31,
           CASE boq.Indicator32
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator32,
           CASE boq.Indicator33
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator33,
           CASE boq.Indicator34
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator34,
           CASE boq.Indicator35
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator35,
           CASE boq.Indicator36
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator36,
           CASE boq.Indicator37
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator37,
           CASE boq.Indicator38
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator38,
           CASE boq.Indicator39
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator39,
           CASE boq.Indicator40
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator40,
           CASE boq.Indicator41
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
               ELSE
                   'Unknown'
           END AS Indicator41,
           ROW_NUMBER() OVER (PARTITION BY boq.ProgramFK ORDER BY boq.FormDate DESC) AS RowNumber
    FROM dbo.BenchmarkOfQuality boq
        INNER JOIN dbo.Program p
            ON p.ProgramPK = boq.ProgramFK
        INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti
            ON p.ProgramPK = ssti.ListItem
    WHERE boq.FormDate
    BETWEEN @StartDate AND @EndDate
    ORDER BY p.ProgramName ASC,
             boq.FormDate DESC;

    SELECT *
    FROM @tblFormsInRange tfir
    WHERE tfir.RowNumber <= 5;

END;

GO

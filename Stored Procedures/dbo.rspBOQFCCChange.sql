SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/16/2019
-- Description:	Benchmarks of Quality Change report. (FCC version)
-- =============================================
CREATE PROC [dbo].[rspBOQFCCChange]
(
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
	@ProgramFKs VARCHAR(8000) = NULL,
	@HubFKs VARCHAR(8000) = NULL,
	@CohortFKs VARCHAR(8000) = NULL,
	@StateFKs VARCHAR(8000) = NULL
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @tblFormsInRange TABLE
    (
        BenchmarkOfQualityFCCPK INT NOT NULL,
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
        Indicator42 VARCHAR(100) NOT NULL,
        Indicator43 VARCHAR(100) NOT NULL,
        Indicator44 VARCHAR(100) NOT NULL,
        Indicator45 VARCHAR(100) NOT NULL,
        Indicator46 VARCHAR(100) NOT NULL,
        Indicator47 VARCHAR(100) NOT NULL,
        RowNumber INT NOT NULL
    );


    INSERT INTO @tblFormsInRange
    (
        BenchmarkOfQualityFCCPK,
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
        Indicator42,
        Indicator43,
        Indicator44,
        Indicator45,
        Indicator46,
        Indicator47,
        RowNumber
    )
    SELECT boqf.BenchmarkOfQualityFCCPK,
           boqf.FormDate,
           boqf.TeamMembers,
           boqf.ProgramFK,
           p.ProgramName,
           CASE boqf.Indicator1
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator1,
           CASE boqf.Indicator2
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator2,
           CASE boqf.Indicator3
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator3,
           CASE boqf.Indicator4
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator4,
           CASE boqf.Indicator5
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator5,
           CASE boqf.Indicator6
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator6,
           CASE boqf.Indicator7
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator7,
           CASE boqf.Indicator8
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator8,
           CASE boqf.Indicator9
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator9,
           CASE boqf.Indicator10
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator10,
           CASE boqf.Indicator11
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator11,
           CASE boqf.Indicator12
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator12,
           CASE boqf.Indicator13
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator13,
           CASE boqf.Indicator14
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator14,
           CASE boqf.Indicator15
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator15,
           CASE boqf.Indicator16
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator16,
           CASE boqf.Indicator17
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator17,
           CASE boqf.Indicator18
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator18,
           CASE boqf.Indicator19
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator19,
           CASE boqf.Indicator20
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator20,
           CASE boqf.Indicator21
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator21,
           CASE boqf.Indicator22
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator22,
           CASE boqf.Indicator23
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator23,
           CASE boqf.Indicator24
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator24,
           CASE boqf.Indicator25
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator25,
           CASE boqf.Indicator26
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator26,
           CASE boqf.Indicator27
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator27,
           CASE boqf.Indicator28
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator28,
           CASE boqf.Indicator29
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator29,
           CASE boqf.Indicator30
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator30,
           CASE boqf.Indicator31
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator31,
           CASE boqf.Indicator32
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator32,
           CASE boqf.Indicator33
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator33,
           CASE boqf.Indicator34
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator34,
           CASE boqf.Indicator35
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator35,
           CASE boqf.Indicator36
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator36,
           CASE boqf.Indicator37
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator37,
           CASE boqf.Indicator38
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator38,
           CASE boqf.Indicator39
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator39,
           CASE boqf.Indicator40
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator40,
           CASE boqf.Indicator41
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator41,
           CASE boqf.Indicator42
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator42,
           CASE boqf.Indicator43
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator43,
           CASE boqf.Indicator44
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator44,
           CASE boqf.Indicator45
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator45,
           CASE boqf.Indicator46
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator46,
           CASE boqf.Indicator47
               WHEN 0 THEN
                   'Not In Place'
               WHEN 1 THEN
                   'Partially In Place'
               WHEN 2 THEN
                   'In Place'
			   WHEN 99 THEN
					'NA'
               ELSE
                   'Unknown'
           END AS Indicator47,
           ROW_NUMBER() OVER (PARTITION BY boqf.ProgramFK ORDER BY boqf.FormDate DESC) AS RowNumber
    FROM dbo.BenchmarkOfQualityFCC boqf
		INNER JOIN dbo.Program p
			ON p.ProgramPK = boqf.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = boqf.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
    boqf.FormDate BETWEEN @StartDate AND @EndDate AND
	boqf.VersionNumber = 1 AND 
	boqf.IsComplete = 1
    ORDER BY p.ProgramName ASC,
             boqf.FormDate DESC;

    SELECT *
    FROM @tblFormsInRange tfir
    WHERE tfir.RowNumber <= 5;

END;
GO

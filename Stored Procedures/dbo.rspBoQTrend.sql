SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/10/2019
-- Description:	BOQ Trend Report
-- Edited on 09/18/2019 by Ben Simmons
-- Edit Reason: Need to format the data differently so that chart works
-- =============================================
CREATE PROC [dbo].[rspBOQTrend]
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

	DECLARE @tblAllBOQs TABLE (
		BOQPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL,
		ELTNotInPlace INT NOT NULL,
		ELTPartial INT NOT NULL,
		ELTInPlace INT NOT NULL,
		ELTAvg DECIMAL(5,2) NOT NULL,
		SBINotInPlace INT NOT NULL,
		SBIPartial INT NOT NULL,
		SBIInPlace INT NOT NULL,
		SBIAvg DECIMAL(5,2) NOT NULL,
		FENotInPlace INT NOT NULL,
		FEPartial INT NOT NULL,
		FEInPlace INT NOT NULL,
		FEAvg DECIMAL(5,2) NOT NULL,
		PWENotInPlace INT NOT NULL,
		PWEPartial INT NOT NULL,
		PWEInPlace INT NOT NULL,
		PWEAvg DECIMAL(5,2) NOT NULL,
		PDSSPNotInPlace INT NOT NULL,
		PDSSPPartial INT NOT NULL,
		PDSSPInPlace INT NOT NULL,
		PDSSPAvg DECIMAL(5,2) NOT NULL,
		PRCBNotInPlace INT NOT NULL,
		PRCBPartial INT NOT NULL,
		PRCBInPlace INT NOT NULL,
		PRCBAvg DECIMAL(5,2) NOT NULL,
		MIONotInPlace INT NOT NULL,
		MIOPartial INT NOT NULL,
		MIOInPlace INT NOT NULL,
		MIOAvg DECIMAL(5,2) NOT NULL

	)

	DECLARE @tblBOQData TABLE (
		BOQPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL,
		CriticalElementAbbr VARCHAR(10) NOT NULL,
		CriticalElementName VARCHAR(150) NOT NULL,
		CriticalElementAvg DECIMAL(5,2) NOT NULL,
		CriticalElementNumNotInPlace INT NOT NULL,
		CriticalElementNumPartial INT NOT NULL,
		CriticalElementNumInPlace INT NOT NULL
	)


	INSERT INTO @tblAllBOQs
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
	    ELTNotInPlace,
	    ELTPartial,
	    ELTInPlace,
	    ELTAvg,
	    SBINotInPlace,
	    SBIPartial,
	    SBIInPlace,
	    SBIAvg,
	    FENotInPlace,
	    FEPartial,
	    FEInPlace,
	    FEAvg,
	    PWENotInPlace,
	    PWEPartial,
	    PWEInPlace,
	    PWEAvg,
	    PDSSPNotInPlace,
	    PDSSPPartial,
	    PDSSPInPlace,
	    PDSSPAvg,
	    PRCBNotInPlace,
	    PRCBPartial,
	    PRCBInPlace,
	    PRCBAvg,
	    MIONotInPlace,
	    MIOPartial,
	    MIOInPlace,
	    MIOAvg
	)
	SELECT boq.BenchmarkOfQualityPK
		 , boq.FormDate
		 , CASE WHEN DATEPART(MONTH, boq.FormDate) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boq.FormDate)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boq.FormDate)), '-2-Fall') END AS GroupingValue
		 , CASE WHEN DATEPART(MONTH, boq.FormDate) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, boq.FormDate))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, boq.FormDate))) END AS GroupingText
		 , boq.ProgramFK
		 , p.ProgramName 

		 --ELT
		 , case when boq.Indicator1 = 0 then 1 else 0 end
		   + case when boq.Indicator2 = 0 then 1 else 0 end
		   + case when boq.Indicator3 = 0 then 1 else 0 end
		   + case when boq.Indicator4 = 0 then 1 else 0 end
		   + case when boq.Indicator5 = 0 then 1 else 0 end
		   + case when boq.Indicator6 = 0 then 1 else 0 end
		   + case when boq.Indicator7 = 0 then 1 else 0 end as ELTNotInPlace

		 , case when boq.Indicator1 = 1 then 1 else 0 end
		   + case when boq.Indicator2 = 1 then 1 else 0 end
		   + case when boq.Indicator3 = 1 then 1 else 0 end
		   + case when boq.Indicator4 = 1 then 1 else 0 end
		   + case when boq.Indicator5 = 1 then 1 else 0 end
		   + case when boq.Indicator6 = 1 then 1 else 0 end
		   + case when boq.Indicator7 = 1 then 1 else 0 end as ELTPartiallyInPlace

		, case when boq.Indicator1 = 2 then 1 else 0 end
		   + case when boq.Indicator2 = 2 then 1 else 0 end
		   + case when boq.Indicator3 = 2 then 1 else 0 end
		   + case when boq.Indicator4 = 2 then 1 else 0 end
		   + case when boq.Indicator5 = 2 then 1 else 0 end
		   + case when boq.Indicator6 = 2 then 1 else 0 end
		   + case when boq.Indicator7 = 2 then 1 else 0 end as ELTInPlace

		, convert(decimal(5,2), boq.Indicator1 + boq.Indicator2 + boq.Indicator3 + boq.Indicator4 + boq.Indicator5 + boq.Indicator6 + boq.Indicator7) / 7 as ELTAvg --ELT
		
		 --SBI
		, case when boq.Indicator8 = 0 then 1 else 0 end
		   + case when boq.Indicator9 = 0 then 1 else 0 end as SBINotInPlace

		, case when boq.Indicator8 = 1 then 1 else 0 end
		   + case when boq.Indicator9 = 1 then 1 else 0 end as SBIPartiallyInPlace

		, case when boq.Indicator8 = 2 then 1 else 0 end
		   + case when boq.Indicator9 = 2 then 1 else 0 end as SBIInPlace

		, convert(decimal(5,2), boq.Indicator8 + boq.Indicator9) / 2 as SBIAvg--SBI

		--FE
		, case when boq.Indicator10 = 0 then 1 else 0 end
		   + case when boq.Indicator11 = 0 then 1 else 0 end
		   + case when boq.Indicator12 = 0 then 1 else 0 end
		   + case when boq.Indicator13 = 0 then 1 else 0 end as FENotInPlace

		, case when boq.Indicator10 = 1 then 1 else 0 end
		   + case when boq.Indicator11 = 1 then 1 else 0 end
		   + case when boq.Indicator12 = 1 then 1 else 0 end
		   + case when boq.Indicator13 = 1 then 1 else 0 end as FEPartiallyInPlace

		, case when boq.Indicator10 = 2 then 1 else 0 end
		   + case when boq.Indicator11 = 2 then 1 else 0 end
		   + case when boq.Indicator12 = 2 then 1 else 0 end
		   + case when boq.Indicator13 = 2 then 1 else 0 end as FEInPlace

		, convert(decimal(5,2), boq.Indicator10 + boq.Indicator11 + boq.Indicator12 + boq.Indicator13) / 4 as FEAvg --FE

		 --PWE
		, case when boq.Indicator14 = 0 then 1 else 0 end
		   + case when boq.Indicator15 = 0 then 1 else 0 end
		   + case when boq.Indicator16 = 0 then 1 else 0 end
		   + case when boq.Indicator17 = 0 then 1 else 0 end
		   + case when boq.Indicator18 = 0 then 1 else 0 end
		   + case when boq.Indicator19 = 0 then 1 else 0 end
		   + case when boq.Indicator20 = 0 then 1 else 0 end as PWENotInPlace

		, case when boq.Indicator14 = 1 then 1 else 0 end
		   + case when boq.Indicator15 = 1 then 1 else 0 end
		   + case when boq.Indicator16 = 1 then 1 else 0 end
		   + case when boq.Indicator17 = 1 then 1 else 0 end
		   + case when boq.Indicator18 = 1 then 1 else 0 end
		   + case when boq.Indicator19 = 1 then 1 else 0 end
		   + case when boq.Indicator20 = 1 then 1 else 0 end as PWEPartiallyInPlace

		, case when boq.Indicator14 = 2 then 1 else 0 end
		   + case when boq.Indicator15 = 2 then 1 else 0 end
		   + case when boq.Indicator16 = 2 then 1 else 0 end
		   + case when boq.Indicator17 = 2 then 1 else 0 end
		   + case when boq.Indicator18 = 2 then 1 else 0 end
		   + case when boq.Indicator19 = 2 then 1 else 0 end
		   + case when boq.Indicator20 = 2 then 1 else 0 end as PWEInPlace

		, convert(decimal(5,2), boq.Indicator14 + boq.Indicator15 + boq.Indicator16 + boq.Indicator17 + boq.Indicator18 + boq.Indicator19 + boq.Indicator20) / 7 as PWEAvg --PWE
		
		 --PDSSP
		, case when boq.Indicator21 = 0 then 1 else 0 end
		   + case when boq.Indicator22 = 0 then 1 else 0 end
		   + case when boq.Indicator23 = 0 then 1 else 0 end
		   + case when boq.Indicator24 = 0 then 1 else 0 end
		   + case when boq.Indicator25 = 0 then 1 else 0 end
		   + case when boq.Indicator26 = 0 then 1 else 0 end
		   + case when boq.Indicator27 = 0 then 1 else 0 end as PDSSPNotInPlace

		, case when boq.Indicator21 = 1 then 1 else 0 end
		   + case when boq.Indicator22 = 1 then 1 else 0 end
		   + case when boq.Indicator23 = 1 then 1 else 0 end
		   + case when boq.Indicator24 = 1 then 1 else 0 end
		   + case when boq.Indicator25 = 1 then 1 else 0 end
		   + case when boq.Indicator26 = 1 then 1 else 0 end
		   + case when boq.Indicator27 = 1 then 1 else 0 end as PDSSPPartiallyInPlace

		, case when boq.Indicator21 = 2 then 1 else 0 end
		   + case when boq.Indicator22 = 2 then 1 else 0 end
		   + case when boq.Indicator23 = 2 then 1 else 0 end
		   + case when boq.Indicator24 = 2 then 1 else 0 end
		   + case when boq.Indicator25 = 2 then 1 else 0 end
		   + case when boq.Indicator26 = 2 then 1 else 0 end
		   + case when boq.Indicator27 = 2 then 1 else 0 end as PDSSPInPlace

		, convert(decimal(5,2), boq.Indicator21 + boq.Indicator22 + boq.Indicator23 + boq.Indicator24 + boq.Indicator25 + boq.Indicator26 + boq.Indicator27) / 7 as PDSSPAvg --PDSSP

		 --PRCB
		, case when boq.Indicator28 = 0 then 1 else 0 end
		   + case when boq.Indicator29 = 0 then 1 else 0 end
		   + case when boq.Indicator30 = 0 then 1 else 0 end
		   + case when boq.Indicator31 = 0 then 1 else 0 end
		   + case when boq.Indicator32 = 0 then 1 else 0 end
		   + case when boq.Indicator33 = 0 then 1 else 0 end
		   + case when boq.Indicator34 = 0 then 1 else 0 end as PRCBNotInPlace

		, case when boq.Indicator28 = 1 then 1 else 0 end
		   + case when boq.Indicator29 = 1 then 1 else 0 end
		   + case when boq.Indicator30 = 1 then 1 else 0 end
		   + case when boq.Indicator31 = 1 then 1 else 0 end
		   + case when boq.Indicator32 = 1 then 1 else 0 end
		   + case when boq.Indicator33 = 1 then 1 else 0 end
		   + case when boq.Indicator34 = 1 then 1 else 0 end as PRCBPartiallyInPlace

		, case when boq.Indicator28 = 2 then 1 else 0 end
		   + case when boq.Indicator29 = 2 then 1 else 0 end
		   + case when boq.Indicator30 = 2 then 1 else 0 end
		   + case when boq.Indicator31 = 2 then 1 else 0 end
		   + case when boq.Indicator32 = 2 then 1 else 0 end
		   + case when boq.Indicator33 = 2 then 1 else 0 end
		   + case when boq.Indicator34 = 2 then 1 else 0 end as PRCBInPlace

		, convert(decimal(5,2), boq.Indicator28 + boq.Indicator29 + boq.Indicator30 + boq.Indicator31 + boq.Indicator32 + boq.Indicator33 + boq.Indicator34) / 7 as PRCBAvg--PRCB

		 --MIO
		, case when boq.Indicator35 = 0 then 1 else 0 end
		   + case when boq.Indicator36 = 0 then 1 else 0 end
		   + case when boq.Indicator37 = 0 then 1 else 0 end
		   + case when boq.Indicator38 = 0 then 1 else 0 end
		   + case when boq.Indicator39 = 0 then 1 else 0 end
		   + case when boq.Indicator40 = 0 then 1 else 0 end
		   + case when boq.Indicator41 = 0 then 1 else 0 end as MIONotInPlace

		, case when boq.Indicator35 = 1 then 1 else 0 end
		   + case when boq.Indicator36 = 1 then 1 else 0 end
		   + case when boq.Indicator37 = 1 then 1 else 0 end
		   + case when boq.Indicator38 = 1 then 1 else 0 end
		   + case when boq.Indicator39 = 1 then 1 else 0 end
		   + case when boq.Indicator40 = 1 then 1 else 0 end
		   + case when boq.Indicator41 = 1 then 1 else 0 end as MIOPartiallyInPlace

		, case when boq.Indicator35 = 2 then 1 else 0 end
		   + case when boq.Indicator36 = 2 then 1 else 0 end
		   + case when boq.Indicator37 = 2 then 1 else 0 end
		   + case when boq.Indicator38 = 2 then 1 else 0 end
		   + case when boq.Indicator39 = 2 then 1 else 0 end
		   + case when boq.Indicator40 = 2 then 1 else 0 end
		   + case when boq.Indicator41 = 2 then 1 else 0 end as MIOInPlace
		
		, convert(decimal(5,2), boq.Indicator35 + boq.Indicator36 + boq.Indicator37 + boq.Indicator38 + boq.Indicator39 + boq.Indicator40 + boq.Indicator41) / 7 as MIOAvg--MIO
		
	FROM dbo.BenchmarkOfQuality boq
	INNER JOIN Program p on p.ProgramPK = boq.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = boq.ProgramFK
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
	boq.FormDate BETWEEN @StartDate AND @EndDate
	ORDER BY boq.FormDate ASC

	--Get the ELT data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'ELT', 'Establish Leadership Team', tabq.ELTAvg, tabq.ELTNotInPlace, tabq.ELTPartial, tabq.ELTInPlace
	FROM @tblAllBOQs tabq

	--Get the SBI data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'SBI', 'Staff Buy-in', tabq.SBIAvg, tabq.SBINotInPlace, tabq.SBIPartial, tabq.SBIInPlace
	FROM @tblAllBOQs tabq

	--Get the FE data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'FE', 'Family Engagement', tabq.FEAvg, tabq.FENotInPlace, tabq.FEPartial, tabq.FEInPlace
	FROM @tblAllBOQs tabq

	--Get the PWE data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PWE', 'Program-Wide Expectations', tabq.PWEAvg, tabq.PWENotInPlace, tabq.PWEPartial, tabq.PWEInPlace
	FROM @tblAllBOQs tabq

	--Get the PDSSP data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PDSSP', 'Professional Development and Staff Support Plan', tabq.PDSSPAvg, tabq.PDSSPNotInPlace, tabq.PDSSPPartial, tabq.PDSSPInPlace
	FROM @tblAllBOQs tabq

	--Get the PRCB data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PRCB', 'Procedures for Responding to Challenging Behavior', tabq.PRCBAvg, tabq.PRCBNotInPlace, tabq.PRCBPartial, tabq.PRCBInPlace
	FROM @tblAllBOQs tabq

	--Get the MIO data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'MIO', 'Monitoring Implementation and Outcomes', tabq.MIOAvg, tabq.MIONotInPlace, tabq.MIOPartial, tabq.MIOInPlace
	FROM @tblAllBOQs tabq

	SELECT * FROM @tblBOQData tbd

END
GO

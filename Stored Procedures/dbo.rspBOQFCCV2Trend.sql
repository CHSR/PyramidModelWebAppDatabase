SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/26/2023
-- Description:	BOQ FCC V2 Trend Report
-- =============================================
CREATE PROC [dbo].[rspBOQFCCV2Trend]
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
		BOQFCCPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL,
		EMPINotInPlace INT NOT NULL,
		EMPIPartial INT NOT NULL,
		EMPIInPlace INT NOT NULL,
		EMPIAvg DECIMAL(5,2) NOT NULL,
		FENotInPlace INT NOT NULL,
		FEPartial INT NOT NULL,
		FEInPlace INT NOT NULL,
		FEAvg DECIMAL(5,2) NOT NULL,
		PENotInPlace INT NOT NULL,
		PEPartial INT NOT NULL,
		PEInPlace INT NOT NULL,
		PEAvg DECIMAL(5,2) NOT NULL,
		PDNotInPlace INT NOT NULL,
		PDPartial INT NOT NULL,
		PDInPlace INT NOT NULL,
		PDAvg DECIMAL(5,2) NOT NULL,
		IPPNotInPlace INT NOT NULL,
		IPPPartial INT NOT NULL,
		IPPInPlace INT NOT NULL,
		IPPAvg DECIMAL(5,2) NOT NULL,
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
		BOQFCCPK INT NOT NULL,
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
	    BOQFCCPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    ProgramFK,
	    ProgramName,
	    EMPINotInPlace,
	    EMPIPartial,
	    EMPIInPlace,
	    EMPIAvg,
	    FENotInPlace,
	    FEPartial,
	    FEInPlace,
	    FEAvg,
	    PENotInPlace,
	    PEPartial,
	    PEInPlace,
	    PEAvg,
	    PDNotInPlace,
	    PDPartial,
	    PDInPlace,
	    PDAvg,
	    IPPNotInPlace,
	    IPPPartial,
	    IPPInPlace,
	    IPPAvg,
	    PRCBNotInPlace,
	    PRCBPartial,
	    PRCBInPlace,
	    PRCBAvg,
	    MIONotInPlace,
	    MIOPartial,
	    MIOInPlace,
	    MIOAvg
	)
	SELECT boqf.BenchmarkOfQualityFCCPK
		 , boqf.FormDate
		 , CASE WHEN DATEPART(MONTH, boqf.FormDate) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqf.FormDate)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqf.FormDate)), '-2-Fall') END AS GroupingValue
		 , CASE WHEN DATEPART(MONTH, boqf.FormDate) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqf.FormDate))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqf.FormDate))) END AS GroupingText
		 , boqf.ProgramFK
		 , p.ProgramName 

		 --EMPI

		 , case when boqf.Indicator1 = 0 then 1 else 0 end
		   + case when boqf.Indicator2 = 0 then 1 else 0 end
		   + case when boqf.Indicator3 = 0 then 1 else 0 end
		   + case when boqf.Indicator4 = 0 then 1 else 0 end
		   + case when boqf.Indicator5 = 0 then 1 else 0 end as EMPINotInPlace

		 , case when boqf.Indicator1 = 1 then 1 else 0 end
		   + case when boqf.Indicator2 = 1 then 1 else 0 end
		   + case when boqf.Indicator3 = 1 then 1 else 0 end
		   + case when boqf.Indicator4 = 1 then 1 else 0 end
		   + case when boqf.Indicator5 = 1 then 1 else 0 end as EMPIPartiallyInPlace

		, case when boqf.Indicator1 = 2 then 1 else 0 end
		   + case when boqf.Indicator2 = 2 then 1 else 0 end
		   + case when boqf.Indicator3 = 2 then 1 else 0 end
		   + case when boqf.Indicator4 = 2 then 1 else 0 end
		   + case when boqf.Indicator5 = 2 then 1 else 0 end as EMPIInPlace

		, convert(decimal(5,2), boqf.Indicator1 + boqf.Indicator2 + boqf.Indicator3 
					+ boqf.Indicator4 + boqf.Indicator5) / 5 as EMPIAvg --EMPI
		
		 --FE
		, case when boqf.Indicator6 = 0 then 1 else 0 end
		   + CASE when boqf.Indicator7 = 0 then 1 else 0 end
		   + case when boqf.Indicator8 = 0 then 1 else 0 end as FENotInPlace

		, case when boqf.Indicator6 = 1 then 1 else 0 end
		   + CASE when boqf.Indicator7 = 1 then 1 else 0 end
		   + case when boqf.Indicator8 = 1 then 1 else 0 end as FEPartiallyInPlace

		, case when boqf.Indicator6 = 2 then 1 else 0 end
		   + CASE when boqf.Indicator7 = 2 then 1 else 0 end
		   + case when boqf.Indicator8 = 2 then 1 else 0 end as FEInPlace

		, convert(decimal(5,2), boqf.Indicator6 + boqf.Indicator7 + boqf.Indicator8) / 3 as FEAvg --FE

		--PE
		, case when boqf.Indicator9 = 0 then 1 else 0 end
		   + case when boqf.Indicator10 = 0 then 1 else 0 end
		   + case when boqf.Indicator11 = 0 then 1 else 0 end
		   + case when boqf.Indicator12 = 0 then 1 else 0 end
		   + case when boqf.Indicator13 = 0 then 1 else 0 end
		   + case when boqf.Indicator14 = 0 then 1 else 0 end as PENotInPlace

		, case when boqf.Indicator9 = 1 then 1 else 0 end
		   + case when boqf.Indicator10 = 1 then 1 else 0 end
		   + case when boqf.Indicator11 = 1 then 1 else 0 end
		   + case when boqf.Indicator12 = 1 then 1 else 0 end
		   + case when boqf.Indicator13 = 1 then 1 else 0 end
		   + case when boqf.Indicator14 = 1 then 1 else 0 end as PEPartiallyInPlace

		, case when boqf.Indicator9 = 2 then 1 else 0 end
		   + case when boqf.Indicator10 = 2 then 1 else 0 end
		   + case when boqf.Indicator11 = 2 then 1 else 0 end
		   + case when boqf.Indicator12 = 2 then 1 else 0 end
		   + case when boqf.Indicator13 = 2 then 1 else 0 end
		   + case when boqf.Indicator14 = 2 then 1 else 0 end as PEInPlace

		, convert(decimal(5,2), boqf.Indicator9 + boqf.Indicator10 + boqf.Indicator11 
					+ boqf.Indicator12 + boqf.Indicator13 + boqf.Indicator14) / 6 as PEAvg --PE

		 --PD
		, case when boqf.Indicator15 = 0 then 1 else 0 end
		   + case when boqf.Indicator16 = 0 then 1 else 0 end
		   + case when boqf.Indicator17 = 0 then 1 else 0 end as PDNotInPlace

		, case when boqf.Indicator15 = 1 then 1 else 0 end
		   + case when boqf.Indicator16 = 1 then 1 else 0 end
		   + case when boqf.Indicator17 = 1 then 1 else 0 end as PDPartiallyInPlace

		, case when boqf.Indicator15 = 2 then 1 else 0 end
		   + case when boqf.Indicator16 = 2 then 1 else 0 end
		   + case when boqf.Indicator17 = 2 then 1 else 0 end as PDInPlace

		, convert(decimal(5,2), boqf.Indicator15 + boqf.Indicator16 + boqf.Indicator17) / 3 as PDAvg --PD
		
		 --IPP
		, case when boqf.Indicator18 = 0 then 1 else 0 end
		   + case when boqf.Indicator19 = 0 then 1 else 0 end
		   + case when boqf.Indicator20 = 0 then 1 else 0 end as IPPNotInPlace

		, case when boqf.Indicator18 = 1 then 1 else 0 end
		   + case when boqf.Indicator19 = 1 then 1 else 0 end
		   + case when boqf.Indicator20 = 1 then 1 else 0 end as IPPPartiallyInPlace

		, case when boqf.Indicator18 = 2 then 1 else 0 end
		   + case when boqf.Indicator19 = 2 then 1 else 0 end
		   + case when boqf.Indicator20 = 2 then 1 else 0 end as IPPInPlace

		, convert(decimal(5,2), boqf.Indicator18 + boqf.Indicator19 + boqf.Indicator20) / 3 as IPPAvg --IPP

		 --PRCB
		, CASE WHEN boqf.Indicator21 = 0 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator22 = 0 then 1 else 0 end
		   + case when boqf.Indicator23 = 0 then 1 else 0 end
		   + case when boqf.Indicator24 = 0 then 1 else 0 end
		   + case when boqf.Indicator25 = 0 then 1 else 0 end
		   + case when boqf.Indicator26 = 0 then 1 else 0 end as PRCBNotInPlace

		, CASE WHEN boqf.Indicator21 = 1 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator22 = 1 then 1 else 0 end
		   + case when boqf.Indicator23 = 1 then 1 else 0 end
		   + case when boqf.Indicator24 = 1 then 1 else 0 end
		   + case when boqf.Indicator25 = 1 then 1 else 0 end
		   + case when boqf.Indicator26 = 1 then 1 else 0 end as PRCBPartiallyInPlace

		, CASE WHEN boqf.Indicator21 = 2 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator22 = 2 then 1 else 0 end
		   + case when boqf.Indicator23 = 2 then 1 else 0 end
		   + case when boqf.Indicator24 = 2 then 1 else 0 end
		   + case when boqf.Indicator25 = 2 then 1 else 0 end
		   + case when boqf.Indicator26 = 2 then 1 else 0 end as PRCBInPlace

		, convert(decimal(5,2), boqf.Indicator21 + boqf.Indicator22 + boqf.Indicator23 
					+ boqf.Indicator24 + boqf.Indicator25 + boqf.Indicator26) / 6 as PRCBAvg--PRCB

		 --MIO
		, case when boqf.Indicator27 = 0 then 1 else 0 end
		   + case when boqf.Indicator28 = 0 then 1 else 0 end
		   + case when boqf.Indicator29 = 0 then 1 else 0 end
		   + case when boqf.Indicator30 = 0 then 1 else 0 end
		   + case when boqf.Indicator31 = 0 then 1 else 0 end as MIONotInPlace

		, case when boqf.Indicator27 = 1 then 1 else 0 end
		   + case when boqf.Indicator28 = 1 then 1 else 0 end
		   + case when boqf.Indicator29 = 1 then 1 else 0 end
		   + case when boqf.Indicator30 = 1 then 1 else 0 end
		   + case when boqf.Indicator31 = 1 then 1 else 0 end as MIOPartiallyInPlace

		, case when boqf.Indicator27 = 2 then 1 else 0 end
		   + case when boqf.Indicator28 = 2 then 1 else 0 end
		   + case when boqf.Indicator29 = 2 then 1 else 0 end
		   + case when boqf.Indicator30 = 2 then 1 else 0 end
		   + case when boqf.Indicator31 = 2 then 1 else 0 end as MIOInPlace
		
		, convert(decimal(5,2), boqf.Indicator27 + boqf.Indicator28 + boqf.Indicator29 
					+ boqf.Indicator30 + boqf.Indicator31) / 5 as MIOAvg --MIO
		
	FROM dbo.BenchmarkOfQualityFCC boqf
	INNER JOIN dbo.Program p on p.ProgramPK = boqf.ProgramFK
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
    boqf.VersionNumber = 2 AND --Only include version 2 forms that are complete
	boqf.IsComplete = 1
	ORDER BY boqf.FormDate ASC

	--Get the EMPI data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'EMPI', 'Establish and Maintain a Plan for Implementation', 
		tabq.EMPIAvg, tabq.EMPINotInPlace, tabq.EMPIPartial, tabq.EMPIInPlace
	FROM @tblAllBOQs tabq

	--Get the FE data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'FE', 'Family Engagement', tabq.FEAvg, tabq.FENotInPlace, tabq.FEPartial, tabq.FEInPlace
	FROM @tblAllBOQs tabq

	--Get the PE data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PE', 'Program Expectations', tabq.PEAvg, tabq.PENotInPlace, tabq.PEPartial, tabq.PEInPlace
	FROM @tblAllBOQs tabq

	--Get the PD data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PD', 'Professional Development', tabq.PDAvg, tabq.PDNotInPlace, tabq.PDPartial, tabq.PDInPlace
	FROM @tblAllBOQs tabq

	--Get the IPP data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'IPP', 'Implementation of Pyramid Practices', tabq.IPPAvg, tabq.IPPNotInPlace, tabq.IPPPartial, tabq.IPPInPlace
	FROM @tblAllBOQs tabq

	--Get the PRCB data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PRCB', 'Procedures for Responding to Challenging Behavior', tabq.PRCBAvg, tabq.PRCBNotInPlace, tabq.PRCBPartial, tabq.PRCBInPlace
	FROM @tblAllBOQs tabq

	--Get the MIO data
	INSERT INTO @tblBOQData
	(
	    BOQFCCPK,
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
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'MIO', 'Monitoring Implementation and Outcomes', tabq.MIOAvg, tabq.MIONotInPlace, tabq.MIOPartial, tabq.MIOInPlace
	FROM @tblAllBOQs tabq

	SELECT * FROM @tblBOQData tbd

END
GO

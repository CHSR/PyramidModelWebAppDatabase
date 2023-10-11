SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 08/01/2022
-- Description:	Community-Wide BOQ Trend Report
-- =============================================
CREATE PROC [dbo].[rspBOQCWLTTrend]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@HubFKs VARCHAR(8000) = NULL,
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
		HubFK INT NOT NULL,
		HubName VARCHAR(400) NOT NULL,
		CLTMTNotInPlace INT NOT NULL,
		CLTMTNeedsImprovement INT NOT NULL,
		CLTMTInPlace INT NOT NULL,
		CLTMTAvg DECIMAL(5,2) NOT NULL,
		FDNotInPlace INT NOT NULL,
		FDNeedsImprovement INT NOT NULL,
		FDInPlace INT NOT NULL,
		FDAvg DECIMAL(5,2) NOT NULL,
		CVNotInPlace INT NOT NULL,
		CVNeedsImprovement INT NOT NULL,
		CVInPlace INT NOT NULL,
		CVAvg DECIMAL(5,2) NOT NULL,
		IDSNotInPlace INT NOT NULL,
		IDSNeedsImprovement INT NOT NULL,
		IDSInPlace INT NOT NULL,
		IDSAvg DECIMAL(5,2) NOT NULL,
		FMNotInPlace INT NOT NULL,
		FMNeedsImprovement INT NOT NULL,
		FMInPlace INT NOT NULL,
		FMAvg DECIMAL(5,2) NOT NULL,
		BSNotInPlace INT NOT NULL,
		BSNeedsImprovement INT NOT NULL,
		BSInPlace INT NOT NULL,
		BSAvg DECIMAL(5,2) NOT NULL,
		PDNotInPlace INT NOT NULL,
		PDNeedsImprovement INT NOT NULL,
		PDInPlace INT NOT NULL,
		PDAvg DECIMAL(5,2) NOT NULL,
		MIONotInPlace INT NOT NULL,
		MIONeedsImprovement INT NOT NULL,
		MIOInPlace INT NOT NULL,
		MIOAvg DECIMAL(5,2) NOT NULL
	)

	DECLARE @tblBOQData TABLE (
		BOQPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		HubFK INT NOT NULL,
		HubName VARCHAR(400) NOT NULL,
		CriticalElementAbbr VARCHAR(10) NOT NULL,
		CriticalElementName VARCHAR(150) NOT NULL,
		CriticalElementAvg DECIMAL(5,2) NOT NULL,
		CriticalElementNumNotInPlace INT NOT NULL,
		CriticalElementNumNeedsImprovement INT NOT NULL,
		CriticalElementNumInPlace INT NOT NULL
	)


	INSERT INTO @tblAllBOQs
	(
	    BOQPK,
	    FormDate,
	    GroupingValue,
	    GroupingText,
	    HubFK,
	    HubName,
	    CLTMTNotInPlace,
	    CLTMTNeedsImprovement,
	    CLTMTInPlace,
	    CLTMTAvg,
	    FDNotInPlace,
	    FDNeedsImprovement,
	    FDInPlace,
	    FDAvg,
	    CVNotInPlace,
	    CVNeedsImprovement,
	    CVInPlace,
	    CVAvg,
	    IDSNotInPlace,
	    IDSNeedsImprovement,
	    IDSInPlace,
	    IDSAvg,
	    FMNotInPlace,
	    FMNeedsImprovement,
	    FMInPlace,
	    FMAvg,
	    BSNotInPlace,
	    BSNeedsImprovement,
	    BSInPlace,
	    BSAvg,
	    PDNotInPlace,
	    PDNeedsImprovement,
	    PDInPlace,
	    PDAvg,
	    MIONotInPlace,
	    MIONeedsImprovement,
	    MIOInPlace,
	    MIOAvg
	)
	SELECT boqc.BenchmarkOfQualityCWLTPK
		 , boqc.FormDate
		 , CASE WHEN DATEPART(MONTH, boqc.FormDate) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqc.FormDate)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqc.FormDate)), '-2-Fall') END AS GroupingValue
		 , CASE WHEN DATEPART(MONTH, boqc.FormDate) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqc.FormDate))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqc.FormDate))) END AS GroupingText
		 , boqc.HubFK
		 , h.[Name]

		 --CLTMT
		 , case when boqc.Indicator1 = 0 then 1 else 0 end
		   + case when boqc.Indicator2 = 0 then 1 else 0 end
		   + case when boqc.Indicator3 = 0 then 1 else 0 end
		   + case when boqc.Indicator4 = 0 then 1 else 0 end
		   + case when boqc.Indicator5 = 0 then 1 else 0 end
		   + case when boqc.Indicator6 = 0 then 1 else 0 end
		   + case when boqc.Indicator7 = 0 then 1 else 0 end
		   + case when boqc.Indicator8 = 0 then 1 else 0 END AS CLTMTNotInPlace

		 , case when boqc.Indicator1 = 1 then 1 else 0 end
		   + case when boqc.Indicator2 = 1 then 1 else 0 end
		   + case when boqc.Indicator3 = 1 then 1 else 0 end
		   + case when boqc.Indicator4 = 1 then 1 else 0 end
		   + case when boqc.Indicator5 = 1 then 1 else 0 end
		   + case when boqc.Indicator6 = 1 then 1 else 0 end
		   + case when boqc.Indicator7 = 1 then 1 else 0 end
		   + case when boqc.Indicator8 = 1 then 1 else 0 end as CLTMTNeedsImprovement

		, case when boqc.Indicator1 = 2 then 1 else 0 end
		   + case when boqc.Indicator2 = 2 then 1 else 0 end
		   + case when boqc.Indicator3 = 2 then 1 else 0 end
		   + case when boqc.Indicator4 = 2 then 1 else 0 end
		   + case when boqc.Indicator5 = 2 then 1 else 0 end
		   + case when boqc.Indicator6 = 2 then 1 else 0 end
		   + case when boqc.Indicator7 = 2 then 1 else 0 end
		   + case when boqc.Indicator8 = 2 then 1 else 0 end as CLTMTInPlace

		, convert(decimal(5,2), boqc.Indicator1 + boqc.Indicator2 + boqc.Indicator3 + 
					boqc.Indicator4 + boqc.Indicator5 + boqc.Indicator6 + boqc.Indicator7 + 
					boqc.Indicator8) / 8 as CLTMTAvg --CLTMT
		
		 --FD
		, case when boqc.Indicator9 = 0 then 1 else 0 end
		   + case when boqc.Indicator10 = 0 then 1 else 0 end
		   + case when boqc.Indicator11 = 0 then 1 else 0 end
		   + case when boqc.Indicator12 = 0 then 1 else 0 end as FDNotInPlace

		, case when boqc.Indicator9 = 1 then 1 else 0 end
		   + case when boqc.Indicator10 = 1 then 1 else 0 end
		   + case when boqc.Indicator11 = 1 then 1 else 0 end
		   + case when boqc.Indicator12 = 1 then 1 else 0 end as FDNeedsImprovement

		, case when boqc.Indicator9 = 2 then 1 else 0 end
		   + case when boqc.Indicator10 = 2 then 1 else 0 end
		   + case when boqc.Indicator11 = 2 then 1 else 0 end
		   + case when boqc.Indicator12 = 2 then 1 else 0 end as FDInPlace

		, convert(decimal(5,2), boqc.Indicator9 + boqc.Indicator10 + 
					boqc.Indicator11 + boqc.Indicator12) / 4 as FDAvg--FD

		--CV
		, case when boqc.Indicator13 = 0 then 1 else 0 end
		   + case when boqc.Indicator14 = 0 then 1 else 0 end
		   + case when boqc.Indicator15 = 0 then 1 else 0 end
		   + case when boqc.Indicator16 = 0 then 1 else 0 end as CVNotInPlace

		, case when boqc.Indicator13 = 1 then 1 else 0 end
		   + case when boqc.Indicator14 = 1 then 1 else 0 end
		   + case when boqc.Indicator15 = 1 then 1 else 0 end
		   + case when boqc.Indicator16 = 1 then 1 else 0 end as CVNeedsImprovement

		, case when boqc.Indicator13 = 2 then 1 else 0 end
		   + case when boqc.Indicator14 = 2 then 1 else 0 end
		   + case when boqc.Indicator15 = 2 then 1 else 0 end
		   + case when boqc.Indicator16 = 2 then 1 else 0 end as CVInPlace

		, convert(decimal(5,2), boqc.Indicator13 + boqc.Indicator14 + 
					boqc.Indicator15 + boqc.Indicator16) / 4 as CVAvg --CV

		 --IDS
		, case when boqc.Indicator17 = 0 then 1 else 0 end
		   + case when boqc.Indicator18 = 0 then 1 else 0 end
		   + case when boqc.Indicator19 = 0 then 1 else 0 end
		   + case when boqc.Indicator20 = 0 then 1 else 0 end
		   + case when boqc.Indicator21 = 0 then 1 else 0 end as IDSNotInPlace

		, case when boqc.Indicator17 = 1 then 1 else 0 end
		   + case when boqc.Indicator18 = 1 then 1 else 0 end
		   + case when boqc.Indicator19 = 1 then 1 else 0 end
		   + case when boqc.Indicator20 = 1 then 1 else 0 end
		   + case when boqc.Indicator21 = 1 then 1 else 0 end as IDSNeedsImprovement

		, case when boqc.Indicator17 = 2 then 1 else 0 end
		   + case when boqc.Indicator18 = 2 then 1 else 0 end
		   + case when boqc.Indicator19 = 2 then 1 else 0 end
		   + case when boqc.Indicator20 = 2 then 1 else 0 end
		   + case when boqc.Indicator21 = 2 then 1 else 0 end as IDSInPlace

		, convert(decimal(5,2), boqc.Indicator17 + boqc.Indicator18 + boqc.Indicator19 +
					boqc.Indicator20 + boqc.Indicator21) / 5 as IDSAvg --IDS
		
		 --FM
		, case when boqc.Indicator22 = 0 then 1 else 0 end
		   + case when boqc.Indicator23 = 0 then 1 else 0 end as FMNotInPlace

		, case when boqc.Indicator22 = 1 then 1 else 0 end
		   + case when boqc.Indicator23 = 1 then 1 else 0 end as FMNeedsImprovement

		, case when boqc.Indicator22 = 2 then 1 else 0 end
		   + case when boqc.Indicator23 = 2 then 1 else 0 end as FMInPlace

		, convert(decimal(5,2), boqc.Indicator22 + boqc.Indicator23) / 2 as FMAvg --FM

		 --BS
		, case when boqc.Indicator24 = 0 then 1 else 0 end
		   + case when boqc.Indicator25 = 0 then 1 else 0 end
		   + case when boqc.Indicator26 = 0 then 1 else 0 end as BSNotInPlace

		, case when boqc.Indicator24 = 1 then 1 else 0 end
		   + case when boqc.Indicator25 = 1 then 1 else 0 end
		   + case when boqc.Indicator26 = 1 then 1 else 0 end as BSNeedsImprovement

		, case when boqc.Indicator24 = 2 then 1 else 0 end
		   + case when boqc.Indicator25 = 2 then 1 else 0 end
		   + case when boqc.Indicator26 = 2 then 1 else 0 end as BSInPlace

		, convert(decimal(5,2), boqc.Indicator24 + boqc.Indicator25 + boqc.Indicator26) / 3 as BSAvg--BS

		 --PD
		, case when boqc.Indicator27 = 0 then 1 else 0 end
		   + case when boqc.Indicator28 = 0 then 1 else 0 end
		   + case when boqc.Indicator29 = 0 then 1 else 0 end
		   + case when boqc.Indicator30 = 0 then 1 else 0 end
		   + case when boqc.Indicator31 = 0 then 1 else 0 end
		   + case when boqc.Indicator32 = 0 then 1 else 0 end as PDNotInPlace

		, case when boqc.Indicator27 = 1 then 1 else 0 end
		   + case when boqc.Indicator28 = 1 then 1 else 0 end
		   + case when boqc.Indicator29 = 1 then 1 else 0 end
		   + case when boqc.Indicator30 = 1 then 1 else 0 end
		   + case when boqc.Indicator31 = 1 then 1 else 0 end
		   + case when boqc.Indicator32 = 1 then 1 else 0 end as PDNeedsImprovement

		, case when boqc.Indicator27 = 2 then 1 else 0 end
		   + case when boqc.Indicator28 = 2 then 1 else 0 end
		   + case when boqc.Indicator29 = 2 then 1 else 0 end
		   + case when boqc.Indicator30 = 2 then 1 else 0 end
		   + case when boqc.Indicator31 = 2 then 1 else 0 end
		   + case when boqc.Indicator32 = 2 then 1 else 0 end as PDInPlace
		
		, convert(decimal(5,2), boqc.Indicator27 + boqc.Indicator28 + boqc.Indicator29 + 
					boqc.Indicator30 + boqc.Indicator31 + boqc.Indicator32) / 6 as PDAvg--PD

		 --MIO
		, case when boqc.Indicator33 = 0 then 1 else 0 END
			+ case when boqc.Indicator34 = 0 then 1 else 0 end
			+ case when boqc.Indicator35 = 0 then 1 else 0 end
			+ case when boqc.Indicator36 = 0 then 1 else 0 end
			+ case when boqc.Indicator37 = 0 then 1 else 0 end
			+ case when boqc.Indicator38 = 0 then 1 else 0 end
			+ case when boqc.Indicator39 = 0 then 1 else 0 end AS MIONotInPlace

		, case when boqc.Indicator33 = 1 then 1 else 0 END
			+ case when boqc.Indicator34 = 1 then 1 else 0 END
			+ case when boqc.Indicator35 = 1 then 1 else 0 END
			+ case when boqc.Indicator36 = 1 then 1 else 0 END
			+ case when boqc.Indicator37 = 1 then 1 else 0 END
			+ case when boqc.Indicator38 = 1 then 1 else 0 END
			+ case when boqc.Indicator39 = 1 then 1 else 0 END AS MIONeedsImprovement

		, case when boqc.Indicator33 = 2 then 1 else 0 END
			+ case when boqc.Indicator34 = 2 then 1 else 0 END
			+ case when boqc.Indicator35 = 2 then 1 else 0 END
			+ case when boqc.Indicator36 = 2 then 1 else 0 END
			+ case when boqc.Indicator37 = 2 then 1 else 0 END
			+ case when boqc.Indicator38 = 2 then 1 else 0 END
			+ case when boqc.Indicator39 = 2 then 1 else 0 END AS MIOInPlace
		
		, convert(decimal(5,2), boqc.Indicator33 + boqc.Indicator34 + boqc.Indicator35 + 
					boqc.Indicator36 + boqc.Indicator37 + boqc.Indicator38 + boqc.Indicator39) / 7 as MIOAvg--MIO

	FROM dbo.BenchmarkOfQualityCWLT boqc
		INNER JOIN dbo.Hub h 
			ON h.HubPK = boqc.HubFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = boqc.HubFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized 
		  boqc.FormDate BETWEEN @StartDate AND @EndDate
	ORDER BY boqc.FormDate ASC

	--Get the CLTMT data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'CLTMT', 'Community Leadership Team Membership and Teaming', tabq.CLTMTAvg, tabq.CLTMTNotInPlace, tabq.CLTMTNeedsImprovement, tabq.CLTMTInPlace
	FROM @tblAllBOQs tabq

	--Get the FD data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'FD', 'Funding', tabq.FDAvg, tabq.FDNotInPlace, tabq.FDNeedsImprovement, tabq.FDInPlace
	FROM @tblAllBOQs tabq

	--Get the CV data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'CV', 'Communication and Visibility', tabq.CVAvg, tabq.CVNotInPlace, tabq.CVNeedsImprovement, tabq.CVInPlace
	FROM @tblAllBOQs tabq

	--Get the IDS data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'IDS', 'Implementation and Demonstration Sites', tabq.IDSAvg, tabq.IDSNotInPlace, tabq.IDSNeedsImprovement, tabq.IDSInPlace
	FROM @tblAllBOQs tabq

	--Get the FM data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'FM', 'Families', tabq.FMAvg, tabq.FMNotInPlace, tabq.FMNeedsImprovement, tabq.FMInPlace
	FROM @tblAllBOQs tabq

	--Get the BS data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'BS', 'Behavior Support', tabq.BSAvg, tabq.BSNotInPlace, tabq.BSNeedsImprovement, tabq.BSInPlace
	FROM @tblAllBOQs tabq

	--Get the PD data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'PD', 'Professional Development', tabq.PDAvg, tabq.PDNotInPlace, tabq.PDNeedsImprovement, tabq.PDInPlace
	FROM @tblAllBOQs tabq

	--Get the MIO data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    HubFK,
	    HubName,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.HubFK, tabq.HubName, 
		'MIO', 'Monitoring Implementation and Outcomes', tabq.MIOAvg, tabq.MIONotInPlace, tabq.MIONeedsImprovement, tabq.MIOInPlace
	FROM @tblAllBOQs tabq

	SELECT * 
	FROM @tblBOQData tbd

END
GO

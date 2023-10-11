SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 07/26/2022
-- Description:	State Leadership Team BOQ Trend Report
-- =============================================
CREATE PROC [dbo].[rspBOQSLTTrend]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@StateFKs VARCHAR(8000) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interSCSring with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblAllBOQs TABLE (
		BOQPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		StateFK INT NOT NULL,
		StateName VARCHAR(400) NOT NULL,
		SMLNotInPlace INT NOT NULL,
		SMLNeedsImprovement INT NOT NULL,
		SMLInPlace INT NOT NULL,
		SMLAvg DECIMAL(5,2) NOT NULL,
		APNotInPlace INT NOT NULL,
		APNeedsImprovement INT NOT NULL,
		APInPlace INT NOT NULL,
		APAvg DECIMAL(5,2) NOT NULL,
		SCSNotInPlace INT NOT NULL,
		SCSNeedsImprovement INT NOT NULL,
		SCSInPlace INT NOT NULL,
		SCSAvg DECIMAL(5,2) NOT NULL,
		SFNotInPlace INT NOT NULL,
		SFNeedsImprovement INT NOT NULL,
		SFInPlace INT NOT NULL,
		SFAvg DECIMAL(5,2) NOT NULL,
		SCVNotInPlace INT NOT NULL,
		SCVNeedsImprovement INT NOT NULL,
		SCVInPlace INT NOT NULL,
		SCVAvg DECIMAL(5,2) NOT NULL,
		APCLNotInPlace INT NOT NULL,
		APCLNeedsImprovement INT NOT NULL,
		APCLInPlace INT NOT NULL,
		APCLAvg DECIMAL(5,2) NOT NULL,
		FPCNotInPlace INT NOT NULL,
		FPCNeedsImprovement INT NOT NULL,
		FPCInPlace INT NOT NULL,
		FPCAvg DECIMAL(5,2) NOT NULL,
		IPSNotInPlace INT NOT NULL,
		IPSNeedsImprovement INT NOT NULL,
		IPSInPlace INT NOT NULL,
		IPSAvg DECIMAL(5,2) NOT NULL,
		DPSNotInPlace INT NOT NULL,
		DPSNeedsImprovement INT NOT NULL,
		DPSInPlace INT NOT NULL,
		DPSAvg DECIMAL(5,2) NOT NULL,
		ICNotInPlace INT NOT NULL,
		ICNeedsImprovement INT NOT NULL,
		ICInPlace INT NOT NULL,
		ICAvg DECIMAL(5,2) NOT NULL,
		PCNotInPlace INT NOT NULL,
		PCNeedsImprovement INT NOT NULL,
		PCInPlace INT NOT NULL,
		PCAvg DECIMAL(5,2) NOT NULL,
		OSTANotInPlace INT NOT NULL,
		OSTANeedsImprovement INT NOT NULL,
		OSTAInPlace INT NOT NULL,
		OSTAAvg DECIMAL(5,2) NOT NULL,
		DBDMNotInPlace INT NOT NULL,
		DBDMNeedsImprovement INT NOT NULL,
		DBDMInPlace INT NOT NULL,
		DBDMAvg DECIMAL(5,2) NOT NULL

	)

	DECLARE @tblBOQData TABLE (
		BOQPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		StateFK INT NOT NULL,
		StateName VARCHAR(400) NOT NULL,
		SectionOrderBy INT NOT NULL,
		SectionAbbr VARCHAR(10) NOT NULL,
		SectionName VARCHAR(200) NOT NULL,
		SectionColor VARCHAR(100) NOT NULL,
		CriticalElementOrderBy INT NOT NULL,
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
	    StateFK,
	    StateName,
	    SMLNotInPlace,
	    SMLNeedsImprovement,
	    SMLInPlace,
	    SMLAvg,
	    APNotInPlace,
	    APNeedsImprovement,
	    APInPlace,
	    APAvg,
	    SCSNotInPlace,
	    SCSNeedsImprovement,
	    SCSInPlace,
	    SCSAvg,
	    SFNotInPlace,
	    SFNeedsImprovement,
	    SFInPlace,
	    SFAvg,
	    SCVNotInPlace,
	    SCVNeedsImprovement,
	    SCVInPlace,
	    SCVAvg,
	    APCLNotInPlace,
	    APCLNeedsImprovement,
	    APCLInPlace,
	    APCLAvg,
	    FPCNotInPlace,
	    FPCNeedsImprovement,
	    FPCInPlace,
	    FPCAvg,
	    IPSNotInPlace,
	    IPSNeedsImprovement,
	    IPSInPlace,
	    IPSAvg,
	    DPSNotInPlace,
	    DPSNeedsImprovement,
	    DPSInPlace,
	    DPSAvg,
	    ICNotInPlace,
	    ICNeedsImprovement,
	    ICInPlace,
	    ICAvg,
	    PCNotInPlace,
	    PCNeedsImprovement,
	    PCInPlace,
	    PCAvg,
	    OSTANotInPlace,
	    OSTANeedsImprovement,
	    OSTAInPlace,
	    OSTAAvg,
	    DBDMNotInPlace,
	    DBDMNeedsImprovement,
	    DBDMInPlace,
	    DBDMAvg
	)
	SELECT boqs.BenchmarkOfQualitySLTPK
		 , boqs.FormDate
		 , CASE WHEN DATEPART(MONTH, boqs.FormDate) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqs.FormDate)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, boqs.FormDate)), '-2-Fall') END AS GroupingValue
		 , CASE WHEN DATEPART(MONTH, boqs.FormDate) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqs.FormDate))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, boqs.FormDate))) END AS GroupingText
		 , boqs.StateFK
		 , s.[Name] 

		 --SML
		 , case when boqs.Indicator1 = 0 then 1 else 0 end
		   + case when boqs.Indicator2 = 0 then 1 else 0 end
		   + case when boqs.Indicator3 = 0 then 1 else 0 end
		   + case when boqs.Indicator4 = 0 then 1 else 0 end
		   + case when boqs.Indicator5 = 0 then 1 else 0 end
		   + case when boqs.Indicator6 = 0 then 1 else 0 end
		   + case when boqs.Indicator7 = 0 then 1 else 0 end
		   + case when boqs.Indicator8 = 0 then 1 else 0 end
		   + case when boqs.Indicator9 = 0 then 1 else 0 end
		   + case when boqs.Indicator10 = 0 then 1 else 0 end as SMLNotInPlace

		 , case when boqs.Indicator1 = 1 then 1 else 0 end
		   + case when boqs.Indicator2 = 1 then 1 else 0 end
		   + case when boqs.Indicator3 = 1 then 1 else 0 end
		   + case when boqs.Indicator4 = 1 then 1 else 0 end
		   + case when boqs.Indicator5 = 1 then 1 else 0 end
		   + case when boqs.Indicator6 = 1 then 1 else 0 end
		   + case when boqs.Indicator7 = 1 then 1 else 0 end
		   + case when boqs.Indicator8 = 1 then 1 else 0 end
		   + case when boqs.Indicator9 = 1 then 1 else 0 end
		   + case when boqs.Indicator10 = 1 then 1 else 0 end as SMLNeedsImprovement

		, case when boqs.Indicator1 = 2 then 1 else 0 end
		   + case when boqs.Indicator2 = 2 then 1 else 0 end
		   + case when boqs.Indicator3 = 2 then 1 else 0 end
		   + case when boqs.Indicator4 = 2 then 1 else 0 end
		   + case when boqs.Indicator5 = 2 then 1 else 0 end
		   + case when boqs.Indicator6 = 2 then 1 else 0 end
		   + case when boqs.Indicator7 = 2 then 1 else 0 end
		   + case when boqs.Indicator8 = 2 then 1 else 0 end
		   + case when boqs.Indicator9 = 2 then 1 else 0 end
		   + case when boqs.Indicator10 = 2 then 1 else 0 end as SMLInPlace

		, convert(decimal(5,2), boqs.Indicator1 + boqs.Indicator2 + boqs.Indicator3 + 
					boqs.Indicator4 + boqs.Indicator5 + boqs.Indicator6 + boqs.Indicator7 + 
					boqs.Indicator8 + boqs.Indicator9 + boqs.Indicator10) / 10 as SMLAvg --SML
		
		 --AP
		, case when boqs.Indicator11 = 0 then 1 else 0 end
		   + case when boqs.Indicator12 = 0 then 1 else 0 end
		   + case when boqs.Indicator13 = 0 then 1 else 0 end
		   + case when boqs.Indicator14 = 0 then 1 else 0 end
		   + case when boqs.Indicator15 = 0 then 1 else 0 end as APNotInPlace

		, case when boqs.Indicator11 = 1 then 1 else 0 end
		   + case when boqs.Indicator12 = 1 then 1 else 0 end
		   + case when boqs.Indicator13 = 1 then 1 else 0 end
		   + case when boqs.Indicator14 = 1 then 1 else 0 end
		   + case when boqs.Indicator15 = 1 then 1 else 0 end as APNeedsImprovement

		, case when boqs.Indicator11 = 2 then 1 else 0 end
		   + case when boqs.Indicator12 = 2 then 1 else 0 end
		   + case when boqs.Indicator13 = 2 then 1 else 0 end
		   + case when boqs.Indicator14 = 2 then 1 else 0 end
		   + case when boqs.Indicator15 = 2 then 1 else 0 end as APInPlace

		, convert(decimal(5,2), boqs.Indicator11 + boqs.Indicator12 + 
					boqs.Indicator13 + boqs.Indicator14 + boqs.Indicator15) / 5 as APAvg--AP

		--SCS
		, case when boqs.Indicator16 = 0 then 1 else 0 end
		   + case when boqs.Indicator17 = 0 then 1 else 0 end
		   + case when boqs.Indicator18 = 0 then 1 else 0 end as SCSNotInPlace

		, case when boqs.Indicator16 = 1 then 1 else 0 end
		   + case when boqs.Indicator17 = 1 then 1 else 0 end
		   + case when boqs.Indicator18 = 1 then 1 else 0 end as SCSNeedsImprovement

		, case when boqs.Indicator16 = 2 then 1 else 0 end
		   + case when boqs.Indicator17 = 2 then 1 else 0 end
		   + case when boqs.Indicator18 = 2 then 1 else 0 end as SCSInPlace

		, convert(decimal(5,2), boqs.Indicator16 + boqs.Indicator17 + 
					boqs.Indicator18) / 3 as SCSAvg --SCS

		 --SF
		, case when boqs.Indicator19 = 0 then 1 else 0 end
		   + case when boqs.Indicator20 = 0 then 1 else 0 end as SFNotInPlace

		, case when boqs.Indicator19 = 1 then 1 else 0 end
		   + case when boqs.Indicator20 = 1 then 1 else 0 end as SFNeedsImprovement

		, case when boqs.Indicator19 = 2 then 1 else 0 end
		   + case when boqs.Indicator20 = 2 then 1 else 0 end as SFInPlace

		, convert(decimal(5,2), boqs.Indicator19 + boqs.Indicator20) / 2 as SFAvg --SF
		
		 --SCV
		, case when boqs.Indicator21 = 0 then 1 else 0 end
		   + case when boqs.Indicator22 = 0 then 1 else 0 end
		   + case when boqs.Indicator23 = 0 then 1 else 0 end as SCVNotInPlace

		, case when boqs.Indicator21 = 1 then 1 else 0 end
		   + case when boqs.Indicator22 = 1 then 1 else 0 end
		   + case when boqs.Indicator23 = 1 then 1 else 0 end as SCVNeedsImprovement

		, case when boqs.Indicator21 = 2 then 1 else 0 end
		   + case when boqs.Indicator22 = 2 then 1 else 0 end
		   + case when boqs.Indicator23 = 2 then 1 else 0 end as SCVInPlace

		, convert(decimal(5,2), boqs.Indicator21 + boqs.Indicator22 + boqs.Indicator23) / 3 as SCVAvg --SCV

		 --APCL
		, case when boqs.Indicator24 = 0 then 1 else 0 end
		   + case when boqs.Indicator25 = 0 then 1 else 0 end
		   + case when boqs.Indicator26 = 0 then 1 else 0 end
		   + case when boqs.Indicator27 = 0 then 1 else 0 end as APCLNotInPlace

		, case when boqs.Indicator24 = 1 then 1 else 0 end
		   + case when boqs.Indicator25 = 1 then 1 else 0 end
		   + case when boqs.Indicator26 = 1 then 1 else 0 end
		   + case when boqs.Indicator27 = 1 then 1 else 0 end as APCLNeedsImprovement

		, case when boqs.Indicator24 = 2 then 1 else 0 end
		   + case when boqs.Indicator25 = 2 then 1 else 0 end
		   + case when boqs.Indicator26 = 2 then 1 else 0 end
		   + case when boqs.Indicator27 = 2 then 1 else 0 end as APCLInPlace

		, convert(decimal(5,2), boqs.Indicator24 + boqs.Indicator25 + boqs.Indicator26 + 
					boqs.Indicator27) / 4 as APCLAvg--APCL

		 --FPC
		, case when boqs.Indicator28 = 0 then 1 else 0 end
		   + case when boqs.Indicator29 = 0 then 1 else 0 end
		   + case when boqs.Indicator30 = 0 then 1 else 0 end
		   + case when boqs.Indicator31 = 0 then 1 else 0 end as FPCNotInPlace

		, case when boqs.Indicator28 = 1 then 1 else 0 end
		   + case when boqs.Indicator29 = 1 then 1 else 0 end
		   + case when boqs.Indicator30 = 1 then 1 else 0 end
		   + case when boqs.Indicator31 = 1 then 1 else 0 end as FPCNeedsImprovement

		, case when boqs.Indicator28 = 2 then 1 else 0 end
		   + case when boqs.Indicator29 = 2 then 1 else 0 end
		   + case when boqs.Indicator30 = 2 then 1 else 0 end
		   + case when boqs.Indicator31 = 2 then 1 else 0 end as FPCInPlace
		
		, convert(decimal(5,2), boqs.Indicator28 + boqs.Indicator29 + boqs.Indicator30 + 
						boqs.Indicator31) / 4 as FPCAvg--FPC

		 --IPS
		, case when boqs.Indicator32 = 0 then 1 else 0 end as IPSNotInPlace

		, case when boqs.Indicator32 = 1 then 1 else 0 END AS IPSNeedsImprovement

		, case when boqs.Indicator32 = 2 then 1 else 0 end as IPSInPlace
		
		, convert(decimal(5,2), boqs.Indicator32) as IPSAvg--IPS

		 --DPS
		, case when boqs.Indicator33 = 0 then 1 else 0 end as DPSNotInPlace

		, case when boqs.Indicator33 = 1 then 1 else 0 end as DPSNeedsImprovement

		, case when boqs.Indicator33 = 2 then 1 else 0 end as DPSInPlace
		
		, convert(decimal(5,2), boqs.Indicator33) as DPSAvg--DPS

		 --IC
		, case when boqs.Indicator34 = 0 then 1 else 0 end
		   + case when boqs.Indicator35 = 0 then 1 else 0 end as ICNotInPlace

		, case when boqs.Indicator34 = 1 then 1 else 0 end
		   + case when boqs.Indicator35 = 1 then 1 else 0 end as ICNeedsImprovement

		, case when boqs.Indicator34 = 2 then 1 else 0 end
		   + case when boqs.Indicator35 = 2 then 1 else 0 end as ICInPlace
		
		, convert(decimal(5,2), boqs.Indicator34 + boqs.Indicator35) / 2 as ICAvg--IC

		 --PC
		, case when boqs.Indicator36 = 0 then 1 else 0 end
		   + case when boqs.Indicator37 = 0 then 1 else 0 end
		   + case when boqs.Indicator38 = 0 then 1 else 0 end
		   + case when boqs.Indicator39 = 0 then 1 else 0 end
		   + case when boqs.Indicator40 = 0 then 1 else 0 end as PCNotInPlace

		, case when boqs.Indicator36 = 1 then 1 else 0 end
		   + case when boqs.Indicator37 = 1 then 1 else 0 end
		   + case when boqs.Indicator38 = 1 then 1 else 0 end
		   + case when boqs.Indicator39 = 1 then 1 else 0 end
		   + case when boqs.Indicator40 = 1 then 1 else 0 end as PCNeedsImprovement

		, case when boqs.Indicator36 = 2 then 1 else 0 end
		   + case when boqs.Indicator37 = 2 then 1 else 0 end
		   + case when boqs.Indicator38 = 2 then 1 else 0 end
		   + case when boqs.Indicator39 = 2 then 1 else 0 end
		   + case when boqs.Indicator40 = 2 then 1 else 0 end as PCInPlace
		
		, convert(decimal(5,2), boqs.Indicator36 + boqs.Indicator37 + boqs.Indicator38 + 
						boqs.Indicator39 + boqs.Indicator40) / 5 as PCAvg--PC

		 --OSTA
		, case when boqs.Indicator41 = 0 then 1 else 0 end
		   + case when boqs.Indicator42 = 0 then 1 else 0 end
		   + case when boqs.Indicator43 = 0 then 1 else 0 end as OSTANotInPlace

		, case when boqs.Indicator41 = 1 then 1 else 0 end
		   + case when boqs.Indicator42 = 1 then 1 else 0 end
		   + case when boqs.Indicator43 = 1 then 1 else 0 end as OSTANeedsImprovement

		, case when boqs.Indicator41 = 2 then 1 else 0 end
		   + case when boqs.Indicator42 = 2 then 1 else 0 end
		   + case when boqs.Indicator43 = 2 then 1 else 0 end as OSTAInPlace
		
		, convert(decimal(5,2), boqs.Indicator41 + boqs.Indicator42 + boqs.Indicator43) / 3 as OSTAAvg--OSTA

		 --DBDM
		, case when boqs.Indicator44 = 0 then 1 else 0 end
		   + case when boqs.Indicator45 = 0 then 1 else 0 end
		   + case when boqs.Indicator46 = 0 then 1 else 0 end
		   + case when boqs.Indicator47 = 0 then 1 else 0 end
		   + case when boqs.Indicator48 = 0 then 1 else 0 end
		   + case when boqs.Indicator49 = 0 then 1 else 0 end as DBDMNotInPlace

		, case when boqs.Indicator44 = 1 then 1 else 0 end
		   + case when boqs.Indicator45 = 1 then 1 else 0 end
		   + case when boqs.Indicator46 = 1 then 1 else 0 end
		   + case when boqs.Indicator47 = 1 then 1 else 0 end
		   + case when boqs.Indicator48 = 1 then 1 else 0 end
		   + case when boqs.Indicator49 = 1 then 1 else 0 end as DBDMNeedsImprovement

		, case when boqs.Indicator44 = 2 then 1 else 0 end
		   + case when boqs.Indicator45 = 2 then 1 else 0 end
		   + case when boqs.Indicator46 = 2 then 1 else 0 end
		   + case when boqs.Indicator47 = 2 then 1 else 0 end
		   + case when boqs.Indicator48 = 2 then 1 else 0 end
		   + case when boqs.Indicator49 = 2 then 1 else 0 end as DBDMInPlace
		
		, convert(decimal(5,2), boqs.Indicator44 + boqs.Indicator45 + boqs.Indicator46 + 
						boqs.Indicator47 + boqs.Indicator48 + boqs.Indicator49) / 6 as DBDMAvg--DBDM
		
	FROM dbo.BenchmarkOfQualitySLT boqs
		INNER JOIN dbo.[State] s
			ON s.StatePK = boqs.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = boqs.StateFK
	WHERE boqs.FormDate BETWEEN @StartDate AND @EndDate
	ORDER BY boqs.FormDate ASC

	--Get the SML data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName,
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		1, 'SML', 'SLT Membership and Logistics', tabq.SMLAvg, tabq.SMLNotInPlace, tabq.SMLNeedsImprovement, tabq.SMLInPlace
	FROM @tblAllBOQs tabq

	--Get the AP data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		2, 'AP', 'Action Planning', tabq.APAvg, tabq.APNotInPlace, tabq.APNeedsImprovement, tabq.APInPlace
	FROM @tblAllBOQs tabq

	--Get the SCS data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		3, 'SCS', 'SLT Coordination and Staffing', tabq.SCSAvg, tabq.SCSNotInPlace, tabq.SCSNeedsImprovement, tabq.SCSInPlace
	FROM @tblAllBOQs tabq

	--Get the SF data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		4, 'SF', 'SLT Funding', tabq.SFAvg, tabq.SFNotInPlace, tabq.SFNeedsImprovement, tabq.SFInPlace
	FROM @tblAllBOQs tabq

	--Get the SCV data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		5, 'SCV', 'SLT Communication & Visibility', tabq.SCVAvg, tabq.SCVNotInPlace, tabq.SCVNeedsImprovement, tabq.SCVInPlace
	FROM @tblAllBOQs tabq

	--Get the APCL data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		1, 'SLT', 'State Leadership Team (SLT)', '253,233,217',
		6, 'APCL', 'Authority, Priority, and Communication Linkages', tabq.APCLAvg, tabq.APCLNotInPlace, tabq.APCLNeedsImprovement, tabq.APCLInPlace
	FROM @tblAllBOQs tabq

	--Get the FPC data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy, 
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		2, 'FE', 'Family Engagement', '218,238,243',
		7, 'FPC', 'Family Participation and Communication', tabq.FPCAvg, tabq.FPCNotInPlace, tabq.FPCNeedsImprovement, tabq.FPCInPlace
	FROM @tblAllBOQs tabq

	--Get the IPS data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		3, 'IPDS', 'Implementation and Demonstration Programs/Sites', '229,223,236',
		8, 'IPS', 'Implementation Programs/Sites', tabq.IPSAvg, tabq.IPSNotInPlace, tabq.IPSNeedsImprovement, tabq.IPSInPlace
	FROM @tblAllBOQs tabq

	--Get the DPS data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		3, 'IPDS', 'Implementation and Demonstration Programs/Sites', '229,223,236',
		9, 'DPS', 'Demonstration Programs/Sites', tabq.DPSAvg, tabq.DPSNotInPlace, tabq.DPSNeedsImprovement, tabq.DPSInPlace
	FROM @tblAllBOQs tabq

	--Get the IC data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		3, 'IPDS', 'Implementation and Demonstration Programs/Sites', '229,223,236',
		10, 'IC', 'Implementation Communities', tabq.ICAvg, tabq.ICNotInPlace, tabq.ICNeedsImprovement, tabq.ICInPlace
	FROM @tblAllBOQs tabq

	--Get the PC data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		4, 'PD', 'Professional Development', '234,241,221',
		11, 'PC', 'Program Coaches', tabq.PCAvg, tabq.PCNotInPlace, tabq.PCNeedsImprovement, tabq.PCInPlace
	FROM @tblAllBOQs tabq

	--Get the OSTA data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		4, 'PD', 'Professional Development', '234,241,221',
		12, 'OSTA', 'Ongoing Support and Technical Assistance', tabq.OSTAAvg, tabq.OSTANotInPlace, tabq.OSTANeedsImprovement, tabq.OSTAInPlace
	FROM @tblAllBOQs tabq

	--Get the DBDM data
	INSERT INTO @tblBOQData
	(
	    BOQPK,
	    FormDate,
		GroupingValue,
		GroupingText,
	    StateFK,
	    StateName,
		SectionOrderBy,
		SectionAbbr, 
		SectionName, 
		SectionColor, 
		CriticalElementOrderBy,
		CriticalElementAbbr,
	    CriticalElementName,
	    CriticalElementAvg,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumNeedsImprovement,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.StateFK, tabq.StateName, 
		5, 'DBDM', 'Evaluation/Data-Based Decision Making', '242,219,219',
		13, 'DBDM', 'Data-Based Decision Making', tabq.DBDMAvg, tabq.DBDMNotInPlace, tabq.DBDMNeedsImprovement, tabq.DBDMInPlace
	FROM @tblAllBOQs tabq

	SELECT * 
	FROM @tblBOQData tbd

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons (copied from Bill O'Brien's BOQ Trend report)
-- Create date: 09/18/2019
-- Description:	BOQ FCC Trend Report
-- =============================================
CREATE PROC [dbo].[rspBOQFCCTrend]
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
		EMPINotApplicable INT NOT NULL,
		EMPINotInPlace INT NOT NULL,
		EMPIPartial INT NOT NULL,
		EMPIInPlace INT NOT NULL,
		EMPIAvg DECIMAL(5,2) NOT NULL,
		FINotApplicable INT NOT NULL,
		FINotInPlace INT NOT NULL,
		FIPartial INT NOT NULL,
		FIInPlace INT NOT NULL,
		FIAvg DECIMAL(5,2) NOT NULL,
		PWENotApplicable INT NOT NULL,
		PWENotInPlace INT NOT NULL,
		PWEPartial INT NOT NULL,
		PWEInPlace INT NOT NULL,
		PWEAvg DECIMAL(5,2) NOT NULL,
		STAPWENotApplicable INT NOT NULL,
		STAPWENotInPlace INT NOT NULL,
		STAPWEPartial INT NOT NULL,
		STAPWEInPlace INT NOT NULL,
		STAPWEAvg DECIMAL(5,2) NOT NULL,
		IPMDAENotApplicable INT NOT NULL,
		IPMDAENotInPlace INT NOT NULL,
		IPMDAEPartial INT NOT NULL,
		IPMDAEInPlace INT NOT NULL,
		IPMDAEAvg DECIMAL(5,2) NOT NULL,
		PRCBNotApplicable INT NOT NULL,
		PRCBNotInPlace INT NOT NULL,
		PRCBPartial INT NOT NULL,
		PRCBInPlace INT NOT NULL,
		PRCBAvg DECIMAL(5,2) NOT NULL,
		PDSPNotApplicable INT NOT NULL,
		PDSPNotInPlace INT NOT NULL,
		PDSPPartial INT NOT NULL,
		PDSPInPlace INT NOT NULL,
		PDSPAvg DECIMAL(5,2) NOT NULL,
		MIONotApplicable INT NOT NULL,
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
		CriticalElementNumNotApplicable INT NOT NULL,
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
		EMPINotApplicable,
	    EMPINotInPlace,
	    EMPIPartial,
	    EMPIInPlace,
	    EMPIAvg,
		FINotApplicable,
	    FINotInPlace,
	    FIPartial,
	    FIInPlace,
	    FIAvg,
		PWENotApplicable,
	    PWENotInPlace,
	    PWEPartial,
	    PWEInPlace,
	    PWEAvg,
		STAPWENotApplicable,
	    STAPWENotInPlace,
	    STAPWEPartial,
	    STAPWEInPlace,
	    STAPWEAvg,
		IPMDAENotApplicable,
	    IPMDAENotInPlace,
	    IPMDAEPartial,
	    IPMDAEInPlace,
	    IPMDAEAvg,
		PRCBNotApplicable,
	    PRCBNotInPlace,
	    PRCBPartial,
	    PRCBInPlace,
	    PRCBAvg,
		PDSPNotApplicable,
	    PDSPNotInPlace,
	    PDSPPartial,
	    PDSPInPlace,
	    PDSPAvg,
		MIONotApplicable,
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
		 , case when boqf.Indicator1 = 99 then 1 else 0 end
		   + case when boqf.Indicator2 = 99 then 1 else 0 end
		   + case when boqf.Indicator3 = 99 then 1 else 0 end
		   + case when boqf.Indicator4 = 99 then 1 else 0 end
		   + case when boqf.Indicator5 = 99 then 1 else 0 end
		   + case when boqf.Indicator6 = 99 then 1 else 0 end as EMPINotApplicable

		 , case when boqf.Indicator1 = 0 then 1 else 0 end
		   + case when boqf.Indicator2 = 0 then 1 else 0 end
		   + case when boqf.Indicator3 = 0 then 1 else 0 end
		   + case when boqf.Indicator4 = 0 then 1 else 0 end
		   + case when boqf.Indicator5 = 0 then 1 else 0 end
		   + case when boqf.Indicator6 = 0 then 1 else 0 end as EMPINotInPlace

		 , case when boqf.Indicator1 = 1 then 1 else 0 end
		   + case when boqf.Indicator2 = 1 then 1 else 0 end
		   + case when boqf.Indicator3 = 1 then 1 else 0 end
		   + case when boqf.Indicator4 = 1 then 1 else 0 end
		   + case when boqf.Indicator5 = 1 then 1 else 0 end
		   + case when boqf.Indicator6 = 1 then 1 else 0 end as EMPIPartiallyInPlace

		, case when boqf.Indicator1 = 2 then 1 else 0 end
		   + case when boqf.Indicator2 = 2 then 1 else 0 end
		   + case when boqf.Indicator3 = 2 then 1 else 0 end
		   + case when boqf.Indicator4 = 2 then 1 else 0 end
		   + case when boqf.Indicator5 = 2 then 1 else 0 end
		   + case when boqf.Indicator6 = 2 then 1 else 0 end as EMPIInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator1 = 99 THEN 0 ELSE boqf.Indicator1 END + CASE WHEN boqf.Indicator2 = 99 THEN 0 ELSE boqf.Indicator2 END + CASE WHEN boqf.Indicator3 = 99 THEN 0 ELSE boqf.Indicator3 END 
					+ CASE WHEN boqf.Indicator4 = 99 THEN 0 ELSE boqf.Indicator4 END + CASE WHEN boqf.Indicator5 = 99 THEN 0 ELSE boqf.Indicator5 END + CASE WHEN boqf.Indicator6 = 99 THEN 0 ELSE boqf.Indicator6 END) / 6 as EMPIAvg --EMPI
		
		 --FI
		, case when boqf.Indicator7 = 99 then 1 else 0 end
		   + CASE when boqf.Indicator8 = 99 then 1 else 0 end
		   + case when boqf.Indicator9 = 99 then 1 else 0 end
		   + case when boqf.Indicator10 = 99 then 1 else 0 end as FINotApplicable

		, case when boqf.Indicator7 = 0 then 1 else 0 end
		   + CASE when boqf.Indicator8 = 0 then 1 else 0 end
		   + case when boqf.Indicator9 = 0 then 1 else 0 end
		   + case when boqf.Indicator10 = 0 then 1 else 0 end as FINotInPlace

		, case when boqf.Indicator7 = 1 then 1 else 0 end
		   + CASE when boqf.Indicator8 = 1 then 1 else 0 end
		   + case when boqf.Indicator9 = 1 then 1 else 0 end
		   + case when boqf.Indicator10 = 1 then 1 else 0 end as FIPartiallyInPlace

		, case when boqf.Indicator7 = 2 then 1 else 0 end
		   + CASE when boqf.Indicator8 = 2 then 1 else 0 end
		   + case when boqf.Indicator9 = 2 then 1 else 0 end
		   + case when boqf.Indicator10 = 2 then 1 else 0 end as FIInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator7 = 99 THEN 0 ELSE boqf.Indicator7 END + CASE WHEN boqf.Indicator8 = 99 THEN 0 ELSE boqf.Indicator8 END + CASE WHEN boqf.Indicator9 = 99 THEN 0 ELSE boqf.Indicator9 END + CASE WHEN boqf.Indicator10 = 99 THEN 0 ELSE boqf.Indicator10 END) / 4 as FIAvg--FI

		--PWE
		, case when boqf.Indicator11 = 99 then 1 else 0 end
		   + case when boqf.Indicator12 = 99 then 1 else 0 end
		   + case when boqf.Indicator13 = 99 then 1 else 0 end
		   + case when boqf.Indicator14 = 99 then 1 else 0 end
		   + case when boqf.Indicator15 = 99 then 1 else 0 end
		   + case when boqf.Indicator16 = 99 then 1 else 0 end
		   + case when boqf.Indicator17 = 99 then 1 else 0 end as PWENotApplicable

		, case when boqf.Indicator11 = 0 then 1 else 0 end
		   + case when boqf.Indicator12 = 0 then 1 else 0 end
		   + case when boqf.Indicator13 = 0 then 1 else 0 end
		   + case when boqf.Indicator14 = 0 then 1 else 0 end
		   + case when boqf.Indicator15 = 0 then 1 else 0 end
		   + case when boqf.Indicator16 = 0 then 1 else 0 end
		   + case when boqf.Indicator17 = 0 then 1 else 0 end as PWENotInPlace

		, case when boqf.Indicator11 = 1 then 1 else 0 end
		   + case when boqf.Indicator12 = 1 then 1 else 0 end
		   + case when boqf.Indicator13 = 1 then 1 else 0 end
		   + case when boqf.Indicator14 = 1 then 1 else 0 end
		   + case when boqf.Indicator15 = 1 then 1 else 0 end
		   + case when boqf.Indicator16 = 1 then 1 else 0 end
		   + case when boqf.Indicator17 = 1 then 1 else 0 end as PWEPartiallyInPlace

		, case when boqf.Indicator11 = 2 then 1 else 0 end
		   + case when boqf.Indicator12 = 2 then 1 else 0 end
		   + case when boqf.Indicator13 = 2 then 1 else 0 end
		   + case when boqf.Indicator14 = 2 then 1 else 0 end
		   + case when boqf.Indicator15 = 2 then 1 else 0 end
		   + case when boqf.Indicator16 = 2 then 1 else 0 end
		   + case when boqf.Indicator17 = 2 then 1 else 0 end as PWEInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator11 = 99 THEN 0 ELSE boqf.Indicator11 END + CASE WHEN boqf.Indicator12 = 99 THEN 0 ELSE boqf.Indicator12 END + CASE WHEN boqf.Indicator13 = 99 THEN 0 ELSE boqf.Indicator13 END 
					+ CASE WHEN boqf.Indicator14 = 99 THEN 0 ELSE boqf.Indicator14 END + CASE WHEN boqf.Indicator15 = 99 THEN 0 ELSE boqf.Indicator15 END + CASE WHEN boqf.Indicator16 = 99 THEN 0 ELSE boqf.Indicator16 END + CASE WHEN boqf.Indicator17 = 99 THEN 0 ELSE boqf.Indicator17 END) / 7 as PWEAvg --PWE

		 --STAPWE
		, case when boqf.Indicator18 = 99 then 1 else 0 end
		   + case when boqf.Indicator19 = 99 then 1 else 0 end
		   + case when boqf.Indicator20 = 99 then 1 else 0 end as STAPWENotApplicable

		, case when boqf.Indicator18 = 0 then 1 else 0 end
		   + case when boqf.Indicator19 = 0 then 1 else 0 end
		   + case when boqf.Indicator20 = 0 then 1 else 0 end as STAPWENotInPlace

		, case when boqf.Indicator18 = 1 then 1 else 0 end
		   + case when boqf.Indicator19 = 1 then 1 else 0 end
		   + case when boqf.Indicator20 = 1 then 1 else 0 end as STAPWEPartiallyInPlace

		, case when boqf.Indicator18 = 2 then 1 else 0 end
		   + case when boqf.Indicator19 = 2 then 1 else 0 end
		   + case when boqf.Indicator20 = 2 then 1 else 0 end as STAPWEInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator18 = 99 THEN 0 ELSE boqf.Indicator18 END + CASE WHEN boqf.Indicator19 = 99 THEN 0 ELSE boqf.Indicator19 END + CASE WHEN boqf.Indicator20 = 99 THEN 0 ELSE boqf.Indicator20 END) / 3 as STAPWEAvg --STAPWE
		
		 --IPMDAE
		 , case when boqf.Indicator21 = 99 then 1 else 0 end
		   + case when boqf.Indicator22 = 99 then 1 else 0 end
		   + case when boqf.Indicator23 = 99 then 1 else 0 end
		   + case when boqf.Indicator24 = 99 then 1 else 0 end
		   + case when boqf.Indicator25 = 99 then 1 else 0 end
		   + case when boqf.Indicator26 = 99 then 1 else 0 end as IPMDAENotApplicable

		, case when boqf.Indicator21 = 0 then 1 else 0 end
		   + case when boqf.Indicator22 = 0 then 1 else 0 end
		   + case when boqf.Indicator23 = 0 then 1 else 0 end
		   + case when boqf.Indicator24 = 0 then 1 else 0 end
		   + case when boqf.Indicator25 = 0 then 1 else 0 end
		   + case when boqf.Indicator26 = 0 then 1 else 0 end as IPMDAENotInPlace

		, case when boqf.Indicator21 = 1 then 1 else 0 end
		   + case when boqf.Indicator22 = 1 then 1 else 0 end
		   + case when boqf.Indicator23 = 1 then 1 else 0 end
		   + case when boqf.Indicator24 = 1 then 1 else 0 end
		   + case when boqf.Indicator25 = 1 then 1 else 0 end
		   + case when boqf.Indicator26 = 1 then 1 else 0 end as IPMDAEPartiallyInPlace

		, case when boqf.Indicator21 = 2 then 1 else 0 end
		   + case when boqf.Indicator22 = 2 then 1 else 0 end
		   + case when boqf.Indicator23 = 2 then 1 else 0 end
		   + case when boqf.Indicator24 = 2 then 1 else 0 end
		   + case when boqf.Indicator25 = 2 then 1 else 0 end
		   + case when boqf.Indicator26 = 2 then 1 else 0 end as IPMDAEInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator21 = 99 THEN 0 ELSE boqf.Indicator21 END + CASE WHEN boqf.Indicator22 = 99 THEN 0 ELSE boqf.Indicator22 END + CASE WHEN boqf.Indicator23 = 99 THEN 0 ELSE boqf.Indicator23 END 
					+ CASE WHEN boqf.Indicator24 = 99 THEN 0 ELSE boqf.Indicator24 END + CASE WHEN boqf.Indicator25 = 99 THEN 0 ELSE boqf.Indicator25 END + CASE WHEN boqf.Indicator26 = 99 THEN 0 ELSE boqf.Indicator26 END) / 6 as IPMDAEAvg --IPMDAE

		 --PRCB
		, CASE WHEN boqf.Indicator27 = 99 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator28 = 99 then 1 else 0 end
		   + case when boqf.Indicator29 = 99 then 1 else 0 end
		   + case when boqf.Indicator30 = 99 then 1 else 0 end
		   + case when boqf.Indicator31 = 99 then 1 else 0 end
		   + case when boqf.Indicator32 = 99 then 1 else 0 end as PRCBNotApplicable

		, CASE WHEN boqf.Indicator27 = 0 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator28 = 0 then 1 else 0 end
		   + case when boqf.Indicator29 = 0 then 1 else 0 end
		   + case when boqf.Indicator30 = 0 then 1 else 0 end
		   + case when boqf.Indicator31 = 0 then 1 else 0 end
		   + case when boqf.Indicator32 = 0 then 1 else 0 end as PRCBNotInPlace

		, CASE WHEN boqf.Indicator27 = 1 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator28 = 1 then 1 else 0 end
		   + case when boqf.Indicator29 = 1 then 1 else 0 end
		   + case when boqf.Indicator30 = 1 then 1 else 0 end
		   + case when boqf.Indicator31 = 1 then 1 else 0 end
		   + case when boqf.Indicator32 = 1 then 1 else 0 end as PRCBPartiallyInPlace

		, CASE WHEN boqf.Indicator27 = 2 THEN 1 ELSE 0 END
		   + CASE when boqf.Indicator28 = 2 then 1 else 0 end
		   + case when boqf.Indicator29 = 2 then 1 else 0 end
		   + case when boqf.Indicator30 = 2 then 1 else 0 end
		   + case when boqf.Indicator31 = 2 then 1 else 0 end
		   + case when boqf.Indicator32 = 2 then 1 else 0 end as PRCBInPlace

		, convert(decimal(5,2), CASE WHEN boqf.Indicator27 = 99 THEN 0 ELSE boqf.Indicator27 END + CASE WHEN boqf.Indicator28 = 99 THEN 0 ELSE boqf.Indicator28 END + CASE WHEN boqf.Indicator29 = 99 THEN 0 ELSE boqf.Indicator29 END 
					+ CASE WHEN boqf.Indicator30 = 99 THEN 0 ELSE boqf.Indicator30 END + CASE WHEN boqf.Indicator31 = 99 THEN 0 ELSE boqf.Indicator31 END + CASE WHEN boqf.Indicator32 = 99 THEN 0 ELSE boqf.Indicator32 END) / 6 as PRCBAvg--PRCB

		 --PDSP
		, case when boqf.Indicator33 = 99 then 1 else 0 end
		   + case when boqf.Indicator34 = 99 then 1 else 0 END
		   + CASE when boqf.Indicator35 = 99 then 1 else 0 end
		   + case when boqf.Indicator36 = 99 then 1 else 0 end
		   + case when boqf.Indicator37 = 99 then 1 else 0 end
		   + case when boqf.Indicator38 = 99 then 1 else 0 end
		   + case when boqf.Indicator39 = 99 then 1 else 0 end
		   + case when boqf.Indicator40 = 99 then 1 else 0 end
		   + case when boqf.Indicator41 = 99 then 1 else 0 end as PDSPNotApplicable

		, case when boqf.Indicator33 = 0 then 1 else 0 end
		   + case when boqf.Indicator34 = 0 then 1 else 0 END
		   + CASE when boqf.Indicator35 = 0 then 1 else 0 end
		   + case when boqf.Indicator36 = 0 then 1 else 0 end
		   + case when boqf.Indicator37 = 0 then 1 else 0 end
		   + case when boqf.Indicator38 = 0 then 1 else 0 end
		   + case when boqf.Indicator39 = 0 then 1 else 0 end
		   + case when boqf.Indicator40 = 0 then 1 else 0 end
		   + case when boqf.Indicator41 = 0 then 1 else 0 end as PDSPNotInPlace

		, case when boqf.Indicator33 = 1 then 1 else 0 end
		   + case when boqf.Indicator34 = 1 then 1 else 0 END
		   + CASE when boqf.Indicator35 = 1 then 1 else 0 end
		   + case when boqf.Indicator36 = 1 then 1 else 0 end
		   + case when boqf.Indicator37 = 1 then 1 else 0 end
		   + case when boqf.Indicator38 = 1 then 1 else 0 end
		   + case when boqf.Indicator39 = 1 then 1 else 0 end
		   + case when boqf.Indicator40 = 1 then 1 else 0 end
		   + case when boqf.Indicator41 = 1 then 1 else 0 end as PDSPPartiallyInPlace

		, case when boqf.Indicator33 = 2 THEN 1 else 0 end
		   + case when boqf.Indicator34 = 2 then 1 else 0 END
		   + CASE when boqf.Indicator35 = 2 then 1 else 0 end
		   + case when boqf.Indicator36 = 2 then 1 else 0 end
		   + case when boqf.Indicator37 = 2 then 1 else 0 end
		   + case when boqf.Indicator38 = 2 then 1 else 0 end
		   + case when boqf.Indicator39 = 2 then 1 else 0 end
		   + case when boqf.Indicator40 = 2 then 1 else 0 end
		   + case when boqf.Indicator41 = 2 then 1 else 0 end as PDSPInPlace
		
		, convert(decimal(5,2), CASE WHEN boqf.Indicator33 = 99 THEN 0 ELSE boqf.Indicator33 END + CASE WHEN boqf.Indicator34 = 99 THEN 0 ELSE boqf.Indicator34 END + CASE WHEN boqf.Indicator35 = 99 THEN 0 ELSE boqf.Indicator35 END 
					+ CASE WHEN boqf.Indicator36 = 99 THEN 0 ELSE boqf.Indicator36 END + CASE WHEN boqf.Indicator37 = 99 THEN 0 ELSE boqf.Indicator37 END + CASE WHEN boqf.Indicator38 = 99 THEN 0 ELSE boqf.Indicator38 END + CASE WHEN boqf.Indicator39 = 99 THEN 0 ELSE boqf.Indicator39 END 
					+ CASE WHEN boqf.Indicator40 = 99 THEN 0 ELSE boqf.Indicator40 END + CASE WHEN boqf.Indicator41 = 99 THEN 0 ELSE boqf.Indicator41 END) / 9 as PDSPAvg--PDSP
		
		 --MIO
		, case when boqf.Indicator42 = 99 then 1 else 0 end
		   + case when boqf.Indicator43 = 99 then 1 else 0 end
		   + case when boqf.Indicator44 = 99 then 1 else 0 end
		   + case when boqf.Indicator45 = 99 then 1 else 0 end
		   + case when boqf.Indicator46 = 99 then 1 else 0 end
		   + case when boqf.Indicator47 = 99 then 1 else 0 end as MIONotApplicable

		, case when boqf.Indicator42 = 0 then 1 else 0 end
		   + case when boqf.Indicator43 = 0 then 1 else 0 end
		   + case when boqf.Indicator44 = 0 then 1 else 0 end
		   + case when boqf.Indicator45 = 0 then 1 else 0 end
		   + case when boqf.Indicator46 = 0 then 1 else 0 end
		   + case when boqf.Indicator47 = 0 then 1 else 0 end as MIONotInPlace

		, case when boqf.Indicator42 = 1 then 1 else 0 end
		   + case when boqf.Indicator43 = 1 then 1 else 0 end
		   + case when boqf.Indicator44 = 1 then 1 else 0 end
		   + case when boqf.Indicator45 = 1 then 1 else 0 end
		   + case when boqf.Indicator46 = 1 then 1 else 0 end
		   + case when boqf.Indicator47 = 1 then 1 else 0 end as MIOPartiallyInPlace

		, case when boqf.Indicator42 = 2 then 1 else 0 end
		   + case when boqf.Indicator43 = 2 then 1 else 0 end
		   + case when boqf.Indicator44 = 2 then 1 else 0 end
		   + case when boqf.Indicator45 = 2 then 1 else 0 end
		   + case when boqf.Indicator46 = 2 then 1 else 0 end
		   + case when boqf.Indicator47 = 2 then 1 else 0 end as MIOInPlace
		
		, convert(decimal(5,2), CASE WHEN boqf.Indicator42 = 99 THEN 0 ELSE boqf.Indicator42 END + CASE WHEN boqf.Indicator43 = 99 THEN 0 ELSE boqf.Indicator43 END + CASE WHEN boqf.Indicator44 = 99 THEN 0 ELSE boqf.Indicator44 END 
					+ CASE WHEN boqf.Indicator45 = 99 THEN 0 ELSE boqf.Indicator45 END + CASE WHEN boqf.Indicator46 = 99 THEN 0 ELSE boqf.Indicator46 END + CASE WHEN boqf.Indicator47 = 99 THEN 0 ELSE boqf.Indicator47 END) / 6 as MIOAvg--MIO
		
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
    boqf.VersionNumber = 1 AND 
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'EMPI', 'Establish and Maintain a Plan for Implementation', 
		tabq.EMPIAvg, tabq.EMPINotApplicable, tabq.EMPINotInPlace, tabq.EMPIPartial, tabq.EMPIInPlace
	FROM @tblAllBOQs tabq

	--Get the FI data
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'FI', 'Family Involvement', tabq.FIAvg, tabq.FINotApplicable, 
		tabq.FINotInPlace, tabq.FIPartial, tabq.FIInPlace
	FROM @tblAllBOQs tabq

	--Get the PWE data
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PWE', 'Program-Wide Expectations', tabq.PWEAvg, tabq.PWENotApplicable, 
		tabq.PWENotInPlace, tabq.PWEPartial, tabq.PWEInPlace
	FROM @tblAllBOQs tabq

	--Get the STAPWE data
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'STAPWE', 'Strategies for Teaching and Acknowledging the Program-Wide Expectations', 
		tabq.STAPWEAvg, tabq.STAPWENotApplicable, tabq.STAPWENotInPlace, tabq.STAPWEPartial, tabq.STAPWEInPlace
	FROM @tblAllBOQs tabq

	--Get the IPMDAE data
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'IPMDAE', 'Implementation of the Pyramid Model is Demonstrated in All Environments', 
		tabq.IPMDAEAvg, tabq.IPMDAENotApplicable, tabq.IPMDAENotInPlace, tabq.IPMDAEPartial, tabq.IPMDAEInPlace
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PRCB', 'Procedures for Responding to Challenging Behavior', 
		tabq.PRCBAvg, tabq.PRCBNotApplicable, tabq.PRCBNotInPlace, tabq.PRCBPartial, tabq.PRCBInPlace
	FROM @tblAllBOQs tabq

	--Get the PDSP data
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'PDSP', 'Professional Development and Support Plan', tabq.PDSPAvg, 
		tabq.PDSPNotApplicable, tabq.PDSPNotInPlace, tabq.PDSPPartial, tabq.PDSPInPlace
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
		CriticalElementNumNotApplicable,
	    CriticalElementNumNotInPlace,
	    CriticalElementNumPartial,
	    CriticalElementNumInPlace
	)
	SELECT tabq.BOQFCCPK, tabq.FormDate, tabq.GroupingValue, tabq.GroupingText, tabq.ProgramFK, tabq.ProgramName, 
		'MIO', 'Monitoring Implementation and Outcomes', tabq.MIOAvg, 
		tabq.MIONotApplicable, tabq.MIONotInPlace, tabq.MIOPartial, tabq.MIOInPlace
	FROM @tblAllBOQs tabq

	SELECT * FROM @tblBOQData tbd

END
GO

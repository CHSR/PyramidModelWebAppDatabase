SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 04/01/2020
-- Description:	This stored procedure provides the necessary information
-- for the tracking report
-- =============================================
/*
DECLARE @ProgramFKs VARCHAR(MAX) = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,'
DECLARE @Year INT = 2018
*/

CREATE PROC [dbo].[rspTracking]
	@Year INT = NULL,
	@ProgramFKs VARCHAR(8000) = NULL,
	@HubFKs VARCHAR(8000) = NULL,
	@CohortFKs VARCHAR(8000) = NULL,
	@StateFKs VARCHAR(8000) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the final information
	DECLARE @tblFinalSelect TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		ProgramName VARCHAR(400) NULL,
		IsFCCProgram BIT NULL DEFAULT 0,
		BOQType VARCHAR(100) NULL DEFAULT 'Missing',
		MostRecentBOQDate DATETIME NULL,
		JanCoachingLogCount INT NULL DEFAULT 0,
		FebCoachingLogCount INT NULL DEFAULT 0,
		MarCoachingLogCount INT NULL DEFAULT 0,
		AprCoachingLogCount INT NULL DEFAULT 0,
		MayCoachingLogCount INT NULL DEFAULT 0,
		JuneCoachingLogCount INT NULL DEFAULT 0,
		JulyCoachingLogCount INT NULL DEFAULT 0,
		AugCoachingLogCount INT NULL DEFAULT 0,
		SeptCoachingLogCount INT NULL DEFAULT 0,
		OctCoachingLogCount INT NULL DEFAULT 0,
		NovCoachingLogCount INT NULL DEFAULT 0,
		DecCoachingLogCount INT NULL DEFAULT 0,
		ArePreschoolClassrooms BIT NULL DEFAULT 0,
		SpringTPOTCount INT NULL DEFAULT 0,
		FallTPOTCount INT NULL DEFAULT 0,
		AreInfantToddlerClassrooms BIT NULL DEFAULT 0,
		SpringTPITOSCount INT NULL DEFAULT 0,
		FallTPITOSCount INT NULL DEFAULT 0,
		JanBIRCount INT NULL DEFAULT 0,
		FebBIRCount INT NULL DEFAULT 0,
		MarBIRCount INT NULL DEFAULT 0,
		AprBIRCount INT NULL DEFAULT 0,
		MayBIRCount INT NULL DEFAULT 0,
		JuneBIRCount INT NULL DEFAULT 0,
		JulyBIRCount INT NULL DEFAULT 0,
		AugBIRCount INT NULL DEFAULT 0,
		SeptBIRCount INT NULL DEFAULT 0,
		OctBIRCount INT NULL DEFAULT 0,
		NovBIRCount INT NULL DEFAULT 0,
		DecBIRCount INT NULL DEFAULT 0,
		SpringSEScreenType VARCHAR(250) NULL DEFAULT 'Missing',
		SpringSEScreenCount INT NULL DEFAULT 0,
		SpringSEScreenTypeCount INT NULL DEFAULT 0,
		FallSEScreenType VARCHAR(250) NULL DEFAULT 'Missing',
		FallSEScreenCount INT NULL DEFAULT 0,
		FallSEScreenTypeCount INT NULL DEFAULT 0
	)

	--To hold the classroom info
	DECLARE @tblClassroomInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		NumPreschoolClassrooms INT NULL,
		NumInfantToddlerClassrooms INT NULL
	)

	--To hold the most recent BOQs
	DECLARE @tblBOQInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		Type VARCHAR(100) NULL,
		MostRecentFormDate DATETIME NULL
	)

	--To hold the coaching logs monthly counts by program
	DECLARE @tblCoachingLogInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		JanFormCount INT NULL,
		FebFormCount INT NULL,
		MarFormCount INT NULL,
		AprFormCount INT NULL,
		MayFormCount INT NULL,
		JuneFormCount INT NULL,
		JulyFormCount INT NULL,
		AugFormCount INT NULL,
		SeptFormCount INT NULL,
		OctFormCount INT NULL,
		NovFormCount INT NULL,
		DecFormCount INT NULL
	)
	
	--To hold the TPOT information
	DECLARE @tblTPOTInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		NumSpringForms INT NULL,
		NumFallForms INT NULL
	)
	
	--To hold the TPITOS information
	DECLARE @tblTPITOSInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		NumSpringForms INT NULL,
		NumFallForms INT NULL
	)

	--To hold the BIR monthly counts by program
	DECLARE @tblBIRInfo TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		JanFormCount INT NULL,
		FebFormCount INT NULL,
		MarFormCount INT NULL,
		AprFormCount INT NULL,
		MayFormCount INT NULL,
		JuneFormCount INT NULL,
		JulyFormCount INT NULL,
		AugFormCount INT NULL,
		SeptFormCount INT NULL,
		OctFormCount INT NULL,
		NovFormCount INT NULL,
		DecFormCount INT NULL
	)
	
	--To hold all the spring SE Screens for each program
	DECLARE @tblAllSpringSEScreens TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		ScreenType VARCHAR(250) NULL,
		FormCount INT NULL
	)
	
	--To hold the most used spring SE Screens for each program
	DECLARE @tblMostUsedSpringSEScreens TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		ScreenType VARCHAR(250) NULL,
		FormCount INT NULL
	)
	
	--To hold all the fall SE Screens for each program
	DECLARE @tblAllFallSEScreens TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		ScreenType VARCHAR(250) NULL,
		FormCount INT NULL
	)
	
	--To hold the most used fall SE Screens for each program
	DECLARE @tblMostUsedFallSEScreens TABLE (
		ProgramFK INT NULL INDEX IXProgramFK CLUSTERED,
		ScreenType VARCHAR(250) NULL,
		FormCount INT NULL
	)

	--Get all the FCC programs and put them into the final select table
	INSERT INTO @tblFinalSelect
	(
	    ProgramFK,
	    ProgramName,
		IsFCCProgram
	)
	SELECT DISTINCT p.ProgramPK, 
		p.ProgramName, 
		CASE WHEN ISNULL((SELECT TOP(1) pt.ProgramTypePK 
			FROM dbo.ProgramType pt
			WHERE pt.ProgramFK = p.ProgramPK 
				AND (pt.TypeCodeFK = 1 OR pt.TypeCodeFK = 2)
			ORDER BY pt.ProgramTypePK ASC), 0) > 0 THEN 1 ELSE 0 END AS IsFCCProgram
	FROM dbo.Program p
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = p.ProgramPK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized 
	
	--Get the classroom info
	INSERT INTO @tblClassroomInfo
	(
	    ProgramFK,
	    NumPreschoolClassrooms,
	    NumInfantToddlerClassrooms
	)
	SELECT c.ProgramFK, 
		SUM(CASE WHEN c.IsPreschool = 1 THEN 1 ELSE 0 END), 
		SUM(CASE WHEN c.IsInfantToddler = 1 THEN 1 ELSE 0 END)
	FROM dbo.Classroom c
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = c.ProgramFK
	GROUP BY c.ProgramFK

	--Update the final select table
	UPDATE tfs
	SET tfs.ArePreschoolClassrooms = CASE WHEN tci.NumPreschoolClassrooms > 0 THEN 1 ELSE 0 END,
		tfs.AreInfantToddlerClassrooms = CASE WHEN tci.NumInfantToddlerClassrooms > 0 THEN 1 ELSE 0 END
	FROM @tblFinalSelect tfs
	INNER JOIN @tblClassroomInfo tci ON tci.ProgramFK = tfs.ProgramFK
	WHERE tfs.ProgramFK = tci.ProgramFK

	--Get the most recent benchmarks of quality FCC forms
	INSERT INTO @tblBOQInfo
	(
	    ProgramFK,
	    Type,
	    MostRecentFormDate
	)
	SELECT boqf.ProgramFK, 'BOQ-FCC', MAX(boqf.FormDate)
	FROM dbo.BenchmarkOfQualityFCC boqf
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = boqf.ProgramFK AND tfs.IsFCCProgram = 1
	WHERE YEAR(boqf.FormDate) = @Year
	GROUP BY boqf.ProgramFK

	--Get the most recent benchmarks of quality forms
	INSERT INTO @tblBOQInfo
	(
	    ProgramFK,
	    Type,
	    MostRecentFormDate
	)
	SELECT boq.ProgramFK, 'BOQ', MAX(boq.FormDate)
	FROM dbo.BenchmarkOfQuality boq
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = boq.ProgramFK AND tfs.IsFCCProgram = 0
	WHERE YEAR(boq.FormDate) = @Year
	GROUP BY boq.ProgramFK

	--Update the final select table
	UPDATE tfs
	SET tfs.BOQType = tbi.Type, tfs.MostRecentBOQDate = tbi.MostRecentFormDate
	FROM @tblFinalSelect tfs
	INNER JOIN @tblBOQInfo tbi ON tbi.ProgramFK = tfs.ProgramFK
	WHERE tfs.ProgramFK = tbi.ProgramFK

	--Get the coaching logs grouped by month
	INSERT INTO @tblCoachingLogInfo
	(
	    ProgramFK,
		JanFormCount,
		FebFormCount,
		MarFormCount,
		AprFormCount,
		MayFormCount,
		JuneFormCount,
		JulyFormCount,
		AugFormCount,
		SeptFormCount,
		OctFormCount,
		NovFormCount,
		DecFormCount
	)
	SELECT pvt.ProgramFK, pvt.[1], pvt.[2], pvt.[3], pvt.[4], pvt.[5], pvt.[6],
		pvt.[7], pvt.[8], pvt.[9], pvt.[10], pvt.[11], pvt.[12]
	FROM
	(SELECT cl.ProgramFK, cl.CoachingLogPK, MONTH(cl.LogDate) FormMonth
		FROM dbo.CoachingLog cl
		INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = cl.ProgramFK
		WHERE YEAR(cl.LogDate) = @Year) AS SourceTable
	PIVOT
	(
		COUNT(CoachingLogPK)
		FOR FormMonth IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS pvt

	--Update the final select table with the coaching log info
	UPDATE tfs
	SET tfs.JanCoachingLogCount = tcli.JanFormCount, tfs.FebCoachingLogCount = tcli.FebFormCount,
		tfs.MarCoachingLogCount = tcli.MarFormCount, tfs.AprCoachingLogCount = tcli.AprFormCount,
		tfs.MayCoachingLogCount = tcli.MayFormCount, tfs.JuneCoachingLogCount = tcli.JuneFormCount,
		tfs.JulyCoachingLogCount = tcli.JulyFormCount, tfs.AugCoachingLogCount = tcli.AugFormCount,
		tfs.SeptCoachingLogCount = tcli.SeptFormCount, tfs.OctCoachingLogCount = tcli.OctFormCount,
		tfs.NovCoachingLogCount = tcli.NovFormCount, tfs.DecCoachingLogCount = tcli.DecFormCount
	FROM @tblFinalSelect tfs
	INNER JOIN @tblCoachingLogInfo tcli ON tcli.ProgramFK = tfs.ProgramFK
	WHERE tfs.ProgramFK = tcli.ProgramFK

	--Get the TPOT information
	INSERT INTO @tblTPOTInfo
	(
	    ProgramFK,
	    NumSpringForms,
	    NumFallForms
	)
	SELECT c.ProgramFK, 
		SUM(CASE WHEN MONTH(t.ObservationStartDateTime) BETWEEN 1 AND 6 THEN 1 ELSE 0 END) SpringCount,
		SUM(CASE WHEN MONTH(t.ObservationStartDateTime) BETWEEN 7 AND 12 THEN 1 ELSE 0 END) FallCount
	FROM dbo.TPOT t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	WHERE YEAR(t.ObservationStartDateTime) = @Year
	GROUP BY c.ProgramFK

	--Update the final select table with the TPOT info
	UPDATE tfs
	SET tfs.SpringTPOTCount = tti.NumSpringForms,
		tfs.FallTPOTCount = tti.NumFallForms
	FROM @tblFinalSelect tfs
	INNER JOIN @tblTPOTInfo tti ON tti.ProgramFK = tfs.ProgramFK
	WHERE tti.ProgramFK = tfs.ProgramFK

	--Get the TPITOS information
	INSERT INTO @tblTPITOSInfo
	(
	    ProgramFK,
	    NumSpringForms,
	    NumFallForms
	)
	SELECT c.ProgramFK, 
		SUM(CASE WHEN MONTH(t.ObservationStartDateTime) BETWEEN 1 AND 6 THEN 1 ELSE 0 END) SpringCount,
		SUM(CASE WHEN MONTH(t.ObservationStartDateTime) BETWEEN 7 AND 12 THEN 1 ELSE 0 END) FallCount
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	WHERE YEAR(t.ObservationStartDateTime) = @Year
	GROUP BY c.ProgramFK

	--Update the final select table with the TPITOS info
	UPDATE tfs
	SET tfs.SpringTPITOSCount = tti.NumSpringForms,
		tfs.FallTPITOSCount = tti.NumFallForms
	FROM @tblFinalSelect tfs
	INNER JOIN @tblTPITOSInfo tti ON tti.ProgramFK = tfs.ProgramFK
	WHERE tti.ProgramFK = tfs.ProgramFK
	
	--Get the BIRs grouped by month
	INSERT INTO @tblBIRInfo
	(
	    ProgramFK,
		JanFormCount,
		FebFormCount,
		MarFormCount,
		AprFormCount,
		MayFormCount,
		JuneFormCount,
		JulyFormCount,
		AugFormCount,
		SeptFormCount,
		OctFormCount,
		NovFormCount,
		DecFormCount
	)
	SELECT pvt.ProgramFK, pvt.[1], pvt.[2], pvt.[3], pvt.[4], pvt.[5], pvt.[6],
		pvt.[7], pvt.[8], pvt.[9], pvt.[10], pvt.[11], pvt.[12]
	FROM
	(SELECT c.ProgramFK, bi.BehaviorIncidentPK, MONTH(bi.IncidentDatetime) FormMonth
		FROM dbo.BehaviorIncident bi
		INNER JOIN dbo.Classroom c ON c.ClassroomPK = bi.ClassroomFK
		INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = c.ProgramFK
		WHERE YEAR(bi.IncidentDatetime) = @Year) AS SourceTable
	PIVOT
	(
		COUNT(BehaviorIncidentPK)
		FOR FormMonth IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS pvt

	--Update the final select table with the coaching log info
	UPDATE tfs
	SET tfs.JanBIRCount = tbi.JanFormCount, tfs.FebBIRCount = tbi.FebFormCount,
		tfs.MarBIRCount = tbi.MarFormCount, tfs.AprBIRCount = tbi.AprFormCount,
		tfs.MayBIRCount = tbi.MayFormCount, tfs.JuneBIRCount = tbi.JuneFormCount,
		tfs.JulyBIRCount = tbi.JulyFormCount, tfs.AugBIRCount = tbi.AugFormCount,
		tfs.SeptBIRCount = tbi.SeptFormCount, tfs.OctBIRCount = tbi.OctFormCount,
		tfs.NovBIRCount = tbi.NovFormCount, tfs.DecBIRCount = tbi.DecFormCount
	FROM @tblFinalSelect tfs
	INNER JOIN @tblBIRInfo tbi ON tfs.ProgramFK = tbi.ProgramFK
	WHERE tfs.ProgramFK = tbi.ProgramFK

	--Get the spring other SE screens
	INSERT INTO @tblAllSpringSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT oss.ProgramFK, cst.Abbreviation ScreenType, COUNT(oss.OtherSEScreenPK)
	FROM dbo.OtherSEScreen oss
	INNER JOIN dbo.CodeScreenType cst ON cst.CodeScreenTypePK = oss.ScreenTypeCodeFK
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = oss.ProgramFK
	WHERE YEAR(oss.ScreenDate) = @Year
		AND MONTH(oss.ScreenDate) BETWEEN 1 AND 6
	GROUP BY oss.ProgramFK, cst.Abbreviation

	--Get the spring ASQ:SEs
	INSERT INTO @tblAllSpringSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT a.ProgramFK, CONCAT('ASQ:SE-', a.Version) ScreenType, COUNT(a.ASQSEPK)
	FROM dbo.ASQSE a
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = a.ProgramFK
	WHERE YEAR(a.FormDate) = @Year
		AND MONTH(a.FormDate) BETWEEN 1 AND 6
	GROUP BY a.ProgramFK, CONCAT('ASQ:SE-', a.Version)

	--Get the most used spring SE screens
	INSERT INTO @tblMostUsedSpringSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT tasss.ProgramFK, tasss.ScreenType, tasss.FormCount
	FROM @tblAllSpringSEScreens tasss
	LEFT OUTER JOIN @tblAllSpringSEScreens tasss2
		ON tasss.ProgramFK = tasss2.ProgramFK AND tasss.FormCount < tasss2.FormCount
	WHERE tasss2.ProgramFK IS NULL

	--Update the final select table with the spring SE screen info
	UPDATE tfs
	SET tfs.SpringSEScreenType = tmusss.ScreenType, 
		tfs.SpringSEScreenCount = tmusss.FormCount,
		tfs.SpringSEScreenTypeCount = (SELECT COUNT(tasss.ScreenType) FROM @tblAllSpringSEScreens tasss WHERE tasss.ProgramFK = tfs.ProgramFK)
	FROM @tblFinalSelect tfs
	INNER JOIN @tblMostUsedSpringSEScreens tmusss ON tmusss.ProgramFK = tfs.ProgramFK
	WHERE tmusss.ProgramFK = tfs.ProgramFK

	--Get the fall other SE screens
	INSERT INTO @tblAllFallSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT oss.ProgramFK, cst.Abbreviation ScreenType, COUNT(oss.OtherSEScreenPK)
	FROM dbo.OtherSEScreen oss
	INNER JOIN dbo.CodeScreenType cst ON cst.CodeScreenTypePK = oss.ScreenTypeCodeFK
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = oss.ProgramFK
	WHERE YEAR(oss.ScreenDate) = @Year
		AND MONTH(oss.ScreenDate) BETWEEN 7 AND 12
	GROUP BY oss.ProgramFK, cst.Abbreviation

	--Get the fall ASQ:SEs
	INSERT INTO @tblAllFallSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT a.ProgramFK, CONCAT('ASQ:SE-', a.Version) ScreenType, COUNT(a.ASQSEPK)
	FROM dbo.ASQSE a
	INNER JOIN @tblFinalSelect tfs ON tfs.ProgramFK = a.ProgramFK
	WHERE YEAR(a.FormDate) = @Year
		AND MONTH(a.FormDate) BETWEEN 7 AND 12
	GROUP BY a.ProgramFK, CONCAT('ASQ:SE-', a.Version)

	--Get the most used fall SE screens
	INSERT INTO @tblMostUsedFallSEScreens
	(
	    ProgramFK,
	    ScreenType,
	    FormCount
	)
	SELECT tafss.ProgramFK, tafss.ScreenType, tafss.FormCount
	FROM @tblAllFallSEScreens tafss
	LEFT OUTER JOIN @tblAllFallSEScreens tafss2
		ON tafss2.ProgramFK = tafss.ProgramFK AND tafss.FormCount < tafss2.FormCount
	WHERE tafss2.ProgramFK IS NULL

	--Update the final select table with the fall SE screen info
	UPDATE tfs
	SET tfs.FallSEScreenType = tmufss.ScreenType, 
		tfs.FallSEScreenCount = tmufss.FormCount,
		tfs.FallSEScreenTypeCount = (SELECT COUNT(tafss.ScreenType) FROM @tblAllFallSEScreens tafss WHERE tafss.ProgramFK = tfs.ProgramFK)
	FROM @tblFinalSelect tfs
	INNER JOIN @tblMostUsedFallSEScreens tmufss ON tmufss.ProgramFK = tfs.ProgramFK
	WHERE tmufss.ProgramFK = tfs.ProgramFK

	SELECT * 
	FROM @tblFinalSelect tfs
	ORDER BY tfs.ProgramName ASC

	
END
GO

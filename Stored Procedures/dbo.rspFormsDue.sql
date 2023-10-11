SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/08/2020
-- Description:	This stored procedure returns all the forms that are required for the
-- specified programs during the specified dates
-- =============================================
CREATE PROC [dbo].[rspFormsDue]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the years (because the recommended date needs to have the year set)
	DECLARE @tblYears TABLE (
		IncludedYear INT NOT NULL
	)

	--To hold the required forms for all included programs
	DECLARE @tblRequiredForms TABLE (
		CodeFormFK INT NOT NULL,
		FormAbbreviation VARCHAR(10) NOT NULL,
		FormName VARCHAR(150) NOT NULL,
		DaysUntilWarning INT NOT NULL,
		DueStartDate DATETIME NOT NULL,
		DueRecommendedDate DATETIME NOT NULL,
		DueEndDate DATETIME NOT NULL,
		HelpText VARCHAR(500) NULL,
		ProgramFK INT NOT NULL,
		StateFK INT NOT NULL
	)

	--To hold the final select information
	DECLARE @tblFinalSelect TABLE (
		FormAbbreviation VARCHAR(10) NOT NULL,
		FormName VARCHAR(150) NOT NULL,
		DaysUntilWarning INT NOT NULL,
		DueDateDescription VARCHAR(250) NOT NULL,
		DueStartDate DATETIME NOT NULL,
		DueRecommendedDate DATETIME NOT NULL,
		DueEndDate DATETIME NOT NULL,
		HelpText VARCHAR(500) NULL,
		ProgramFK INT NOT NULL,
		StateFK INT NOT NULL,
		FormFK INT NULL,
		FormDate DATETIME NULL,
		IsComplete BIT NOT NULL
	)

	--Get the year, starting with the start date year
	DECLARE @CurrentYear INT = YEAR(@StartDate)

	--Get the included years by looping through the years between start and end dates
	WHILE @CurrentYear <= YEAR(@EndDate)
	BEGIN
		--Add the current year
		INSERT INTO @tblYears
		(
			IncludedYear
		)
		SELECT @CurrentYear

		--Add 1 year to the current year
		SET @CurrentYear = @CurrentYear + 1
	end

	--Get the forms required by program
	INSERT INTO @tblRequiredForms
	(
		CodeFormFK,
		FormAbbreviation,
		FormName,
		DaysUntilWarning,
		DueStartDate,
		DueRecommendedDate,
		DueEndDate,
		HelpText,
		ProgramFK,
		StateFK
	)
	SELECT cf.CodeFormPK, cf.FormAbbreviation, cf.FormName, ss.DueDatesDaysUntilWarning,
		DATEADD(YEAR, ty.IncludedYear - YEAR(fdd.DueRecommendedDate), DATEADD(DAY, fdd.DueStartWindow, fdd.DueRecommendedDate)) DueStartDate, 
		DATEADD(YEAR, ty.IncludedYear - YEAR(fdd.DueRecommendedDate), fdd.DueRecommendedDate) DueRecommendedDate,
		DATEADD(YEAR, ty.IncludedYear - YEAR(fdd.DueRecommendedDate), DATEADD(DAY, fdd.DueEndWindow, fdd.DueRecommendedDate)) DueEndDate,
		ISNULL(fdd.HelpText, '(No help information available)'),
		p.ProgramPK,
		fdd.StateFK
	FROM dbo.FormDueDate fdd
	INNER JOIN dbo.CodeForm cf ON cf.CodeFormPK = fdd.CodeFormFK AND cf.AllowDueDate = 1
	INNER JOIN dbo.Program p ON p.StateFK = fdd.StateFK
	INNER JOIN dbo.StateSettings ss ON ss.StateFK = p.StateFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON p.ProgramPK = ssti.ListItem
	INNER JOIN @tblYears ty ON ty.IncludedYear IS NOT NULL
	WHERE DATEADD(YEAR, ty.IncludedYear - YEAR(fdd.DueRecommendedDate), fdd.DueRecommendedDate) BETWEEN @StartDate AND @EndDate

	--Get any TPOT forms that match a required TPOT row
	INSERT INTO @tblFinalSelect
	(
		FormAbbreviation,
		FormName,
		DaysUntilWarning,
		DueDateDescription,
		DueStartDate,
		DueRecommendedDate,
		DueEndDate,
		HelpText,
		ProgramFK,
		StateFK,
		FormFK,
		FormDate,
		IsComplete
	)
	SELECT trf.FormAbbreviation, trf.FormName, trf.DaysUntilWarning, CONCAT(c.Name, ' observation data must be entered within the specified date range.'), 
		   trf.DueStartDate, trf.DueRecommendedDate, trf.DueEndDate, trf.HelpText,
		   trf.ProgramFK, trf.StateFK, t.TPOTPK, t.ObservationStartDateTime,
		   CASE WHEN t.TPOTPK IS NULL THEN 0 ELSE 1 END AS IsComplete
	FROM @tblRequiredForms trf
	INNER JOIN dbo.Classroom c ON c.IsPreschool = 1 AND c.ProgramFK = trf.ProgramFK
	OUTER APPLY (
		SELECT TOP(1) t.TPOTPK, t.ObservationStartDateTime
		FROM dbo.TPOT t 
		WHERE t.ClassroomFK = c.ClassroomPK 
			  AND t.ObservationStartDateTime BETWEEN trf.DueStartDate AND trf.DueEndDate 
		ORDER BY t.ObservationStartDateTime ASC
	) t
	WHERE trf.CodeFormFK = 1

	--Get any TPITOS forms that match a required TPITOS row
	INSERT INTO @tblFinalSelect
	(
		FormAbbreviation,
		FormName,
		DaysUntilWarning,
		DueDateDescription,
		DueStartDate,
		DueRecommendedDate,
		DueEndDate,
		HelpText,
		ProgramFK,
		StateFK,
		FormFK,
		FormDate,
		IsComplete
	)
	SELECT trf.FormAbbreviation, trf.FormName, trf.DaysUntilWarning, CONCAT(c.Name, ' observation data must be entered within the specified date range.'), 
		   trf.DueStartDate, trf.DueRecommendedDate, trf.DueEndDate, trf.HelpText, 
		   trf.ProgramFK, trf.StateFK, t.TPITOSPK, t.ObservationStartDateTime,
		   CASE WHEN t.TPITOSPK IS NULL THEN 0 ELSE 1 END AS IsComplete
	FROM @tblRequiredForms trf
	INNER JOIN dbo.Classroom c ON c.IsInfantToddler = 1 AND c.ProgramFK = trf.ProgramFK
	OUTER APPLY (
		SELECT TOP(1) t.TPITOSPK, t.ObservationStartDateTime
		FROM dbo.TPITOS t 
		WHERE t.ClassroomFK = c.ClassroomPK 
			  AND t.ObservationStartDateTime BETWEEN trf.DueStartDate AND trf.DueEndDate 
		ORDER BY t.ObservationStartDateTime ASC
	) t
	WHERE trf.CodeFormFK = 2

	--Get any BOQ forms that match a required BOQ row
	INSERT INTO @tblFinalSelect
	(
		FormAbbreviation,
		FormName,
		DaysUntilWarning,
		DueDateDescription,
		DueStartDate,
		DueRecommendedDate,
		DueEndDate,
		HelpText,
		ProgramFK,
		StateFK,
		FormFK,
		FormDate,
		IsComplete
	)
	SELECT trf.FormAbbreviation, trf.FormName, trf.DaysUntilWarning, 'A BOQ form must be entered within the specified date range.', 
		   trf.DueStartDate, trf.DueRecommendedDate, trf.DueEndDate, trf.HelpText,
		   trf.ProgramFK, trf.StateFK, boq.BenchmarkOfQualityPK, boq.FormDate,
		   CASE WHEN boq.BenchmarkOfQualityPK IS NULL THEN 0 ELSE 1 END AS IsComplete
	FROM @tblRequiredForms trf
	OUTER APPLY (
		SELECT TOP(1) pt.ProgramTypePK
		FROM dbo.ProgramType pt
		WHERE pt.ProgramFK = trf.ProgramFK AND (pt.TypeCodeFK = 1 OR pt.TypeCodeFK = 2)
		ORDER BY pt.ProgramTypePK DESC
	) pt
	OUTER APPLY (
		SELECT TOP(1) boq.BenchmarkOfQualityPK, boq.FormDate
		FROM dbo.BenchmarkOfQuality boq 
		WHERE boq.ProgramFK = trf.ProgramFK 
			  AND boq.FormDate BETWEEN trf.DueStartDate AND trf.DueEndDate 
		ORDER BY boq.FormDate DESC
	) boq
	WHERE trf.CodeFormFK = 3
		  AND pt.ProgramTypePK IS NULL

	--Get any BOQFCC forms that match a required BOQFCC row
	INSERT INTO @tblFinalSelect
	(
		FormAbbreviation,
		FormName,
		DaysUntilWarning,
		DueDateDescription,
		DueStartDate,
		DueRecommendedDate,
		DueEndDate,
		HelpText,
		ProgramFK,
		StateFK,
		FormFK,
		FormDate,
		IsComplete
	)
	SELECT trf.FormAbbreviation, trf.FormName, trf.DaysUntilWarning, 'A BOQ-FCC form must be entered within the specified date range.', 
		   trf.DueStartDate, trf.DueRecommendedDate, trf.DueEndDate, trf.HelpText,
		   trf.ProgramFK, trf.StateFK, boqf.BenchmarkOfQualityFCCPK, boqf.FormDate,
		   CASE WHEN boqf.BenchmarkOfQualityFCCPK IS NULL THEN 0 ELSE 1 END AS IsComplete
	FROM @tblRequiredForms trf
	OUTER APPLY (
		SELECT TOP(1) pt.ProgramTypePK
		FROM dbo.ProgramType pt
		WHERE pt.ProgramFK = trf.ProgramFK AND (pt.TypeCodeFK = 1 OR pt.TypeCodeFK = 2)
		ORDER BY pt.ProgramTypePK DESC
	) pt
	OUTER APPLY (
		SELECT TOP(1) boqf.BenchmarkOfQualityFCCPK, boqf.FormDate
		FROM dbo.BenchmarkOfQualityFCC boqf 
		WHERE boqf.ProgramFK = trf.ProgramFK 
			  AND boqf.FormDate BETWEEN trf.DueStartDate AND trf.DueEndDate 
		ORDER BY boqf.FormDate DESC
	) boqf
	WHERE trf.CodeFormFK = 4
		  AND pt.ProgramTypePK IS NOT NULL

	--Final select
	SELECT *, CASE WHEN tfs.IsComplete = 1 THEN	'Yes' ELSE 'No' END AS IsCompleteText
	FROM @tblFinalSelect tfs
	ORDER BY tfs.DueDateDescription ASC
	
END
GO

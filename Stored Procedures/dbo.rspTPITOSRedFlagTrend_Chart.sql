SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/25/2019
-- Description:	This stored procedure returns the necessary information for the
-- chart on the TPITOS Trend report
-- =============================================
CREATE PROC [dbo].[rspTPITOSRedFlagTrend_Chart]
    @ProgramFKs VARCHAR(MAX) = NULL,
    @ClassroomFKs VARCHAR(MAX) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--To hold all the TPITOS
    DECLARE @tblAllTPITOS TABLE
    (
        TPITOSPK INT NOT NULL,
        FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
        LeadTeacherRedFlagsNumYes INT NULL,
        LeadTeacherRedFlagsNumPossible INT NULL,
        OtherTeacherRedFlagsNumYes INT NULL,
        OtherTeacherRedFlagsNumPossible INT NULL,
        ClassroomRedFlagsNumYes INT NULL,
        ClassroomRedFlagsNumPossible INT NULL,
		ProgramFK INT NOT NULL,
		ClassroomFK INT NOT NULL
    );

	--To hold the averages
	DECLARE @tblAverages TABLE (
		GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		RedFlagType VARCHAR(50) NOT NULL,
		PercentYes DECIMAL(5, 2) NULL
	)

	--To hold the data for the final select
	DECLARE @tblFinalSelect TABLE (
		RedFlagType VARCHAR(50) NOT NULL,
		GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		PercentYes DECIMAL(5,2) NOT NULL
	)

	--Get all the TPITOS forms
    INSERT INTO @tblAllTPITOS
    (
        TPITOSPK,
        FormDate,
        GroupingValue,
		GroupingText,
        LeadTeacherRedFlagsNumYes,
        LeadTeacherRedFlagsNumPossible,
        OtherTeacherRedFlagsNumYes,
        OtherTeacherRedFlagsNumPossible,
        ClassroomRedFlagsNumYes,
        ClassroomRedFlagsNumPossible,
        ProgramFK,
        ClassroomFK
    )
	SELECT t.TPITOSPK, t.ObservationStartDateTime, 
		CASE WHEN DATEPART(MONTH, t.ObservationStartDateTime) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime)), '-2-Fall') END AS GroupingValue,
		CASE WHEN DATEPART(MONTH, t.ObservationStartDateTime) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime))) END AS GroupingText,
		t.LeadTeacherRedFlagsNumYes, t.LeadTeacherRedFlagsNumPossible, 
		t.OtherTeacherRedFlagsNumYes, t.OtherTeacherRedFlagsNumPossible,
		t.ClassroomRedFlagsNumYes, t.ClassroomRedFlagsNumPossible, 
		c.ProgramFK, t.ClassroomFK
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON c.ProgramFK = programList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON t.ClassroomFK = classroomList.ListItem
	WHERE t.ObservationStartDateTime BETWEEN @StartDate AND @EndDate
		AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria


	--Get the averages for each red flag
	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    RedFlagType,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		'Observed Teacher',
		CONVERT(DECIMAL(5,2), SUM(tatt.LeadTeacherRedFlagsNumYes)) / NULLIF(SUM(tatt.LeadTeacherRedFlagsNumPossible), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText
	
	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    RedFlagType,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		'Other Teacher',
		CONVERT(DECIMAL(5,2), SUM(tatt.OtherTeacherRedFlagsNumYes)) / NULLIF(SUM(tatt.OtherTeacherRedFlagsNumPossible), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText
	
	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    RedFlagType,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		'Classroom',
		CONVERT(DECIMAL(5,2), SUM(tatt.ClassroomRedFlagsNumYes)) / NULLIF(SUM(tatt.ClassroomRedFlagsNumPossible), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText


	--Get the data for the final select
	INSERT INTO @tblFinalSelect
	(
	    RedFlagType,
	    GroupingValue,
	    GroupingText,
	    PercentYes
	)
	SELECT ta.RedFlagType, ta.GroupingValue, ta.GroupingText, ISNULL(ta.PercentYes, 0.00) AS PercentYes
	FROM @tblAverages ta
	ORDER BY ta.RedFlagType ASC, ta.GroupingValue ASC

	--Perform the final select
	SELECT * FROM @tblFinalSelect tfs ORDER BY tfs.RedFlagType ASC, tfs.GroupingValue ASC

END;
GO

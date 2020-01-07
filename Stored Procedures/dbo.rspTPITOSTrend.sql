SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/25/2019
-- Description:	This stored procedure returns the necessary information for the
-- TPITOS Trend report
-- =============================================
CREATE PROC [dbo].[rspTPITOSTrend]
    @ProgramFKs VARCHAR(MAX) = NULL,
    @ClassroomFKs VARCHAR(MAX) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--To hold all the TPITOS forms
    DECLARE @tblAllTPITOS TABLE
    (
        TPITOSPK INT NOT NULL,
        FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
        Item1NumNo INT NULL,
        Item1NumYes INT NULL,
        Item2NumNo INT NULL,
        Item2NumYes INT NULL,
        Item3NumNo INT NULL,
        Item3NumYes INT NULL,
        Item4NumNo INT NULL,
        Item4NumYes INT NULL,
        Item5NumNo INT NULL,
        Item5NumYes INT NULL,
        Item6NumNo INT NULL,
        Item6NumYes INT NULL,
        Item7NumNo INT NULL,
        Item7NumYes INT NULL,
        Item8NumNo INT NULL,
        Item8NumYes INT NULL,
        Item9NumNo INT NULL,
        Item9NumYes INT NULL,
        Item10NumNo INT NULL,
        Item10NumYes INT NULL,
        Item11NumNo INT NULL,
        Item11NumYes INT NULL,
        Item12NumNo INT NULL,
        Item12NumYes INT NULL,
        Item13NumNo INT NULL,
        Item13NumYes INT NULL,
        Item14NumNo INT NULL,
        Item14NumYes INT NULL,
		ProgramFK INT NOT NULL,
		ClassroomFK INT NOT NULL
    );

	--To hold the first and last form dates and the count of forms
	DECLARE @tblFormDatesAndCount TABLE (
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		NumForms INT NULL
	)

	--To hold the averages
	DECLARE @tblAverages TABLE (
		GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		ItemNum INT NOT NULL,
		PercentYes DECIMAL(5, 2) NULL
	)

	--To hold the data for the final select
	DECLARE @tblFinalSelect TABLE (
		ItemNum INT NOT NULL,
		GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		PercentYes DECIMAL(5,2) NOT NULL,
		KeyPractice VARCHAR(250) NOT NULL,
		KeyPracticeAbbreviation VARCHAR(20) NOT NULL,
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		NumFormsIncluded INT NULL
	)

	--Get all the TPITOS forms
    INSERT INTO @tblAllTPITOS
    (
        TPITOSPK,
        FormDate,
        GroupingValue,
		GroupingText,
        Item1NumNo,
        Item1NumYes,
        Item2NumNo,
        Item2NumYes,
        Item3NumNo,
        Item3NumYes,
        Item4NumNo,
        Item4NumYes,
        Item5NumNo,
        Item5NumYes,
        Item6NumNo,
        Item6NumYes,
        Item7NumNo,
        Item7NumYes,
        Item8NumNo,
        Item8NumYes,
        Item9NumNo,
        Item9NumYes,
        Item10NumNo,
        Item10NumYes,
        Item11NumNo,
        Item11NumYes,
        Item12NumNo,
        Item12NumYes,
        Item13NumNo,
        Item13NumYes,
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
		t.Item1NumNo, t.Item1NumYes, t.Item2NumNo, t.Item2NumYes, t.Item3NumNo, t.Item3NumYes,
		t.Item4NumNo, t.Item4NumYes, t.Item5NumNo, t.Item5NumYes, t.Item6NumNo, t.Item6NumYes,
		t.Item7NumNo, t.Item7NumYes, t.Item8NumNo, t.Item8NumYes, t.Item9NumNo, t.Item9NumYes,
		t.Item10NumNo, t.Item10NumYes, t.Item11NumNo, t.Item11NumYes, t.Item12NumNo, t.Item12NumYes,
		t.Item13NumNo, t.Item13NumYes, c.ProgramFK, t.ClassroomFK
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON c.ProgramFK = programList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON t.ClassroomFK = classroomList.ListItem
	WHERE t.ObservationStartDateTime BETWEEN @StartDate AND @EndDate
		AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria


	--Get the first form date, last form date, and count of forms
	INSERT INTO @tblFormDatesAndCount
	(
	    FirstFormDate,
	    LastFormDate,
	    NumForms
	)
	SELECT MIN(tat.FormDate) AS FirstFormDate, MAX(tat.FormDate) AS LastFormDate, COUNT(DISTINCT tat.TPITOSPK) AS NumForms 
	FROM @tblAllTPITOS tat


	--Get the averages for each item
	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		1,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item1NumYes)) / NULLIF((SUM(tatt.Item1NumNo) + SUM(tatt.Item1NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		2,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item2NumYes)) / NULLIF((SUM(tatt.Item2NumNo) + SUM(tatt.Item2NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		3,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item3NumYes)) / NULLIF((SUM(tatt.Item3NumNo) + SUM(tatt.Item3NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		4,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item4NumYes)) / NULLIF((SUM(tatt.Item4NumNo) + SUM(tatt.Item4NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		5,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item5NumYes)) / NULLIF((SUM(tatt.Item5NumNo) + SUM(tatt.Item5NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		6,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item6NumYes)) / NULLIF((SUM(tatt.Item6NumNo) + SUM(tatt.Item6NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		7,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item7NumYes)) / NULLIF((SUM(tatt.Item7NumNo) + SUM(tatt.Item7NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		8,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item8NumYes)) / NULLIF((SUM(tatt.Item8NumNo) + SUM(tatt.Item8NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		9,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item9NumYes)) / NULLIF((SUM(tatt.Item9NumNo) + SUM(tatt.Item9NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		10,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item10NumYes)) / NULLIF((SUM(tatt.Item10NumNo) + SUM(tatt.Item10NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		11,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item11NumYes)) / NULLIF((SUM(tatt.Item11NumNo) + SUM(tatt.Item11NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		12,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item12NumYes)) / NULLIF((SUM(tatt.Item12NumNo) + SUM(tatt.Item12NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		13,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item13NumYes)) / NULLIF((SUM(tatt.Item13NumNo) + SUM(tatt.Item13NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		14,
		CONVERT(DECIMAL(5,2), SUM(tatt.Item14NumYes)) / NULLIF((SUM(tatt.Item14NumNo) + SUM(tatt.Item14NumYes)), 0) AS PercentYes
	FROM @tblAllTPITOS tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	--Get the data for the final select
	INSERT INTO @tblFinalSelect
	(
	    ItemNum,
	    GroupingValue,
	    GroupingText,
	    PercentYes,
	    KeyPractice,
	    KeyPracticeAbbreviation
	)
	SELECT ta.ItemNum, ta.GroupingValue, ta.GroupingText, ISNULL(ta.PercentYes, 0.00) AS PercentYes, 
		ctkp.Description AS KeyPractice, CONCAT(FORMAT(ta.ItemNum, '00'), '-', ctkp.Abbreviation) AS KeyPracticeAbbreviation
	FROM @tblAverages ta
	INNER JOIN dbo.CodeTPITOSKeyPractice ctkp ON ctkp.CodeTPITOSKeyPracticePK = ta.ItemNum
	ORDER BY ctkp.OrderBy ASC, ta.GroupingValue ASC

	--Update the final select table with the form dates and count
	UPDATE @tblFinalSelect SET FirstFormDate = tfdac.FirstFormDate, LastFormDate = tfdac.LastFormDate, 
		NumFormsIncluded = tfdac.NumForms
	FROM @tblFormDatesAndCount tfdac
	WHERE ItemNum IS NOT NULL

	--Perform the final select
	SELECT * 
	FROM @tblFinalSelect tfs
	ORDER BY tfs.GroupingValue ASC

END;
GO

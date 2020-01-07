SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/26/2019
-- Description:	This stored procedure returns the necessary information for the
-- details section of the TPITOS Red Flag Trend report
-- =============================================
CREATE PROC [dbo].[rspTPITOSRedFlagTrend_Details]
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
		ProgramFK INT NOT NULL,
		ClassroomFK INT NOT NULL
    );

	--To hold the distinct grouping values
	DECLARE @tblGroupingValues TABLE
	(
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL
	)

	--To hold the first and last form dates and the count of forms
	DECLARE @tblFormDatesAndCount TABLE (
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		NumForms INT NULL
	)

	--To hold the red flag counts
	DECLARE @tblRedFlagCounts TABLE (
		GroupingValue VARCHAR(20) NULL,
		GroupingText VARCHAR(40) NULL,
		RedFlagType VARCHAR(100) NOT NULL,
		RedFlagName VARCHAR(250) NOT NULL,
		RedFlagAbbreviation VARCHAR(20) NOT NULL,
		RedFlagTotal INT NULL
	)

	--To hold the data for the final select
	DECLARE @tblFinalSelect TABLE (
		GroupingValue VARCHAR(20) NULL,
		GroupingText VARCHAR(40) NULL,
		RedFlagType VARCHAR(100) NOT NULL,
		RedFlagName VARCHAR(250) NOT NULL,
		RedFlagAbbreviation VARCHAR(20) NOT NULL,
		RedFlagTotal INT NOT NULL,
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
		c.ProgramFK, t.ClassroomFK
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
	SELECT MIN(tatt.FormDate) AS FirstFormDate, MAX(tatt.FormDate) AS LastFormDate, COUNT(DISTINCT tatt.TPITOSPK) AS NumForms 
	FROM @tblAllTPITOS tatt


	--Get all the grouping values
	INSERT INTO @tblGroupingValues
	(
	    GroupingValue,
	    GroupingText
	)
	SELECT DISTINCT GroupingValue, GroupingText FROM @tblAllTPITOS tatt


	--Get the red flag counts by grouping value
	INSERT INTO @tblRedFlagCounts
	(
	    GroupingValue,
	    GroupingText,
		RedFlagType,
	    RedFlagName,
		RedFlagAbbreviation,
	    RedFlagTotal
	)
	SELECT tgv.GroupingValue,
		tgv.GroupingText,
		ctrf.Type,
		ctrf.Description,
		ctrf.Abbreviation,
		COUNT(DISTINCT tatt.TPITOSPK)
	FROM dbo.CodeTPITOSRedFlag ctrf
		INNER JOIN @tblGroupingValues tgv ON tgv.GroupingText = tgv.GroupingText
        LEFT JOIN dbo.TPITOSRedFlags trf
            ON trf.RedFlagCodeFK = ctrf.CodeTPITOSRedFlagPK
        LEFT JOIN @tblAllTPITOS tatt
            ON tatt.TPITOSPK = trf.TPITOSFK AND tatt.GroupingValue = tgv.GroupingValue
	GROUP BY ctrf.Type, ctrf.Description, ctrf.Abbreviation, tgv.GroupingValue, tgv.GroupingText


	--Get the data for the final select
	INSERT INTO @tblFinalSelect
	(
	    GroupingValue,
	    GroupingText,
		RedFlagType,
	    RedFlagName,
	    RedFlagAbbreviation,
	    RedFlagTotal
	)
	SELECT trfc.GroupingValue, trfc.GroupingText, 
		trfc.RedFlagType, trfc.RedFlagName, trfc.RedFlagAbbreviation, trfc.RedFlagTotal 
	FROM @tblRedFlagCounts trfc

	--Update the final select table with the form dates and count
	UPDATE @tblFinalSelect SET FirstFormDate = tfdac.FirstFormDate, LastFormDate = tfdac.LastFormDate, 
		NumFormsIncluded = tfdac.NumForms
	FROM @tblFormDatesAndCount tfdac
	WHERE RedFlagName IS NOT NULL

	--Perform the final select
	SELECT * 
	FROM @tblFinalSelect tfs
	ORDER BY tfs.GroupingValue ASC

END;
GO

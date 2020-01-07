SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/25/2019
-- Description:	This stored procedure returns the necessary information for the
-- chart on the TPOT Trend report
-- =============================================
CREATE PROC [dbo].[rspTPOTRedFlagTrend_Chart]
    @ProgramFKs VARCHAR(MAX) = NULL,
    @ClassroomFKs VARCHAR(MAX) = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--To hold all the TPOTs
    DECLARE @tblAllTPOTs TABLE
    (
        TPOTPK INT NOT NULL,
        FormDate DATETIME NOT NULL,
        GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
        RedFlagsNumNo INT NULL,
        RedFlagsNumYes INT NULL,
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

	--Get all the TPOT forms
    INSERT INTO @tblAllTPOTs
    (
        TPOTPK,
        FormDate,
        GroupingValue,
		GroupingText,
        RedFlagsNumNo,
        RedFlagsNumYes,
        ProgramFK,
        ClassroomFK
    )
	SELECT t.TPOTPK, t.ObservationStartDateTime, 
		CASE WHEN DATEPART(MONTH, t.ObservationStartDateTime) < 7 
			THEN CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime)), '-1-Spring') 
			ELSE CONCAT(CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime)), '-2-Fall') END AS GroupingValue,
		CASE WHEN DATEPART(MONTH, t.ObservationStartDateTime) < 7 
			THEN CONCAT('Spring ', CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime))) 
			ELSE CONCAT('Fall ', CONVERT(VARCHAR(10), DATEPART(YEAR, t.ObservationStartDateTime))) END AS GroupingText,
		t.RedFlagsNumNo, t.RedFlagsNumYes, c.ProgramFK, t.ClassroomFK
	FROM dbo.TPOT t
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
		'Red Flags',
		CONVERT(DECIMAL(5,2), SUM(tatt.RedFlagsNumYes)) / NULLIF((SUM(tatt.RedFlagsNumNo) + SUM(tatt.RedFlagsNumYes)), 0) AS PercentYes
	FROM @tblAllTPOTs tatt
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

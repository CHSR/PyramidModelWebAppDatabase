SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/25/2019
-- Description:	This stored procedure returns the necessary information for the
-- TPOT Trend report
-- =============================================
CREATE PROC [dbo].[rspTPOTTrend]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ClassroomFKs VARCHAR(8000) = NULL,
    @EmployeeFKs VARCHAR(8000),
    @EmployeeRole VARCHAR(10),
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--To hold all the TPOTs
    DECLARE @tblAllTPOTs TABLE
    (
        TPOTPK INT NOT NULL,
		ObserverFK INT NOT NULL,
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
		PercentYes DECIMAL(5, 2) NULL,
		TotalYes INT NULL,
		TotalNo INT NULL
	)

	--To hold the form counts per time period
	DECLARE @tblFormsPeriod TABLE(
		GroupingValue VARCHAR(20) NOT NULL,
		FormCount INT NOT NULL	
	)

	--To hold the data for the final select
	DECLARE @tblFinalSelect TABLE (
		ItemNum INT NOT NULL,
		GroupingValue VARCHAR(20) NOT NULL,
		GroupingText VARCHAR(40) NOT NULL,
		PercentYes DECIMAL(5, 2) NOT NULL,
		TotalYes INT NOT NULL,
		TotalNo INT NOT NULL,
		KeyPractice VARCHAR(250) NOT NULL,
		KeyPracticeAbbreviation VARCHAR(20) NOT NULL,
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		NumFormsIncluded INT NULL,
		FormsPerPeriod INT NULL

	)

	--Get all the TPOT forms
    INSERT INTO @tblAllTPOTs
    (
        TPOTPK,
		ObserverFK,
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
        Item14NumNo,
        Item14NumYes,
        ProgramFK,
        ClassroomFK
    )
	SELECT t.TPOTPK, t.ObserverFK, t.ObservationStartDateTime, 
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
		t.Item13NumNo, t.Item13NumYes, t.Item14NumNo, t.Item14NumYes, c.ProgramFK, t.ClassroomFK
	FROM dbo.TPOT t
		INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = c.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON t.ClassroomFK = classroomList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = c.ProgramFK
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
		t.ObservationStartDateTime BETWEEN @StartDate AND @EndDate
		AND t.IsComplete = 1
		AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria
	
	--Handle the optional employee criteria
    IF (@EmployeeFKs IS NOT NULL AND @EmployeeFKs <> '')
    BEGIN
        --To hold the participants
        DECLARE @tblParticipants TABLE
        (
            TPOTFK INT,
            ParticipantPK INT,
            ParticipantRoleAbbreviation VARCHAR(10)
        );

        --Get the observers
        INSERT INTO @tblParticipants
        (
            TPOTFK,
            ParticipantPK,
            ParticipantRoleAbbreviation
        )
        SELECT tc.TPOTPK,
               tc.ObserverFK,
               'OBS'
        FROM @tblAllTPOTs tc;

        --Get the other participants
        INSERT INTO @tblParticipants
        (
            TPOTFK,
            ParticipantPK,
            ParticipantRoleAbbreviation
        )
        SELECT tc.TPOTPK,
               tp.ProgramEmployeeFK,
               CASE
                   WHEN tp.ParticipantTypeCodeFK = 1 THEN
                       'LT'
                   ELSE
                       'TA'
               END AS RoleAbbrevation
        FROM @tblAllTPOTs tc
            INNER JOIN dbo.TPOTParticipant tp
                ON tp.TPOTFK = tc.TPOTPK;

        --Remove any participants that are not included in the employee criteria (if used)
        DELETE tp
        FROM @tblParticipants tp
            LEFT JOIN dbo.SplitStringToInt(@EmployeeFKs, ',') participantList
                ON tp.ParticipantPK = participantList.ListItem
                   AND
                   (
                       @EmployeeRole = 'ANY'
                       OR tp.ParticipantRoleAbbreviation = @EmployeeRole
                   )
        WHERE (
                  @EmployeeFKs IS NOT NULL
                  AND @EmployeeFKs <> ''
                  AND participantList.ListItem IS NULL
              ); --Optional employee criteria

        --Remove any TPOTs from the cohort if they don't match the employee criteria
        DELETE tc
        FROM @tblAllTPOTs tc
            LEFT JOIN @tblParticipants tp
                ON tp.TPOTFK = tc.TPOTPK
        WHERE tp.ParticipantPK IS NULL;

    END;

		--Get the count of the forms per each time period
	INSERT INTO @tblFormsPeriod
	(
	    GroupingValue,
	    FormCount
	)
	SELECT tps.GroupingValue, COUNT(DISTINCT tps.TPOTPK) AS FormCount
	FROM @tblAllTPOTs tps
	GROUP BY tps.GroupingValue

	--Get the first form date, last form date, and count of forms
	INSERT INTO @tblFormDatesAndCount
	(
	    FirstFormDate,
	    LastFormDate,
	    NumForms
	)
	SELECT MIN(tatt.FormDate) AS FirstFormDate, MAX(tatt.FormDate) AS LastFormDate, COUNT(DISTINCT tatt.TPOTPK) AS NumForms 
	FROM @tblAllTPOTs tatt


	--Get the averages for each item
	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		1,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item1NumYes)) / NULLIF((SUM(tatt.Item1NumNo) + SUM(tatt.Item1NumYes)), 0) AS PercentYes,
		SUM(tatt.Item1NumYes) AS TotalYes, SUM(tatt.Item1NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		2,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item2NumYes)) / NULLIF((SUM(tatt.Item2NumNo) + SUM(tatt.Item2NumYes)), 0) AS PercentYes,
		SUM(tatt.Item2NumYes) AS TotalYes, SUM(tatt.Item2NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		3,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item3NumYes)) / NULLIF((SUM(tatt.Item3NumNo) + SUM(tatt.Item3NumYes)), 0) AS PercentYes,
		SUM(tatt.Item3NumYes) AS TotalYes, SUM(tatt.Item3NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		4,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item4NumYes)) / NULLIF((SUM(tatt.Item4NumNo) + SUM(tatt.Item4NumYes)), 0) AS PercentYes,
		SUM(tatt.Item4NumYes) AS TotalYes, SUM(tatt.Item4NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		5,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item5NumYes)) / NULLIF((SUM(tatt.Item5NumNo) + SUM(tatt.Item5NumYes)), 0) AS PercentYes,
		SUM(tatt.Item5NumYes) AS TotalYes, SUM(tatt.Item5NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		6,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item6NumYes)) / NULLIF((SUM(tatt.Item6NumNo) + SUM(tatt.Item6NumYes)), 0) AS PercentYes,
		SUM(tatt.Item6NumYes) AS TotalYes, SUM(tatt.Item6NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		7,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item7NumYes)) / NULLIF((SUM(tatt.Item7NumNo) + SUM(tatt.Item7NumYes)), 0) AS PercentYes,
		SUM(tatt.Item7NumYes) AS TotalYes, SUM(tatt.Item7NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		8,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item8NumYes)) / NULLIF((SUM(tatt.Item8NumNo) + SUM(tatt.Item8NumYes)), 0) AS PercentYes,
		SUM(tatt.Item8NumYes) AS TotalYes, SUM(tatt.Item8NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		9,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item9NumYes)) / NULLIF((SUM(tatt.Item9NumNo) + SUM(tatt.Item9NumYes)), 0) AS PercentYes,
		SUM(tatt.Item9NumYes) AS TotalYes, SUM(tatt.Item9NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		10,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item10NumYes)) / NULLIF((SUM(tatt.Item10NumNo) + SUM(tatt.Item10NumYes)), 0) AS PercentYes,
		SUM(tatt.Item10NumYes) AS TotalYes, SUM(tatt.Item10NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		11,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item11NumYes)) / NULLIF((SUM(tatt.Item11NumNo) + SUM(tatt.Item11NumYes)), 0) AS PercentYes,
		SUM(tatt.Item11NumYes) AS TotalYes, SUM(tatt.Item11NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		12,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item12NumYes)) / NULLIF((SUM(tatt.Item12NumNo) + SUM(tatt.Item12NumYes)), 0) AS PercentYes,
		SUM(tatt.Item12NumYes) AS TotalYes, SUM(tatt.Item12NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		13,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item13NumYes)) / NULLIF((SUM(tatt.Item13NumNo) + SUM(tatt.Item13NumYes)), 0) AS PercentYes,
		SUM(tatt.Item13NumYes) AS TotalYes, SUM(tatt.Item13NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText

	INSERT INTO @tblAverages
	(
	    GroupingValue,
		GroupingText,
	    ItemNum,
	    PercentYes,
		TotalYes,
		TotalNo
	)
	SELECT tatt.GroupingValue,
		tatt.GroupingText,
		14,
		CONVERT(DECIMAL(15,2), SUM(tatt.Item14NumYes)) / NULLIF((SUM(tatt.Item14NumNo) + SUM(tatt.Item14NumYes)), 0) AS PercentYes,
		SUM(tatt.Item14NumYes) AS TotalYes, SUM(tatt.Item14NumNo) AS TotalNo
	FROM @tblAllTPOTs tatt
	GROUP BY tatt.GroupingValue, tatt.GroupingText


	--Get the data for the final select
	INSERT INTO @tblFinalSelect
	(
	    ItemNum,
	    GroupingValue,
	    GroupingText,
	    PercentYes,
	    KeyPractice,
	    KeyPracticeAbbreviation,
		TotalYes,
		TotalNo,
		FormsPerPeriod
	)
	SELECT ta.ItemNum, ta.GroupingValue, ta.GroupingText, ISNULL(ta.PercentYes, 0.00) AS PercentYes, 
		ctkp.Description AS KeyPractice, CONCAT(FORMAT(ta.ItemNum, '00'), '-', ctkp.Abbreviation) AS KeyPracticeAbbreviation,ISNULL(ta.TotalYes, 0.00) AS TotalYes,
		ISNULL(ta.TotalNo,0.00) AS TotalNo, fp.FormCount
	FROM @tblAverages ta
	INNER JOIN dbo.CodeTPOTKeyPractice ctkp ON ctkp.CodeTPOTKeyPracticePK = ta.ItemNum
	INNER JOIN @tblFormsPeriod fp ON fp.GroupingValue = ta.GroupingValue
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

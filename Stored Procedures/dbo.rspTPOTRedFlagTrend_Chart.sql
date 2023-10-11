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
		ObserverFK,
        FormDate,
        GroupingValue,
		GroupingText,
        RedFlagsNumNo,
        RedFlagsNumYes,
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
		t.RedFlagsNumNo, t.RedFlagsNumYes, c.ProgramFK, t.ClassroomFK
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
		CONVERT(DECIMAL(15,2), SUM(tatt.RedFlagsNumYes)) / NULLIF((SUM(tatt.RedFlagsNumNo) + SUM(tatt.RedFlagsNumYes)), 0) AS PercentYes
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

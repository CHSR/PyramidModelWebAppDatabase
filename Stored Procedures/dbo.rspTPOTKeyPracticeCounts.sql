SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/24/2019
-- Description:	Percentage of 'Yes' for each TPOT Key Practice.
-- =============================================
CREATE PROC [dbo].[rspTPOTKeyPracticeCounts]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ClassroomFKs VARCHAR(8000),
    @EmployeeFKs VARCHAR(8000),
    @EmployeeRole VARCHAR(10),
    @ProgramFKs VARCHAR(8000),
    @HubFKs VARCHAR(8000),
    @CohortFKs VARCHAR(8000),
    @StateFKs VARCHAR(8000)
AS
BEGIN

    DECLARE @tblCohort AS TABLE
    (
		TPOTPK INT NOT NULL,
		ObserverFK INT NOT NULL,
        FormDate DATETIME NOT NULL,
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
        Item14NumYes INT NULL
    );
    INSERT INTO @tblCohort
    (
		TPOTPK,
		ObserverFK,
        FormDate,
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
        Item14NumYes
    )
    SELECT t.TPOTPK, 
		   t.ObserverFK,
		   t.ObservationStartDateTime,
           t.Item1NumNo,
           t.Item1NumYes,
           t.Item2NumNo,
           t.Item2NumYes,
           t.Item3NumNo,
           t.Item3NumYes,
           t.Item4NumNo,
           t.Item4NumYes,
           t.Item5NumNo,
           t.Item5NumYes,
           t.Item6NumNo,
           t.Item6NumYes,
           t.Item7NumNo,
           t.Item7NumYes,
           t.Item8NumNo,
           t.Item8NumYes,
           t.Item9NumNo,
           t.Item9NumYes,
           t.Item10NumNo,
           t.Item10NumYes,
           t.Item11NumNo,
           t.Item11NumYes,
           t.Item12NumNo,
           t.Item12NumYes,
           t.Item13NumNo,
           t.Item13NumYes,
           t.Item14NumNo,
           t.Item14NumYes
    FROM dbo.TPOT t
        INNER JOIN dbo.Classroom c
            ON c.ClassroomPK = t.ClassroomFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = c.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList
            ON c.ClassroomPK = classroomList.ListItem
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
          AND
          (
              @ClassroomFKs IS NULL
              OR @ClassroomFKs = ''
              OR classroomList.ListItem IS NOT NULL
          ); --Optional classroom criteria

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
        FROM @tblCohort tc;

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
        FROM @tblCohort tc
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
        FROM @tblCohort tc
            LEFT JOIN @tblParticipants tp
                ON tp.TPOTFK = tc.TPOTPK
        WHERE tp.ParticipantPK IS NULL;

    END;


    DECLARE @tblResults AS TABLE
    (
        CodeTPOTKeyPracticeFK INT NOT NULL,
        IndicatorNumber INT NOT NULL,
        PctYes DECIMAL(5,2) NULL,
        CntYes INT NULL,
        CntNo INT NULL,
        CntTPOT INT NULL,
        MinDate DATETIME NULL,
        MaxDate DATETIME NULL
    );

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 1,
           1,
           CONVERT(DECIMAL(15,2), SUM(Item1NumYes)) / NULLIF(SUM(Item1NumYes) + SUM(Item1NumNo), 0),
           SUM(Item1NumYes),
           SUM(Item1NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 2,
           2,
           CONVERT(DECIMAL(15,2), SUM(Item2NumYes)) / NULLIF(SUM(Item2NumYes) + SUM(Item2NumNo), 0),
           SUM(Item2NumYes),
           SUM(Item2NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 3,
           3,
           CONVERT(DECIMAL(15,2), SUM(Item3NumYes)) / NULLIF(SUM(Item3NumYes) + SUM(Item3NumNo), 0),
           SUM(Item3NumYes),
           SUM(Item3NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 4,
           4,
           CONVERT(DECIMAL(15,2), SUM(Item4NumYes)) / NULLIF(SUM(Item4NumYes) + SUM(Item4NumNo), 0),
           SUM(Item4NumYes),
           SUM(Item4NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 5,
           5,
           CONVERT(DECIMAL(15,2), SUM(Item5NumYes)) / NULLIF(SUM(Item5NumYes) + SUM(Item5NumNo), 0),
           SUM(Item5NumYes),
           SUM(Item5NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 6,
           6,
           CONVERT(DECIMAL(15,2), SUM(Item6NumYes)) / NULLIF(SUM(Item6NumYes) + SUM(Item6NumNo), 0),
           SUM(Item6NumYes),
           SUM(Item6NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 7,
           7,
           CONVERT(DECIMAL(15,2), SUM(Item7NumYes)) / NULLIF(SUM(Item7NumYes) + SUM(Item7NumNo), 0),
           SUM(Item7NumYes),
           SUM(Item7NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 8,
           8,
           CONVERT(DECIMAL(15,2), SUM(Item8NumYes)) / NULLIF(SUM(Item8NumYes) + SUM(Item8NumNo), 0),
           SUM(Item8NumYes),
           SUM(Item8NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 9,
           9,
           CONVERT(DECIMAL(15,2), SUM(Item9NumYes)) / NULLIF(SUM(Item9NumYes) + SUM(Item9NumNo), 0),
           SUM(Item9NumYes),
           SUM(Item9NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 10,
           10,
           CONVERT(DECIMAL(15,2), SUM(Item10NumYes)) / NULLIF(SUM(Item10NumYes) + SUM(Item10NumNo), 0),
           SUM(Item10NumYes),
           SUM(Item10NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 11,
           11,
           CONVERT(DECIMAL(15,2), SUM(Item11NumYes)) / NULLIF(SUM(Item11NumYes) + SUM(Item11NumNo), 0),
           SUM(Item11NumYes),
           SUM(Item11NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 12,
           12,
           CONVERT(DECIMAL(15,2), SUM(Item12NumYes)) / NULLIF(SUM(Item12NumYes) + SUM(Item12NumNo), 0),
           SUM(Item12NumYes),
           SUM(Item12NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 13,
           13,
           CONVERT(DECIMAL(15,2), SUM(Item13NumYes)) / NULLIF(SUM(Item13NumYes) + SUM(Item13NumNo), 0),
           SUM(Item13NumYes),
           SUM(Item13NumNo)
    FROM @tblCohort tc;

    INSERT INTO @tblResults
    (
        CodeTPOTKeyPracticeFK,
        IndicatorNumber,
        PctYes,
        CntYes,
        CntNo
    )
    SELECT 14,
           14,
           CONVERT(DECIMAL(15,2), SUM(Item14NumYes)) / NULLIF(SUM(Item14NumYes) + SUM(Item14NumNo), 0),
           SUM(Item14NumYes),
           SUM(Item14NumNo)
    FROM @tblCohort tc;

    UPDATE @tblResults
    SET CntTPOT =
        (
            SELECT COUNT(*) FROM @tblCohort
        );
    UPDATE @tblResults
    SET MinDate =
        (
            SELECT MIN(FormDate) FROM @tblCohort
        );
    UPDATE @tblResults
    SET MaxDate =
        (
            SELECT MAX(FormDate) FROM @tblCohort
        );

    SELECT c.Description KeyPractice,
		   tr.IndicatorNumber,
           ISNULL(tr.PctYes, 0) AS PctYes,
           ISNULL(tr.CntYes, 0) AS CntYes,
           ISNULL(tr.CntNo, 0) AS CntNo,
           tr.CntTPOT,
           tr.MinDate,
           tr.MaxDate
    FROM @tblResults tr
        INNER JOIN dbo.CodeTPOTKeyPractice c
            ON tr.CodeTPOTKeyPracticeFK = c.CodeTPOTKeyPracticePK
    ORDER BY tr.IndicatorNumber ASC;
END;
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Derek Cacciotti
-- Create date: 09/16/2019
-- Description:	This stored procedure returns the necessary information for the
-- TPOT count report
-- =============================================
CREATE PROC [dbo].[rspTPOTRedFlagCounts]
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

    DECLARE @tblAllTPOT TABLE
    (
        TPOTPK INT NOT NULL,
		ObserverFK INT NOT NULL,
        TPOTDate DATETIME NOT NULL
    );

    DECLARE @tblTPOTData TABLE
    (
        RedFlagName VARCHAR(250) NOT NULL,
        RedFlagAbbreviation VARCHAR(20) NOT NULL,
		OrderBy INT NOT NULL,
        Total INT NOT NULL,
        MinDate DATETIME NULL,
        MaxDate DATETIME NULL,
        NumTPOTs INT NULL
    );

    INSERT INTO @tblAllTPOT
    (
        TPOTPK,
		ObserverFK,
        TPOTDate
    )
    SELECT t.TPOTPK,
		   t.ObserverFK,
           t.ObservationStartDateTime
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
        FROM @tblAllTPOT tc;

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
        FROM @tblAllTPOT tc
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
        FROM @tblAllTPOT tc
            LEFT JOIN @tblParticipants tp
                ON tp.TPOTFK = tc.TPOTPK
        WHERE tp.ParticipantPK IS NULL;

    END;

    INSERT INTO @tblTPOTData
    (
        RedFlagName,
        RedFlagAbbreviation,
		OrderBy,
        Total
    )
    SELECT ctrf.Description,
           ctrf.Abbreviation,
		   ctrf.OrderBy,
           COUNT(tat.TPOTPK)
    FROM dbo.CodeTPOTRedFlag ctrf
        LEFT JOIN dbo.TPOTRedFlags trf
            ON trf.RedFlagCodeFK = ctrf.CodeTPOTRedFlagPK
        LEFT JOIN @tblAllTPOT tat
            ON tat.TPOTPK = trf.TPOTFK
    GROUP BY ctrf.Description,
             ctrf.Abbreviation,
			 ctrf.OrderBy;

    UPDATE @tblTPOTData
    SET MinDate =
        (
            SELECT MIN(tp.TPOTDate) FROM @tblAllTPOT tp
        );

    UPDATE @tblTPOTData
    SET MaxDate =
        (
            SELECT MAX(tp.TPOTDate) FROM @tblAllTPOT tp
        );

    UPDATE @tblTPOTData
    SET NumTPOTs =
        (
            SELECT COUNT(DISTINCT tp.TPOTPK) FROM @tblAllTPOT tp
        );


    SELECT *
    FROM @tblTPOTData
    ORDER BY OrderBy ASC;

END;
GO

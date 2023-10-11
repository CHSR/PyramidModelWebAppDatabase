SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Derek Cacciotti
-- Create date: 09/14/2019
-- Description:	This stored procedure returns the necessary information for the
-- TPITOS count report
-- =============================================
CREATE PROC [dbo].[rspTPITOSRedFlagCounts]
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


    DECLARE @tblAllTPITOS TABLE
    (
        TPITOSPK INT NOT NULL,
		ObserverFK INT NOT NULL,
        TPITOSDate DATETIME NOT NULL
    );

    DECLARE @tblTPITOSData TABLE
    (
        RedFlagName VARCHAR(250) NOT NULL,
        RedFlagType VARCHAR(100) NOT NULL,
        RedFlagTypeAbbreviation VARCHAR(20) NOT NULL,
        RedFlagAbbreviation VARCHAR(20) NOT NULL,
		OrderBy INT NOT NULL,
        Total INT NOT NULL,
        MinDate DATETIME NULL,
        MaxDate DATETIME NULL,
        NumTPITOS INT NULL
    );

    --Get all the TPITOS in the date range
    INSERT INTO @tblAllTPITOS
    (
        TPITOSPK,
		ObserverFK,
        TPITOSDate
    )
    SELECT t.TPITOSPK,
		   t.ObserverFK,
           t.ObservationStartDateTime
    FROM dbo.TPITOS t
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
	IF(@EmployeeFKs IS NOT NULL AND @EmployeeFKs <> '')
	BEGIN
		--To hold the participants
		DECLARE @tblParticipants TABLE (
			TPITOSFK INT,
			ParticipantPK INT,
			ParticipantRoleAbbreviation VARCHAR(10)
		)

		--Get the observers
		INSERT INTO	 @tblParticipants
		(
			TPITOSFK,
			ParticipantPK,
			ParticipantRoleAbbreviation
		)
		SELECT tc.TPITOSPK, 
			   tc.ObserverFK, 
			   'OBS'
		FROM @tblAllTPITOS tc

		--Get the other participants
		INSERT INTO @tblParticipants
		(
			TPITOSFK,
			ParticipantPK,
			ParticipantRoleAbbreviation
		)
		SELECT tc.TPITOSPK,
			   tp.ProgramEmployeeFK,
			   CASE WHEN tp.ParticipantTypeCodeFK = 1 THEN 'LT' ELSE 'TA' END AS RoleAbbrevation
		FROM @tblAllTPITOS tc
		INNER JOIN dbo.TPITOSParticipant tp
			ON tp.TPITOSFK = tc.TPITOSPK

		--Remove any participants that are not included in the employee criteria (if used)
		DELETE tp
		FROM @tblParticipants tp		
		LEFT JOIN dbo.SplitStringToInt(@EmployeeFKs, ',') participantList
			ON tp.ParticipantPK = participantList.ListItem
				AND (@EmployeeRole = 'ANY' OR tp.ParticipantRoleAbbreviation = @EmployeeRole)
		WHERE (@EmployeeFKs IS NOT NULL AND @EmployeeFKs <> '' AND participantList.ListItem IS NULL); --Optional employee criteria

		--Remove any TPITOS from the cohort if they don't match the employee criteria
		DELETE tc 
		FROM @tblAllTPITOS tc
		LEFT JOIN @tblParticipants tp ON tp.TPITOSFK = tc.TPITOSPK
		WHERE tp.ParticipantPK IS NULL

    END

    --Get the red flag types and check to see how many TPITOS reference them
    INSERT INTO @tblTPITOSData
    (
        RedFlagName,
        RedFlagType,
		RedFlagTypeAbbreviation,
		RedFlagAbbreviation,
		OrderBy,
        Total
    )
    SELECT ctrf.Description,
           ctrf.Type,
		   ctrf.TypeAbbreviation,
		   ctrf.Abbreviation,
		   ctrf.OrderBy,
           COUNT(tat.TPITOSPK)
    FROM dbo.CodeTPITOSRedFlag ctrf
        LEFT JOIN dbo.TPITOSRedFlags trf
            ON trf.RedFlagCodeFK = ctrf.CodeTPITOSRedFlagPK
        LEFT JOIN @tblAllTPITOS tat
            ON tat.TPITOSPK = trf.TPITOSFK
    GROUP BY ctrf.Description,
             ctrf.Type,
			 ctrf.TypeAbbreviation,
			 ctrf.Abbreviation,
			 ctrf.OrderBy;

    --Get the minimum TPITOS date
    UPDATE @tblTPITOSData
    SET MinDate =
        (
            SELECT MIN(tp.TPITOSDate) FROM @tblAllTPITOS tp
        );

    --Get the maximum TPITOS date
    UPDATE @tblTPITOSData
    SET MaxDate =
        (
            SELECT MAX(tp.TPITOSDate) FROM @tblAllTPITOS tp
        );

    --Get the number of TPITOS forms
    UPDATE @tblTPITOSData
    SET NumTPITOS =
        (
            SELECT COUNT(DISTINCT tp.TPITOSPK) FROM @tblAllTPITOS tp
        );

    --Final select
    SELECT *
    FROM @tblTPITOSData
    ORDER BY OrderBy ASC;

END;
GO

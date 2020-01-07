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
    @ProgramFKs VARCHAR(MAX),
    @ClassroomFKs VARCHAR(MAX)
AS
BEGIN

    DECLARE @tblAllTPOT TABLE
    (
        TPOTPK INT NOT NULL,
        TPOTDate DATETIME NOT NULL
    );

    DECLARE @tblTPOTData TABLE
    (
        RedFlagName VARCHAR(250) NOT NULL,
        Total INT NOT NULL,
        MinDate DATETIME NULL,
        MaxDate DATETIME NULL,
        NumTPOTs INT NULL
    );

    INSERT INTO @tblAllTPOT
    (
        TPOTPK,
        TPOTDate
    )
    SELECT t.TPOTPK,
           t.ObservationStartDateTime
    FROM dbo.TPOT t
        INNER JOIN dbo.Classroom c
            ON c.ClassroomPK = t.ClassroomFK
        INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON c.ProgramFK = programList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList
            ON c.ClassroomPK = classroomList.ListItem
    WHERE t.ObservationStartDateTime BETWEEN @StartDate AND @EndDate
		AND t.IsValid = 1
		AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria


    INSERT INTO @tblTPOTData
    (
        RedFlagName,
        Total
    )
    SELECT codetpotredflag.Description,
           COUNT(alltpots.TPOTPK)
    FROM dbo.CodeTPOTRedFlag codetpotredflag
        LEFT JOIN dbo.TPOTRedFlags tpotredflag
            ON tpotredflag.RedFlagCodeFK = codetpotredflag.CodeTPOTRedFlagPK
        LEFT JOIN @tblAllTPOT alltpots
            ON alltpots.TPOTPK = tpotredflag.TPOTFK
    GROUP BY codetpotredflag.Description;

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
	ORDER BY Total ASC;

END;

GO

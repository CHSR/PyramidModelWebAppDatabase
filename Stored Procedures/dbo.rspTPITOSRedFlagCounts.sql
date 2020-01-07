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
    @ProgramFKs VARCHAR(MAX),
    @ClassroomFKs VARCHAR(MAX)
AS
BEGIN


DECLARE @tblAllTPITOS TABLE
(
    TTPITOSPK INT NOT NULL,
    TPITOSDate DATETIME NOT NULL
);

DECLARE @tblTPITOSData TABLE
(
    RedFlagName VARCHAR(250) NOT NULL,
    RedFlagType VARCHAR(100) NOT NULL,
    Total INT NOT NULL,
    MinDate DATETIME NULL,
    MaxDate DATETIME NULL,
	NumTPITOS INT NULL
);

--Get all the TPITOS in the date range
INSERT INTO @tblAllTPITOS
(
    TTPITOSPK,
    TPITOSDate
)
SELECT t.TPITOSPK,
       t.ObservationStartDateTime
FROM dbo.TPITOS t
    INNER JOIN dbo.Classroom c
        ON c.ClassroomPK = t.ClassroomFK
    INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
        ON c.ProgramFK = programList.ListItem
    LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList
        ON c.ClassroomPK = classroomList.ListItem
WHERE t.ObservationStartDateTime BETWEEN @StartDate AND @EndDate
AND t.IsValid = 1
AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria

--Get the red flag types and check to see how many TPITOS reference them
INSERT INTO @tblTPITOSData
(
    RedFlagName,
    Total,
    RedFlagType
)
SELECT codetpitosredflag.Description,
       COUNT(allTPITOS.TTPITOSPK),
       codetpitosredflag.Type
FROM dbo.CodeTPITOSRedFlag codetpitosredflag
    LEFT JOIN dbo.TPITOSRedFlags TPITTOSRedFlag
        ON TPITTOSRedFlag.RedFlagCodeFK = codetpitosredflag.CodeTPITOSRedFlagPK
    LEFT JOIN @tblAllTPITOS allTPITOS
        ON allTPITOS.TTPITOSPK = TPITTOSRedFlag.TPITOSFK
GROUP BY codetpitosredflag.Description,
         codetpitosredflag.Type;

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
        SELECT COUNT(DISTINCT tp.TTPITOSPK) FROM @tblAllTPITOS tp
    );

--Final select
SELECT *
FROM @tblTPITOSData 
ORDER BY NumTPITOS ASC;

END;

GO

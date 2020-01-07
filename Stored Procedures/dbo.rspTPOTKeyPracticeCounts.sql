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
    @ProgramFKs VARCHAR(MAX),
    @ClassroomFKs VARCHAR(MAX)
AS
BEGIN

DECLARE @tblCohort AS TABLE	(
	  FormDate DATETIME
	, [Item1NumNo] [INT]
	, [Item1NumYes] [INT]
	, [Item2NumNo] [INT]
	, [Item2NumYes] [INT]
	, [Item3NumNo] [INT]
	, [Item3NumYes] [INT]
	, [Item4NumNo] [INT]
	, [Item4NumYes] [INT]
	, [Item5NumNo] [INT]
	, [Item5NumYes] [INT]
	, [Item6NumNo] [INT]
	, [Item6NumYes] [INT]
	, [Item7NumNo] [INT]
	, [Item7NumYes] [INT]
	, [Item8NumNo] [INT]
	, [Item8NumYes] [INT]
	, [Item9NumNo] [INT]
	, [Item9NumYes] [INT]
	, [Item10NumNo] [INT]
	, [Item10NumYes] [INT]
	, [Item11NumNo] [INT]
	, [Item11NumYes] [INT]
	, [Item12NumNo] [INT]
	, [Item12NumYes] [INT]
	, [Item13NumNo] [INT]
	, [Item13NumYes] [INT]
	, [Item14NumNo] [INT]
	, [Item14NumYes] [INT]
)
INSERT	INTO @tblCohort
(
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
SELECT
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
INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
    ON c.ProgramFK = programList.ListItem
LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList
    ON c.ClassroomPK = classroomList.ListItem
WHERE t.ObservationStartDateTime
BETWEEN @StartDate AND @EndDate
AND t.IsValid = 1
AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria


DECLARE @tblResults AS	TABLE (
     CodeTPOTKeyPracticeFK INT
	,PctYes	FLOAT
	,CntYes INT
	,CntNo INT
	,CntTPOT INT
	,MinDate DATETIME
	,MaxDate DATETIME
)

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	1
	, CONVERT(FLOAT, SUM(Item1NumYes)) / NULLIF(SUM(Item1NumYes) + SUM(Item1NumNo), 0)
	, SUM(Item1NumYes)
	, SUM(Item1NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	2
	, CONVERT(FLOAT, SUM(Item2NumYes)) / NULLIF(SUM(Item2NumYes) + SUM(Item2NumNo), 0)
	, SUM(Item2NumYes)
	, SUM(Item2NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	3
	, CONVERT(FLOAT, SUM(Item3NumYes)) / NULLIF(SUM(Item3NumYes) + SUM(Item3NumNo), 0)
	, SUM(Item3NumYes)
	, SUM(Item3NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	4
	, CONVERT(FLOAT, SUM(Item4NumYes)) / NULLIF(SUM(Item4NumYes) + SUM(Item4NumNo), 0)
	, SUM(Item4NumYes)
	, SUM(Item4NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	5
	, CONVERT(FLOAT, SUM(Item5NumYes)) / NULLIF(SUM(Item5NumYes) + SUM(Item5NumNo), 0)
	, SUM(Item5NumYes)
	, SUM(Item5NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	6
	, CONVERT(FLOAT, SUM(Item6NumYes)) / NULLIF(SUM(Item6NumYes) + SUM(Item6NumNo), 0)
	, SUM(Item6NumYes)
	, SUM(Item6NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	7
	, CONVERT(FLOAT, SUM(Item7NumYes)) / NULLIF(SUM(Item7NumYes) + SUM(Item7NumNo), 0)
	, SUM(Item7NumYes)
	, SUM(Item7NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	8
	, CONVERT(FLOAT, SUM(Item8NumYes)) / NULLIF(SUM(Item8NumYes) + SUM(Item8NumNo), 0)
	, SUM(Item8NumYes)
	, SUM(Item8NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	9
	, CONVERT(FLOAT, SUM(Item9NumYes)) / NULLIF(SUM(Item9NumYes) + SUM(Item9NumNo), 0)
	, SUM(Item9NumYes)
	, SUM(Item9NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	10
	, CONVERT(FLOAT, SUM(Item10NumYes)) / NULLIF(SUM(Item10NumYes) + SUM(Item10NumNo), 0)
	, SUM(Item10NumYes)
	, SUM(Item10NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	11
	, CONVERT(FLOAT, SUM(Item11NumYes)) / NULLIF(SUM(Item11NumYes) + SUM(Item11NumNo), 0)
	, SUM(Item11NumYes)
	, SUM(Item11NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	12
	, CONVERT(FLOAT, SUM(Item12NumYes)) / NULLIF(SUM(Item12NumYes) + SUM(Item12NumNo), 0)
	, SUM(Item12NumYes)
	, SUM(Item12NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	13
	, CONVERT(FLOAT, SUM(Item13NumYes)) / NULLIF(SUM(Item13NumYes) + SUM(Item13NumNo), 0)
	, SUM(Item13NumYes)
	, SUM(Item13NumNo)
FROM @tblCohort tc

INSERT INTO 
	@tblResults (CodeTPOTKeyPracticeFK, PctYes, CntYes, CntNo)
SELECT 
	14
	, CONVERT(FLOAT, SUM(Item14NumYes)) / NULLIF(SUM(Item14NumYes) + SUM(Item14NumNo), 0)
	, SUM(Item14NumYes)
	, SUM(Item14NumNo)
FROM @tblCohort tc

UPDATE @tblResults SET CntTPOT = (SELECT COUNT(*) FROM @tblCohort)
UPDATE @tblResults SET MinDate = (SELECT MIN(FormDate) FROM @tblCohort)
UPDATE @tblResults SET MaxDate = (SELECT MAX(FormDate) FROM @tblCohort)

SELECT 
       c.Description KeyPractice,
       ISNULL(PctYes, 0) AS PctYes,
       ISNULL(CntYes, 0) AS CntYes,
       ISNULL(CntNo, 0) AS CntNo,
       CntTPOT,
       MinDate,
       MaxDate FROM @tblResults
	   INNER JOIN CodeTPOTKeyPractice c ON CodeTPOTKeyPracticeFK = c.CodeTPOTKeyPracticePK ORDER BY PctYes desc
END;

GO

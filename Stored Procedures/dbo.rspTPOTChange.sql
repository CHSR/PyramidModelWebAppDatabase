SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/26/2019
-- Description:	This report calculates the difference from year to year of the percentage of 'Yes' responses for all TPOT items.
-- =============================================
CREATE PROC [dbo].[rspTPOTChange]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ProgramFKs VARCHAR(MAX),
    @ClassroomFKs VARCHAR(MAX)
AS
BEGIN

DECLARE @tblCohort AS TABLE	(
	[TPOTPK] [INT],
	[ObservationStartDateTime] [DATETIME],
	[Item1NumNo] [INT],
	[Item1NumYes] [INT],
	[Item2NumNo] [INT],
	[Item2NumYes] [INT],
	[Item3NumNo] [INT],
	[Item3NumYes] [INT],
	[Item4NumNo] [INT],
	[Item4NumYes] [INT],
	[Item5NumNo] [INT],
	[Item5NumYes] [INT],
	[Item6NumNo] [INT],
	[Item6NumYes] [INT],
	[Item7NumNo] [INT],
	[Item7NumYes] [INT],
	[Item8NumNo] [INT],
	[Item8NumYes] [INT],
	[Item9NumNo] [INT],
	[Item9NumYes] [INT],
	[Item10NumNo] [INT],
	[Item10NumYes] [INT],
	[Item11NumNo] [INT],
	[Item11NumYes] [INT],
	[Item12NumNo] [INT],
	[Item12NumYes] [INT],
	[Item13NumNo] [INT],
	[Item13NumYes] [INT],
	[Item14NumNo] [INT],
	[Item14NumYes] [INT]
)
INSERT INTO @tblCohort
(
   [TPOTPK],
   [ObservationStartDateTime],
	[Item1NumNo],
	[Item1NumYes],
	[Item2NumNo],
	[Item2NumYes],
	[Item3NumNo],
	[Item3NumYes],
	[Item4NumNo],
	[Item4NumYes],
	[Item5NumNo],
	[Item5NumYes],
	[Item6NumNo],
	[Item6NumYes],
	[Item7NumNo],
	[Item7NumYes],
	[Item8NumNo],
	[Item8NumYes],
	[Item9NumNo],
	[Item9NumYes],
	[Item10NumNo],
	[Item10NumYes],
	[Item11NumNo],
	[Item11NumYes],
	[Item12NumNo],
	[Item12NumYes],
	[Item13NumNo],
	[Item13NumYes],
	[Item14NumNo],
	[Item14NumYes]
)
SELECT
   t.[TPOTPK],
   t.[ObservationStartDateTime],
	t.[Item1NumNo],
	t.[Item1NumYes],
	t.[Item2NumNo],
	t.[Item2NumYes],
	t.[Item3NumNo],
	t.[Item3NumYes],
	t.[Item4NumNo],
	t.[Item4NumYes],
	t.[Item5NumNo],
	t.[Item5NumYes],
	t.[Item6NumNo],
	t.[Item6NumYes],
	t.[Item7NumNo],
	t.[Item7NumYes],
	t.[Item8NumNo],
	t.[Item8NumYes],
	t.[Item9NumNo],
	t.[Item9NumYes],
	t.[Item10NumNo],
	t.[Item10NumYes],
	t.[Item11NumNo],
	t.[Item11NumYes],
	t.[Item12NumNo],
	t.[Item12NumYes],
	t.[Item13NumNo],
	t.[Item13NumYes],
	t.[Item14NumNo],
	t.[Item14NumYes]
 
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



DECLARE @tblYearlyPercentage AS	TABLE (
     CodeTPOTKeyPracticeFK INT
	,YearObserved Int
	,PctYes FLOAT
	,CntYes INT
	,CntNo INT
	,MinDate DATETIME
	,MaxDate DATETIME
)

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	1
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item1NumYes)) / NULLIF(SUM(tc.Item1NumYes) + SUM(tc.Item1NumNo), 0)
	,ISNULL(SUM(tc.Item1NumYes), 0)
	,ISNULL(SUM(tc.Item1NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')	

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	2
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item2NumYes)) / NULLIF(SUM(tc.Item2NumYes) + SUM(tc.Item2NumNo), 0)
	,ISNULL(SUM(tc.Item2NumYes), 0)
	,ISNULL(SUM(tc.Item2NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	3
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item3NumYes)) / NULLIF(SUM(tc.Item3NumYes) + SUM(tc.Item3NumNo), 0)
	,ISNULL(SUM(tc.Item3NumYes), 0)
	,ISNULL(SUM(tc.Item3NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	4
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item4NumYes)) / NULLIF(SUM(tc.Item4NumYes) + SUM(tc.Item4NumNo), 0)
	,ISNULL(SUM(tc.Item4NumYes), 0)
	,ISNULL(SUM(tc.Item4NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	5
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item5NumYes)) / NULLIF(SUM(tc.Item5NumYes) + SUM(tc.Item5NumNo), 0)
	,ISNULL(SUM(tc.Item5NumYes), 0)
	,ISNULL(SUM(tc.Item5NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	6
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item6NumYes)) / NULLIF(SUM(tc.Item6NumYes) + SUM(tc.Item6NumNo), 0)
	,ISNULL(SUM(tc.Item6NumYes), 0)
	,ISNULL(SUM(tc.Item6NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	7
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item7NumYes)) / NULLIF(SUM(tc.Item7NumYes) + SUM(tc.Item7NumNo), 0)
	,ISNULL(SUM(tc.Item7NumYes), 0)
	,ISNULL(SUM(tc.Item7NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	8
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item8NumYes)) / NULLIF(SUM(tc.Item8NumYes) + SUM(tc.Item8NumNo), 0)
	,ISNULL(SUM(tc.Item8NumYes), 0)
	,ISNULL(SUM(tc.Item8NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	9
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item9NumYes)) / NULLIF(SUM(tc.Item9NumYes) + SUM(tc.Item9NumNo), 0)
	,ISNULL(SUM(tc.Item9NumYes), 0)
	,ISNULL(SUM(tc.Item9NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	10
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item10NumYes)) / NULLIF(SUM(tc.Item10NumYes) + SUM(tc.Item10NumNo), 0)
	,ISNULL(SUM(tc.Item10NumYes), 0)
	,ISNULL(SUM(tc.Item10NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	11
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item11NumYes)) / NULLIF(SUM(tc.Item11NumYes) + SUM(tc.Item11NumNo), 0)
	,ISNULL(SUM(tc.Item11NumYes), 0)
	,ISNULL(SUM(tc.Item11NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	12
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item12NumYes)) / NULLIF(SUM(tc.Item12NumYes) + SUM(tc.Item12NumNo), 0)
	,ISNULL(SUM(tc.Item12NumYes), 0)
	,ISNULL(SUM(tc.Item12NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	13
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item13NumYes)) / NULLIF(SUM(tc.Item13NumYes) + SUM(tc.Item13NumNo), 0)
	,ISNULL(SUM(tc.Item13NumYes), 0)
	,ISNULL(SUM(tc.Item13NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPOTKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	14
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item14NumYes)) / NULLIF(SUM(tc.Item14NumYes) + SUM(tc.Item14NumNo), 0)
	,ISNULL(SUM(tc.Item14NumYes), 0)
	,ISNULL(SUM(tc.Item14NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

DECLARE @tblYearlyPercentageDifference AS TABLE (
	  CodeTPOTKeyPracticeFK INT
	, TimeSpan VARCHAR(9)
	, PctYesDiff FLOAT
	, MinDate DATETIME
	, MaxDate DATETIME
	, CntTPOT INT
) 

INSERT INTO @tblYearlyPercentageDifference
(
    CodeTPOTKeyPracticeFK,
    TimeSpan,
    PctYesDiff
)

SELECT 
	typNext.CodeTPOTKeyPracticeFK
	,CONCAT(typPrev.YearObserved, '-', typNext.YearObserved)
	,typNext.PctYes - typPrev.PctYes 
	FROM @tblYearlyPercentage typPrev
	INNER JOIN @tblYearlyPercentage typNext ON typPrev.CodeTPOTKeyPracticeFK = typNext.CodeTPOTKeyPracticeFK
	AND typPrev.YearObserved = typNext.YearObserved - 1

DECLARE @tblAverage AS TABLE (
	CodeTPOTKeyPracticeFK INT
	,AvgPctYesDiff FLOAT
)

INSERT	INTO @tblAverage
(CodeTPOTKeyPracticeFK, AvgPctYesDiff)

SELECT 
	CodeTPOTKeyPracticeFK
	,AVG(PctYesDiff)
FROM @tblYearlyPercentageDifference typd GROUP BY typd.CodeTPOTKeyPracticeFK

    
UPDATE @tblYearlyPercentageDifference SET MinDate = (SELECT MIN(ObservationStartDateTime) FROM @tblCohort tc)
UPDATE @tblYearlyPercentageDifference SET MaxDate = (SELECT MAX(ObservationStartDateTime) FROM @tblCohort tc)
UPDATE @tblYearlyPercentageDifference SET CntTPOT = (SELECT COUNT(*) FROM @tblCohort tc)

SELECT 
	   typd.CodeTPOTKeyPracticeFK,
	   ctkp.Description,
       typd.TimeSpan,
       typd.PctYesDiff,
       typd.MinDate,
       typd.MaxDate,
       typd.CntTPOT,
       ta.AvgPctYesDiff FROM @tblYearlyPercentageDifference typd
INNER JOIN @tblAverage ta ON ta.CodeTPOTKeyPracticeFK = typd.CodeTPOTKeyPracticeFK
INNER JOIN dbo.CodeTPOTKeyPractice ctkp ON ctkp.CodeTPOTKeyPracticePK = typd.CodeTPOTKeyPracticeFK
END;

GO

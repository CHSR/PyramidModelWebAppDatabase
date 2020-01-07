SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/30/2019
-- Description:	This report calculates the difference from year to year of the percentage of 'Yes' responses for all TPITOS items.
-- =============================================
CREATE PROC [dbo].[rspTPITOSChange]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ProgramFKs VARCHAR(MAX),
    @ClassroomFKs VARCHAR(MAX)
AS
BEGIN

DECLARE @tblCohort AS TABLE	(
	[TPITOSPK] [INT],
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
	[Item13NumYes] [INT]
)
INSERT INTO @tblCohort
(
    [TPITOSPK],
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
	[Item13NumYes]
)
SELECT
    [TPITOSPK],
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
	[Item13NumYes]
 
	FROM dbo.TPITOS t
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
     CodeTPITOSKeyPracticeFK INT
	,YearObserved Int
	,PctYes FLOAT
	,CntYes INT
	,CntNo INT
	,MinDate DATETIME
	,MaxDate DATETIME
)

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	1
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item1NumYes)) / NULLIF(SUM(tc.Item1NumYes) + SUM(tc.Item1NumNo), 0)
	,ISNULL(SUM(tc.Item1NumYes), 0)
	,ISNULL(SUM(tc.Item1NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')	

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	2
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item2NumYes)) / NULLIF(SUM(tc.Item2NumYes) + SUM(tc.Item2NumNo), 0)
	,ISNULL(SUM(tc.Item2NumYes), 0)
	,ISNULL(SUM(tc.Item2NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	3
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item3NumYes)) / NULLIF(SUM(tc.Item3NumYes) + SUM(tc.Item3NumNo), 0)
	,ISNULL(SUM(tc.Item3NumYes), 0)
	,ISNULL(SUM(tc.Item3NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	4
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item4NumYes)) / NULLIF(SUM(tc.Item4NumYes) + SUM(tc.Item4NumNo), 0)
	,ISNULL(SUM(tc.Item4NumYes), 0)
	,ISNULL(SUM(tc.Item4NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	5
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item5NumYes)) / NULLIF(SUM(tc.Item5NumYes) + SUM(tc.Item5NumNo), 0)
	,ISNULL(SUM(tc.Item5NumYes), 0)
	,ISNULL(SUM(tc.Item5NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	6
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item6NumYes)) / NULLIF(SUM(tc.Item6NumYes) + SUM(tc.Item6NumNo), 0)
	,ISNULL(SUM(tc.Item6NumYes), 0)
	,ISNULL(SUM(tc.Item6NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	7
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item7NumYes)) / NULLIF(SUM(tc.Item7NumYes) + SUM(tc.Item7NumNo), 0)
	,ISNULL(SUM(tc.Item7NumYes), 0)
	,ISNULL(SUM(tc.Item7NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	8
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item8NumYes)) / NULLIF(SUM(tc.Item8NumYes) + SUM(tc.Item8NumNo), 0)
	,ISNULL(SUM(tc.Item8NumYes), 0)
	,ISNULL(SUM(tc.Item8NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	9
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item9NumYes)) / NULLIF(SUM(tc.Item9NumYes) + SUM(tc.Item9NumNo), 0)
	,ISNULL(SUM(tc.Item9NumYes), 0)
	,ISNULL(SUM(tc.Item9NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	10
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item10NumYes)) / NULLIF(SUM(tc.Item10NumYes) + SUM(tc.Item10NumNo), 0)
	,ISNULL(SUM(tc.Item10NumYes), 0)
	,ISNULL(SUM(tc.Item10NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	11
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item11NumYes)) / NULLIF(SUM(tc.Item11NumYes) + SUM(tc.Item11NumNo), 0)
	,ISNULL(SUM(tc.Item11NumYes), 0)
	,ISNULL(SUM(tc.Item11NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	12
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item12NumYes)) / NULLIF(SUM(tc.Item12NumYes) + SUM(tc.Item12NumNo), 0)
	,ISNULL(SUM(tc.Item12NumYes), 0)
	,ISNULL(SUM(tc.Item12NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

INSERT INTO	@tblYearlyPercentage (CodeTPITOSKeyPracticeFK, YearObserved, PctYes, CntYes, CntNo)
SELECT 
	13
	,CONVERT(INT, FORMAT(tc.ObservationStartDateTime, 'yyyy'))
	,CONVERT(FLOAT,SUM(tc.Item13NumYes)) / NULLIF(SUM(tc.Item13NumYes) + SUM(tc.Item13NumNo), 0)
	,ISNULL(SUM(tc.Item13NumYes), 0)
	,ISNULL(SUM(tc.Item13NumNo), 0)
FROM @tblCohort tc
GROUP BY FORMAT(tc.ObservationStartDateTime, 'yyyy')

DECLARE @tblYearlyPercentageDifference AS TABLE (
	  CodeTPITOSKeyPracticeFK INT
	, TimeSpan VARCHAR(9)
	, PctYesDiff FLOAT
	, MinDate DATETIME
	, MaxDate DATETIME
	, CntTPITOS INT
) 

INSERT INTO @tblYearlyPercentageDifference
(
    CodeTPITOSKeyPracticeFK,
    TimeSpan,
    PctYesDiff
)

SELECT 
	typNext.CodeTPITOSKeyPracticeFK
	,CONCAT(typPrev.YearObserved, '-', typNext.YearObserved)
	,typNext.PctYes - typPrev.PctYes 
	FROM @tblYearlyPercentage typPrev
	INNER JOIN @tblYearlyPercentage typNext ON typPrev.CodeTPITOSKeyPracticeFK = typNext.CodeTPITOSKeyPracticeFK
	AND typPrev.YearObserved = typNext.YearObserved - 1

DECLARE @tblAverage AS TABLE (
	CodeTPITOSKeyPracticeFK INT
	,AvgPctYesDiff FLOAT
)

INSERT	INTO @tblAverage
(CodeTPITOSKeyPracticeFK, AvgPctYesDiff)

SELECT 
	CodeTPITOSKeyPracticeFK
	,AVG(PctYesDiff)
FROM @tblYearlyPercentageDifference typd GROUP BY typd.CodeTPITOSKeyPracticeFK

    
UPDATE @tblYearlyPercentageDifference SET MinDate = (SELECT MIN(ObservationStartDateTime) FROM @tblCohort tc)
UPDATE @tblYearlyPercentageDifference SET MaxDate = (SELECT MAX(ObservationStartDateTime) FROM @tblCohort tc)
UPDATE @tblYearlyPercentageDifference SET CntTPITOS = (SELECT COUNT(*) FROM @tblCohort tc)

SELECT 
	   typd.CodeTPITOSKeyPracticeFK,
	   ctkp.Description,
       typd.TimeSpan,
       typd.PctYesDiff,
       typd.MinDate,
       typd.MaxDate,
       typd.CntTPITOS,
       ta.AvgPctYesDiff FROM @tblYearlyPercentageDifference typd
INNER JOIN @tblAverage ta ON ta.CodeTPITOSKeyPracticeFK = typd.CodeTPITOSKeyPracticeFK
INNER JOIN dbo.CodeTPITOSKeyPractice ctkp ON ctkp.CodeTPITOSKeyPracticePK = typd.CodeTPITOSKeyPracticeFK
END;

GO

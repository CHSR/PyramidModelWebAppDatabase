SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/27/2019
-- Description:	This stored procedure returns the necessary information for the
-- ASQSE Percent by Month Report
-- =============================================
CREATE PROC [dbo].[rspASQSEPercentByMonth]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@ClassroomFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--To hold the ASQSEs
	DECLARE @tblCohort TABLE (
		ASQSEPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
		HasDemographicInfoSheet BIT NOT NULL,
		HasPhysicianInfoLetter BIT NOT NULL,
		TotalScore INT NOT NULL,
		ChildFK INT NOT NULL,
		IntervalCodeFK INT NOT NULL,
		ProgramFK INT NOT NULL,
		Version INT NOT NULL
	)

	--To hold the score types and codes
	DECLARE @tblScoreTypes TABLE
	(
		ScoreTypeCode INT NOT NULL,
		ScoreType VARCHAR(50) NOT NULL
	)

	--To hold the classroom history info
	DECLARE @tblClassroomAssignments TABLE (
		ChildPK INT NOT NULL,
		ClassroomPK INT NULL,
		RowNum INT NULL
	)

	--To hold the filtered cohort
	DECLARE @tblFilteredCohort TABLE (
		ASQSEPK INT NOT NULL,
		FormDate DATETIME NOT NULL,
		HasDemographicInfoSheet BIT NOT NULL,
		HasPhysicianInfoLetter BIT NOT NULL,
		TotalScore INT NOT NULL,
		ChildFK INT NOT NULL,
		IntervalCodeFK INT NOT NULL,
		ProgramFK INT NOT NULL,
		Version INT NOT NULL,
		ScoreTypeCode INT NULL
	)

	--To hold the first and last form dates and the count of forms
	DECLARE @tblFormDatesAndCount TABLE (
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		NumForms INT NULL
	)

	--To hold the number of forms by interval
	DECLARE @tblIntervalFormCounts TABLE (
		IntervalMonth INT NOT NULL,
		IntervalDescription VARCHAR(250),
		NumIntervalForms INT NOT NULL
	)

	--To hold the number of forms by score type
	DECLARE @tblIntervalScoreTypeFormCounts TABLE (
		IntervalMonth INT NOT NULL,
		IntervalDescription VARCHAR(250),
		ScoreType VARCHAR(50),
		NumIntervalScoreTypeForms INT NOT NULL
	)

	--To hold the final select info
	DECLARE @tblFinalSelect TABLE (
		IntervalMonth INT NOT NULL,
		IntervalDescription VARCHAR(250),
		ScoreType VARCHAR(50) NOT NULL,
		NumIntervalForms INT NULL,
		NumIntervalScoreTypeForms INT NULL,
		FirstFormDate DATETIME NULL,
		LastFormDate DATETIME NULL,
		TotalForms INT NULL,
		PercentForIntervalScoreType DECIMAL(5,2) NULL
	)
	
	--Get all the ASQSEs
	INSERT INTO @tblCohort
	(
	    ASQSEPK,
	    FormDate,
	    HasDemographicInfoSheet,
	    HasPhysicianInfoLetter,
	    TotalScore,
	    ChildFK,
	    IntervalCodeFK,
	    ProgramFK,
	    Version
	)
	SELECT a.ASQSEPK, a.FormDate, a.HasDemographicInfoSheet, a.HasPhysicianInfoLetter, a.TotalScore, 
		a.ChildFK, a.IntervalCodeFK, a.ProgramFK, a.Version 
	FROM dbo.ASQSE a
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON a.ProgramFK = programList.ListItem
	WHERE a.FormDate BETWEEN @StartDate AND @EndDate

	--Get the score types and codes
	INSERT INTO @tblScoreTypes
	(
		ScoreTypeCode,
	    ScoreType
	)
	VALUES
	(1, 'Well Below'), (2, 'Monitor'), (3, 'Above Cutoff')

	--Get the classroom assignments for the children
	INSERT INTO	 @tblClassroomAssignments
	(
	    ChildPK,
	    ClassroomPK,
		RowNum
	)
	SELECT tc.ChildFK, cc.ClassroomFK, ROW_NUMBER() OVER (PARTITION BY tc.ChildFK ORDER BY cc.AssignDate DESC) AS RowNum
	FROM @tblCohort tc
	INNER JOIN dbo.ChildClassroom cc ON cc.ChildFK = tc.ChildFK
	WHERE cc.AssignDate <= @EndDate
	AND (cc.LeaveDate IS NULL OR cc.LeaveDate >= @StartDate);

	--Filter all the children by the current classroom assignment and the classroom fks parameter
	INSERT INTO @tblFilteredCohort
	(
	    ASQSEPK,
	    FormDate,
	    HasDemographicInfoSheet,
	    HasPhysicianInfoLetter,
	    TotalScore,
	    ChildFK,
	    IntervalCodeFK,
	    ProgramFK,
	    Version,
		ScoreTypeCode
	)
	SELECT tc.ASQSEPK, tc.FormDate, tc.HasDemographicInfoSheet, tc.HasPhysicianInfoLetter,
		tc.TotalScore, tc.ChildFK, tc.IntervalCodeFK, tc.ProgramFK, tc.Version, 
		CASE WHEN tc.TotalScore > sa.CutoffScore THEN 3 
			 WHEN tc.TotalScore BETWEEN sa.MonitoringScoreStart AND sa.MonitoringScoreEnd THEN 2 
			 ELSE 1 END
	FROM @tblCohort tc
	INNER JOIN @tblClassroomAssignments tca ON tca.ChildPK = tc.ChildFK AND tca.RowNum = 1
	INNER JOIN dbo.ScoreASQSE sa ON tc.IntervalCodeFK = sa.IntervalCodeFK
	LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON tca.ClassroomPK = classroomList.ListItem
	WHERE (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria

	--Get the first form date, last form date, and count of forms
	INSERT INTO @tblFormDatesAndCount
	(
	    FirstFormDate,
	    LastFormDate,
	    NumForms
	)
	SELECT MIN(tfc.FormDate) AS FirstFormDate, MAX(tfc.FormDate) AS LastFormDate, COUNT(DISTINCT tfc.ASQSEPK) AS NumForms 
	FROM @tblFilteredCohort tfc

	--Get the number of ASQSEs for each interval
	INSERT INTO @tblIntervalFormCounts
	(
	    IntervalMonth,
		IntervalDescription,
	    NumIntervalForms
	)
	SELECT cai.IntervalMonth,
		cai.Description,
		COUNT(DISTINCT tfc.ASQSEPK) NumIntervalForms
	FROM dbo.CodeASQSEInterval cai
	LEFT JOIN @tblFilteredCohort tfc ON tfc.IntervalCodeFK = cai.CodeASQSEIntervalPK
	GROUP BY cai.IntervalMonth, cai.Description

	--Get the number of ASQSEs for each score type in each interval
	INSERT INTO @tblIntervalScoreTypeFormCounts
	(
	    IntervalMonth,
		IntervalDescription,
	    ScoreType,
	    NumIntervalScoreTypeForms
	)
	SELECT cai.IntervalMonth,
		cai.Description,
		tst.ScoreType,
		COUNT(DISTINCT tfc.ASQSEPK) NumIntervalScoreTypeForms
	FROM dbo.CodeASQSEInterval cai
	INNER JOIN @tblScoreTypes tst ON tst.ScoreType = tst.ScoreType
	LEFT JOIN @tblFilteredCohort tfc ON tfc.IntervalCodeFK = cai.CodeASQSEIntervalPK AND tfc.ScoreTypeCode = tst.ScoreTypeCode
	GROUP BY cai.IntervalMonth, cai.Description, tst.ScoreType

	--Prep for final select
	INSERT INTO @tblFinalSelect
	(
	    IntervalMonth,
		IntervalDescription,
	    ScoreType,
		NumIntervalForms,
		NumIntervalScoreTypeForms
	)
	SELECT tifc.IntervalMonth, tifc.IntervalDescription, tistfc.ScoreType, 
		tifc.NumIntervalForms, tistfc.NumIntervalScoreTypeForms
	FROM @tblIntervalFormCounts tifc
	INNER JOIN @tblIntervalScoreTypeFormCounts tistfc ON tistfc.IntervalMonth = tifc.IntervalMonth

	--Update the final select table with the form dates and count of forms
	UPDATE @tblFinalSelect SET FirstFormDate = tfdac.FirstFormDate, 
							   LastFormDate = tfdac.LastFormDate, 
							   TotalForms = tfdac.NumForms
	FROM @tblFormDatesAndCount tfdac
	WHERE IntervalMonth IS NOT NULL

	--Update the final select table with the percentage
	UPDATE @tblFinalSelect SET PercentForIntervalScoreType = CONVERT(DECIMAL(5, 2), NumIntervalScoreTypeForms) / NULLIF(NumIntervalForms, 0)
	WHERE IntervalMonth IS NOT NULL
	
	--Final select
	SELECT tfs.IntervalMonth,
		   tfs.IntervalDescription,
           tfs.ScoreType,
           tfs.NumIntervalForms,
           tfs.NumIntervalScoreTypeForms,
           tfs.FirstFormDate,
           tfs.LastFormDate,
           ISNULL(tfs.TotalForms, 0) AS TotalForms,
           ISNULL(tfs.PercentForIntervalScoreType, 0.00) AS PercentForIntervalScoreType
		   FROM @tblFinalSelect tfs
		   ORDER BY tfs.IntervalMonth ASC, tfs.ScoreType ASC

END
GO

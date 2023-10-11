SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/08/2021
-- Description:	This stored procedure returns the necessary information for the
-- form printing report
-- =============================================
CREATE PROC [dbo].[rspBOQCWLT] 
	@BenchmarkOfQualityCWLTPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DECLARE @tblCohort TABLE
	(
		BenchmarkOfQualityCWLTPK INT,
		FormDate DATETIME,
		Indicator1 VARCHAR(100),
		Indicator2 VARCHAR(100),
		Indicator3 VARCHAR(100),
		Indicator4 VARCHAR(100),
		Indicator5 VARCHAR(100),
		Indicator6 VARCHAR(100),
		Indicator7 VARCHAR(100),
		Indicator8 VARCHAR(100),
		Indicator9 VARCHAR(100),
		Indicator10 VARCHAR(100),
		Indicator11 VARCHAR(100),
		Indicator12 VARCHAR(100),
		Indicator13 VARCHAR(100),
		Indicator14 VARCHAR(100),
		Indicator15 VARCHAR(100),
		Indicator16 VARCHAR(100),
		Indicator17 VARCHAR(100),
		Indicator18 VARCHAR(100),
		Indicator19 VARCHAR(100),
		Indicator20 VARCHAR(100),
		Indicator21 VARCHAR(100),
		Indicator22 VARCHAR(100),
		Indicator23 VARCHAR(100),
		Indicator24 VARCHAR(100),
		Indicator25 VARCHAR(100),
		Indicator26 VARCHAR(100),
		Indicator27 VARCHAR(100),
		Indicator28 VARCHAR(100),
		Indicator29 VARCHAR(100),
		Indicator30 VARCHAR(100),
		Indicator31 VARCHAR(100),
		Indicator32 VARCHAR(100),
		Indicator33 VARCHAR(100),
		Indicator34 VARCHAR(100),
		Indicator35 VARCHAR(100),
		Indicator36 VARCHAR(100),
		Indicator37 VARCHAR(100),
		Indicator38 VARCHAR(100),
		Indicator39 VARCHAR(100),
		HubName VARCHAR(400)
	)

	DECLARE @tblTeamMembers TABLE (
		BenchmarksOfQualityCWLTFK INT,
		TeamMemberNames VARCHAR(MAX)
	)
	
    --Get the BOQ information
	INSERT INTO @tblCohort
	(
	    BenchmarkOfQualityCWLTPK,
	    FormDate,
	    Indicator1,
	    Indicator2,
	    Indicator3,
	    Indicator4,
	    Indicator5,
	    Indicator6,
	    Indicator7,
	    Indicator8,
	    Indicator9,
	    Indicator10,
	    Indicator11,
	    Indicator12,
	    Indicator13,
	    Indicator14,
	    Indicator15,
	    Indicator16,
	    Indicator17,
	    Indicator18,
	    Indicator19,
	    Indicator20,
	    Indicator21,
	    Indicator22,
	    Indicator23,
	    Indicator24,
	    Indicator25,
	    Indicator26,
	    Indicator27,
	    Indicator28,
	    Indicator29,
	    Indicator30,
	    Indicator31,
	    Indicator32,
	    Indicator33,
	    Indicator34,
	    Indicator35,
	    Indicator36,
	    Indicator37,
	    Indicator38,
	    Indicator39,
	    HubName
	)
    SELECT boqs.BenchmarkOfQualityCWLTPK,
           boqs.FormDate,
           CASE WHEN boqs.Indicator1 = 0 THEN 'Not In Place' WHEN boqs.Indicator1 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator1 = 2 THEN 'In Place' ELSE 'Error!' END Indicator1,
           CASE WHEN boqs.Indicator2 = 0 THEN 'Not In Place' WHEN boqs.Indicator2 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator2 = 2 THEN 'In Place' ELSE 'Error!' END Indicator2,
           CASE WHEN boqs.Indicator3 = 0 THEN 'Not In Place' WHEN boqs.Indicator3 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator3 = 2 THEN 'In Place' ELSE 'Error!' END Indicator3,
           CASE WHEN boqs.Indicator4 = 0 THEN 'Not In Place' WHEN boqs.Indicator4 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator4 = 2 THEN 'In Place' ELSE 'Error!' END Indicator4,
           CASE WHEN boqs.Indicator5 = 0 THEN 'Not In Place' WHEN boqs.Indicator5 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator5 = 2 THEN 'In Place' ELSE 'Error!' END Indicator5,
           CASE WHEN boqs.Indicator6 = 0 THEN 'Not In Place' WHEN boqs.Indicator6 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator6 = 2 THEN 'In Place' ELSE 'Error!' END Indicator6,
           CASE WHEN boqs.Indicator7 = 0 THEN 'Not In Place' WHEN boqs.Indicator7 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator7 = 2 THEN 'In Place' ELSE 'Error!' END Indicator7,
           CASE WHEN boqs.Indicator8 = 0 THEN 'Not In Place' WHEN boqs.Indicator8 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator8 = 2 THEN 'In Place' ELSE 'Error!' END Indicator8,
           CASE WHEN boqs.Indicator9 = 0 THEN 'Not In Place' WHEN boqs.Indicator9 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator9 = 2 THEN 'In Place' ELSE 'Error!' END Indicator9,
           CASE WHEN boqs.Indicator10 = 0 THEN 'Not In Place' WHEN boqs.Indicator10 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator10 = 2 THEN 'In Place' ELSE 'Error!' END Indicator10,
           CASE WHEN boqs.Indicator11 = 0 THEN 'Not In Place' WHEN boqs.Indicator11 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator11 = 2 THEN 'In Place' ELSE 'Error!' END Indicator11,
           CASE WHEN boqs.Indicator12 = 0 THEN 'Not In Place' WHEN boqs.Indicator12 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator12 = 2 THEN 'In Place' ELSE 'Error!' END Indicator12,
           CASE WHEN boqs.Indicator13 = 0 THEN 'Not In Place' WHEN boqs.Indicator13 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator13 = 2 THEN 'In Place' ELSE 'Error!' END Indicator13,
           CASE WHEN boqs.Indicator14 = 0 THEN 'Not In Place' WHEN boqs.Indicator14 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator14 = 2 THEN 'In Place' ELSE 'Error!' END Indicator14,
           CASE WHEN boqs.Indicator15 = 0 THEN 'Not In Place' WHEN boqs.Indicator15 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator15 = 2 THEN 'In Place' ELSE 'Error!' END Indicator15,
           CASE WHEN boqs.Indicator16 = 0 THEN 'Not In Place' WHEN boqs.Indicator16 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator16 = 2 THEN 'In Place' ELSE 'Error!' END Indicator16,
           CASE WHEN boqs.Indicator17 = 0 THEN 'Not In Place' WHEN boqs.Indicator17 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator17 = 2 THEN 'In Place' WHEN boqs.Indicator17 = 99 THEN 'NA' ELSE 'Error!' END Indicator17,
           CASE WHEN boqs.Indicator18 = 0 THEN 'Not In Place' WHEN boqs.Indicator18 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator18 = 2 THEN 'In Place' WHEN boqs.Indicator18 = 99 THEN 'NA' ELSE 'Error!' END Indicator18,
           CASE WHEN boqs.Indicator19 = 0 THEN 'Not In Place' WHEN boqs.Indicator19 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator19 = 2 THEN 'In Place' WHEN boqs.Indicator19 = 99 THEN 'NA' ELSE 'Error!' END Indicator19,
           CASE WHEN boqs.Indicator20 = 0 THEN 'Not In Place' WHEN boqs.Indicator20 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator20 = 2 THEN 'In Place' WHEN boqs.Indicator20 = 99 THEN 'NA' ELSE 'Error!' END Indicator20,
           CASE WHEN boqs.Indicator21 = 0 THEN 'Not In Place' WHEN boqs.Indicator21 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator21 = 2 THEN 'In Place' ELSE 'Error!' END Indicator21,
           CASE WHEN boqs.Indicator22 = 0 THEN 'Not In Place' WHEN boqs.Indicator22 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator22 = 2 THEN 'In Place' ELSE 'Error!' END Indicator22,
           CASE WHEN boqs.Indicator23 = 0 THEN 'Not In Place' WHEN boqs.Indicator23 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator23 = 2 THEN 'In Place' ELSE 'Error!' END Indicator23,
           CASE WHEN boqs.Indicator24 = 0 THEN 'Not In Place' WHEN boqs.Indicator24 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator24 = 2 THEN 'In Place' ELSE 'Error!' END Indicator24,
           CASE WHEN boqs.Indicator25 = 0 THEN 'Not In Place' WHEN boqs.Indicator25 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator25 = 2 THEN 'In Place' ELSE 'Error!' END Indicator25,
           CASE WHEN boqs.Indicator26 = 0 THEN 'Not In Place' WHEN boqs.Indicator26 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator26 = 2 THEN 'In Place' ELSE 'Error!' END Indicator26,
           CASE WHEN boqs.Indicator27 = 0 THEN 'Not In Place' WHEN boqs.Indicator27 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator27 = 2 THEN 'In Place' ELSE 'Error!' END Indicator27,
           CASE WHEN boqs.Indicator28 = 0 THEN 'Not In Place' WHEN boqs.Indicator28 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator28 = 2 THEN 'In Place' ELSE 'Error!' END Indicator28,
           CASE WHEN boqs.Indicator29 = 0 THEN 'Not In Place' WHEN boqs.Indicator29 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator29 = 2 THEN 'In Place' ELSE 'Error!' END Indicator29,
           CASE WHEN boqs.Indicator30 = 0 THEN 'Not In Place' WHEN boqs.Indicator30 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator30 = 2 THEN 'In Place' ELSE 'Error!' END Indicator30,
           CASE WHEN boqs.Indicator31 = 0 THEN 'Not In Place' WHEN boqs.Indicator31 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator31 = 2 THEN 'In Place' ELSE 'Error!' END Indicator31,
           CASE WHEN boqs.Indicator32 = 0 THEN 'Not In Place' WHEN boqs.Indicator32 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator32 = 2 THEN 'In Place' ELSE 'Error!' END Indicator32,
           CASE WHEN boqs.Indicator33 = 0 THEN 'Not In Place' WHEN boqs.Indicator33 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator33 = 2 THEN 'In Place' ELSE 'Error!' END Indicator33,
           CASE WHEN boqs.Indicator34 = 0 THEN 'Not In Place' WHEN boqs.Indicator34 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator34 = 2 THEN 'In Place' ELSE 'Error!' END Indicator34,
           CASE WHEN boqs.Indicator35 = 0 THEN 'Not In Place' WHEN boqs.Indicator35 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator35 = 2 THEN 'In Place' ELSE 'Error!' END Indicator35,
           CASE WHEN boqs.Indicator36 = 0 THEN 'Not In Place' WHEN boqs.Indicator36 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator36 = 2 THEN 'In Place' ELSE 'Error!' END Indicator36,
           CASE WHEN boqs.Indicator37 = 0 THEN 'Not In Place' WHEN boqs.Indicator37 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator37 = 2 THEN 'In Place' ELSE 'Error!' END Indicator37,
           CASE WHEN boqs.Indicator38 = 0 THEN 'Not In Place' WHEN boqs.Indicator38 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator38 = 2 THEN 'In Place' ELSE 'Error!' END Indicator38,
           CASE WHEN boqs.Indicator39 = 0 THEN 'Not In Place' WHEN boqs.Indicator39 = 1 THEN 'Needs Improvement' WHEN boqs.Indicator39 = 2 THEN 'In Place' ELSE 'Error!' END Indicator39,
		   s.[Name] HubName
    FROM dbo.BenchmarkOfQualityCWLT boqs
    INNER JOIN dbo.Hub s ON s.HubPK = boqs.HubFK
    WHERE boqs.BenchmarkOfQualityCWLTPK = @BenchmarkOfQualityCWLTPK

	INSERT INTO @tblTeamMembers
	(
	    BenchmarksOfQualityCWLTFK,
	    TeamMemberNames
	)
	SELECT bp.BenchmarksOfQualityCWLTFK, STRING_AGG(CONCAT('(', sm.IDNumber, ') ', sm.FirstName, ' ', sm.LastName), ', ') TeamMemberNames
	FROM dbo.BOQCWLTParticipant bp
	INNER JOIN dbo.CWLTMember sm ON sm.CWLTMemberPK = bp.CWLTMemberFK
	WHERE bp.BenchmarksOfQualityCWLTFK = @BenchmarkOfQualityCWLTPK
	GROUP BY bp.BenchmarksOfQualityCWLTFK

	SELECT tc.BenchmarkOfQualityCWLTPK,
           tc.FormDate,
           tc.Indicator1,
           tc.Indicator2,
           tc.Indicator3,
           tc.Indicator4,
           tc.Indicator5,
           tc.Indicator6,
           tc.Indicator7,
           tc.Indicator8,
           tc.Indicator9,
           tc.Indicator10,
           tc.Indicator11,
           tc.Indicator12,
           tc.Indicator13,
           tc.Indicator14,
           tc.Indicator15,
           tc.Indicator16,
           tc.Indicator17,
           tc.Indicator18,
           tc.Indicator19,
           tc.Indicator20,
           tc.Indicator21,
           tc.Indicator22,
           tc.Indicator23,
           tc.Indicator24,
           tc.Indicator25,
           tc.Indicator26,
           tc.Indicator27,
           tc.Indicator28,
           tc.Indicator29,
           tc.Indicator30,
           tc.Indicator31,
           tc.Indicator32,
           tc.Indicator33,
           tc.Indicator34,
           tc.Indicator35,
           tc.Indicator36,
           tc.Indicator37,
           tc.Indicator38,
           tc.Indicator39,
           tc.HubName,
           ttm.TeamMemberNames
	FROM @tblCohort tc
	LEFT JOIN @tblTeamMembers ttm ON ttm.BenchmarksOfQualityCWLTFK = tc.BenchmarkOfQualityCWLTPK

END;
GO

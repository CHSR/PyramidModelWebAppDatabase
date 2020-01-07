SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/21/2019
-- Description:	This stored procedure returns the necessary information for the
-- BIR Excel file created by Myra Veguilla (veguilla@usf.edu) for the Pyramid Model
-- =============================================
CREATE PROC [dbo].[rspBIRExcel_ChildrenAndBIRs]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@SchoolYear DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Calculate the school start date and end date
	DECLARE @schoolStartDate DATETIME = DATEADD(MONTH, 7, @SchoolYear);
	DECLARE @schoolEndDate DATETIME = DATEADD(DAY, -1, DATEADD(YEAR, 1, @schoolStartDate));

	DECLARE @tbl1999BehaviorIncidents TABLE (
		BehaviorIncidentPK INT NOT NULL PRIMARY KEY CLUSTERED,
		BehaviorDescription VARCHAR(MAX) NULL, 
		IncidentDatetime DATETIME NOT NULL, 
		Notes VARCHAR(MAX) NULL,
		Activity VARCHAR(250) NOT NULL, 
		AdminFollowUp VARCHAR(250) NOT NULL, 
		OthersInvolved VARCHAR(250) NOT NULL, 
		PossibleMotivation VARCHAR(250) NOT NULL, 
		ProblemBehavior VARCHAR(250) NOT NULL, 
		StrategyResponse VARCHAR(250) NOT NULL, 
		ChildFK INT NOT NULL,
		ClassroomFK INT NOT NULL,
		ClassroomID VARCHAR(100) NOT NULL,
		ProgramFKClassroom INT NOT NULL,
		ProgramNameClassroom VARCHAR(400) NOT NULL,
		INDEX IX_tbl1999BIR_IncidentDatetime (IncidentDatetime),
		INDEX IX_tbl1999BIR_ChildFK (ChildFK),
		INDEX IX_tbl1999BIR_ClassroomFK (ClassroomFK)
	)

	DECLARE @tbl172UniqueChildren TABLE (
		ChildPK INT NOT NULL PRIMARY KEY CLUSTERED
	)
	
	--Get the top 1999 behavior incident reports
	INSERT INTO @tbl1999BehaviorIncidents
	(
	    BehaviorIncidentPK,
	    BehaviorDescription,
	    IncidentDatetime,
	    Notes,
	    Activity,
	    AdminFollowUp,
	    OthersInvolved,
	    PossibleMotivation,
	    ProblemBehavior,
	    StrategyResponse,
	    ChildFK,
	    ClassroomFK,
		ClassroomID,
		ProgramFKClassroom,
		ProgramNameClassroom
	)
	SELECT TOP(1999) bi.BehaviorIncidentPK, bi.BehaviorDescription,
	bi.IncidentDatetime, bi.Notes, ca.Description, cafu.Description, coi.Description,
	cpm.Description, cpb.Description, csr.Description,
	bi.ChildFK,
	bi.ClassroomFK, c.ProgramSpecificID, c.ProgramFK,
	p.ProgramName
	FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = bi.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.CodeActivity ca ON ca.CodeActivityPK = bi.ActivityCodeFK
	INNER JOIN dbo.CodeAdminFollowUp cafu ON cafu.CodeAdminFollowUpPK = bi.AdminFollowUpCodeFK
	INNER JOIN dbo.CodeOthersInvolved coi ON coi.CodeOthersInvolvedPK = bi.OthersInvolvedCodeFK
	INNER JOIN dbo.CodePossibleMotivation cpm ON cpm.CodePossibleMotivationPK = bi.PossibleMotivationCodeFK
	INNER JOIN dbo.CodeProblemBehavior cpb ON cpb.CodeProblemBehaviorPK = bi.ProblemBehaviorCodeFK
	INNER JOIN dbo.CodeStrategyResponse csr ON csr.CodeStrategyResponsePK = bi.StrategyResponseCodeFK
	WHERE bi.IncidentDatetime BETWEEN @schoolStartDate AND @schoolEndDate
	ORDER BY bi.IncidentDatetime ASC

	--Get 172 unique ChildPKs from the BIR table
	INSERT INTO @tbl172UniqueChildren
	(
	    ChildPK
	)
	SELECT DISTINCT TOP(172) ChildFK 
	FROM @tbl1999BehaviorIncidents tbi
	ORDER BY tbi.ChildFK ASC

	--Filter out any BIRs that are not in the unique child table so that the Excel document doesn't overflow
	DELETE tbi 
	FROM @tbl1999BehaviorIncidents tbi 
	LEFT JOIN @tbl172UniqueChildren tuc ON tbi.ChildFK = tuc.ChildPK
	WHERE tuc.ChildPK IS NULL

	--Final select with all necessary information for the file
	SELECT tbi.*, 
	c.FirstName, c.LastName, 
	cp.ProgramSpecificID, cp.EnrollmentDate, cp.DischargeDate, cdr.Description DischargeReason, cp.IsDLL, cp.HasIEP, cp.ProgramFK ProgramFKChild,
	p.ProgramName ProgramNameChild,
	cg.Description Gender,
	ce.Description Ethnicity,
	CASE WHEN cr.Description LIKE '%Hawaiian%' OR cr.Description LIKE '%Pacific Islander%' THEN 'Native Hawaiian or Other Pacific Islander'
			WHEN cr.Description LIKE '%Alaskan%' OR cr.Description LIKE '%American Indian%' THEN 'American Indian or Alaskan Native' 
			ELSE cr.Description END Race
	FROM @tbl1999BehaviorIncidents tbi
	INNER JOIN dbo.Child c ON tbi.ChildFK = c.ChildPK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
	LEFT JOIN dbo.CodeDischargeReason cdr ON cdr.CodeDischargeReasonPK = cp.DischargeCodeFK
	INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
	INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
	INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	ORDER BY tbi.IncidentDatetime ASC

END
GO

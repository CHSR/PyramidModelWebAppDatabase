SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/24/2019
-- Description:	This stored procedure returns the necessary information for the
-- Child Demographic Report
-- =============================================
CREATE PROC [dbo].[rspChildDemographics]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@ClassroomFKs VARCHAR(MAX) = NULL,
	@RaceFKs VARCHAR(MAX) = NULL,
	@EthnicityFKs VARCHAR(MAX) = NULL,
	@GenderFKs VARCHAR(MAX) = NULL,
	@IEP BIT = NULL,
	@DLL BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the child information
	DECLARE @tblAllChildren TABLE (
		ChildProgramPK INT NOT NULL,
		ProgramSpecificID VARCHAR(100) NOT NULL,
		ChildPK INT NOT NULL,
		ChildName VARCHAR(600) NOT NULL,
		BirthDate DATETIME NOT NULL,
		Ethnicity VARCHAR(250) NOT NULL,
		Gender VARCHAR(250) NOT NULL,
		Race VARCHAR(250) NOT NULL,
		EnrollmentDate DATETIME NOT NULL,
		HasIEP BIT NULL,
		IsDLL BIT NULL,
		DischargeDate DATETIME NULL,
		DischargeReason VARCHAR(250) NULL,
		ProgramName VARCHAR(400) NOT NULL
	)

	--To hold the classroom history info
	DECLARE @tblClassroomAssignments TABLE (
		ChildPK INT NOT NULL,
		ClassroomPK INT NULL,
		RowNum INT NULL
	)
	
	--Get all the child demographic information
	INSERT INTO @tblAllChildren
	(
		ChildProgramPK,
	    ProgramSpecificID,
		ChildPK,
	    ChildName,
	    BirthDate,
	    Ethnicity,
	    Gender,
	    Race,
	    EnrollmentDate,
	    HasIEP,
	    IsDLL,
	    DischargeDate,
	    DischargeReason,
	    ProgramName
	)
	SELECT cp.ChildProgramPK, cp.ProgramSpecificID, c.ChildPK, c.FirstName + ' ' + c.LastName AS ChildName, c.BirthDate,
		ce.Description AS Ethnicity, cg.Description AS Gender, cr.Description AS Race,
		cp.EnrollmentDate, cp.HasIEP, cp.IsDLL, cp.DischargeDate, 
		cdr.Description AS DischargeReason,
		p.ProgramName
	FROM dbo.ChildProgram cp
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON cp.ProgramFK = programList.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
	INNER JOIN dbo.Child c ON c.ChildPK = cp.ChildFK
	INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
	INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	LEFT JOIN dbo.CodeDischargeReason cdr ON cdr.CodeDischargeReasonPK = cp.DischargeCodeFK
	LEFT JOIN dbo.SplitStringToInt(@RaceFKs, ',') raceList ON c.RaceCodeFK = raceList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@EthnicityFKs, ',') ethnicityList ON c.EthnicityCodeFK = ethnicityList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@GenderFKs, ',') genderList ON c.GenderCodeFK = genderList.ListItem
	WHERE cp.EnrollmentDate <= @EndDate
		AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate)
		AND (@IEP IS NULL OR cp.HasIEP = @IEP)
		AND (@DLL IS NULL OR cp.IsDLL = @DLL)
		AND (@RaceFKs IS NULL OR @RaceFKs = '' OR raceList.ListItem IS NOT NULL) --Optional Race criteria
		AND (@EthnicityFKs IS NULL OR @EthnicityFKs = '' OR ethnicityList.ListItem IS NOT NULL) --Optional ethnicity criteria
		AND (@GenderFKs IS NULL OR @GenderFKs = '' OR genderList.ListItem IS NOT NULL); --Optional gender criteria

	--Get the classroom assignments for the children
	INSERT INTO	 @tblClassroomAssignments
	(
	    ChildPK,
	    ClassroomPK,
		RowNum
	)
	SELECT tac.ChildPK, cc.ClassroomFK, ROW_NUMBER() OVER (PARTITION BY tac.ChildPK ORDER BY cc.AssignDate DESC) AS RowNum
	FROM @tblAllChildren tac
	INNER JOIN dbo.ChildClassroom cc ON cc.ChildFK = tac.ChildPK
	WHERE cc.AssignDate <= @EndDate
	AND (cc.LeaveDate IS NULL OR cc.LeaveDate >= @StartDate);

	--Filter all the children by the current classroom assignment and the classroom fks parameter
	SELECT tac.ChildProgramPK,
           tac.ProgramSpecificID,
           tac.ChildPK,
           tac.ChildName,
           tac.BirthDate,
           tac.Ethnicity,
           tac.Gender,
           tac.Race,
           tac.EnrollmentDate,
           CASE WHEN tac.HasIEP = 1 THEN 'Has IEP' WHEN tac.HasIEP = 0 THEN 'No IEP' ELSE 'No IEP' END AS IEPStatus,
           CASE WHEN tac.IsDLL = 1 THEN 'Is DLL' WHEN tac.IsDLL = 0 THEN 'Not DLL' ELSE 'Not DLL' END AS DLLStatus,
           tac.DischargeDate,
           tac.DischargeReason,
           tac.ProgramName
	FROM @tblAllChildren tac 
	INNER JOIN @tblClassroomAssignments tca ON tca.ChildPK = tac.ChildPK AND tca.RowNum = 1
	LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON tca.ClassroomPK = classroomList.ListItem
	WHERE (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL) --Optional classroom criteria
	ORDER BY tac.ProgramSpecificID ASC;

END
GO

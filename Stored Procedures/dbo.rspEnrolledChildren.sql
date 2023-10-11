SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/24/2020
-- Description:	This stored procedure returns the number of enrolled children for the
-- reports
-- =============================================
CREATE PROC [dbo].[rspEnrolledChildren]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
	@ChildFKs VARCHAR(8000) = NULL,
	@ClassroomFKs VARCHAR(8000) = NULL,
	@RaceFKs VARCHAR(8000) = NULL,
	@EthnicityFKs VARCHAR(8000) = NULL,
	@GenderFKs VARCHAR(8000) = NULL,
	@IEP BIT = NULL,
	@DLL BIT = NULL,
	@ProgramFKs VARCHAR(8000) = NULL,
	@HubFKs VARCHAR(8000) = NULL,
	@CohortFKs VARCHAR(8000) = NULL,
	@StateFKs VARCHAR(8000) = NULL
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
		FirstName VARCHAR(256) NOT NULL,
		LastName VARCHAR(256) NOT NULL,
		BirthDate DATETIME NOT NULL,
		EnrollmentDate DATETIME NOT NULL,
		DischargeDate DATETIME NULL,
		HasIEP BIT NOT NULL,
		IEPInt INT NOT NULL,
		IsDLL BIT NOT NULL,
		DLLInt INT NOT NULL,
		RaceCodeFK INT NOT NULL,
		Race VARCHAR(250) NOT NULL,
		EthnicityCodeFK INT NOT NULL,
		Ethnicity VARCHAR(250) NOT NULL,
		GenderCodeFK INT NOT NULL,
		Gender VARCHAR(250) NOT NULL
	)

	--To hold the classroom history info
	DECLARE @tblClassroomAssignments TABLE (
		ChildPK INT NOT NULL,
		ClassroomPK INT NULL,
		RowNum INT NULL
	)

	--Get the enrolled children
	INSERT INTO @tblAllChildren
	(
	    ChildProgramPK,
		ProgramSpecificID,
	    ChildPK,
		FirstName,
		LastName,
	    BirthDate,
	    EnrollmentDate,
	    DischargeDate,
		HasIEP,
		IEPInt,
		IsDLL,
		DLLInt,
		RaceCodeFK,
		Race,
		EthnicityCodeFK,
		Ethnicity,
		GenderCodeFK,
		Gender
	)
    SELECT cp.ChildProgramPK,
		   cp.ProgramSpecificID,
		   child.ChildPK,
		   child.FirstName,
		   child.LastName,
		   child.BirthDate,
		   cp.EnrollmentDate,
		   cp.DischargeDate,
		   cp.HasIEP,
		   CAST(cp.HasIEP AS INT) IEPInt,
		   cp.IsDLL,
		   CAST(cp.IsDLL AS INT) DLLInt,
		   child.RaceCodeFK,
		   cr.Description Race,
		   child.EthnicityCodeFK,
		   ce.Description Ethnicity,
		   child.GenderCodeFK,
		   cg.Description Gender
    FROM dbo.ChildProgram cp
		INNER JOIN dbo.Child child ON child.ChildPK = cp.ChildFK
		INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = child.RaceCodeFK
		INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = child.EthnicityCodeFK
		INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = child.GenderCodeFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = cp.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ChildFKs, ',') childList ON cp.ChildFK = childList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@RaceFKs, ',') raceList ON child.RaceCodeFK = raceList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@EthnicityFKs, ',') ethnicityList ON child.EthnicityCodeFK = ethnicityList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@GenderFKs, ',') genderList ON child.GenderCodeFK = genderList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = cp.ProgramFK
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
		cp.EnrollmentDate <= @EndDate AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate) --Child must be enrolled
		AND (@ChildFKs IS NULL OR @ChildFKs = '' OR childList.ListItem IS NOT NULL) --Optional child criteria
		AND (@IEP IS NULL OR cp.HasIEP = @IEP) --Optional IEP criteria
		AND (@DLL IS NULL OR cp.IsDLL = @DLL) --Optional DLL criteria
		AND (@RaceFKs IS NULL OR @RaceFKs = '' OR raceList.ListItem IS NOT NULL) --Optional Race criteria
		AND (@EthnicityFKs IS NULL OR @EthnicityFKs = '' OR ethnicityList.ListItem IS NOT NULL) --Optional ethnicity criteria
		AND (@GenderFKs IS NULL OR @GenderFKs = '' OR genderList.ListItem IS NOT NULL); --Optional gender criteria

	--Get the classroom assignments for the children (joined on the classroom criteria)
	INSERT INTO	 @tblClassroomAssignments
	(
	    ChildPK,
	    ClassroomPK,
		RowNum
	)
	SELECT tac.ChildPK, cc.ClassroomFK, ROW_NUMBER() OVER (PARTITION BY tac.ChildPK ORDER BY cc.AssignDate DESC) AS RowNum
	FROM @tblAllChildren tac
	INNER JOIN dbo.ChildClassroom cc ON cc.ChildFK = tac.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON cc.ClassroomFK = classroomList.ListItem --Inner join because we only use the assignments for filtering by criteria
	WHERE cc.AssignDate <= @EndDate
	AND (cc.LeaveDate IS NULL OR cc.LeaveDate >= @StartDate);

	--Filter all the children by the optional classroom assignment
	SELECT tac.ChildProgramPK,
           tac.ProgramSpecificID,
           tac.ChildPK,
		   tac.FirstName,
		   tac.LastName,
           tac.BirthDate,
           tac.EnrollmentDate,
           tac.DischargeDate,
           tac.HasIEP,
		   tac.IEPInt,
           tac.IsDLL,
		   tac.DLLInt,
           tac.RaceCodeFK,
		   tac.Race,
           tac.EthnicityCodeFK,
		   tac.Ethnicity,
           tac.GenderCodeFK,
		   tac.Gender
	FROM @tblAllChildren tac 
	LEFT JOIN @tblClassroomAssignments tca ON tca.ChildPK = tac.ChildPK AND tca.RowNum = 1
	WHERE (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR tca.ClassroomPK IS NOT NULL) --Optional classroom criteria
	ORDER BY tac.ProgramSpecificID ASC;

END;
GO

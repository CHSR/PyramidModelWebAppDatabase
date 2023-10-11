SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/04/2020
-- Description:	This stored procedure returns child discharge information
-- =============================================
CREATE PROC [dbo].[rspChildDischargeDetails]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
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

	--To hold the discharged child information
	DECLARE @tblDischargedChildren TABLE (
		ChildProgramPK INT NOT NULL,
		ChildID VARCHAR(100) NOT NULL,
		ChildPK INT NOT NULL,
		ChildName VARCHAR(600) NOT NULL,
		BirthDate DATETIME NOT NULL,
		Ethnicity VARCHAR(250) NOT NULL,
		Gender VARCHAR(250) NOT NULL,
		Race VARCHAR(250) NOT NULL,
		EnrollmentDate DATETIME NOT NULL,
		HasIEP BIT NULL,
		IsDLL BIT NULL,
		DischargeCodeFK INT NULL,
		DischargeDate DATETIME NULL,
		DischargeReasonSpecify VARCHAR(500) NULL,
		DischargeReason VARCHAR(250) NULL,
		ProgramName VARCHAR(400) NOT NULL
	)

	--To hold the classroom assignment history
	DECLARE @tblClassroomAssignments TABLE (
		ChildPK INT NOT NULL,
		ClassroomPK INT NULL,
		ClassroomID VARCHAR(100) NULL,
		ClassroomName VARCHAR(250) NULL,
		RowNum INT NULL
	)
	
	--Get all the discharged children
	INSERT INTO @tblDischargedChildren
	(
		ChildProgramPK,
	    ChildID,
		ChildPK,
	    ChildName,
	    BirthDate,
	    Ethnicity,
	    Gender,
	    Race,
	    EnrollmentDate,
	    HasIEP,
	    IsDLL,
		DischargeCodeFK,
	    DischargeDate,
		DischargeReasonSpecify,
	    DischargeReason,
	    ProgramName
	)
	SELECT cp.ChildProgramPK, cp.ProgramSpecificID, c.ChildPK, c.FirstName + ' ' + c.LastName AS ChildName, c.BirthDate,
		ce.Description AS Ethnicity, cg.Description AS Gender, cr.Description AS Race,
		cp.EnrollmentDate, cp.HasIEP, cp.IsDLL, cp.DischargeCodeFK, cp.DischargeDate, cp.DischargeReasonSpecify,
		cdr.Description AS DischargeReason,
		p.ProgramName
	FROM dbo.ChildProgram cp
		INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
		INNER JOIN dbo.Child c ON c.ChildPK = cp.ChildFK
		INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
		INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
		INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
		LEFT JOIN dbo.CodeDischargeReason cdr ON cdr.CodeDischargeReasonPK = cp.DischargeCodeFK
		LEFT JOIN dbo.SplitStringToInt(@RaceFKs, ',') raceList ON c.RaceCodeFK = raceList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@EthnicityFKs, ',') ethnicityList ON c.EthnicityCodeFK = ethnicityList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@GenderFKs, ',') genderList ON c.GenderCodeFK = genderList.ListItem
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
		cp.DischargeDate IS NOT NULL
		AND cp.DischargeDate BETWEEN @StartDate AND @EndDate
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
		ClassroomID,
		ClassroomName,
		RowNum
	)
	SELECT tdc.ChildPK, cc.ClassroomFK, c.ProgramSpecificID, c.Name, ROW_NUMBER() OVER (PARTITION BY tdc.ChildPK ORDER BY cc.AssignDate DESC) AS RowNum
	FROM @tblDischargedChildren tdc
	INNER JOIN dbo.ChildClassroom cc ON cc.ChildFK = tdc.ChildPK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = cc.ClassroomFK
	WHERE cc.AssignDate <= @EndDate
	AND (cc.LeaveDate IS NULL OR cc.LeaveDate >= @StartDate);

	--Filter all the children by the current classroom assignment and the optional classroom fks parameter
	SELECT tdc.ChildProgramPK,
           tdc.ChildID,
           tdc.ChildPK,
           tdc.ChildName,
           tdc.BirthDate,
           tdc.Ethnicity,
           tdc.Gender,
           tdc.Race,
           tdc.EnrollmentDate,
           CASE WHEN tdc.HasIEP = 1 THEN 'Has IEP' WHEN tdc.HasIEP = 0 THEN 'No IEP' ELSE 'No IEP' END AS IEPStatus,
           CASE WHEN tdc.IsDLL = 1 THEN 'Is DLL' WHEN tdc.IsDLL = 0 THEN 'Not DLL' ELSE 'Not DLL' END AS DLLStatus,
		   tdc.DischargeCodeFK,
           tdc.DischargeDate,
		   tdc.DischargeReasonSpecify,
           tdc.DischargeReason,
		   tca.ClassroomID,
		   tca.ClassroomName,
           tdc.ProgramName
	FROM @tblDischargedChildren tdc 
	LEFT JOIN @tblClassroomAssignments tca ON tca.ChildPK = tdc.ChildPK AND tca.RowNum = 1 --We only want the most recent classroom assignment (if it exists)
	LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON tca.ClassroomPK = classroomList.ListItem --Left join on the classroom criteria
	WHERE (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL) --Optional classroom criteria
	ORDER BY tca.ClassroomID ASC, tdc.ChildID ASC;

END
GO

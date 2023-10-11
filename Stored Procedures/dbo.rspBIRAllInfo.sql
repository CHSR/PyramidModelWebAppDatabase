SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/06/2020
-- Description:	This stored procedure returns the necessary information for several
-- of the BIR reports
-- =============================================
CREATE PROC [dbo].[rspBIRAllInfo]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
	@ChildFKs VARCHAR(8000) = NULL,
	@ClassroomFKs VARCHAR(8000) = NULL,
	@RaceFKs VARCHAR(8000) = NULL,
	@EthnicityFKs VARCHAR(8000) = NULL,
	@GenderFKs VARCHAR(8000) = NULL,
	@ProblemBehaviorFKs VARCHAR(8000) = NULL,
	@ActivityFKs VARCHAR(8000) = NULL,
	@OthersInvolvedFKs VARCHAR(8000) = NULL,
	@PossibleMotivationFKs VARCHAR(8000) = NULL,
	@StrategyResponseFKs VARCHAR(8000) = NULL,
	@AdminFollowUpFKs VARCHAR(8000) = NULL,
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

    DECLARE @tblCohort TABLE
    (
        BehaviorIncidentPK INT NOT NULL,
        IncidentDatetime DATETIME NOT NULL,
        ActivityCodeFK INT NOT NULL,
        AdminFollowUpCodeFK INT NOT NULL,
        OthersInvolvedCodeFK INT NOT NULL,
        PossibleMotivationCodeFK INT NOT NULL,
        ProblemBehaviorCodeFK INT NOT NULL,
        StrategyResponseCodeFK INT NOT NULL,
        ChildFK INT NOT NULL,
        ClassroomFK INT NOT NULL,
        FirstName VARCHAR(256) NOT NULL,
        LastName VARCHAR(256) NOT NULL,
        BirthDate DATETIME NOT NULL,
        ChildID VARCHAR(100) NOT NULL,
        EnrollmentDate DATETIME NOT NULL,
        DischargeDate DATETIME NULL,
		RaceCodeFK INT NOT NULL,
		EthnicityCodeFK INT NOT NULL,
		GenderCodeFK INT NOT NULL,
        HasIEP BIT NOT NULL,
		IEPInt INT NOT NULL,
        IsDLL BIT NOT NULL,
		DLLInt INT NOT NULL,
        ClassroomName VARCHAR(250) NOT NULL,
        IsInfantToddler BIT NOT NULL,
        IsPreschool BIT NOT NULL,
        ClassroomID VARCHAR(100) NOT NULL
    );

	INSERT INTO @tblCohort
	(
	    BehaviorIncidentPK,
	    IncidentDatetime,
	    ActivityCodeFK,
	    AdminFollowUpCodeFK,
	    OthersInvolvedCodeFK,
	    PossibleMotivationCodeFK,
	    ProblemBehaviorCodeFK,
	    StrategyResponseCodeFK,
	    ChildFK,
	    ClassroomFK,
	    FirstName,
	    LastName,
	    BirthDate,
	    ChildID,
	    EnrollmentDate,
	    DischargeDate,
		RaceCodeFK,
		EthnicityCodeFK,
		GenderCodeFK,
	    HasIEP,
		IEPInt,
	    IsDLL,
		DLLInt,
	    ClassroomName,
	    IsInfantToddler,
	    IsPreschool,
	    ClassroomID
	)
    SELECT bi.BehaviorIncidentPK,
           bi.IncidentDatetime,
           bi.ActivityCodeFK,
           bi.AdminFollowUpCodeFK,
           bi.OthersInvolvedCodeFK,
           bi.PossibleMotivationCodeFK,
           bi.ProblemBehaviorCodeFK,
           bi.StrategyResponseCodeFK,
           bi.ChildFK,
           bi.ClassroomFK,
           child.FirstName,
           child.LastName,
           child.BirthDate,
           cp.ProgramSpecificID ChildID,
           cp.EnrollmentDate,
           cp.DischargeDate,
		   child.RaceCodeFK,
		   child.EthnicityCodeFK,
		   child.GenderCodeFK,
           cp.HasIEP,
		   CAST(cp.HasIEP AS INT) IEPInt,
           cp.IsDLL,
		   CAST(cp.IsDLL AS INT) DLLInt,
           classroom.Name ClassroomName,
           classroom.IsInfantToddler,
           classroom.IsPreschool,
           classroom.ProgramSpecificID ClassroomID
    FROM dbo.BehaviorIncident bi
        INNER JOIN dbo.Child child ON child.ChildPK = bi.ChildFK
        INNER JOIN dbo.Classroom classroom ON classroom.ClassroomPK = bi.ClassroomFK
        INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = child.ChildPK
		INNER JOIN dbo.Program p ON p.ProgramPK = classroom.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@ChildFKs, ',') childList ON cp.ChildFK = childList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ClassroomFKs, ',') classroomList ON classroom.ClassroomPK = classroomList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@RaceFKs, ',') raceList ON child.RaceCodeFK = raceList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@EthnicityFKs, ',') ethnicityList ON child.EthnicityCodeFK = ethnicityList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@GenderFKs, ',') genderList ON child.GenderCodeFK = genderList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProblemBehaviorFKs, ',') problemBehaviorList ON bi.ProblemBehaviorCodeFK = problemBehaviorList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ActivityFKs, ',') activityList ON bi.ActivityCodeFK = activityList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@OthersInvolvedFKs, ',') othersInvolvedList ON bi.OthersInvolvedCodeFK = othersInvolvedList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@PossibleMotivationFKs, ',') possibleMotivationList ON bi.PossibleMotivationCodeFK = possibleMotivationList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@StrategyResponseFKs, ',') strategyResponseList ON bi.StrategyResponseCodeFK = strategyResponseList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@AdminFollowUpFKs, ',') adminFollowUpList ON bi.AdminFollowUpCodeFK = adminFollowUpList.ListItem
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = classroom.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized 
		AND bi.IncidentDatetime BETWEEN @StartDate AND @EndDate
		AND (@ChildFKs IS NULL OR @ChildFKs = '' OR childList.ListItem IS NOT NULL) --Optional child criteria
		AND (@ClassroomFKs IS NULL OR @ClassroomFKs = '' OR classroomList.ListItem IS NOT NULL) --Optional classroom criteria
		AND (@IEP IS NULL OR cp.HasIEP = @IEP) --Optional IEP criteria
		AND (@DLL IS NULL OR cp.IsDLL = @DLL) --Optional DLL criteria
		AND (@RaceFKs IS NULL OR @RaceFKs = '' OR raceList.ListItem IS NOT NULL) --Optional Race criteria
		AND (@EthnicityFKs IS NULL OR @EthnicityFKs = '' OR ethnicityList.ListItem IS NOT NULL) --Optional ethnicity criteria
		AND (@GenderFKs IS NULL OR @GenderFKs = '' OR genderList.ListItem IS NOT NULL) --Optional gender criteria
		AND (@ProblemBehaviorFKs IS NULL OR @ProblemBehaviorFKs = '' OR problemBehaviorList.ListItem IS NOT NULL) --Optional problem behavior criteria
		AND (@ActivityFKs IS NULL OR @ActivityFKs = '' OR activityList.ListItem IS NOT NULL) --Optional activity criteria
		AND (@OthersInvolvedFKs IS NULL OR @OthersInvolvedFKs = '' OR othersInvolvedList.ListItem IS NOT NULL) --Optional others involved criteria
		AND (@PossibleMotivationFKs IS NULL OR @PossibleMotivationFKs = '' OR possibleMotivationList.ListItem IS NOT NULL) --Optional possible motivation criteria
		AND (@StrategyResponseFKs IS NULL OR @StrategyResponseFKs = '' OR strategyResponseList.ListItem IS NOT NULL) --Optional strategy response criteria
		AND (@AdminFollowUpFKs IS NULL OR @AdminFollowUpFKs = '' OR adminFollowUpList.ListItem IS NOT NULL); --Optional gender criteria

	--Get the BIR info
	SELECT * 
	FROM @tblCohort tc

END;
GO

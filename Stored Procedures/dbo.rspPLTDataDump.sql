SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 03/02/2023
-- Description:	This stored procedure returns the necessary information for the
-- Program Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspPLTDataDump]
	@StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
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
		PLTMemberPK INT,
        Creator VARCHAR(256),
        CreateDate DATETIME,
        Editor VARCHAR(256),
        EditDate DATETIME,
        EmailAddress VARCHAR(256),
        FirstName VARCHAR(256),
        IDNumber VARCHAR(256),
        LastName VARCHAR(256),
        LeaveDate DATETIME,
        PhoneNumber VARCHAR(256),
        StartDate DATETIME,
        ProgramFK INT,
		ProgramName VARCHAR(256),
		StatePK INT,
		StateName VARCHAR(256)
	
	)

	DECLARE @tblPLTMembers TABLE
	(
	PLTMemberFK int,
	PLTMemberRoles VARCHAR(max)
	)

	INSERT INTO @tblCohort
	(
	    PLTMemberPK,
	    Creator,
	    CreateDate,
	    Editor,
	    EditDate,
	    EmailAddress,
	    FirstName,
	    IDNumber,
	    LastName,
	    LeaveDate,
	    PhoneNumber,
	    StartDate,
	    ProgramFK,
	    ProgramName,
		StateName,
		StatePK
	)
	--Get all the necessary information
    SELECT pm.PLTMemberPK,
           pm.Creator,
           pm.CreateDate,
           pm.Editor,
           pm.EditDate,
           pm.EmailAddress,
           pm.FirstName,
           pm.IDNumber,
           pm.LastName,
           pm.LeaveDate,
           pm.PhoneNumber,
           pm.StartDate,
           pm.ProgramFK,
		   p.ProgramName,
		   s.[Name] StateName,
		   s.StatePK
	FROM dbo.PLTMember pm
		INNER JOIN dbo.Program p 
			ON p.ProgramPK = pm.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = pm.ProgramFK
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
		AND pm.StartDate <= @EndDate
		AND (pm.LeaveDate IS NULL OR pm.LeaveDate >= @StartDate);

		INSERT INTO @tblPLTMembers
		(
		    PLTMemberFK,
		    PLTMemberRoles
		)
		SELECT pmr.PLTMemberFK, STRING_AGG(ctp.Description, ', ')
		FROM dbo.PLTMemberRole pmr
		INNER JOIN dbo.CodeTeamPosition ctp
			ON ctp.CodeTeamPositionPK=pmr.TeamPositionCodeFK
		inner JOIN @tblCohort tc
			ON pmr.PLTMemberFK = tc.PLTMemberPK
		GROUP BY pmr.PLTMemberFK

	SELECT 
		tc.PLTMemberPK,
	    tc.Creator,
	    tc.CreateDate,
	    tc.Editor,
	    tc.EditDate,
	    tc.EmailAddress,
	    tc.FirstName,
	    tc.IDNumber,
	    tc.LastName,
	    tc.LeaveDate,
	    tc.PhoneNumber,
	    tc.StartDate,
	    tc.ProgramFK,
	    tc.ProgramName,
		tc.StateName,
		tc.StatePK,
		tpm.PLTMemberRoles
		

	FROM @tblCohort tc
	LEFT JOIN @tblPLTMembers tpm
		ON tpm.PLTMemberFK = tc.PLTMemberPK

END;
GO

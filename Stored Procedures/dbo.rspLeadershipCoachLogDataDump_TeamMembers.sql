SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 04/17/2023
-- Description:	This stored procedure returns the necessary information for the Team Members section of the 
-- Leadership Coach Log Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachLogDataDump_TeamMembers]
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
        LeadershipCoachLogPK INT,
        LCLTeamMemberEngagementPK INT,
        PLTMemberPK INT,
        IDNumber VARCHAR(300),
        FirstName VARCHAR(300),
        LastName VARCHAR(300),
        Email VARCHAR(300),
        Creator VARCHAR(256),
        CreateDate DATETIME,
        ProgramFK INT,
        ProgramName VARCHAR(400),
        StateFK INT,
        StateName VARCHAR(400)
    );

    DECLARE @tblDistinctPLTMembersIncluded TABLE
    (
        PLTMemberFK INT NOT NULL
    );

    DECLARE @tblRoles TABLE
    (
        PLTMemberFK INT,
        Roles VARCHAR(8000)
    );

    --Retrieve necessary information
    INSERT INTO @tblCohort
    (
        LeadershipCoachLogPK,
        LCLTeamMemberEngagementPK,
        PLTMemberPK,
        IDNumber,
        FirstName,
        LastName,
        Email,
        Creator,
        CreateDate,
        ProgramFK,
        ProgramName,
        StateFK,
        StateName
    )
    SELECT lcl.LeadershipCoachLogPK,
           ltme.LCLTeamMemberEngagementPK,
		   pm.PLTMemberPK,
		   pm.IDNumber,
           pm.FirstName,
           pm.LastName,
           pm.EmailAddress,
		   ltme.Creator,
		   ltme.CreateDate,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name]
    FROM dbo.LeadershipCoachLog lcl
        INNER JOIN dbo.Program p
            ON p.ProgramPK = lcl.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
        INNER JOIN dbo.LCLTeamMemberEngagement ltme
            ON ltme.LeadershipCoachLogFK = lcl.LeadershipCoachLogPK
        INNER JOIN dbo.PLTMember pm
            ON pm.PLTMemberPK = ltme.PLTMemberFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = lcl.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = p.HubFK
        LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList
            ON cohortList.ListItem = p.CohortFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR hubList.ListItem IS NOT NULL
              OR cohortList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
          AND lcl.DateCompleted BETWEEN @StartDate AND @EndDate;

    INSERT INTO @tblDistinctPLTMembersIncluded
    (
        PLTMemberFK
    )
    SELECT DISTINCT
           tc.PLTMemberPK
    FROM @tblCohort tc;

    --Retrieve a comma separated list of the roles for each PLTMember
    INSERT INTO @tblRoles
    (
        PLTMemberFK,
        Roles
    )
    SELECT tdpmi.PLTMemberFK,
           STRING_AGG(ctp.Description, ', ' )WITHIN GROUP (ORDER BY ctp.OrderBy) Roles
    FROM @tblDistinctPLTMembersIncluded tdpmi
        INNER JOIN dbo.PLTMemberRole pmr
            ON pmr.PLTMemberFK = tdpmi.PLTMemberFK
        INNER JOIN dbo.CodeTeamPosition ctp
            ON ctp.CodeTeamPositionPK = pmr.TeamPositionCodeFK
    GROUP BY tdpmi.PLTMemberFK;

    --Final select
    SELECT tc.LeadershipCoachLogPK,
           tc.LCLTeamMemberEngagementPK,
           tc.PLTMemberPK,
           tc.IDNumber,
           tc.FirstName,
           tc.LastName,
           tc.Email,
           tc.Creator,
           tc.CreateDate,
           tc.ProgramFK,
           tc.ProgramName,
           tc.StateFK,
           tc.StateName,
           tr.Roles
    FROM @tblCohort tc
        LEFT JOIN @tblRoles tr
            ON tr.PLTMemberFK = tc.PLTMemberPK
    ORDER BY tc.LeadershipCoachLogPK;

END;
GO

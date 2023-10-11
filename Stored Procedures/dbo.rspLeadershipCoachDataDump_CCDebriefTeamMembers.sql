SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- coaching circle debrief team member section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_CCDebriefTeamMembers]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT cclmdtm.CoachingCircleLCMeetingDebriefTeamMemberPK,
           cclmdtm.Creator,
           cclmdtm.CreateDate,
           cclmdtm.Editor,
           cclmdtm.EditDate,
           cclmdtm.FirstName,
           cclmdtm.LastName,
           cclmdtm.EmailAddress,
           cclmdtm.PhoneNumber,
		   ctp.CodeTeamPositionPK,
		   ctp.[Description] TeamPositionText,
           cclmd.CoachingCircleLCMeetingDebriefPK,
		   cclmd.CoachingCircleName,
		   cclmd.DebriefYear,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.CoachingCircleLCMeetingDebriefTeamMember cclmdtm
		INNER JOIN dbo.CodeTeamPosition ctp
			ON ctp.CodeTeamPositionPK = cclmdtm.TeamPositionCodeFK
		INNER JOIN dbo.CoachingCircleLCMeetingDebrief cclmd
			ON cclmd.CoachingCircleLCMeetingDebriefPK = cclmdtm.CoachingCircleLCMeetingDebriefFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = cclmd.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = cclmd.StateFK
    WHERE cclmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

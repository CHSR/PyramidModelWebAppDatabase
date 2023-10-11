SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- coaching circle debrief section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_CCDebriefs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT cclmd.CoachingCircleLCMeetingDebriefPK,
           cclmd.CoachingCircleName,
           cclmd.Creator,
           cclmd.CreateDate,
           cclmd.DebriefYear,
           cclmd.Editor,
           cclmd.EditDate,
           cclmd.TargetAudience,
           cclmd.LeadershipCoachUsername,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.CoachingCircleLCMeetingDebrief cclmd
        INNER JOIN dbo.[State] s
            ON s.StatePK = cclmd.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = cclmd.StateFK
    WHERE cclmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- programs not affiliated schedule section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_HubDebriefs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT hlmd.HubLCMeetingDebriefPK,
           hlmd.Creator,
           hlmd.CreateDate,
           hlmd.DebriefYear,
           hlmd.Editor,
           hlmd.EditDate,
           hlmd.LeadOrganization,
           hlmd.LocationAddress,
           hlmd.PrimaryContactEmail,
           hlmd.PrimaryContactPhone,
           hlmd.LeadershipCoachUsername,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.HubLCMeetingDebrief hlmd
		INNER JOIN dbo.Hub h
			ON h.HubPK = hlmd.HubFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = h.StateFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = hlmd.HubFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = h.StateFK
    WHERE (
              hubList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND hlmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

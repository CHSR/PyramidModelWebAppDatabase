SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- hub leadership team meeting schedule section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_HubMeetingSchedules]
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
    SELECT hlms.HubLCMeetingSchedulePK,
           hlms.Creator,
           hlms.CreateDate,
           hlms.Editor,
           hlms.EditDate,
           hlms.MeetingInJan,
           hlms.MeetingInFeb,
           hlms.MeetingInMar,
           hlms.MeetingInApr,
           hlms.MeetingInMay,
           hlms.MeetingInJun,
           hlms.MeetingInJul,
           hlms.MeetingInAug,
           hlms.MeetingInSep,
           hlms.MeetingInOct,
           hlms.MeetingInNov,
           hlms.MeetingInDec,
           hlms.MeetingYear,
           hlms.TotalMeetings,
           hlms.LeadershipCoachUsername,
           h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.HubLCMeetingSchedule hlms
		INNER JOIN dbo.Hub h
			ON h.HubPK = hlms.HubFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = h.StateFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = hlms.HubFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = h.StateFK
    WHERE (
              hubList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND hlms.MeetingYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

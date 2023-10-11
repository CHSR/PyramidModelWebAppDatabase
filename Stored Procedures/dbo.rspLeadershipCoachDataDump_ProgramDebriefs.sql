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
CREATE PROC [dbo].[rspLeadershipCoachDataDump_ProgramDebriefs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT plmd.ProgramLCMeetingDebriefPK,
           plmd.Creator,
           plmd.CreateDate,
           plmd.DebriefYear,
           plmd.Editor,
           plmd.EditDate,
           plmd.LocationAddress,
           plmd.PrimaryContactEmail,
           plmd.PrimaryContactPhone,
           plmd.LeadershipCoachUsername,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.ProgramLCMeetingDebrief plmd
		INNER JOIN dbo.Program p
			ON p.ProgramPK = plmd.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = plmd.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND plmd.DebriefYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

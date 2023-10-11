SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- program leadership team meeting schedule section of the Leadership Coach Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachDataDump_ProgramMeetingSchedules]
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
    SELECT plms.ProgramLCMeetingSchedulePK,
           plms.Creator,
           plms.CreateDate,
           plms.Editor,
           plms.EditDate,
           plms.MeetingInJan,
           plms.MeetingInFeb,
           plms.MeetingInMar,
           plms.MeetingInApr,
           plms.MeetingInMay,
           plms.MeetingInJun,
           plms.MeetingInJul,
           plms.MeetingInAug,
           plms.MeetingInSep,
           plms.MeetingInOct,
           plms.MeetingInNov,
           plms.MeetingInDec,
           plms.MeetingYear,
           plms.TotalMeetings,
           plms.LeadershipCoachUsername,
           p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.ProgramLCMeetingSchedule plms
		INNER JOIN dbo.Program p
			ON p.ProgramPK = plms.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = plms.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		  AND plms.MeetingYear BETWEEN DATEPART(YEAR, @StartDate) AND DATEPART(YEAR, @EndDate);

END;
GO

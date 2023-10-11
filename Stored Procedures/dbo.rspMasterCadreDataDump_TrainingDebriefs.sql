SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/20/2022
-- Description:	This stored procedure returns the necessary information for the
-- training debrief section of the Master Cadre Data Dump report
-- =============================================
CREATE PROC [dbo].[rspMasterCadreDataDump_TrainingDebriefs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	--Get all the necessary information
    SELECT mctd.MasterCadreTrainingDebriefPK,
           mctd.AspireEventNum,
           mctd.AssistanceNeeded,
           mctd.CoachingInterest,
		   mctd.CourseIDNum,
           mctd.Creator,
           mctd.CreateDate,
           mctd.DateCompleted,
           mctd.Editor,
           mctd.EditDate,
           mctd.MeetingLocation,
           mctd.NumAttendees,
           mctd.NumEvalsReceived,
           mctd.Reflection,
           mctd.WasUploadedToAspire,
           mctd.MasterCadreMemberUsername,
		   cmf.CodeMeetingFormatPK,
		   cmf.[Description] MeetingFormatText,
		   cmca.CodeMasterCadreActivityPK,
		   cmca.Description ActivityText,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.MasterCadreTrainingDebrief mctd
		INNER JOIN dbo.CodeMasterCadreActivity cmca
			ON cmca.CodeMasterCadreActivityPK = mctd.MasterCadreActivityCodeFK
		INNER JOIN dbo.CodeMeetingFormat cmf
			ON cmf.CodeMeetingFormatPK = mctd.MeetingFormatCodeFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = mctd.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = mctd.StateFK
    WHERE mctd.DateCompleted BETWEEN @StartDate AND @EndDate;

END;
GO

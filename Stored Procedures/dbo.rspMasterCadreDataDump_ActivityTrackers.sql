SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/16/2022
-- Description:	This stored procedure returns the necessary information for the
-- activity tracker section of the Master Cadre Data Dump report
-- =============================================
CREATE PROC [dbo].[rspMasterCadreDataDump_ActivityTrackers]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Retrieve oldest item date for each Tracker Item
	DECLARE @tblItemDates TABLE(
		TrackerItemFK INT,
		StartDateTime DATETIME,
		EndDateTime DATETIME
	)

	INSERT INTO @tblItemDates
	(
	    TrackerItemFK,
	    StartDateTime,
	    EndDateTime
	)
	SELECT tid.MasterCadreTrainingTrackerItemFK,
			MIN(tid.StartDateTime),
			MAX(tid.EndDateTime)
	FROM dbo.MasterCadreTrainingTrackerItemDate tid
	WHERE tid.StartDateTime BETWEEN @StartDate AND @EndDate
	GROUP BY tid.MasterCadreTrainingTrackerItemFK
	
	--Get all the necessary information
    SELECT mctti.MasterCadreTrainingTrackerItemPK,
           mctti.AspireEventNum,
		   mctti.CourseIDNum,
           mctti.Creator,
           mctti.CreateDate,
           mctti.DidEventOccur,
           mctti.Editor,
           mctti.EditDate,
           mctti.IsOpenToPublic,
           mctti.MeetingLocation,
           mctti.NumHours,
           mctti.ParticipantFee,
           mctti.TargetAudience,
           mctti.MasterCadreMemberUsername,
		   cmcfs.CodeMasterCadreFundingSourcePK,
		   cmcfs.[Description] FundingSourceText,
		   cmf.CodeMeetingFormatPK,
		   cmf.[Description] MeetingFormatText,
		   cmca.CodeMasterCadreActivityPK,
		   cmca.[Description] ActivityText,
		   id.StartDateTime,
		   id.EndDateTime,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.MasterCadreTrainingTrackerItem mctti
		INNER JOIN @tblItemDates id
			ON id.TrackerItemFK = mctti.MasterCadreTrainingTrackerItemPK
		INNER JOIN dbo.CodeMasterCadreActivity cmca
			ON cmca.CodeMasterCadreActivityPK = mctti.MasterCadreActivityCodeFK
		INNER JOIN dbo.CodeMasterCadreFundingSource cmcfs
			ON cmcfs.CodeMasterCadreFundingSourcePK = mctti.MasterCadreFundingSourceCodeFK
		INNER JOIN dbo.CodeMeetingFormat cmf
			ON cmf.CodeMeetingFormatPK = mctti.MeetingFormatCodeFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = mctti.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = mctti.StateFK
    ORDER BY id.StartDateTime

END;
GO

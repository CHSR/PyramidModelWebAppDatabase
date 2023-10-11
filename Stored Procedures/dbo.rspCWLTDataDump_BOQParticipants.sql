SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/13/2022
-- Description:	This stored procedure returns the necessary information for the
-- CWLT BOQ Participants section of the Community Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspCWLTDataDump_BOQParticipants]
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
    SELECT bp.BOQCWLTParticipantPK,
           bp.Creator,
           bp.CreateDate,
           bp.Editor,
           bp.EditDate,
           cm.CWLTMemberPK,
		   cm.IDNumber ParticipantIDNumber,
		   cm.FirstName ParticipantFirstName,
		   cm.LastName ParticipantLastName,
		   boqc.BenchmarkOfQualityCWLTPK,
		   boqc.FormDate BOQFormDate,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.BOQCWLTParticipant bp
		INNER JOIN dbo.BenchmarkOfQualityCWLT boqc
			ON boqc.BenchmarkOfQualityCWLTPK = bp.BenchmarksOfQualityCWLTFK
		INNER JOIN dbo.CWLTMember cm
			ON cm.CWLTMemberPK = bp.CWLTMemberFK
		INNER JOIN dbo.Hub h
			ON h.HubPK = boqc.HubFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = h.StateFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = h.HubPK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
			AND boqc.FormDate BETWEEN @StartDate AND @EndDate;

END;
GO

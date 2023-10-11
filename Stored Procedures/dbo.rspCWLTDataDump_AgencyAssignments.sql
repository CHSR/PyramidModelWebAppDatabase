SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/13/2022
-- Description:	This stored procedure returns the necessary information for the
-- Agency Assignment section of the Community Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspCWLTDataDump_AgencyAssignments]
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
    SELECT cmaa.CWLTMemberAgencyAssignmentPK,
           cmaa.Creator,
           cmaa.CreateDate,
           cmaa.Editor,
           cmaa.EditDate,
           cmaa.EndDate,
           cmaa.StartDate,
           cm.CWLTMemberPK,
		   cm.IDNumber TeamMemberIDNumber,
		   cm.FirstName TeamMemberFirstName,
		   cm.LastName TeamMemberLastName,
		   ca.CWLTAgencyPK,
           ca.[Name] AgencyName,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.CWLTMemberAgencyAssignment cmaa
		INNER JOIN dbo.CWLTMember cm
			ON cm.CWLTMemberPK = cmaa.CWLTMemberFK
		INNER JOIN dbo.CWLTAgency ca
			ON ca.CWLTAgencyPK = cmaa.CWLTAgencyFK
		INNER JOIN dbo.Hub h
			ON h.HubPK = cm.HubFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = h.StateFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = h.HubPK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
			AND cm.StartDate <= @EndDate
			AND (cm.LeaveDate IS NULL OR cm.LeaveDate >= @StartDate);

END;
GO

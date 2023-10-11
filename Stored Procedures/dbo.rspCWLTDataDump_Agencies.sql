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
CREATE PROC [dbo].[rspCWLTDataDump_Agencies]
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
    SELECT ca.CWLTAgencyPK,
           ca.AddressCity,
           ca.AddressState,
           ca.AddressStreet,
           ca.AddressZIPCode,
           ca.Creator,
           ca.CreateDate,
           ca.Editor,
           ca.EditDate,
           ca.[Name] AgencyName,
           ca.PhoneNumber,
           ca.Website,
           ca.CWLTAgencyTypeFK,
		   cat.CWLTAgencyTypePK,
		   cat.[Name] AgencyTypeName,
		   cat.[Description] AgencyTypeDescription,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.CWLTAgency ca
		INNER JOIN dbo.CWLTAgencyType cat
			ON cat.CWLTAgencyTypePK = ca.CWLTAgencyTypeFK
		INNER JOIN dbo.Hub h
			ON h.HubPK = ca.HubFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = h.StateFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = h.HubPK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL);  --At least one of the options must be utilized

END;
GO

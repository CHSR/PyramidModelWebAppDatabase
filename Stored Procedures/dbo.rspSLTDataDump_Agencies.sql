SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- Agency section of the State Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspSLTDataDump_Agencies]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT sa.SLTAgencyPK,
           sa.AddressCity,
           sa.AddressState,
           sa.AddressStreet,
           sa.AddressZIPCode,
           sa.Creator,
           sa.CreateDate,
           sa.Editor,
           sa.EditDate,
           sa.[Name] AgencyName,
           sa.PhoneNumber,
           sa.Website,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.SLTAgency sa
		INNER JOIN dbo.[State] s
			ON s.StatePK = sa.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = sa.StateFK

END;
GO

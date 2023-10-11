SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- CWLT Agency Type section of the State Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspSLTDataDump_CWLTAgencyTypes]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT cat.CWLTAgencyTypePK,
           cat.Creator,
           cat.CreateDate,
           cat.Editor,
           cat.EditDate,
           cat.[Description] TypeDescription,
           cat.[Name] TypeName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.CWLTAgencyType cat
		INNER JOIN dbo.[State] s
			ON s.StatePK = cat.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = cat.StateFK

END;
GO

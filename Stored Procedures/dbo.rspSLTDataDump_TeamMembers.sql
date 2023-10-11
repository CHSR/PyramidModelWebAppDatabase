SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- SLT Team Members section of the State Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspSLTDataDump_TeamMembers]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT sm.SLTMemberPK,
		   sm.IDNumber TeamMemberIDNumber,
		   sm.FirstName TeamMemberFirstName,
		   sm.LastName TeamMemberLastName,
           sm.Creator,
           sm.CreateDate,
           sm.Editor,
           sm.EditDate,
           sm.EmailAddress,
           sm.LeaveDate,
		   sm.PhoneNumber,
           sm.StartDate,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.SLTMember sm
		INNER JOIN dbo.[State] s
			ON s.StatePK = sm.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = sm.StateFK
	WHERE sm.StartDate <= @EndDate
			AND (sm.LeaveDate IS NULL OR sm.LeaveDate >= @StartDate);

END;
GO

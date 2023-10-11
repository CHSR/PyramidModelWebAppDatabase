SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/30/2022
-- Description:	This stored procedure returns the necessary information for the
-- hub data dump report
-- =============================================
CREATE PROC [dbo].[rspProgramManagementDataDump_Hubs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT h.HubPK,
           h.Creator,
           h.CreateDate,
           h.Editor,
           h.EditDate,
           h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.Hub h
        INNER JOIN dbo.[State] s
            ON s.StatePK = h.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = h.StateFK;

END;
GO

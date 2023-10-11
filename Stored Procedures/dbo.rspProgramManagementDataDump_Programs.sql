SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/03/2022
-- Description:	This stored procedure returns the necessary information for the
-- program section of the program management data dump report
-- =============================================
CREATE PROC [dbo].[rspProgramManagementDataDump_Programs]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT p.ProgramPK,
           p.Creator,
           p.CreateDate,
           p.Editor,
           p.EditDate,
		   p.IDNumber,
           p.[Location],
           p.ProgramEndDate,
           p.ProgramName,
           p.ProgramStartDate,
		   c.CohortPK,
		   c.CohortName,
		   h.HubPK,
		   h.[Name] HubName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.Program p
		INNER JOIN dbo.Hub h
			ON h.HubPK = p.HubFK
		INNER JOIN dbo.Cohort c
			ON c.CohortPK = p.CohortFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
	WHERE p.ProgramStartDate <= @EndDate
		AND (p.ProgramEndDate IS NULL OR p.ProgramEndDate >= @StartDate);

END;
GO

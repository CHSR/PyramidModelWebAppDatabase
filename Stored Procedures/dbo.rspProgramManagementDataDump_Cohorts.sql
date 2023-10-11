SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/03/2022
-- Description:	This stored procedure returns the necessary information for the
-- cohort section of the program management data dump report
-- =============================================
CREATE PROC [dbo].[rspProgramManagementDataDump_Cohorts]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT c.CohortPK,
           c.CohortName,
           c.Creator,
           c.CreateDate,
           c.Editor,
           c.EditDate,
           c.EndDate,
           c.StartDate,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.Cohort c
        INNER JOIN dbo.[State] s
            ON s.StatePK = c.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = c.StateFK
	WHERE c.StartDate <= @EndDate
		AND (c.EndDate IS NULL OR c.EndDate >= @StartDate);

END;
GO

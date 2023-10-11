SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/05/2023
-- Description:	This stored procedure returns the necessary information for the
-- Leadership Coach Log Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachLogDataDump_MultiSelects]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT lclr.LCLResponsePK,
            lclr.Creator,
            lclr.CreateDate,
            lclr.LeadershipCoachLogFK,
			clclr.CodeLCLResponsePK,
            clclr.Abbreviation,
            clclr.[Description],
			clclr.FieldName,
            clclr.[Group],
			p.ProgramPK,
			p.ProgramName,
			s.StatePK,
			s.[Name] StateName
	FROM dbo.LCLResponse lclr
		INNER JOIN dbo.CodeLCLResponse clclr
			ON clclr.CodeLCLResponsePK = lclr.LCLResponseCodeFK
		INNER JOIN dbo.LeadershipCoachLog lcl
			ON lcl.LeadershipCoachLogPK = lclr.LeadershipCoachLogFK
        INNER JOIN dbo.Program p 
			ON p.ProgramPK = lcl.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = lcl.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = p.HubFK
        LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList
            ON cohortList.ListItem = p.CohortFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
	WHERE (
              programList.ListItem IS NOT NULL
              OR hubList.ListItem IS NOT NULL
              OR cohortList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
          AND lcl.DateCompleted BETWEEN @StartDate AND @EndDate
	ORDER BY lclr.LeadershipCoachLogFK, clclr.[Group], clclr.OrderBy
END;
GO

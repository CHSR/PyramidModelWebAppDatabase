SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 04/18/2023
-- Description:	This stored procedure returns the necessary information for the Involved Coaches section of the
-- Leadership Coach Log Data Dump report
-- =============================================
CREATE PROC [dbo].[rspLeadershipCoachLogDataDump_Coaches]
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

	SELECT 
		lcl.LeadershipCoachLogPK,
		e.FirstName,
		e.LastName,
		pe.ProgramEmployeePK,
		pe.ProgramSpecificID,
		e.EmailAddress,
		lic.Creator, 
		lic.CreateDate,
		p.ProgramPK,
		p.ProgramName,
		s.StatePK,
		s.[Name] StateName
	FROM dbo.LeadershipCoachLog lcl
		INNER JOIN dbo.Program p 
			ON p.ProgramPK = lcl.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		INNER JOIN dbo.LCLInvolvedCoach lic
			ON lic.LeadershipCoachLogFK = lcl.LeadershipCoachLogPK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.ProgramEmployeePK= lic.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
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
	ORDER BY lcl.LeadershipCoachLogPK;

	END;
GO

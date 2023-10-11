SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 01/10/2023
-- Description:	This stored procedure returns the necessary information for the
-- Coachee section of the Coaching Log Data Dump report
-- =============================================
CREATE PROCEDURE [dbo].[rspCoachingLogCoacheeDataDump] 
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

	--Get all the necessary information
    SELECT clc.CoachingLogCoacheesPK,
	       clc.Creator,
		   clc.CreateDate,
		   clc.Editor,
		   clc.EditDate,
		   clc.CoacheeFK,
		   clc.CoachingLogFK,
		   e.FirstName,
		   e.LastName,
		   pe.ProgramSpecificID CoacheeID,
		   pe.ProgramEmployeePK CoacheeEmployeeKey,
		   p.ProgramName,
		   p.ProgramPK,
		   st.StatePK,
		   st.[Name] StateName,
		   c.LogDate
	FROM dbo.CoachingLogCoachees clc
		INNER JOIN dbo.CoachingLog c
			ON c.CoachingLogPK = clc.CoachingLogFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.ProgramEmployeePK = clc.CoacheeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = c.ProgramFK
		INNER JOIN dbo.[State] st
			ON st.StatePK=p.StateFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = p.ProgramPK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
		AND c.LogDate BETWEEN @StartDate AND @EndDate

END
GO

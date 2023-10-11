SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 09/21/2022
-- Description:	This stored procedure returns the necessary information for the
-- TPOT section of the TPOT Data Dump report
-- =============================================
CREATE PROC [dbo].[rspTPOTDataDump]
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
    SELECT tp.TPOTPK,
		   tp.AdditionalStrategiesNumUsed,
		   tp.ChallengingBehaviorsNumObserved,
		   tp.Creator,
		   tp.CreateDate,
		   tp.Editor,
		   tp.EditDate,
		   tp.IsComplete,
		   tp.Item1NumNo,
		   tp.Item2NumNo,
		   tp.Item3NumNo,
		   tp.Item4NumNo,
		   tp.Item5NumNo,
		   tp.Item6NumNo,
		   tp.Item7NumNo,
		   tp.Item8NumNo,
		   tp.Item9NumNo,
		   tp.Item10NumNo,
		   tp.Item11NumNo,
		   tp.Item12NumNo,
		   tp.Item13NumNo,
		   tp.Item14NumNo,
		   tp.Item1NumYes,
		   tp.Item2NumYes,
		   tp.Item3NumYes,
		   tp.Item4NumYes,
		   tp.Item5NumYes,
		   tp.Item6NumYes,
		   tp.Item7NumYes,
		   tp.Item8NumYes,
		   tp.Item9NumYes,
		   tp.Item10NumYes,
		   tp.Item11NumYes,
		   tp.Item12NumYes,
		   tp.Item13NumYes,
		   tp.Item14NumYes,
		   tp.Notes,
		   tp.NumAdultsBegin,
		   tp.NumAdultsEnd,
		   tp.NumAdultsEntered,
		   tp.NumKidsBegin,
		   tp.NumKidsEnd,
		   tp.ObservationEndDateTime,
		   tp.ObservationStartDateTime,
		   tp.RedFlagsNumNo,
		   tp.RedFlagsNumYes,
		   tp.ClassroomFK,
		   tp.EssentialStrategiesUsedCodeFK,
		   tp.ObserverFK,
		   cl.ProgramSpecificID ClassroomIDNumber,
		   cl.[Name] ClassroomName,
		   cl.ClassroomPK ClassroomKey,
		   es.[Description] EssentialStrategiesUsed,
		   e.FirstName ObserverFirstName,
		   e.LastName ObserverLastName,
		   pe.ProgramSpecificID ObserverID,
		   pe.ProgramEmployeePK ObserverEmployeeKey,
		   p.ProgramPK,
		   p.ProgramName,
		   st.StatePK,
		   st.[Name] StateName
	FROM dbo.TPOT tp
		INNER JOIN dbo.Classroom cl
			ON cl.ClassroomPK = tp.ClassroomFK
		INNER JOIN dbo.CodeEssentialStrategiesUsed es
			ON es.CodeEssentialStrategiesUsedPK = tp.EssentialStrategiesUsedCodeFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.ProgramEmployeePK = tp.ObserverFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = cl.ProgramFK
		INNER JOIN dbo.[State] st
			ON st.StatePK = p.StateFK
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
		AND tp.ObservationStartDateTime BETWEEN @StartDate AND @EndDate

END;
GO

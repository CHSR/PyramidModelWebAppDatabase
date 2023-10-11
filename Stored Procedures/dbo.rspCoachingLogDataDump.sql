SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 09/12/2022
-- Description:	This stored procedure returns the necessary information for the
-- Coaching Log Data Dump report
-- =============================================
CREATE PROC [dbo].[rspCoachingLogDataDump]
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
    SELECT cl.CoachingLogPK,
		   cl.Creator,
           cl.CreateDate,
		   cl.DurationMinutes,
           cl.Editor,
           cl.EditDate,
           cl.LogDate,
		   CASE WHEN cl.FUEmail = 1 THEN 'Yes' ELSE 'No' END FUEmail,
		   CASE WHEN cl.FUInPerson = 1 THEN 'Yes' ELSE 'No' END FUInPerson,
		   CASE WHEN cl.FUNone = 1 THEN 'Yes' ELSE 'No' END FUNone,
		   CASE WHEN cl.FUPhone= 1 THEN 'Yes' ELSE 'No' END FUPhone,
		   CASE WHEN cl.MEETDemonstration= 1 THEN 'Yes' ELSE 'No' END MEETDemonstration,
		   CASE WHEN cl.MEETEnvironment= 1 THEN 'Yes' ELSE 'No' END MEETEnvironment,
		   CASE WHEN cl.MEETGoalSetting= 1 THEN 'Yes' ELSE 'No' END MEETGoalSetting,
		   CASE WHEN cl.MEETGraphic= 1 THEN 'Yes' ELSE 'No' END MEETGraphic,
		   CASE WHEN cl.MEETMaterial= 1 THEN 'Yes' ELSE 'No' END MEETMaterial,
		   CASE WHEN cl.MEETOther= 1 THEN 'Yes' ELSE 'No' END MEETOther,
		   CASE WHEN cl.MEETOtherSpecify IS NULL THEN 'NA' ELSE cl.MEETOtherSpecify END AS MEETOtherSpecify,
		   CASE WHEN cl.MEETPerformance= 1 THEN 'Yes' ELSE 'No' END MEETPerformance,
		   CASE WHEN cl.MEETProblemSolving= 1 THEN 'Yes' ELSE 'No' END MEETProblemSolving,
		   CASE WHEN cl.MEETReflectiveConversation= 1 THEN 'Yes' ELSE 'No' END MEETReflectiveConversation,
		   CASE WHEN cl.MEETRoleplay= 1 THEN 'Yes' ELSE 'No' END MEETRoleplay,
		   CASE WHEN cl.MEETVideo= 1 THEN 'Yes' ELSE 'No' END MEETVideo,
		   CASE WHEN cl.OBSConductTPITOS= 1 THEN 'Yes' ELSE 'No' END OBSConductTPITOS,
		   CASE WHEN cl.OBSConductTPOT= 1 THEN 'Yes' ELSE 'No' END OBSConductTPOT,
		   CASE WHEN cl.OBSEnvironment= 1 THEN 'Yes' ELSE 'No' END OBSEnvironment,
		   CASE WHEN cl.OBSModeling= 1 THEN 'Yes' ELSE 'No' END OBSModeling,
		   CASE WHEN cl.OBSObserving= 1 THEN 'Yes' ELSE 'No' END OBSOberving,
		   CASE WHEN cl.OBSOther= 1 THEN 'Yes' ELSE 'No' END OBSOther,
		   CASE WHEN cl.OBSOtherHelp= 1 THEN 'Yes' ELSE 'No' END OBSOtherHelp,
		   CASE WHEN cl.OBSOtherSpecify IS NULL THEN 'NA' ELSE cl.OBSOtherSpecify END AS OBSOtherSpecify,
		   CASE WHEN cl.OBSProblemSolving= 1 THEN 'Yes' ELSE 'No' END OBSProblemSolving,
		   CASE WHEN cl.OBSReflectiveConversation= 1 THEN 'Yes' ELSE 'No' END OBSReflectiveConversation,
		   CASE WHEN cl.OBSSideBySide= 1 THEN 'Yes' ELSE 'No' END OBSSideBySide,
		   CASE WHEN cl.OBSVerbalSupport= 1 THEN 'Yes' ELSE 'No' END OBSVerbalSupport,
		   cl.Narrative,
		   cl.CoachFK,
		   cl.ProgramFK,
		   p.ProgramPK,
		   p.ProgramName,
		   e.FirstName CoachFirstName,
		   e.LastName CoachLastName,
		   coach.ProgramSpecificID CoachID,
		   coach.ProgramEmployeePK CoachEmployeeKey,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.CoachingLog cl
        INNER JOIN dbo.Program p 
			ON p.ProgramPK = cl.ProgramFK
        INNER JOIN dbo.[State] s 
			ON s.StatePK = p.StateFK
		INNER JOIN dbo.ProgramEmployee coach 
			ON coach.ProgramEmployeePK = cl.CoachFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = coach.EmployeeFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = cl.ProgramFK
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
          AND cl.LogDate BETWEEN @StartDate AND @EndDate;

END;
GO

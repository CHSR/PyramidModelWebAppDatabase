SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu	
-- Create date: 08/29/2022
-- Description:	This stored procedure returns the necessary information for the
-- BIR Data Dump report
-- =============================================
CREATE PROC [dbo].[rspBIRDataDump]
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
    SELECT bi.ActivitySpecify,
           bi.AdminFollowUpSpecify,
           bi.BehaviorIncidentPK,
           bi.Creator,
           bi.CreateDate,
           bi.Editor,
           bi.EditDate,
           bi.BehaviorDescription,
           bi.IncidentDatetime,
           bi.ChildFK,
           bi.Notes,
           bi.OthersInvolvedSpecify,
           bi.PossibleMotivationSpecify,
           bi.ProblemBehaviorSpecify,
           bi.StrategyResponseSpecify,
           bi.ActivityCodeFK,
           bi.AdminFollowUpCodeFK,
           bi.OthersInvolvedCodeFK,
           bi.PossibleMotivationCodeFK,
           bi.StrategyResponseCodeFK,
           bi.ProblemBehaviorCodeFK,
           bi.ChildFK,
           bi.ClassroomFK,
           ca.[Description] ActivityDescription,
           af.[Description] AdminFollowUpDescription,
           co.[Description] OthersInvolvedDescription,
           pm.[Description] PossibleMotivationDescription,
           sr.[Description] StrategyResponseDescription,
           pb.[Description] ProblemBehaviorDescription,
           p.ProgramPK,
           p.ProgramName,
           s.StatePK,
           s.[Name] StateName,
		   cl.Name ClassroomName,
		   cl.ClassroomPK,
		   cl.ProgramSpecificID ProgramID,
           cp.ChildProgramPK,
           cp.ProgramSpecificID ChildIDNumber,
           c.FirstName ChildFirstName,
           c.LastName ChildLastName
    FROM dbo.BehaviorIncident bi
        INNER JOIN dbo.CodeActivity ca
            ON ca.CodeActivityPK = bi.ActivityCodeFK
        INNER JOIN dbo.CodeAdminFollowUp af
            ON af.CodeAdminFollowUpPK = bi.AdminFollowUpCodeFK
        INNER JOIN dbo.CodeOthersInvolved co
            ON co.CodeOthersInvolvedPK = bi.OthersInvolvedCodeFK
        INNER JOIN dbo.CodePossibleMotivation pm
            ON pm.CodePossibleMotivationPK = bi.PossibleMotivationCodeFK
        INNER JOIN dbo.CodeStrategyResponse sr
            ON sr.CodeStrategyResponsePK = bi.StrategyResponseCodeFK
        INNER JOIN dbo.Classroom cl
            ON cl.ClassroomPK = bi.ClassroomFK
        INNER JOIN dbo.Child c
            ON c.ChildPK = bi.ChildFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = cl.ProgramFK
        INNER JOIN dbo.ChildProgram cp
            ON cp.ChildFK = c.ChildPK
               AND cp.ProgramFK = p.ProgramPK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        INNER JOIN dbo.CodeProblemBehavior pb
            ON pb.CodeProblemBehaviorPK = bi.ProblemBehaviorCodeFK
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
          AND bi.IncidentDatetime BETWEEN @StartDate AND @EndDate;

END;
GO

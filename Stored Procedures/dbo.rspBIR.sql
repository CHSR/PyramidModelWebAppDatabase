SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/05/2020
-- Description:	This stored procedure returns the necessary information for the
-- BIR report
-- =============================================
CREATE PROC [dbo].[rspBIR]
	@BehaviorIncidentPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the BIR information
	SELECT bi.BehaviorIncidentPK, bi.IncidentDatetime, bi.BehaviorDescription, bi.Notes,
		   child.FirstName ChildFirstName, child.LastName ChildLastName,
		   cp.ProgramSpecificID ChildID,
		   classroom.ProgramSpecificID ClassroomID, classroom.Name ClassroomName,
		   cpb.Description ProblemBehavior, bi.ProblemBehaviorSpecify,
		   ca.Description Activity, bi.ActivitySpecify,
		   coi.Description OthersInvolved, bi.OthersInvolvedSpecify,
		   cpm.Description PossibleMotivation, bi.PossibleMotivationSpecify,
		   csr.Description StrategyResponse, bi.StrategyResponseSpecify,
		   cafu.Description AdminFollowUp, bi.AdminFollowUpSpecify,
		   p.ProgramName
	FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.Child child ON child.ChildPK = bi.ChildFK
	INNER JOIN dbo.Classroom classroom ON classroom.ClassroomPK = bi.ClassroomFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = child.ChildPK AND cp.ProgramFK = classroom.ProgramFK
	INNER JOIN dbo.CodeProblemBehavior cpb ON cpb.CodeProblemBehaviorPK = bi.ProblemBehaviorCodeFK
	INNER JOIN dbo.CodeActivity ca ON ca.CodeActivityPK = bi.ActivityCodeFK
	INNER JOIN dbo.CodeOthersInvolved coi ON coi.CodeOthersInvolvedPK = bi.OthersInvolvedCodeFK
	INNER JOIN dbo.CodePossibleMotivation cpm ON cpm.CodePossibleMotivationPK = bi.PossibleMotivationCodeFK
	INNER JOIN dbo.CodeStrategyResponse csr ON csr.CodeStrategyResponsePK = bi.StrategyResponseCodeFK
	INNER JOIN dbo.CodeAdminFollowUp cafu ON cafu.CodeAdminFollowUpPK = bi.AdminFollowUpCodeFK
	INNER JOIN dbo.Program p ON p.ProgramPK = classroom.ProgramFK
	WHERE bi.BehaviorIncidentPK = @BehaviorIncidentPK

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/16/2019
-- Description:	Example report stored procedure
-- =============================================
CREATE PROC [dbo].[rspSecondExample]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get all the behavior incidents
	SELECT bi.IncidentDatetime, cpb.Description AS ProblemBehavior, ca.Description AS Activity,
	c.ChildPK, '(' + cp.ProgramSpecificID + ') ' + c.FirstName + ' ' + c.LastName AS ChildName,
	p.ProgramPK, p.ProgramName
	FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.Child c ON c.ChildPK = bi.ChildFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
	INNER JOIN dbo.CodeProblemBehavior cpb ON cpb.CodeProblemBehaviorPK = bi.ProblemBehaviorCodeFK
	INNER JOIN dbo.CodeActivity ca ON ca.CodeActivityPK = bi.ActivityCodeFK
	WHERE bi.IncidentDatetime BETWEEN @StartDate AND @EndDate
	
END
GO

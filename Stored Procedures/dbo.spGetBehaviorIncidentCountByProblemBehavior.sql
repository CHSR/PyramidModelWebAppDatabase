SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/03/2019
-- Description:	This stored procedure returns the number of behavior incidents
-- for each type of problem behavior in the database
-- =============================================
CREATE PROC [dbo].[spGetBehaviorIncidentCountByProblemBehavior]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the number of behavior incidents for each problem behavior
	SELECT cpb.Description ProblemBehavior, COUNT(bi.BehaviorIncidentPK) NumIncidents FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.CodeProblemBehavior cpb ON cpb.CodeProblemBehaviorPK = bi.ProblemBehaviorCodeFK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = bi.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	WHERE bi.IncidentDatetime BETWEEN @StartDate AND @EndDate
	GROUP BY cpb.Description
END
GO

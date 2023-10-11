SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/01/2020
-- Description:	This stored procedure returns the necessary information for the
-- ASQSE report
-- =============================================
CREATE PROC [dbo].[rspASQSE]
	@ASQSEPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the ASQSE information
	SELECT a.ASQSEPK, a.FormDate ASQSEDate, a.HasDemographicInfoSheet, a.HasPhysicianInfoLetter, a.TotalScore, a.Version ASQSEVersion, 
           sa.CutoffScore, sa.MaxScore, sa.MonitoringScoreStart, sa.MonitoringScoreEnd,
		   cai.IntervalMonth, cai.Description IntervalDescription,
           child.FirstName, child.LastName, child.BirthDate,
           cp.ProgramSpecificID,
		   p.ProgramName,
		   classroom.Name ClassroomName
	FROM dbo.ASQSE a
	INNER JOIN dbo.ScoreASQSE sa ON sa.IntervalCodeFK = a.IntervalCodeFK AND sa.Version = a.Version
	INNER JOIN dbo.CodeASQSEInterval cai ON cai.CodeASQSEIntervalPK = a.IntervalCodeFK
	INNER JOIN dbo.Child child ON child.ChildPK = a.ChildFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = child.ChildPK AND cp.ProgramFK = a.ProgramFK
	INNER JOIN dbo.Program p ON p.ProgramPK = a.ProgramFK
	LEFT JOIN dbo.ChildClassroom cc ON cc.ChildFK = child.ChildPK AND a.FormDate BETWEEN cc.AssignDate AND ISNULL(cc.LeaveDate, GETDATE())
	LEFT JOIN dbo.Classroom classroom ON classroom.ClassroomPK = cc.ClassroomFK
	WHERE a.ASQSEPK = @ASQSEPK

END
GO

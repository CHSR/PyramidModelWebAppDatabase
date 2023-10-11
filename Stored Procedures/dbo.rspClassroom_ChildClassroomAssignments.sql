SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/08/2020
-- Description:	This stored procedure returns the necessary information for the
-- child classroom assignment section of the classroom report
-- =============================================
CREATE PROC [dbo].[rspClassroom_ChildClassroomAssignments]
	@ClassroomPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the child classroom assignment information
	SELECT cc.ChildClassroomPK, cc.AssignDate, cc.LeaveDate, cc.LeaveReasonSpecify,
		   classroom.ClassroomPK, classroom.Name ClassroomName,
		   cp.ProgramSpecificID ChildID,
		   child.FirstName ChildFirstName, child.LastName ChildLastName,
		   cclr.Description LeaveReason
	FROM dbo.ChildClassroom cc
	INNER JOIN dbo.Classroom classroom ON classroom.ClassroomPK = cc.ClassroomFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = cc.ChildFK AND cp.ProgramFK = classroom.ProgramFK
	INNER JOIN dbo.Child child ON child.ChildPK = cp.ChildFK
	LEFT JOIN dbo.CodeChildLeaveReason cclr ON cclr.CodeChildLeaveReasonPK = cc.LeaveReasonCodeFK
	WHERE cc.ClassroomFK = @ClassroomPK
	ORDER BY cc.AssignDate ASC

END
GO

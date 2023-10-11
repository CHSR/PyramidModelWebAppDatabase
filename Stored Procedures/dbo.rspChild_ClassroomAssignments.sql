SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/07/2020
-- Description:	This stored procedure returns the necessary information for the
-- classroom assignment section of the child report
-- =============================================
CREATE PROC [dbo].[rspChild_ClassroomAssignments]
	@ChildProgramPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the classroom assignment history
	SELECT cc.AssignDate, cc.LeaveDate, cc.LeaveReasonSpecify,
		   c.Name ClassroomName, c.ProgramSpecificID ClassroomID, c.Location ClassroomLocation,
		   cp.ChildProgramPK, cp.ProgramSpecificID ChildID,
		   cclr.Description LeaveReason
	FROM dbo.ChildClassroom cc
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = cc.ClassroomFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = cc.ChildFK AND cp.ProgramFK = c.ProgramFK
	LEFT JOIN dbo.CodeChildLeaveReason cclr ON cclr.CodeChildLeaveReasonPK = cc.LeaveReasonCodeFK
	WHERE cp.ChildProgramPK = @ChildProgramPK
	ORDER BY cc.AssignDate ASC

END
GO

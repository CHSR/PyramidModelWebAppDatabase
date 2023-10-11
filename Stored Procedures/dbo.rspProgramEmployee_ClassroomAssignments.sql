SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/11/2020
-- Description:	This stored procedure returns the necessary information for the
-- classroom assignments section of the Program Employee report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployee_ClassroomAssignments]
	@ProgramEmployeePK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the classroom assignment information
	SELECT ec.AssignDate, ec.LeaveDate, ec.LeaveReasonSpecify,
		   c.ProgramSpecificID ClassroomID, c.Name ClassroomName,
		   cjt.Description ClassroomJob,
		   celr.Description LeaveReason
	FROM dbo.EmployeeClassroom ec
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = ec.ClassroomFK
	INNER JOIN dbo.CodeJobType cjt ON cjt.CodeJobTypePK = ec.JobTypeCodeFK
	LEFT JOIN dbo.CodeEmployeeLeaveReason celr ON celr.CodeEmployeeLeaveReasonPK = ec.LeaveReasonCodeFK
	WHERE ec.ProgramEmployeeFK = @ProgramEmployeePK
	ORDER BY ec.AssignDate ASC

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/08/2020
-- Description:	This stored procedure returns the necessary information for the
-- employee classroom assignment section of the classroom report
-- =============================================
CREATE PROC [dbo].[rspClassroom_EmployeeClassroomAssignments] @ClassroomPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the employee classroom assignment information
    SELECT ec.EmployeeClassroomPK,
           ec.AssignDate,
           ec.LeaveDate,
           ec.LeaveReasonSpecify,
           classroom.ClassroomPK,
           classroom.Name ClassroomName,
		   pe.ProgramSpecificID EmployeeID,
           e.FirstName EmployeeFirstName,
           e.LastName EmployeeLastName,
           cjt.Description ClassroomJob,
           celr.Description LeaveReason
    FROM dbo.EmployeeClassroom ec
        INNER JOIN dbo.Classroom classroom
            ON classroom.ClassroomPK = ec.ClassroomFK
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = ec.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeJobType cjt
            ON cjt.CodeJobTypePK = ec.JobTypeCodeFK
        LEFT JOIN dbo.CodeEmployeeLeaveReason celr
            ON celr.CodeEmployeeLeaveReasonPK = ec.LeaveReasonCodeFK
    WHERE ec.ClassroomFK = @ClassroomPK
    ORDER BY ec.AssignDate ASC;

END;
GO

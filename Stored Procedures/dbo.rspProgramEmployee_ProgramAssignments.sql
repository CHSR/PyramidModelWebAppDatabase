SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/24/2023
-- Description:	This stored procedure returns the necessary information for the
-- program assignments section of the Program Employee report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployee_ProgramAssignments] 
	@ProgramEmployeePK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the employee FK that relates to the current ProgramEemployee record
    DECLARE @EmployeeFK INT =
            (
                SELECT TOP (1)
                       pe.EmployeeFK
                FROM dbo.ProgramEmployee pe
                WHERE pe.ProgramEmployeePK = @ProgramEmployeePK
                ORDER BY pe.ProgramEmployeePK ASC
            );

    --Get the program assignment information
    SELECT p.ProgramName,
           pe.HireDate,
           pe.TermDate,
           ctr.[Description] TermReason
    FROM dbo.Employee e
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.EmployeeFK = e.EmployeePK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = pe.ProgramFK
        LEFT JOIN dbo.CodeTermReason ctr
            ON ctr.CodeTermReasonPK = pe.TermReasonCodeFK
    WHERE e.EmployeePK = @EmployeeFK
    ORDER BY pe.HireDate DESC;

END;
GO

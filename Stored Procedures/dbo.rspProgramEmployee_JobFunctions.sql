SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/11/2020
-- Description:	This stored procedure returns the necessary information for the
-- job function section of the Program Employee report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployee_JobFunctions]
	@ProgramEmployeePK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the job function information
	SELECT jf.StartDate, jf.EndDate,
		   cjt.Description JobFunction
	FROM dbo.JobFunction jf
	INNER JOIN dbo.CodeJobType cjt ON cjt.CodeJobTypePK = jf.JobTypeCodeFK
	WHERE jf.ProgramEmployeeFK = @ProgramEmployeePK
	ORDER BY jf.StartDate ASC

END
GO

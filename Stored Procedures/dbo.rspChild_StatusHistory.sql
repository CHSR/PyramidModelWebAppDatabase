SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/07/2020
-- Description:	This stored procedure returns the necessary information for the
-- status section of the child report
-- =============================================
CREATE PROC [dbo].[rspChild_StatusHistory]
	@ChildProgramPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the child program info
	DECLARE @tblChildProgramInfo TABLE (
		ChildProgramPK INT NOT NULL,
		ChildFK INT NOT NULL,
		ProgramFK INT NOT NULL
	)

	--Get the child program info
	INSERT INTO @tblChildProgramInfo
	(
	    ChildProgramPK,
	    ChildFK,
	    ProgramFK
	)
	SELECT cp.ChildProgramPK, cp.ChildFK, cp.ProgramFK
	FROM dbo.ChildProgram cp
	WHERE cp.ChildProgramPK = @ChildProgramPK

	--Get the child and program FK
	DECLARE @ChildFK INT = (SELECT TOP(1) tcpi.ChildFK FROM @tblChildProgramInfo tcpi ORDER BY tcpi.ChildProgramPK)
	DECLARE @ProgramFK INT = (SELECT TOP(1) tcpi.ProgramFK FROM @tblChildProgramInfo tcpi ORDER BY tcpi.ChildProgramPK)

	--Get the status history
	EXEC dbo.spGetChildStatusHistory @ChildPK = @ChildFK,  -- int
	                                 @ProgramFK = @ProgramFK -- int
	

END
GO

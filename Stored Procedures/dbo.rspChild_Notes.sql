SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/07/2020
-- Description:	This stored procedure returns the necessary information for the
-- notes section of the child report
-- =============================================
CREATE PROC [dbo].[rspChild_Notes]
	@ChildProgramPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the notes
	SELECT cn.NoteDate, cn.Contents,
		   cp.ChildProgramPK, cp.ProgramSpecificID
	FROM dbo.ChildNote cn
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = cn.ChildFK AND cp.ProgramFK = cn.ProgramFK
	WHERE cp.ChildProgramPK = @ChildProgramPK
	ORDER BY cn.NoteDate ASC

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/08/2020
-- Description:	This stored procedure returns the necessary information for the
-- basic information section of the classroom report
-- =============================================
CREATE PROC [dbo].[rspClassroom_BasicInfo]
	@ClassroomPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the classroom information
	SELECT c.ClassroomPK, c.BeingServedSubstitute, c.IsInfantToddler, c.IsPreschool, c.Location, c.Name ClassroomName, c.ProgramSpecificID ClassroomID,
		   p.ProgramName
	FROM dbo.Classroom c
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	WHERE c.ClassroomPK = @ClassroomPK

END
GO

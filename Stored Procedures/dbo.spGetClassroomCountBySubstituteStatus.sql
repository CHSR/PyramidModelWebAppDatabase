SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/20/2019
-- Description:	This stored procedure returns the number of classrooms
-- that are or are not served by substitutes
-- =============================================
CREATE PROC [dbo].[spGetClassroomCountBySubstituteStatus] 
	@ProgramFKs VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the classrooms and whether or not they are being served by a substitute
	SELECT CASE WHEN c.BeingServedSubstitute = 1 THEN 'Substitute' ELSE 'Regular Teacher(s)' END SubstituteStatus, COUNT(c.ClassroomPK) NumClassrooms
	FROM dbo.Classroom c
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	GROUP BY c.BeingServedSubstitute
END
GO

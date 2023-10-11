SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/01/2020
-- Description:	This stored procedure returns the necessary information for the
-- Other SE Screening report
-- =============================================
CREATE PROC [dbo].[rspOtherSEScreen]
	@OtherSEScreenPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the screening information
	SELECT oss.OtherSEScreenPK, oss.ScreenDate, oss.Score,
		   c.FirstName ChildFirstName, c.LastName ChildLastName, c.BirthDate,
		   cp.ProgramSpecificID ChildID,
		   scoreType.Description ScoreType,
		   screenType.Description ScreenType, screenType.Abbreviation ScreenTypeAbbr,
		   p.ProgramName
	FROM dbo.OtherSEScreen oss
	INNER JOIN dbo.Child c ON c.ChildPK = oss.ChildFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK AND cp.ProgramFK = oss.ProgramFK
	INNER JOIN dbo.CodeScoreType scoreType ON scoreType.CodeScoreTypePK = oss.ScoreTypeCodeFK
	INNER JOIN dbo.CodeScreenType screenType ON screenType.CodeScreenTypePK = oss.ScreenTypeCodeFK
	INNER JOIN dbo.Program p ON p.ProgramPK = oss.ProgramFK
	WHERE oss.OtherSEScreenPK = @OtherSEScreenPK

END
GO

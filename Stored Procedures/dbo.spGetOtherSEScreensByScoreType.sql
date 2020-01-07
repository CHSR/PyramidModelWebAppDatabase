SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/12/2019
-- Description:	This stored procedure returns the number of other SE screen
-- forms by the score type (above, expected, below)
-- =============================================
CREATE PROC [dbo].[spGetOtherSEScreensByScoreType] 
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the count of the ASQSEs in each score type
    SELECT cst.Description ScoreType, COUNT(oss.OtherSEScreenPK) NumOtherSEScreens 
	FROM dbo.OtherSEScreen oss 
	INNER JOIN dbo.CodeScoreType cst ON cst.CodeScoreTypePK = oss.ScoreTypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON oss.ProgramFK = ssti.ListItem
	WHERE oss.ScreenDate BETWEEN @StartDate AND @EndDate
	GROUP BY cst.Description
END
GO

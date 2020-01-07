SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/10/2019
-- Description:	This stored procedure returns the necessary information for the
-- Login History report
-- =============================================
CREATE PROC [dbo].[rspLoginHistory]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@ProgramFKs VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Get the login history
	SELECT lh.LoginHistoryPK, 
		   lh.LoginTime, 
		   lh.LogoutTime, 
		   lh.LogoutType, 
		   lh.[Role], 
		   lh.Username, 
		   lh.ProgramFK, 
           p.ProgramName
	FROM dbo.LoginHistory lh
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON lh.ProgramFK = programList.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = lh.ProgramFK
	WHERE lh.LoginTime >= @StartDate
		AND lh.LoginTime <= @EndDate
	ORDER BY lh.LoginTime DESC;

END
GO

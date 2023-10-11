SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/13/2020
-- Description:	This stored procedure returns the necessary information for the
-- red flags observed section of the TPOT report
-- =============================================
CREATE PROC [dbo].[rspTPOT_BehaviorResponses]
	@TPOTPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the observed behavior responses
	DECLARE @tblBehaviorResponses TABLE (
		TPOTBehaviorResponsesPK INT NOT NULL,
		TPOTPK INT NOT NULL,
		BehaviorResponseCodeFK INT NULL
	)

	--Get the observed behavior responses
	INSERT INTO @tblBehaviorResponses
	(
		TPOTBehaviorResponsesPK,
	    TPOTPK,
	    BehaviorResponseCodeFK
	)
	SELECT tbr.TPOTBehaviorResponsesPK, tbr.TPOTFK, tbr.BehaviorResponseCodeFK
	FROM dbo.TPOTBehaviorResponses tbr
	WHERE tbr.TPOTFK = @TPOTPK

	--Get all the behavior responses joined on the observed behavior responses
	SELECT ctbr.Description ChallengingBehavior, CAST(CASE WHEN tbr.TPOTBehaviorResponsesPK IS NOT NULL THEN 1 ELSE 0 END AS BIT) IsObserved
	FROM dbo.CodeTPOTBehaviorResponse ctbr
	LEFT JOIN @tblBehaviorResponses tbr ON tbr.BehaviorResponseCodeFK = ctbr.CodeTPOTBehaviorResponsePK
	ORDER BY ctbr.OrderBy ASC

END
GO

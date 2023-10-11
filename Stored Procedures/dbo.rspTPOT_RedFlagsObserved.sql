SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/13/2020
-- Description:	This stored procedure returns the necessary information for the
-- red flags observed section of the TPITOS report
-- =============================================
CREATE PROC [dbo].[rspTPOT_RedFlagsObserved]
	@TPOTPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the observed red flags
	DECLARE @tblRedFlagsObserved TABLE (
		TPOTRedFlagsPK INT NOT NULL,
		TPOTPK INT NOT NULL,
		RedFlagCodeFK INT NULL
	)

	--Get the observed red flags
	INSERT INTO @tblRedFlagsObserved
	(
		TPOTRedFlagsPK,
	    TPOTPK,
	    RedFlagCodeFK
	)
	SELECT trf.TPOTRedFlagsPK, trf.TPOTFK, trf.RedFlagCodeFK
	FROM dbo.TPOTRedFlags trf
	WHERE trf.TPOTFK = @TPOTPK

	--Get all the red flags joined on the observed red flags
	SELECT ctrf.Description RedFlagDescription, CAST(CASE WHEN trfo.TPOTRedFlagsPK IS NOT NULL THEN 1 ELSE 0 END AS BIT) IsObserved
	FROM dbo.CodeTPOTRedFlag ctrf
	LEFT JOIN @tblRedFlagsObserved trfo ON trfo.RedFlagCodeFK = ctrf.CodeTPOTRedFlagPK
	ORDER BY ctrf.OrderBy ASC

END
GO

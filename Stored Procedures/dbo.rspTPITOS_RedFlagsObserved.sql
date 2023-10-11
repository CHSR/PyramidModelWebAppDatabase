SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/12/2020
-- Description:	This stored procedure returns the necessary information for the
-- red flags observed section of the TPITOS report
-- =============================================
CREATE PROC [dbo].[rspTPITOS_RedFlagsObserved]
	@TPITOSPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--To hold the observed red flags
	DECLARE @tblRedFlagsObserved TABLE (
		TPITOSRedFlagsPK INT NOT NULL,
		TPITOSPK INT NOT NULL,
		RedFlagCodeFK INT NULL
	)

	--Get the observed red flags
	INSERT INTO @tblRedFlagsObserved
	(
		TPITOSRedFlagsPK,
	    TPITOSPK,
	    RedFlagCodeFK
	)
	SELECT trf.TPITOSRedFlagsPK, trf.TPITOSFK, trf.RedFlagCodeFK
	FROM dbo.TPITOSRedFlags trf
	WHERE trf.TPITOSFK = @TPITOSPK

	--Get all the red flags joined on the observed red flags
	SELECT ctrf.Description RedFlagDescription, CAST(CASE WHEN trfo.TPITOSRedFlagsPK IS NOT NULL THEN 1 ELSE 0 END AS BIT) IsObserved
	FROM dbo.CodeTPITOSRedFlag ctrf
	LEFT JOIN @tblRedFlagsObserved trfo ON trfo.RedFlagCodeFK = ctrf.CodeTPITOSRedFlagPK
	ORDER BY ctrf.OrderBy ASC

END
GO

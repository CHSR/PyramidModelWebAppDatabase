SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 03/02/2023
-- Description:	This stored procedure returns the necessary information for the
-- basic information section of the address report
-- =============================================
CREATE PROC [dbo].[rspProgramAddress_BasicInfo]
	@AddressPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the address information
	SELECT c.ProgramAddressPK, c.City, c.IsMailingAddress, c.State, c.Street, c.ZIPCode, c.Notes, c.LicenseNumber,
		   p.ProgramName
	FROM dbo.ProgramAddress c
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	WHERE c.ProgramAddressPK= @AddressPK

END
GO

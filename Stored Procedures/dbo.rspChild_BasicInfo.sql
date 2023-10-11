SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/06/2020
-- Description:	This stored procedure returns the necessary information for the
-- basic information section of the child report
-- =============================================
CREATE PROC [dbo].[rspChild_BasicInfo]
	@ChildProgramPK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the child information
	SELECT c.ChildPK, c.BirthDate, c.FirstName, c.LastName, c.EthnicitySpecify, c.GenderSpecify, c.RaceSpecify,
		   cp.ChildProgramPK, cp.ProgramSpecificID, cp.HasIEP, cp.IsDLL,
		   cp.HasParentPermission, cp.ParentPermissionDocumentFileName, cp.ParentPermissionDocumentFilePath,
		   cp.EnrollmentDate, cp.DischargeDate, cp.DischargeReasonSpecify,
		   ce.Description Ethnicity,
		   cg.Description Gender,
		   cr.Description Race,
		   p.ProgramName,
		   cdr.Description DischargeReason
	FROM dbo.Child c
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
	INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
	LEFT JOIN dbo.CodeDischargeReason cdr ON cdr.CodeDischargeReasonPK = cp.DischargeCodeFK
	WHERE cp.ChildProgramPK = @ChildProgramPK

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/16/2019
-- Description:	Example report stored procedure
-- =============================================
CREATE PROC [dbo].[rspExample]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get all the children
	SELECT c.ChildPK, '(' + cp.ProgramSpecificID + ') ' + c.FirstName + ' ' + c.LastName AS ChildName, 
	cp.IsDLL, cp.HasIEP, 
	cg.Description AS Gender,
	cr.Description AS Race,
	ce.Description AS Ethnicity,
	p.ProgramPK, p.ProgramName, p.Location
	FROM dbo.Child c
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
	INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
	WHERE cp.EnrollmentDate <= @EndDate AND
	(cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate)
	
END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/11/2020
-- Description:	This stored procedure returns the necessary information for the
-- Program Employee report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployee_BasicInfo] 
	@ProgramEmployeePK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the employee information
    SELECT pe.ProgramEmployeePK,
           e.AspireEmail,
           e.AspireID,
           e.AspireVerified,
           pe.Creator,
           pe.CreateDate,
           pe.Editor,
           pe.EditDate,
           e.EmailAddress,
           e.EthnicitySpecify,
           e.FirstName,
           e.GenderSpecify,
           pe.HireDate,
		   pe.IsEmployeeOfProgram,
           e.LastName,
           pe.ProgramSpecificID,
           e.RaceSpecify,
           pe.TermDate,
           pe.TermReasonSpecify,
           e.EthnicityCodeFK,
		   ce.Description EthnicityDescription,
           e.GenderCodeFK,
		   cg.Description GenderDescription,
           pe.ProgramFK,
           e.RaceCodeFK,
		   cr.Description RaceDescription,
           pe.TermReasonCodeFK,
           p.ProgramName,
           ctr.Description TermReason
    FROM dbo.ProgramEmployee pe
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = pe.ProgramFK
		INNER JOIN dbo.CodeEthnicity ce
			ON ce.CodeEthnicityPK = e.EthnicityCodeFK
		INNER JOIN dbo.CodeGender cg
			ON cg.CodeGenderPK = e.GenderCodeFK
		INNER JOIN dbo.CodeRace cr
			ON cr.CodeRacePK = e.RaceCodeFK
        LEFT JOIN dbo.CodeTermReason ctr
            ON ctr.CodeTermReasonPK = pe.TermReasonCodeFK
    WHERE pe.ProgramEmployeePK = @ProgramEmployeePK;

END;
GO

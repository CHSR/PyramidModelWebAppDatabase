SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- Employee section of the Employee Data Dump report
-- =============================================
CREATE PROC [dbo].[rspProgramEmployeeDataDump_Employees]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT pe.ProgramEmployeePK,
           e.AspireEmail,
           e.AspireID,
           e.AspireVerified,
           pe.Creator,
           pe.CreateDate,
           pe.Editor,
           pe.EditDate,
           e.EmailAddress,
           e.FirstName,
           pe.HireDate,
		   pe.IsEmployeeOfProgram,
           e.LastName,
           pe.ProgramSpecificID EmployeeIDNumber,
           pe.TermDate,
           e.EthnicityCodeFK,
		   ce.[Description] EthnicityText,
           e.EthnicitySpecify,
           e.GenderCodeFK,
		   cg.[Description] GenderText,
           e.GenderSpecify,
           e.RaceCodeFK,
		   cr.[Description] RaceText,
           e.RaceSpecify,
		   pe.TermReasonCodeFK,
		   ctr.[Description] TermReasonText,
           pe.TermReasonSpecify,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.ProgramEmployee pe
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeEthnicity ce
			ON ce.CodeEthnicityPK = e.EthnicityCodeFK
		INNER JOIN dbo.CodeGender cg
			ON cg.CodeGenderPK = e.GenderCodeFK
		INNER JOIN dbo.CodeRace cr
			ON cr.CodeRacePK = e.RaceCodeFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = pe.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
		LEFT JOIN dbo.CodeTermReason ctr
			ON ctr.CodeTermReasonPK = pe.TermReasonCodeFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = pe.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList
            ON hubList.ListItem = p.HubFK
        LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList
            ON cohortList.ListItem = p.CohortFK
        LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
    WHERE (
              programList.ListItem IS NOT NULL
              OR hubList.ListItem IS NOT NULL
              OR cohortList.ListItem IS NOT NULL
              OR stateList.ListItem IS NOT NULL
          ) --At least one of the options must be utilized 
		AND pe.HireDate <= @EndDate
		AND (pe.TermDate IS NULL OR pe.TermDate >= @StartDate);

END;
GO

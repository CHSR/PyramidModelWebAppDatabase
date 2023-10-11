SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/13/2022
-- Description:	This stored procedure returns the necessary information for the
-- child section of the Child Data Dump report
-- =============================================
CREATE PROC [dbo].[rspChildDataDump_Children]
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
    SELECT cp.ChildProgramPK,
           cp.Creator,
           cp.CreateDate,
           cp.Editor,
           cp.EditDate,
           cp.DischargeDate,
           cp.DischargeReasonSpecify,
		   cdr.[Description] DischargeReasonText,
           cp.EnrollmentDate,
           cp.HasIEP,
           cp.HasParentPermission,
           cp.IsDLL,
           cp.ProgramSpecificID ChildIDNumber,
           cp.ChildFK,
           cp.DischargeCodeFK,
           cp.ProgramFK,
		   c.ChildPK,
           c.BirthDate,
           c.FirstName,
           c.LastName,
           c.EthnicityCodeFK,
           c.EthnicitySpecify,
		   ce.[Description] EthnicityText,
           c.GenderCodeFK,
           c.GenderSpecify,
		   cg.[Description] GenderText,
           c.RaceCodeFK,
           c.RaceSpecify,
		   cr.[Description] RaceText,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.ChildProgram cp
		INNER JOIN dbo.Child c 
			ON c.ChildPK = cp.ChildFK
		INNER JOIN dbo.CodeEthnicity ce
			ON ce.CodeEthnicityPK = c.EthnicityCodeFK
		INNER JOIN dbo.CodeGender cg
			ON cg.CodeGenderPK = c.GenderCodeFK
		INNER JOIN dbo.CodeRace cr
			ON cr.CodeRacePK = c.RaceCodeFK
		INNER JOIN dbo.Program p 
			ON p.ProgramPK = cp.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.CodeDischargeReason cdr 
			ON cdr.CodeDischargeReasonPK = cp.DischargeCodeFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = cp.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
		AND cp.EnrollmentDate <= @EndDate
		AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate);

END;
GO

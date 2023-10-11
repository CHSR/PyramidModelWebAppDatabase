SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/03/2022
-- Description:	This stored procedure returns the necessary information for the
-- program type section of the program management data dump report
-- =============================================
CREATE PROC [dbo].[rspProgramManagementDataDump_ProgramTypes]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT pt.ProgramTypePK,
           pt.Creator,
           pt.CreateDate,
		   cpt.CodeProgramTypePK,
		   cpt.[Description] ProgramTypeDescription,
		   p.ProgramPK,
           p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.ProgramType pt
		INNER JOIN dbo.CodeProgramType cpt
			ON cpt.CodeProgramTypePK = pt.TypeCodeFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = pt.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
	WHERE p.ProgramStartDate <= @EndDate
		AND (p.ProgramEndDate IS NULL OR p.ProgramEndDate >= @StartDate);

END;
GO

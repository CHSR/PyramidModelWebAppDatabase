SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 11/17/2022
-- Description:	This stored procedure returns the necessary information for the
-- program status section of the program management data dump report
-- =============================================
CREATE PROC [dbo].[rspProgramManagementDataDump_ProgramStatuses]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT ps.ProgramStatusPK,
		   ps.ProgramFK,
		   ps.Creator,
		   ps.CreateDate,
		   ps.Editor,
		   ps.EditDate,
		   ps.StatusDate,
		   ps.StatusDetails,
		   cpt.CodeProgramStatusPK,
		   cpt.Description ProgramStatusDescription,
		   p.ProgramPK,
           p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
    FROM dbo.ProgramStatus ps
		INNER JOIN dbo.CodeProgramStatus cpt
			ON cpt.CodeProgramStatusPK = ps.StatusFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = ps.ProgramFK
		INNER JOIN dbo.State s
			ON s.StatePK = p.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = p.StateFK
	WHERE p.ProgramStartDate <= @EndDate
		AND (p.ProgramEndDate IS NULL OR p.ProgramEndDate >= @StartDate);

END;
GO

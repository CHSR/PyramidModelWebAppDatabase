SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu	
-- Create date: 08/30/2022
-- Description:	This stored procedure returns the necessary information for the
-- OSES Data Dump report
-- =============================================
CREATE PROC [dbo].[rspOSESDataDump]
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
    SELECT oses.OtherSEScreenPK,
           oses.ScreenDate,
           oses.Score,
           oses.Creator,
           oses.CreateDate,
           oses.Editor,
           oses.EditDate,
           oses.ChildFK,
           oses.ProgramFK,
           oses.ScoreTypeCodeFK,
           oses.ScreenTypeCodeFK,
           st.[Description] ScoreTypeDescription,
           sct.[Description] ScreenTypeDescription,
           p.ProgramPK,
           p.ProgramName,
           s.StatePK,
           s.[Name] StateName,
           cp.ChildProgramPK,
           cp.ProgramSpecificID ChildIDNumber,
           c.FirstName ChildFirstName,
           c.LastName ChildLastName
    FROM dbo.OtherSEScreen oses
        INNER JOIN dbo.CodeScoreType st
            ON st.CodeScoreTypePK = oses.ScoreTypeCodeFK
        INNER JOIN dbo.CodeScreenType sct
            ON sct.CodeScreenTypePK = oses.ScreenTypeCodeFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = oses.ProgramFK
        INNER JOIN dbo.Child c
            ON c.ChildPK = oses.ChildFK
        INNER JOIN dbo.ChildProgram cp
            ON cp.ChildFK = c.ChildPK
               AND cp.ProgramFK = oses.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = oses.ProgramFK
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
		AND oses.ScreenDate BETWEEN @StartDate AND @EndDate;

END;
GO

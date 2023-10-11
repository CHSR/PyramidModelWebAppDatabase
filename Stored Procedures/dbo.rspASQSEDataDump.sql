SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/29/2022
-- Description:	This stored procedure returns the necessary information for the
-- ASQSE Data Dump report
-- =============================================
CREATE PROC [dbo].[rspASQSEDataDump]
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
    SELECT a.ASQSEPK,
		   a.Creator,
           a.CreateDate,
           a.Editor,
           a.EditDate,
           a.FormDate,
           a.HasDemographicInfoSheet,
           a.HasPhysicianInfoLetter,
           a.TotalScore,
           a.ChildFK,
           a.IntervalCodeFK,
           a.ProgramFK,
           a.[Version],
           sa.CutoffScore,
           sa.MaxScore,
           sa.MonitoringScoreStart,
           sa.MonitoringScoreEnd,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName,
		   cai.[Description] IntervalDescription,
		   cai.IntervalMonth,
		   cp.ChildProgramPK,
		   cp.ProgramSpecificID ChildIDNumber,
		   c.FirstName ChildFirstName,
		   c.LastName ChildLastName
    FROM dbo.ASQSE a
        INNER JOIN dbo.ScoreASQSE sa
            ON sa.IntervalCodeFK = a.IntervalCodeFK
               AND sa.[Version] = a.[Version]
        INNER JOIN dbo.Program p
            ON p.ProgramPK = a.ProgramFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = p.StateFK
        INNER JOIN dbo.CodeASQSEInterval cai
            ON cai.CodeASQSEIntervalPK = a.IntervalCodeFK
        INNER JOIN dbo.Child c
            ON c.ChildPK = a.ChildFK
        INNER JOIN dbo.ChildProgram cp
            ON cp.ChildFK = c.ChildPK
               AND cp.ProgramFK = a.ProgramFK
        LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON programList.ListItem = a.ProgramFK
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
          AND a.FormDate BETWEEN @StartDate AND @EndDate;

END;
GO

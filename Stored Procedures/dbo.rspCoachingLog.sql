SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/08/2020
-- Description:	This stored procedure returns the necessary information for the
-- classroom coaching log form printing report
-- =============================================
CREATE PROC [dbo].[rspCoachingLog] 
	@CoachingLogPK INT = NULL,
	@ViewPrivateEmployeeInfo BIT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DECLARE @tblCoachees TABLE (
		CoachingLogFK INT NOT NULL,
		CoacheeNames VARCHAR(8000) NULL
	)

	INSERT INTO @tblCoachees
	(
	    CoachingLogFK,
	    CoacheeNames
	)
	SELECT clc.CoachingLogFK, 
		   STRING_AGG(CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('(', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) ELSE pe.ProgramSpecificID END, ', ') CoacheeNames
	FROM dbo.CoachingLogCoachees clc
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.ProgramEmployeePK = clc.CoacheeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
	WHERE clc.CoachingLogFK = @CoachingLogPK
	GROUP BY clc.CoachingLogFK
	
    --Get the coaching log information
    SELECT cl.CoachingLogPK,
           cl.LogDate,
           cl.DurationMinutes,
           cl.FUEmail,
           cl.FUInPerson,
           cl.FUNone,
           cl.FUPhone,
           cl.MEETDemonstration,
           cl.MEETEnvironment,
           cl.MEETGoalSetting,
           cl.MEETGraphic,
           cl.MEETMaterial,
           cl.MEETOther,
           cl.MEETOtherSpecify,
           cl.MEETPerformance,
           cl.MEETProblemSolving,
           cl.MEETReflectiveConversation,
           cl.MEETRoleplay,
           cl.MEETVideo,
		   cl.Narrative,
           cl.OBSConductTPITOS,
           cl.OBSConductTPOT,
           cl.OBSEnvironment,
           cl.OBSModeling,
           cl.OBSObserving,
           cl.OBSOther,
           cl.OBSOtherHelp,
           cl.OBSOtherSpecify,
           cl.OBSProblemSolving,
           cl.OBSReflectiveConversation,
           cl.OBSSideBySide,
           cl.OBSVerbalSupport,
		   coach.ProgramSpecificID CoachID,
           e.FirstName CoachFirstName,
           e.LastName CoachLastName,
           p.ProgramName,
		   tc.CoacheeNames
    FROM dbo.CoachingLog cl
        INNER JOIN dbo.ProgramEmployee coach
            ON coach.ProgramEmployeePK = cl.CoachFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = coach.EmployeeFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = cl.ProgramFK
		LEFT JOIN @tblCoachees tc
			ON tc.CoachingLogFK = cl.CoachingLogPK
    WHERE cl.CoachingLogPK = @CoachingLogPK;

END;
GO

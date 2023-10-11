SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/13/2022
-- Description:	This stored procedure returns the necessary information for the
-- child classroom assignment section of the Child Data Dump report
-- =============================================
CREATE PROC [dbo].[rspChildDataDump_Classrooms]
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
    SELECT cc.ChildClassroomPK,
           cc.AssignDate,
           cc.Creator,
           cc.CreateDate,
           cc.Editor,
           cc.EditDate,
           cc.LeaveDate,
		   cclr.Description LeaveReasonText,
           cc.LeaveReasonSpecify,
		   class.ClassroomPK,
		   class.ProgramSpecificID ClassroomID,
		   class.[Name] ClassroomName,
		   cp.ChildProgramPK,
		   cp.ProgramSpecificID ChildIDNumber,
		   c.FirstName ChildFirstName,
		   c.LastName ChildLastName,
		   p.ProgramPK,
		   p.ProgramName,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.ChildClassroom cc
		INNER JOIN dbo.Classroom class
			ON class.ClassroomPK = cc.ClassroomFK
		INNER JOIN dbo.ChildProgram cp
			ON cp.ChildFK = cc.ChildFK
				AND cp.ProgramFK = class.ProgramFK
		INNER JOIN dbo.Child c 
			ON c.ChildPK = cp.ChildFK
		INNER JOIN dbo.Program p 
			ON p.ProgramPK = cp.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.CodeChildLeaveReason cclr
			ON cclr.CodeChildLeaveReasonPK = cc.LeaveReasonCodeFK
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

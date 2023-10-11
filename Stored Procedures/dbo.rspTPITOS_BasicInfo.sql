SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/11/2020
-- Description:	This stored procedure returns the necessary information for the
-- basic info, subscale 1, and subscale 2 sections of the TPITOS report
-- =============================================
CREATE PROC [dbo].[rspTPITOS_BasicInfo] 
	@TPITOSPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the TPITOS information
    SELECT t.TPITOSPK,
           t.ClassroomRedFlagsNumPossible,
           t.ClassroomRedFlagsNumYes,
           t.IsComplete,
           t.Item1NumNo,
           t.Item1NumYes,
           t.Item2NumNo,
           t.Item2NumYes,
           t.Item3NumNo,
           t.Item3NumYes,
           t.Item4NumNo,
           t.Item4NumYes,
           t.Item5NumNo,
           t.Item5NumYes,
           t.Item6NumNo,
           t.Item6NumYes,
           t.Item7NumNo,
           t.Item7NumYes,
           t.Item8NumNo,
           t.Item8NumYes,
           t.Item9NumNo,
           t.Item9NumYes,
           t.Item10NumNo,
           t.Item10NumYes,
           t.Item11NumNo,
           t.Item11NumYes,
           t.Item12NumNo,
           t.Item12NumYes,
           t.Item13NumNo,
           t.Item13NumYes,
           t.LeadTeacherRedFlagsNumYes,
           t.LeadTeacherRedFlagsNumPossible,
           t.Notes,
           t.NumAdultsBegin,
           t.NumAdultsEnd,
           t.NumAdultsEntered,
           t.NumKidsBegin,
           t.NumKidsEnd,
           t.ObservationEndDateTime,
           t.ObservationStartDateTime,
           t.OtherTeacherRedFlagsNumYes,
           t.OtherTeacherRedFlagsNumPossible,
           c.ProgramSpecificID ClassroomID,
           c.[Name] ClassroomName,
		   observer.ProgramSpecificID ObserverID,
           e.FirstName ObserverFirstName,
           e.LastName ObserverLastName,
           p.ProgramName
    FROM dbo.TPITOS t
        INNER JOIN dbo.Classroom c
            ON c.ClassroomPK = t.ClassroomFK
        INNER JOIN dbo.ProgramEmployee observer
            ON observer.ProgramEmployeePK = t.ObserverFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = observer.EmployeeFK
        INNER JOIN dbo.Program p
            ON p.ProgramPK = c.ProgramFK
    WHERE t.TPITOSPK = @TPITOSPK;

END;
GO

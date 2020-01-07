SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/19/2019
-- Description:	This stored procedure returns all the items in the database
-- that have dates that are before the enrollment date or after the discharge
-- date for this child, depending on which date is sent to this stored procedure
-- =============================================
CREATE PROC [dbo].[spValidateEnrollmentDischargeDates] 
	@ChildPK INT = NULL,
	@ProgramFK INT = NULL,
	@EnrollmentDate DATETIME = NULL,
	@DischargeDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		ChildPK INT NULL,
		ObjectName VARCHAR(500) NULL,
		ObjectDate DATETIME NULL,
		ProgramFK INT NULL
	)

	--================= ChildStatus =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT cs.ChildFK, 'Status', cs.StatusDate, cs.ProgramFK 
	FROM dbo.ChildStatus cs
	WHERE cs.ChildFK = @ChildPK AND cs.ProgramFK = @ProgramFK
	AND (cs.StatusDate > ISNULL(@DischargeDate, cs.StatusDate)
	OR cs.StatusDate < ISNULL(@EnrollmentDate, cs.StatusDate))
	
	--================= ChildNote =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT cn.ChildFK, 'Note', cn.NoteDate, cn.ProgramFK 
	FROM dbo.ChildNote cn
	WHERE cn.ChildFK = @ChildPK AND cn.ProgramFK = @ProgramFK
	AND (cn.NoteDate > ISNULL(@DischargeDate, cn.NoteDate)
	OR cn.NoteDate < ISNULL(@EnrollmentDate, cn.NoteDate))
	
	--================= ClassroomAssignment =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT cc.ChildFK, 'Classroom Assignment - ' + c.ProgramSpecificID, cc.AssignDate, c.ProgramFK 
	FROM dbo.ChildClassroom cc
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = cc.ClassroomFK
	WHERE cc.ChildFK = @ChildPK AND c.ProgramFK = @ProgramFK
	AND ((cc.AssignDate > ISNULL(@DischargeDate, cc.AssignDate) OR cc.LeaveDate > ISNULL(@DischargeDate, cc.LeaveDate))
	OR (cc.AssignDate < ISNULL(@EnrollmentDate, cc.AssignDate) OR cc.LeaveDate < ISNULL(@EnrollmentDate, cc.LeaveDate)))
	
	--================= BehaviorIncident =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT bi.ChildFK, 'Behavior Incident', bi.IncidentDatetime, c.ProgramFK 
	FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = bi.ClassroomFK
	WHERE bi.ChildFK = @ChildPK AND c.ProgramFK = @ProgramFK
	AND (bi.IncidentDatetime > ISNULL(@DischargeDate, bi.IncidentDatetime)
	OR bi.IncidentDatetime < ISNULL(@EnrollmentDate, bi.IncidentDatetime))
	
	--================= ASQSE =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT a.ChildFK, 'ASQSE', a.FormDate, a.ProgramFK 
	FROM dbo.ASQSE a
	WHERE a.ChildFK = @ChildPK AND a.ProgramFK = @ProgramFK
	AND (a.FormDate > ISNULL(@DischargeDate, a.FormDate)
	OR a.FormDate < ISNULL(@EnrollmentDate, a.FormDate))
	
	--================= OtherSEScreen =====================
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT oss.ChildFK, 'Other SE Screen', oss.ScreenDate, oss.ProgramFK 
	FROM dbo.OtherSEScreen oss
	WHERE oss.ChildFK = @ChildPK AND oss.ProgramFK = @ProgramFK
	AND (oss.ScreenDate > ISNULL(@DischargeDate, oss.ScreenDate)
	OR oss.ScreenDate < ISNULL(@EnrollmentDate, oss.ScreenDate))

	SELECT * FROM @tblFinalSelect tfs ORDER BY tfs.ObjectDate ASC

END
GO

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
CREATE PROC [dbo].[spValidateHireTermDates] 
	@ProgramEmployeePK INT = NULL,
	@ProgramFK INT = NULL,
	@HireDate DATETIME = NULL,
	@TermDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		ProgramEmployeePK INT NULL,
		ObjectName VARCHAR(500) NULL,
		ObjectDate DATETIME NULL,
		ProgramFK INT NULL
	)

	--================= EmployeeClassroom =====================
	INSERT INTO @tblFinalSelect
	(
	    ProgramEmployeePK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT ec.ProgramEmployeeFK, 'Classroom Assignment - ' + c.ProgramSpecificID, ec.AssignDate, c.ProgramFK 
	FROM dbo.EmployeeClassroom ec
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = ec.ClassroomFK
	WHERE ec.ProgramEmployeeFK = @ProgramEmployeePK AND c.ProgramFK = @ProgramFK
	AND ((ec.AssignDate > ISNULL(@TermDate, ec.AssignDate) OR ec.LeaveDate > ISNULL(@TermDate, ec.LeaveDate))
	OR (ec.AssignDate < ISNULL(@HireDate, ec.AssignDate) OR ec.LeaveDate < ISNULL(@HireDate, ec.LeaveDate)))


	--================= JobFunction =====================
	INSERT INTO @tblFinalSelect
	(
	    ProgramEmployeePK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT jf.ProgramEmployeeFK, 'Job Function - ' + cjt.Description, jf.StartDate, @ProgramFK 
	FROM dbo.JobFunction jf
	INNER JOIN dbo.CodeJobType cjt ON cjt.CodeJobTypePK = jf.JobTypeCodeFK
	WHERE jf.ProgramEmployeeFK = @ProgramEmployeePK
	AND ((jf.StartDate > ISNULL(@TermDate, jf.StartDate) OR jf.EndDate > ISNULL(@TermDate, jf.EndDate))
	OR (jf.StartDate < ISNULL(@HireDate, jf.StartDate) OR jf.EndDate < ISNULL(@HireDate, jf.EndDate)))

	
	--================= CoachingLog =====================
	INSERT INTO @tblFinalSelect
	(
	    ProgramEmployeePK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT DISTINCT @ProgramEmployeePK, 'Coaching Log', cl.LogDate, @ProgramFK 
	FROM dbo.CoachingLog cl
		LEFT JOIN dbo.CoachingLogCoachees clc
			ON clc.CoachingLogFK = cl.CoachingLogPK
	WHERE (clc.CoacheeFK = @ProgramEmployeePK OR cl.CoachFK = @ProgramEmployeePK)
	AND cl.ProgramFK = @ProgramFK
	AND (cl.LogDate > ISNULL(@TermDate, cl.LogDate)
	OR cl.LogDate < ISNULL(@HireDate, cl.LogDate))


	--================= TPOT =====================
	INSERT INTO @tblFinalSelect
	(
	    ProgramEmployeePK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT @ProgramEmployeePK, 'TPOT', t2.ObservationStartDateTime, @ProgramFK 
	FROM dbo.TPOTParticipant tp
	INNER JOIN dbo.TPOT t2 ON t2.TPOTPK = tp.TPOTFK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t2.ClassroomFK
	WHERE tp.ProgramEmployeeFK = @ProgramEmployeePK
	AND c.ProgramFK = @ProgramFK
	AND (t2.ObservationStartDateTime > ISNULL(@TermDate, t2.ObservationStartDateTime)
	OR t2.ObservationStartDateTime < ISNULL(@HireDate, t2.ObservationStartDateTime))

	
	--================= TPITOS =====================
	INSERT INTO @tblFinalSelect
	(
	    ProgramEmployeePK,
	    ObjectName,
	    ObjectDate,
	    ProgramFK
	)
	SELECT @ProgramEmployeePK, 'TPITOS', t2.ObservationStartDateTime, @ProgramFK 
	FROM dbo.TPITOSParticipant tp
	INNER JOIN dbo.TPITOS t2 ON t2.TPITOSPK = tp.TPITOSFK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t2.ClassroomFK
	WHERE tp.ProgramEmployeeFK = @ProgramEmployeePK
	AND c.ProgramFK = @ProgramFK
	AND (t2.ObservationStartDateTime > ISNULL(@TermDate, t2.ObservationStartDateTime)
	OR t2.ObservationStartDateTime < ISNULL(@HireDate, t2.ObservationStartDateTime))

	SELECT * FROM @tblFinalSelect tfs ORDER BY tfs.ObjectDate ASC

END
GO

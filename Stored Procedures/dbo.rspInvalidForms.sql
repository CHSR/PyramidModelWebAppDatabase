SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/11/2019
-- Description:	This stored procedure returns all the objects in the
-- database for specific programs that are invalid
-- =============================================
CREATE PROC [dbo].[rspInvalidForms]
	@ViewPrivateChildInfo BIT = NULL,
	@ViewPrivateEmployeeInfo BIT = NULL,
	@ProgramFKs VARCHAR(8000) = NULL,
	@HubFKs VARCHAR(8000) = NULL,
	@CohortFKs VARCHAR(8000) = NULL,
	@StateFKs VARCHAR(8000) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		ObjectPK INT NOT NULL,
		ObjectAbbrevation VARCHAR(10) NOT NULL,
		ObjectName VARCHAR(500) NOT NULL,
		ObjectDate DATETIME NULL,
		InvalidProgramEmployeePK INT NULL,
		InvalidReason VARCHAR(MAX) NOT NULL,
		InvalidExplanation VARCHAR(MAX) NOT NULL,
		ProgramFK INT NOT NULL,
		ProgramName VARCHAR(400) NOT NULL
	)
	
	--================= BIRs with Invalid Classroom Assignments =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT bi.BehaviorIncidentPK, 'BIR', 'Behavior Incident Report', bi.IncidentDatetime, NULL,
			CASE WHEN @ViewPrivateChildInfo = 1 THEN CONCAT('Invalid BIR for child: (', cp.ProgramSpecificID, ') ', child.FirstName, ' ', child.LastName, '')
				ELSE CONCAT('Invalid BIR for child: ', cp.ProgramSpecificID) END AS Reason,
			'As of the form date, the child selected on this BIR is no longer assigned to the classroom selected on this BIR.',
			classroom.ProgramFK, p.ProgramName
	FROM dbo.BehaviorIncident bi
	INNER JOIN dbo.Classroom classroom ON classroom.ClassroomPK = bi.ClassroomFK
	INNER JOIN dbo.Program p ON p.ProgramPK = classroom.ProgramFK
	INNER JOIN dbo.Child child ON child.ChildPK = bi.ChildFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = child.ChildPK AND cp.ProgramFK = classroom.ProgramFK
	LEFT JOIN dbo.ChildClassroom cc ON cc.ChildFK = child.ChildPK 
			AND cc.ClassroomFK = classroom.ClassroomPK
			AND cc.AssignDate <= bi.IncidentDatetime AND (cc.LeaveDate IS NULL OR cc.LeaveDate >= bi.IncidentDatetime)
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = classroom.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	cc.ChildClassroomPK IS NULL
	
	--================= Coaching Log Coaches =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT cl.CoachingLogPK, 'CCL', 'Coaching Log', cl.LogDate, pe.ProgramEmployeePK, 
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid coach: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid coach: ', pe.ProgramSpecificID) END AS Reason,
			CASE WHEN t.TrainingPK IS NULL AND p.StateFK = 1 THEN 'The professional is missing their coaching training or the training date is after the form date.  Please contact a CCF PIDS administrator and ask them to enter the necessary training information.'
				WHEN t.TrainingPK IS NULL THEN 'The professional is missing their coaching training or the training date is after the form date.  Please contact a PIDS administrator and ask them to enter the necessary training information.'
				ELSE '' END AS Explanation, 
			cl.ProgramFK, p.ProgramName
	FROM dbo.CoachingLog cl
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = cl.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = cl.CoachFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	LEFT JOIN dbo.Training t ON t.EmployeeFK = e.EmployeePK
		AND t.TrainingCodeFK IN (1, 2, 16)
		AND t.TrainingDate <= cl.LogDate
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = cl.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(pe.HireDate > cl.LogDate
	OR ISNULL(pe.TermDate, GETDATE()) < cl.LogDate
	OR t.TrainingPK IS NULL)
	ORDER BY cl.LogDate DESC

	--================= Coaching Log Coachees =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT c.CoachingLogPK, 'CCL', 'Coaching Log', c.LogDate, coachee.ProgramEmployeePK,
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid coachee: (', coachee.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid coachee: ', coachee.ProgramSpecificID) END AS Reason,
			'The coachee is either not active as of the form date, or does not have an active teacher or teaching assistant job function as of the form date.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.CoachingLogCoachees cl
	INNER JOIN dbo.CoachingLog c 
		ON c.CoachingLogPK = cl.CoachingLogFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee coachee 
		ON coachee.ProgramEmployeePK = cl.CoacheeFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = coachee.EmployeeFK
	LEFT JOIN dbo.JobFunction jf 
		ON jf.ProgramEmployeeFK = coachee.ProgramEmployeePK 
			AND jf.JobTypeCodeFK IN (1, 2) --Teacher and teaching assistant
			AND jf.StartDate <= c.LogDate
			AND ISNULL(jf.EndDate, c.LogDate) >= c.LogDate
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(coachee.HireDate > c.LogDate
		OR ISNULL(coachee.TermDate, GETDATE()) < c.LogDate
		OR jf.JobFunctionPK IS NULL)
	ORDER BY c.LogDate DESC
	
	--================= Employee Classroom Assignments =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT pe.ProgramEmployeePK, 'PE', 'Professional', ec.AssignDate, pe.ProgramEmployeePK,
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid professional classroom assignment for: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid professional classroom assignment for: ', pe.ProgramSpecificID) END AS Reason,
			CONCAT('Professional is assigned to classroom (', c.ProgramSpecificID, ') ', c.Name, ' with a classroom job of ' + cjt.Description, '.',
			' However, the professional does not have an active ', cjt.Description, ' job function as of the classroom assign date of ', FORMAT(ec.AssignDate, 'MM/dd/yyyy'), '.'), 
			pe.ProgramFK, p.ProgramName
	FROM dbo.EmployeeClassroom ec
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = ec.ProgramEmployeeFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	INNER JOIN dbo.Classroom c 
		ON c.ClassroomPK = ec.ClassroomFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = pe.ProgramFK
	INNER JOIN dbo.CodeJobType cjt 
		ON cjt.CodeJobTypePK = ec.JobTypeCodeFK
	LEFT JOIN dbo.JobFunction jf 
		ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
			AND jf.JobTypeCodeFK = ec.JobTypeCodeFK
			AND jf.StartDate <= ec.AssignDate
			AND ISNULL(jf.EndDate, ec.AssignDate) >= ec.AssignDate
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = pe.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	jf.JobFunctionPK IS NULL
	ORDER BY ec.AssignDate DESC

	--================= TPOT Participants =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t2.TPOTPK, 'TPOT', 'TPOT', t2.ObservationStartDateTime, pe.ProgramEmployeePK,
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid participant: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid participant: ', pe.ProgramSpecificID) END AS Reason,
			'The professional does not have an active teacher or teaching assistant job function as of the form date.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOTParticipant tp
	INNER JOIN dbo.TPOT t2 
		ON t2.TPOTPK = tp.TPOTFK
	INNER JOIN dbo.Classroom c 
		ON c.ClassroomPK = t2.ClassroomFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
		AND jf.StartDate <= t2.ObservationStartDateTime
		AND ISNULL(jf.EndDate, t2.ObservationStartDateTime) >= t2.ObservationStartDateTime
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(pe.HireDate > t2.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t2.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL)
	ORDER BY t2.ObservationStartDateTime DESC


	--================= TPOT Observer =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPOTPK, 'TPOT', 'TPOT', t.ObservationStartDateTime, pe.ProgramEmployeePK,
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid observer: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid observer: ', pe.ProgramSpecificID) END AS Reason,
			CASE WHEN t2.TrainingPK IS NULL AND p.StateFK = 1 THEN 'The professional is missing their observer training, the training date is after the form date, or the training has expired as of the form date.  Please contact a CCF PIDS administrator and ask them to enter the necessary training information.'
				WHEN t2.TrainingPK IS NULL THEN 'The professional is missing their observer training, the training date is after the form date, or the training has expired as of the form date.  Please contact a PIDS administrator and ask them to enter the necessary training information.'
				ELSE '' END AS Explanation, 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOT t
	INNER JOIN dbo.Classroom c 
		ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = t.ObserverFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	LEFT JOIN dbo.Training t2 
		ON t2.EmployeeFK = e.EmployeePK
			AND t2.TrainingCodeFK = 3
			AND t2.TrainingDate <= t.ObservationStartDateTime
			AND (t2.ExpirationDate IS NULL OR t2.ExpirationDate >= t.ObservationStartDateTime)
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(pe.HireDate > t.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t.ObservationStartDateTime
	OR t2.TrainingPK IS NULL)
	ORDER BY t.ObservationStartDateTime DESC

	--================= Incomplete TPOT =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPOTPK, 'TPOT', 'TPOT', t.ObservationStartDateTime, NULL, CONCAT('Incomplete form for classroom: (', c.ProgramSpecificID, ') ', c.Name), 
			'The form is incomplete, please edit it and fix any validation errors.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOT t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	LEFT JOIN dbo.TPOTParticipant tp ON tp.TPOTFK = t.TPOTPK
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(t.IsComplete <> 1 OR 
	tp.TPOTParticipantPK IS NULL)
	ORDER BY t.ObservationStartDateTime DESC

	--================= TPITOS Participants =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t2.TPITOSPK, 'TPITOS', 'TPITOS', t2.ObservationStartDateTime, pe.ProgramEmployeePK, 
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid participant: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid participant: ', pe.ProgramSpecificID) END AS Reason,
			'The professional does not have an active teacher or teaching assistant job function as of the form date.', c.ProgramFK, p.ProgramName
	FROM dbo.TPITOSParticipant tp
	INNER JOIN dbo.TPITOS t2 
		ON t2.TPITOSPK = tp.TPITOSFK
	INNER JOIN dbo.Classroom c 
		ON c.ClassroomPK = t2.ClassroomFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	LEFT JOIN dbo.JobFunction jf 
		ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
			AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
			AND jf.StartDate <= t2.ObservationStartDateTime
			AND ISNULL(jf.EndDate, t2.ObservationStartDateTime) >= t2.ObservationStartDateTime
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(pe.HireDate > t2.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t2.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL)
	ORDER BY t2.ObservationStartDateTime DESC


	--================= TPITOS Observer =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPITOSPK, 'TPITOS', 'TPITOS', t.ObservationStartDateTime, pe.ProgramEmployeePK,
			CASE WHEN @ViewPrivateEmployeeInfo = 1 THEN CONCAT('Invalid observer: (', pe.ProgramSpecificID, ') ', e.FirstName, ' ', e.LastName) 
				ELSE CONCAT('Invalid observer: ', pe.ProgramSpecificID) END AS Reason,
			CASE WHEN t2.TrainingPK IS NULL AND p.StateFK = 1 THEN 'The professional is missing their observer training, the training date is after the form date, or the training has expired as of the form date.  Please contact a CCF PIDS administrator and ask them to enter the necessary training information.'
				WHEN t2.TrainingPK IS NULL THEN 'The professional is missing their observer training, the training date is after the form date, or the training has expired as of the form date.  Please contact a PIDS administrator and ask them to enter the necessary training information.'
				ELSE '' END AS Explanation, 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c 
		ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.Program p 
		ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe 
		ON pe.ProgramEmployeePK = t.ObserverFK
	INNER JOIN dbo.Employee e
		ON e.EmployeePK = pe.EmployeeFK
	LEFT JOIN dbo.Training t2 
		ON t2.EmployeeFK = e.EmployeePK
			AND t2.TrainingCodeFK = 4
			AND t2.TrainingDate <= t.ObservationStartDateTime
			AND (t2.ExpirationDate IS NULL OR t2.ExpirationDate >= t.ObservationStartDateTime)
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(pe.HireDate > t.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t.ObservationStartDateTime
	OR t2.TrainingPK IS NULL)
	ORDER BY t.ObservationStartDateTime DESC

	--================= Incomplete TPITOS =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
		ObjectAbbrevation,
	    ObjectName,
	    ObjectDate,
		InvalidProgramEmployeePK,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPITOSPK, 'TPITOS', 'TPITOS', t.ObservationStartDateTime, NULL, CONCAT('Incomplete form for classroom: (', c.ProgramSpecificID, ') ', c.Name), 
			'The form is incomplete, please edit it and fix any validation errors.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	LEFT JOIN dbo.TPITOSParticipant tp ON tp.TPITOSFK = t.TPITOSPK
	LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
		ON programList.ListItem = c.ProgramFK
	LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
		ON hubList.ListItem = p.HubFK
	LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
		ON cohortList.ListItem = p.CohortFK
	LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
		ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized
	(t.IsComplete <> 1 OR 
	tp.TPITOSParticipantPK IS NULL)
	ORDER BY t.ObservationStartDateTime DESC

	SELECT * 
	FROM @tblFinalSelect tfs 
	ORDER BY tfs.ObjectDate DESC
END
GO

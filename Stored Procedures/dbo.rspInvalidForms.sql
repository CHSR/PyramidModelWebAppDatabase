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
	@ProgramFKs VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		ObjectPK INT NULL,
		ObjectName VARCHAR(500) NULL,
		ObjectDate DATETIME NULL,
		InvalidReason VARCHAR(MAX) NULL,
		InvalidExplanation VARCHAR(MAX) NULL,
		ProgramFK INT NULL,
		ProgramName VARCHAR(400) NULL
	)
	
	--================= Coaching Log Coaches =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT cl.CoachingLogPK, 'Coaching Log', cl.LogDate, CONCAT('Invalid coach - ', pe.FirstName, ' ', pe.LastName), 
			CASE WHEN t.TrainingPK IS NULL THEN 'The coach is missing their coaching training or the training date is after the form date.'
				WHEN jf.JobFunctionPK IS NULL THEN 'The participant does not have an active classroom coach job function as of the form date.' ELSE '' END AS Explanation, 
			cl.ProgramFK, p.ProgramName
	FROM dbo.CoachingLog cl
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cl.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = cl.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = cl.CoachFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND jf.JobTypeCodeFK = 4
		AND jf.StartDate <= cl.LogDate
		AND ISNULL(jf.EndDate, cl.LogDate) >= cl.LogDate
	LEFT JOIN dbo.Training t ON t.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND (t.TrainingCodeFK = 1 OR t.TrainingCodeFK = 2)
		AND t.TrainingDate <= cl.LogDate
	WHERE pe.HireDate > cl.LogDate
	OR ISNULL(pe.TermDate, GETDATE()) < cl.LogDate
	OR jf.JobFunctionPK IS NULL
	OR t.TrainingPK IS NULL
	ORDER BY cl.LogDate DESC

	--================= Coaching Log Teachers =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT cl.CoachingLogPK, 'Coaching Log', cl.LogDate, CONCAT('Invalid teacher - ', pe.FirstName, ' ', pe.LastName),
			'The teacher does not have an active teacher job function as of the form date.', 
			cl.ProgramFK, p.ProgramName
	FROM dbo.CoachingLog cl
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cl.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = cl.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = cl.CoachFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND jf.JobTypeCodeFK = 1
		AND jf.StartDate <= cl.LogDate
		AND ISNULL(jf.EndDate, cl.LogDate) >= cl.LogDate
	WHERE pe.HireDate > cl.LogDate
	OR ISNULL(pe.TermDate, GETDATE()) < cl.LogDate
	OR jf.JobFunctionPK IS NULL
	ORDER BY cl.LogDate DESC


	--================= TPOT Participants =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t2.TPOTPK, 'TPOT', t2.ObservationStartDateTime, CONCAT('Invalid participant - ', pe.FirstName, ' ', pe.LastName), 
			'The participant does not have an active teacher or teaching assistant job function as of the form date.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOTParticipant tp
	INNER JOIN dbo.TPOT t2 ON t2.TPOTPK = tp.TPOTFK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t2.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
		AND jf.StartDate <= t2.ObservationStartDateTime
		AND ISNULL(jf.EndDate, t2.ObservationStartDateTime) >= t2.ObservationStartDateTime
	WHERE pe.HireDate > t2.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t2.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL
	ORDER BY t2.ObservationStartDateTime DESC


	--================= TPOT Observer =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPOTPK, 'TPOT', t.ObservationStartDateTime, CONCAT('Invalid observer - ', pe.FirstName, ' ', pe.LastName), 
			CASE WHEN t2.TrainingPK IS NULL THEN 'The observer is missing their observer training or the training date is after the form date.'
				WHEN jf.JobFunctionPK IS NULL THEN 'The participant does not have an active TPOT observer job function as of the form date.' ELSE '' END AS Explanation, 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOT t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = t.ObserverFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND jf.JobTypeCodeFK = 5
		AND jf.StartDate <= t.ObservationStartDateTime
		AND ISNULL(jf.EndDate, t.ObservationStartDateTime) >= t.ObservationStartDateTime
	LEFT JOIN dbo.Training t2 ON t2.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND t2.TrainingCodeFK = 3
		AND t2.TrainingDate <= t.ObservationStartDateTime
	WHERE pe.HireDate > t.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL
	OR t2.TrainingPK IS NULL
	ORDER BY t.ObservationStartDateTime DESC

	--================= Incomplete TPOT =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPOTPK, 'TPOT', t.ObservationStartDateTime, 'Incomplete form', 
			'The form is incomplete, please go to the TPOT dashboard, edit this form, and fix any validation errors.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPOT t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	WHERE t.IsValid <> 1
	ORDER BY t.ObservationStartDateTime DESC

	--================= TPITOS Participants =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t2.TPITOSPK, 'TPITOS', t2.ObservationStartDateTime, CONCAT('Invalid participant - ', pe.FirstName, ' ', pe.LastName), 
			'The participant does not have an active teacher or teaching assistant job function as of the form date.', c.ProgramFK, p.ProgramName
	FROM dbo.TPITOSParticipant tp
	INNER JOIN dbo.TPITOS t2 ON t2.TPITOSPK = tp.TPITOSFK
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t2.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
		AND jf.StartDate <= t2.ObservationStartDateTime
		AND ISNULL(jf.EndDate, t2.ObservationStartDateTime) >= t2.ObservationStartDateTime
	WHERE pe.HireDate > t2.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t2.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL
	ORDER BY t2.ObservationStartDateTime DESC


	--================= TPITOS Observer =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPITOSPK, 'TPITOS', t.ObservationStartDateTime, CONCAT('Invalid observer - ', pe.FirstName, ' ', pe.LastName), 
			CASE WHEN t2.TrainingPK IS NULL THEN 'The observer is missing their observer training or the training date is after the form date.'
				WHEN jf.JobFunctionPK IS NULL THEN 'The participant does not have an active TPITOS observer job function as of the form date.' ELSE '' END AS Explanation, 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	INNER JOIN dbo.ProgramEmployee pe ON pe.ProgramEmployeePK = t.ObserverFK
	LEFT JOIN dbo.JobFunction jf ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND jf.JobTypeCodeFK = 5
		AND jf.StartDate <= t.ObservationStartDateTime
		AND ISNULL(jf.EndDate, t.ObservationStartDateTime) >= t.ObservationStartDateTime
	LEFT JOIN dbo.Training t2 ON t2.ProgramEmployeeFK = pe.ProgramEmployeePK 
		AND t2.TrainingCodeFK = 3
		AND t2.TrainingDate <= t.ObservationStartDateTime
	WHERE pe.HireDate > t.ObservationStartDateTime
	OR ISNULL(pe.TermDate, GETDATE()) < t.ObservationStartDateTime
	OR jf.JobFunctionPK IS NULL
	OR t2.TrainingPK IS NULL
	ORDER BY t.ObservationStartDateTime DESC

	--================= Incomplete TPITOS =====================
	INSERT INTO @tblFinalSelect
	(
	    ObjectPK,
	    ObjectName,
	    ObjectDate,
		InvalidReason,
		InvalidExplanation,
	    ProgramFK,
		ProgramName
	)
	SELECT t.TPITOSPK, 'TPITOS', t.ObservationStartDateTime, 'Incomplete form', 
			'The form is incomplete, please go to the TPITOS dashboard, edit this form, and fix any validation errors.', 
			c.ProgramFK, p.ProgramName
	FROM dbo.TPITOS t
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN dbo.Program p ON p.ProgramPK = c.ProgramFK
	WHERE t.IsValid <> 1
	ORDER BY t.ObservationStartDateTime DESC

	SELECT * FROM @tblFinalSelect tfs ORDER BY tfs.ObjectDate DESC

END
GO

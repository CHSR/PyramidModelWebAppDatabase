SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/04/2019
-- Description:	This stored procedure returns the status history
-- for a child if the child pk is passed, and all children in 
-- the program otherwise
-- =============================================
CREATE PROCEDURE [dbo].[spGetChildStatusHistory] 
	@ChildPK INT = NULL,
	@ProgramFK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	DECLARE @tblCohort TABLE (
		ChildPK INT NOT NULL,
		ChildProgramPK INT NOT NULL,
		FirstName VARCHAR(256) NOT NULL,
		LastName VARCHAR(256) NOT NULL,
		EnrollmentDate DATE NOT NULL,
		DischargeDate DATE NULL
	)

	DECLARE @tblFinalSelect TABLE (
		ChildPK INT NOT NULL,
		ChildProgramPK INT NOT NULL,
		ChildStatusPK INT NULL,
		CodeChildStatusPK INT NULL,
		FirstName VARCHAR(256) NOT NULL,
		LastName VARCHAR(256) NOT NULL,
		EnrollmentDate DATE NOT NULL,
		DischargeDate DATE NULL,
		StatusDate DATE NOT NULL,
		StatusDescription VARCHAR(250) NOT NULL
	)

	--Get the cohort
	INSERT INTO @tblCohort
	(
	    ChildPK,
	    ChildProgramPK,
	    FirstName,
	    LastName,
	    EnrollmentDate,
	    DischargeDate
	)
	SELECT c.ChildPK, cp.ChildProgramPK, 
		c.FirstName, c.LastName,
		cp.EnrollmentDate, cp.DischargeDate
	FROM 
	dbo.Child c
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK AND cp.ProgramFK = @ProgramFK
	WHERE c.ChildPK = ISNULL(@ChildPK, c.ChildPK)

	--Get the status history
	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ChildProgramPK,
	    ChildStatusPK,
	    CodeChildStatusPK,
	    FirstName,
	    LastName,
	    EnrollmentDate,
	    DischargeDate,
	    StatusDate,
	    StatusDescription
	)
	SELECT tc.ChildPK, tc.ChildProgramPK, cs.ChildStatusPK, ccs.CodeChildStatusPK, 
		tc.FirstName, tc.LastName,
		tc.EnrollmentDate, tc.DischargeDate,
		cs.StatusDate,
		ccs.Description AS StatusDescription 
	FROM 
	@tblCohort tc
	INNER JOIN dbo.ChildStatus cs ON cs.ChildFK = tc.ChildPK AND cs.ProgramFK = @ProgramFK
	INNER JOIN dbo.CodeChildStatus ccs ON ccs.CodeChildStatusPK = cs.ChildStatusCodeFK

	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ChildProgramPK,
	    ChildStatusPK,
	    CodeChildStatusPK,
	    FirstName,
	    LastName,
	    EnrollmentDate,
	    DischargeDate,
	    StatusDate,
	    StatusDescription
	)
	SELECT tc.ChildPK, tc.ChildProgramPK, NULL, NULL,
		tc.FirstName, tc.LastName, tc.EnrollmentDate, tc.DischargeDate, tc.EnrollmentDate,
		'Enrolled'
	FROM @tblCohort tc

	INSERT INTO @tblFinalSelect
	(
	    ChildPK,
	    ChildProgramPK,
	    ChildStatusPK,
	    CodeChildStatusPK,
	    FirstName,
	    LastName,
	    EnrollmentDate,
	    DischargeDate,
	    StatusDate,
	    StatusDescription
	)
	SELECT tc.ChildPK, tc.ChildProgramPK, NULL, NULL,
		tc.FirstName, tc.LastName, tc.EnrollmentDate, tc.DischargeDate, tc.DischargeDate,
		'Discharged'
	FROM @tblCohort tc
	WHERE tc.DischargeDate IS NOT NULL

	SELECT * FROM @tblFinalSelect tfs
	ORDER BY tfs.FirstName, tfs.ChildPK, tfs.StatusDate

END
GO

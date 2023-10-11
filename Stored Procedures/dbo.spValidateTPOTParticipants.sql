SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/23/2019
-- Description:	This stored procedure returns all the employees that are associated
-- with the TPOT and whether or not they are valid
-- =============================================
CREATE PROC [dbo].[spValidateTPOTParticipants]
    @TPOTPK INT = NULL,
    @ObservationDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @tblAllTPOTParticipants TABLE
    (
        ProgramEmployeePK INT NULL,
        EmployeeID VARCHAR(100) NULL,
        EmployeeName VARCHAR(500) NULL
    );

    DECLARE @tblValidTPOTParticipants TABLE
    (
        ProgramEmployeePK INT NULL,
        EmployeeID VARCHAR(100) NULL,
        EmployeeName VARCHAR(500) NULL
    );

    DECLARE @tblFinalSelect TABLE
    (
        ProgramEmployeePK INT NULL,
        EmployeeID VARCHAR(100) NULL,
        EmployeeName VARCHAR(500) NULL,
        IsValid BIT NULL
    );

    --Get all the participants
    INSERT INTO @tblAllTPOTParticipants
    (
        ProgramEmployeePK,
		EmployeeID,
        EmployeeName
    )
    SELECT DISTINCT
           pe.ProgramEmployeePK,
		   pe.ProgramSpecificID,
           (e.FirstName + ' ' + e.LastName) AS EmployeeName
    FROM dbo.TPOTParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
    WHERE tp.TPOTFK = @TPOTPK;

    --Get the valid participants
    INSERT INTO @tblValidTPOTParticipants
    (
        ProgramEmployeePK,
		EmployeeID,
        EmployeeName
    )
    SELECT DISTINCT
           pe.ProgramEmployeePK,
		   pe.ProgramSpecificID,
           (e.FirstName + ' ' + e.LastName) AS EmployeeName
    FROM dbo.TPOTParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
        INNER JOIN dbo.JobFunction jf
            ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK
    WHERE tp.TPOTFK = @TPOTPK
          AND pe.HireDate <= @ObservationDate
          AND ISNULL(pe.TermDate, GETDATE()) >= @ObservationDate
          AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
          AND jf.StartDate <= @ObservationDate
          AND ISNULL(jf.EndDate, GETDATE()) >= @ObservationDate;

    --Get the participants and whether or not they are valid
    INSERT INTO @tblFinalSelect
    (
        ProgramEmployeePK,
		EmployeeID,
        EmployeeName,
        IsValid
    )
    SELECT tatp.ProgramEmployeePK,
		   tatp.EmployeeID,
           tatp.EmployeeName,
           CASE
               WHEN tvtp.ProgramEmployeePK IS NULL THEN
                   0
               ELSE
                   1
           END AS IsValid
    FROM @tblAllTPOTParticipants tatp
        LEFT JOIN @tblValidTPOTParticipants tvtp
            ON tvtp.ProgramEmployeePK = tatp.ProgramEmployeePK;

    --Return the participants and validity
    SELECT tfs.ProgramEmployeePK,
           tfs.EmployeeID,
           tfs.EmployeeName,
           tfs.IsValid
    FROM @tblFinalSelect tfs
	ORDER BY tfs.EmployeeName ASC;
END;
GO

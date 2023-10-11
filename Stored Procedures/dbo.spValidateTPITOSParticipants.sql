SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/19/2019
-- Description:	This stored procedure returns all the employees that are associated
-- with the TPITOS that are not valid as of the observation date
-- =============================================
CREATE PROC [dbo].[spValidateTPITOSParticipants]
    @TPITOSPK INT = NULL,
    @ObservationDate DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @tblAllTPITOSParticipants TABLE
    (
        ProgramEmployeePK INT NULL,
        EmployeeID VARCHAR(100) NULL,
        EmployeeName VARCHAR(500) NULL
    );

    DECLARE @tblValidTPITOSParticipants TABLE
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

    INSERT INTO @tblAllTPITOSParticipants
    (
        ProgramEmployeePK,
        EmployeeID,
        EmployeeName
    )
    SELECT DISTINCT
           pe.ProgramEmployeePK,
           pe.ProgramSpecificID,
           (e.FirstName + ' ' + e.LastName) AS EmployeeName
    FROM dbo.TPITOSParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
    WHERE tp.TPITOSFK = @TPITOSPK;

    INSERT INTO @tblValidTPITOSParticipants
    (
        ProgramEmployeePK,
        EmployeeID,
        EmployeeName
    )
    SELECT DISTINCT
           pe.ProgramEmployeePK,
           pe.ProgramSpecificID,
           (e.FirstName + ' ' + e.LastName) AS EmployeeName
    FROM dbo.TPITOSParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
        INNER JOIN dbo.JobFunction jf
            ON jf.ProgramEmployeeFK = pe.ProgramEmployeePK
    WHERE tp.TPITOSFK = @TPITOSPK
          AND pe.HireDate <= @ObservationDate
          AND ISNULL(pe.TermDate, GETDATE()) >= @ObservationDate
          AND (jf.JobTypeCodeFK = 1 OR jf.JobTypeCodeFK = 2)
          AND jf.StartDate <= @ObservationDate
          AND ISNULL(jf.EndDate, GETDATE()) >= @ObservationDate;

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
    FROM @tblAllTPITOSParticipants tatp
        LEFT JOIN @tblValidTPITOSParticipants tvtp
            ON tvtp.ProgramEmployeePK = tatp.ProgramEmployeePK;

    SELECT tfs.ProgramEmployeePK,
           tfs.EmployeeID,
           tfs.EmployeeName,
           tfs.IsValid
    FROM @tblFinalSelect tfs
	ORDER BY tfs.EmployeeName ASC;
END;
GO

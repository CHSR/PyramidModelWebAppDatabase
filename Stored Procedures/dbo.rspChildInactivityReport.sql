SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Derek Cacciotti
-- Create date: 09/09/19
-- Description:	This stored procedure returns children who have not had any activity in one year
-- =============================================
CREATE PROC [dbo].[rspChildInactivityReport] 
	@ProgramFKs VARCHAR(max),
	@PointInTime DATETIME
AS
BEGIN

DECLARE @tblCohort TABLE (
	ChildPK INT NOT NULL, 
	UUID VARCHAR(100) NOT NULL,
	ChildName varchar(MAX) NOT NULL,
	ProgramFK INT NOT NULL,
	ProgramName varchar(MAX) NOT NULL,
	BirthDate DATETIME NOT NULL,
	EnrollementDate DATETIME NOT NULL
)

DECLARE @tblkids TABLE(
	ChildPK INT NOT NULL, 
	UUID VARCHAR(100) NOT NULL,
	ChildName varchar(MAX) NOT NULL,
	ProgramName varchar(MAX) NOT NULL,
	BirthDate DATETIME NOT NULL,
	EnrollementDate DATETIME NOT NULL,
	ActivityType VARCHAR(max) NULL,
	DateOfEvent DATETIME NULL
)

DECLARE @tblfinal TABLE(
	ChildPK INT NOT NULL, 
	UUID VARCHAR(100) NOT NULL,
	ChildName varchar(MAX) NOT NULL,
	ProgramName varchar(MAX) NOT NULL,
	BirthDate DATETIME NOT NULL,
	EnrollementDate DATETIME NOT NULL,
	ActivityType VARCHAR(max) NULL,
	DateOfEvent DATETIME NULL,
	rownum INT NOT NULL
)

--Get the cohort to save joins
INSERT INTO @tblCohort
(
    ChildPK,
    UUID,
    ChildName,
	ProgramFK,
    ProgramName,
    BirthDate,
    EnrollementDate
)
SELECT c.ChildPK, cp.ProgramSpecificID, c.FirstName + ' ' + c.LastName  AS ChildName, 
p.ProgramPK, p.ProgramName, c.BirthDate, cp.EnrollmentDate 
FROM dbo.Child c 
INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
INNER JOIN dbo.Program p ON p.ProgramPK = cp.ProgramFK
INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
WHERE cp.EnrollmentDate <= DATEADD(YEAR, -1, @PointInTime) AND cp.DischargeDate IS NULL

INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent
)
--Enrollment
SELECT  tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'Enrollment', tc.EnrollementDate
FROM @tblCohort tc

INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent
)
-- bir
SELECT  tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'BIR', MAX(bir.IncidentDatetime) 
FROM @tblCohort tc
INNER JOIN dbo.BehaviorIncident bir ON bir.ChildFK = tc.ChildPK
INNER JOIN dbo.Classroom c ON c.ClassroomPK = bir.ClassroomFK
WHERE c.ProgramFK = tc.ProgramFK
GROUP BY tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, tc.EnrollementDate

-- asq
INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent
)
SELECT tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'ASQSE', MAX(asq.FormDate) 
FROM @tblCohort tc
INNER JOIN dbo.ASQSE asq ON asq.ChildFK = tc.ChildPK
WHERE asq.ProgramFK = tc.ProgramFK
GROUP BY tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, tc.EnrollementDate

-- notes 
INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent
)
SELECT  tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'Child Note', MAX(cn.NoteDate) 
FROM @tblCohort tc
INNER JOIN dbo.ChildNote cn ON cn.ChildFK = tc.ChildPK
WHERE cn.ProgramFK = tc.ProgramFK
GROUP BY tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, tc.EnrollementDate

-- status
INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent

)
SELECT tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'Child Status', MAX(cs.StatusDate) 
FROM @tblCohort tc
INNER JOIN dbo.ChildStatus cs ON cs.ChildFK = tc.ChildPK
WHERE cs.ProgramFK = tc.ProgramFK
GROUP BY tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, tc.EnrollementDate

-- other screening tools
INSERT INTO @tblkids
(
    ChildPK,
	UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent

)
SELECT tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, 
tc.EnrollementDate, 'Other Screening Tool', MAX(ose.ScreenDate) 
FROM @tblCohort tc
INNER JOIN dbo.OtherSEScreen ose ON ose.ChildFK = tc.ChildPK
WHERE ose.ProgramFK = tc.ProgramFK
GROUP BY tc.ChildPK, tc.UUID, tc.ChildName, tc.ProgramName, tc.BirthDate, tc.EnrollementDate

INSERT into  @tblfinal
(
    ChildPK,
    UUID,
    ChildName,
    ProgramName,
    BirthDate,
    EnrollementDate,
    ActivityType,
    DateOfEvent,
    rownum
)
SELECT ChildPK,
       UUID,
       ChildName,
       ProgramName,
       BirthDate,
       EnrollementDate,
       ActivityType,
	   DateOfEvent,
	   ROW_NUMBER() OVER (PARTITION BY ChildPK ORDER BY DateOfEvent DESC)
       FROM @tblkids

SELECT * 
FROM @tblfinal 
WHERE rownum = 1 AND DATEADD(YEAR, -1, @PointInTime) > DateOfEvent
ORDER BY DateOfEvent DESC

END

GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 6/4/2019
-- Description:	This stored procedure returns counts for the 
-- dashboard master page
-- =============================================
CREATE PROC [dbo].[spGetCountsForDashboardMaster] 
	@PointInTime DATETIME = NULL,
	@ProgramFKs VARCHAR(MAX) = NULL,
	@HubFK INT = NULL,
	@StateFK INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @tblFinalSelect TABLE (
		ChildrenCount INT NULL,
		ClassroomCount INT NULL,
		CoachingLogCount INT NULL,
		EmployeeCount INT NULL,
		BOQCount INT NULL,
		BOQFCCCount INT NULL,
		BehaviorIncidentCount INT NULL,
		FileUploadCount INT NULL,
		ASQSECount INT NULL,
		OtherSEScreenCount INT NULL,
		TPOTCount INT NULL,
		TPITOSCount INT NULL
	)

	INSERT INTO @tblFinalSelect
	VALUES
	(
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	)

	--Children
	--Must be currently active
	UPDATE @tblFinalSelect 
	SET ChildrenCount = (SELECT COUNT(c.ChildPK) ChildCount FROM dbo.Child c 
						INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
						INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
						WHERE cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime)
	
	--Classrooms
	UPDATE @tblFinalSelect 
	SET ClassroomCount = (SELECT COUNT(c.ClassroomPK) ClassroomCount FROM dbo.Classroom c
						 INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem)
	
	--Employees
	--Must be currently active
	UPDATE @tblFinalSelect 
	SET EmployeeCount = (SELECT COUNT(pe.ProgramEmployeePK) EmployeeCount FROM dbo.ProgramEmployee pe
						 INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON pe.ProgramFK = ssti.ListItem
						 WHERE pe.TermDate IS NULL OR pe.TermDate > @PointInTime)
	
	--Benchmarks of Quality forms
	--Only select forms in the last year
	UPDATE @tblFinalSelect
	SET BOQCount = (SELECT COUNT(boq.BenchmarkOfQualityPK) BOQCount  FROM dbo.BenchmarkOfQuality boq
					INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',' ) ssti ON boq.ProgramFK = ssti.ListItem
					WHERE boq.FormDate < @PointInTime AND boq.FormDate >= DATEADD(YEAR, -1, @PointInTime))

	--Benchmarks of Quality FCC forms
	--Only select forms in the last year
	UPDATE @tblFinalSelect 
	SET BOQFCCCount = (SELECT COUNT(boqfcc.BenchmarkOfQualityFCCPK) BOQFCCCount FROM dbo.BenchmarkOfQualityFCC boqfcc
						INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON boqfcc.ProgramFK = ssti.ListItem
						WHERE boqfcc.FormDate < @PointInTime AND boqfcc.FormDate >= DATEADD(YEAR, -1, @PointInTime)) 

	--Behavior Incidents
	--Only select incidents in the last year
	UPDATE @tblFinalSelect
	SET BehaviorIncidentCount = (SELECT COUNT(bi.BehaviorIncidentPK) FROM dbo.BehaviorIncident bi
								 INNER JOIN dbo.Classroom c ON c.ClassroomPK = bi.ClassroomFK
								 INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
								 WHERE bi.IncidentDatetime < @PointInTime AND bi.IncidentDatetime >= DATEADD(YEAR, -1, @PointInTime))

	--File uploads
	--Only select the last year of uploads
	DECLARE @tblAllUploads TABLE (
		UserFileUploadPK INT,
		FileCreator VARCHAR(256) NULL,
		FileCreateDate DATETIME NULL,
		FileDescription VARCHAR(256) NULL,
		DisplayFileName VARCHAR(300) NULL,
		FileEditor VARCHAR(256) NULL,
		FileEditDate DATETIME NULL,
		FileType VARCHAR(50) NULL,
		FileName VARCHAR(300) NULL,
		FilePath VARCHAR(1000) NULL,
		ProgramFK INT NULL,
		HubFK INT NULL,
		StateFK INT NULL,
		CohortFK INT NULL,
		TypeCodeFK INT NULL,
		TypeDescription VARCHAR(250) NULL,
		FileUploadedBy VARCHAR(MAX) NULL
	)

	INSERT INTO @tblAllUploads
	(
	    UserFileUploadPK,
	    FileCreator,
	    FileCreateDate,
	    FileDescription,
	    DisplayFileName,
	    FileEditor,
	    FileEditDate,
	    FileType,
	    FileName,
	    FilePath,
	    ProgramFK,
		HubFK,
		StateFK,
		CohortFK,
	    TypeCodeFK,
	    TypeDescription,
		FileUploadedBy
	)
	EXEC dbo.spGetAllFileUploads @ProgramFKs = @ProgramFKs, -- varchar(max)
	                             @HubFK = @HubFK,     -- varchar(max)
	                             @StateFK = @StateFK      -- int

	UPDATE @tblFinalSelect SET FileUploadCount = (SELECT COUNT(DISTINCT UserFileUploadPK) FROM @tblAllUploads tau
												  WHERE tau.FileCreateDate < @PointInTime AND tau.FileCreateDate >= DATEADD(YEAR, -1, @PointInTime))

	--ASQSE
	--Only select forms in the last year
	UPDATE @tblFinalSelect SET ASQSECount = (SELECT COUNT(a.ASQSEPK) FROM dbo.ASQSE a
			INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON a.ProgramFK = ssti.ListItem
			WHERE a.FormDate < @PointInTime AND a.FormDate >= DATEADD(YEAR, -1, @PointInTime))
	
	--Other SE Screens
	--Only select screens in the last year
	UPDATE @tblFinalSelect SET OtherSEScreenCount = (SELECT COUNT(oss.OtherSEScreenPK) FROM dbo.OtherSEScreen oss
			INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON oss.ProgramFK = ssti.ListItem
			WHERE oss.ScreenDate < @PointInTime AND oss.ScreenDate >= DATEADD(YEAR, -1, @PointInTime))

	--Coaching Logs
	--Only select logs in the last year
	UPDATE @tblFinalSelect SET CoachingLogCount = (SELECT COUNT(cl.CoachingLogPK) FROM dbo.CoachingLog cl
			INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cl.ProgramFK = ssti.ListItem
			WHERE cl.LogDate < @PointInTime AND cl.LogDate >= DATEADD(YEAR, -1, @PointInTime))
			
	--TPOT
	--Only select TPOTs in the last year
	UPDATE @tblFinalSelect SET TPOTCount = (SELECT COUNT(t.TPOTPK) FROM dbo.TPOT t
			INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
			INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
			WHERE t.ObservationStartDateTime < @PointInTime AND t.ObservationStartDateTime >= DATEADD(YEAR, -1, @PointInTime))
			
	--TPITOS
	--Only select TPITOS in the last year
	UPDATE @tblFinalSelect SET TPITOSCount = (SELECT COUNT(t.TPITOSPK) FROM dbo.TPITOS t
			INNER JOIN dbo.Classroom c ON c.ClassroomPK = t.ClassroomFK
			INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
			WHERE t.ObservationStartDateTime < @PointInTime AND t.ObservationStartDateTime >= DATEADD(YEAR, -1, @PointInTime))
	
	--Select all the counts from the table variable
	SELECT * FROM @tblFinalSelect tfs
END
GO

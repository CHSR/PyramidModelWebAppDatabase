SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/04/2019
-- Description:	This stored procedure returns the uploaded files
-- for a specific set of programs
-- =============================================
CREATE PROC [dbo].[spGetAllFileUploads]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@HubFK INT = NULL,
	@StateFK INT = NULL,
	@CohortFKs VARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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

	--Get the file uploads for the programs
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
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.Description, ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.FileName, ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.Description, ufu.UploadedBy
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON ufu.ProgramFK = ssti.ListItem
	WHERE ufu.TypeCodeFK = 3

	--Get the file uploads for the hubs
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
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.Description, ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.FileName, ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.Description, ufu.UploadedBy
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	WHERE ufu.TypeCodeFK = 2 AND ufu.HubFK = @HubFK

	--Get the file uploads for the state
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
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.Description, ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.FileName, ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.Description, ufu.UploadedBy
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	WHERE ufu.TypeCodeFK = 1 AND ufu.StateFK = @StateFK

	--Get the file uploads for the cohorts
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
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.Description, ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.FileName, ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.Description, ufu.UploadedBy
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@CohortFKs, ',') ssti ON ufu.CohortFK = ssti.ListItem
	WHERE ufu.TypeCodeFK = 4

	SELECT * FROM @tblAllUploads tau

END
GO

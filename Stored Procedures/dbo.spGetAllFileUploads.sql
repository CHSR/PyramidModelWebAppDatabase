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
	@ProgramFKs VARCHAR(8000) = NULL,
	@HubFKs VARCHAR(8000) = NULL,
	@StateFKs VARCHAR(8000) = NULL,
	@CohortFKs VARCHAR(8000) = NULL,
	@RoleFK INT = NULL,
	@Username VARCHAR(256) = NULL
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
		[FileName] VARCHAR(300) NULL,
		FilePath VARCHAR(1000) NULL,
		ProgramFK INT NULL,
		HubFK INT NULL,
		StateFK INT NULL,
		CohortFK INT NULL,
		TypeCodeFK INT NULL,
		TypeDescription VARCHAR(250) NULL,
		FileUploadedBy VARCHAR(MAX) NULL,
		RolesAuthorizedToModify VARCHAR(100)
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
	    [FileName],
	    FilePath,
	    ProgramFK,
		HubFK,
		StateFK,
		CohortFK,
	    TypeCodeFK,
	    TypeDescription,
		FileUploadedBy,
		RolesAuthorizedToModify
	)
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.[Description], ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.[FileName], ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.[Description], ufu.UploadedBy, cfut.RolesAuthorizedToModify
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON ufu.ProgramFK = ssti.ListItem
	WHERE ufu.TypeCodeFK = 3
	AND EXISTS (SELECT roleList.ListItem FROM dbo.SplitStringToInt(cfut.RolesAuthorizedToModify, ',') roleList WHERE roleList.ListItem = @RoleFK)
	AND @RoleFK <> 18 --Exclude national roles
	AND (@RoleFK <> 12 OR ufu.Creator = @Username) --Classroom Coach Data Collector role can only see what they uploaded
	AND (@RoleFK <> 15 OR ufu.Creator = @Username) --Leadership Coach role can only see what they uploaded
	AND (@RoleFK <> 16 OR ufu.Creator = @Username) --Master Cadre Member role can only see what they uploaded
	AND (@RoleFK <> 21 OR ufu.Creator = @Username) --Combined LC and CCDC role can only see what they uploaded

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
	    [FileName],
	    FilePath,
	    ProgramFK,
		HubFK,
		StateFK,
		CohortFK,
	    TypeCodeFK,
	    TypeDescription,
		FileUploadedBy,
		RolesAuthorizedToModify
	)
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.[Description], ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.[FileName], ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.[Description], ufu.UploadedBy, cfut.RolesAuthorizedToModify
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@HubFKs, ',') ssti ON ufu.HubFK = ssti.ListItem
	WHERE ufu.TypeCodeFK = 2 
	AND EXISTS (SELECT roleList.ListItem FROM dbo.SplitStringToInt(cfut.RolesAuthorizedToModify, ',') roleList WHERE roleList.ListItem = @RoleFK)
	AND @RoleFK <> 18 --Exclude national roles
	AND (@RoleFK <> 12 OR ufu.Creator = @Username) --Classroom Coach Data Collector role can only see what they uploaded
	AND (@RoleFK <> 15 OR ufu.Creator = @Username) --Leadership Coach role can only see what they uploaded
	AND (@RoleFK <> 16 OR ufu.Creator = @Username) --Master Cadre Member role can only see what they uploaded
	AND (@RoleFK <> 21 OR ufu.Creator = @Username) --Combined LC and CCDC role can only see what they uploaded

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
	    [FileName],
	    FilePath,
	    ProgramFK,
		HubFK,
		StateFK,
		CohortFK,
	    TypeCodeFK,
	    TypeDescription,
		FileUploadedBy,
		RolesAuthorizedToModify
	)
	SELECT ufu.UserFileUploadPK, ufu.Creator, ufu.CreateDate, ufu.[Description], ufu.DisplayFileName, ufu.Editor, ufu.EditDate,
		ufu.FileType, ufu.[FileName], ufu.FilePath, ufu.ProgramFK, ufu.HubFK, ufu.StateFK, ufu.CohortFK, ufu.TypeCodeFK, 
		cfut.[Description], ufu.UploadedBy, cfut.RolesAuthorizedToModify
	FROM dbo.UserFileUpload ufu
	INNER JOIN dbo.CodeFileUploadType cfut ON cfut.CodeFileUploadTypePK = ufu.TypeCodeFK
	INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') ssti ON ufu.StateFK = ssti.ListItem
	WHERE ufu.TypeCodeFK = 1 
	AND EXISTS (SELECT roleList.ListItem FROM dbo.SplitStringToInt(cfut.RolesAuthorizedToModify, ',') roleList WHERE roleList.ListItem = @RoleFK)
	AND @RoleFK <> 18 --Exclude national roles
	AND (@RoleFK <> 12 OR ufu.Creator = @Username) --Classroom Coach Data Collector role can only see what they uploaded
	AND (@RoleFK <> 15 OR ufu.Creator = @Username) --Leadership Coach role can only see what they uploaded
	AND (@RoleFK <> 16 OR ufu.Creator = @Username) --Master Cadre Member role can only see what they uploaded
	AND (@RoleFK <> 21 OR ufu.Creator = @Username) --Combined LC and CCDC role can only see what they uploaded

	SELECT * FROM @tblAllUploads tau

END
GO

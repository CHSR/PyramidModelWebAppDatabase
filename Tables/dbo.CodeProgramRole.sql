CREATE TABLE [dbo].[CodeProgramRole]
(
[CodeProgramRolePK] [int] NOT NULL,
[DisplayOnHelpPage] [bit] NOT NULL CONSTRAINT [DF_CodeProgramRole_DisplayOnHelpPage] DEFAULT ((1)),
[RoleDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeProgramRole_RoleDescription] DEFAULT ('No description...'),
[RoleName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewPrivateChildInfo] [bit] NOT NULL CONSTRAINT [DF_CodeProgramRole_AllowedToViewPrivateInfo] DEFAULT ((0)),
[ViewPrivateEmployeeInfo] [bit] NOT NULL CONSTRAINT [DF_CodeProgramRole_ViewPrivateEmployeeInfo] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 10/22/2021
-- Description:	This trigger ensures that the CodeProgramRolePermission table is populated
-- and that other fields that utilize CodeProgramRole PKs are populated.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CodeProgramRole_Added]
ON [dbo].[CodeProgramRole]
AFTER INSERT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Add rows to the CodeProgramRolePermission table.
    --It should have a row for each form and this new role.
    INSERT INTO dbo.CodeProgramRolePermission
    (
        AllowedToAdd,
        AllowedToDelete,
        AllowedToEdit,
        AllowedToView,
        AllowedToViewDashboard,
        CodeFormFK,
        CodeProgramRoleFK
    )
    SELECT 1,
           1,
           1,
           1,
           1,
           cf.CodeFormPK,
           i.CodeProgramRolePK
    FROM Inserted i
        LEFT JOIN dbo.CodeProgramRolePermission cprp
            ON cprp.CodeProgramRoleFK = i.CodeProgramRolePK
        CROSS JOIN dbo.CodeForm cf
    WHERE cprp.CodeProgramRolePermissionPK IS NULL;

    --Update the CodeJobType table
    UPDATE dbo.CodeJobType
    SET RolesAuthorizedToModify = CONCAT(cjt.RolesAuthorizedToModify, i.CodeProgramRolePK, ',')
    FROM Inserted i
        CROSS JOIN dbo.CodeJobType cjt
    WHERE NOT EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cjt.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = i.CodeProgramRolePK)

    --Update the CodeNewsEntryType table
    UPDATE cnet
    SET cnet.RolesAuthorizedToModify = CONCAT(cnet.RolesAuthorizedToModify, i.CodeProgramRolePK, ',')
    FROM Inserted i
        CROSS JOIN dbo.CodeNewsEntryType cnet
    WHERE NOT EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cnet.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = i.CodeProgramRolePK)

    --Update the CodeFileUploadType table
    UPDATE cfut
    SET cfut.RolesAuthorizedToModify = CONCAT(cfut.RolesAuthorizedToModify, i.CodeProgramRolePK, ',')
    FROM Inserted i
        CROSS JOIN dbo.CodeFileUploadType cfut
    WHERE NOT EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cfut.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = i.CodeProgramRolePK)
	
    --Update the CodeTraining table
    UPDATE ct
    SET ct.RolesAuthorizedToModify = CONCAT(ct.RolesAuthorizedToModify, i.CodeProgramRolePK, ',')
    FROM Inserted i
        CROSS JOIN dbo.CodeTraining ct
    WHERE NOT EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(ct.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = i.CodeProgramRolePK)

    --Update the ReportCatalog table
    UPDATE rc
    SET rc.RolesAuthorizedToRun = CONCAT(rc.RolesAuthorizedToRun, i.CodeProgramRolePK, ',')
    FROM Inserted i
        CROSS JOIN dbo.ReportCatalog rc
    WHERE NOT EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(rc.RolesAuthorizedToRun, ',') ssti WHERE ssti.ListItem = i.CodeProgramRolePK)

END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 10/22/2021
-- Description:	This trigger ensures that the CodeProgramRolePermission table is populated
-- and that other fields that utilize CodeProgramRole PKs are populated.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CodeProgramRole_Deleted]
ON [dbo].[CodeProgramRole]
INSTEAD OF DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Delete rows to the CodeProgramRolePermission table.
    DELETE cprp
    FROM dbo.CodeProgramRolePermission cprp
        INNER JOIN Deleted d
            ON d.CodeProgramRolePK = cprp.CodeProgramRoleFK
    WHERE d.CodeProgramRolePK IS NOT NULL;

    --Update the CodeJobType table
    UPDATE cjt
    SET cjt.RolesAuthorizedToModify = REPLACE(cjt.RolesAuthorizedToModify, CONCAT(',', d.CodeProgramRolePK, ','), ',')
    FROM Deleted d
        CROSS JOIN dbo.CodeJobType cjt
    WHERE EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cjt.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = d.CodeProgramRolePK);

    --Update the CodeNewsEntryType table
    UPDATE cnet
    SET cnet.RolesAuthorizedToModify = REPLACE(cnet.RolesAuthorizedToModify, CONCAT(',', d.CodeProgramRolePK, ','), ',')
    FROM Deleted d
        CROSS JOIN dbo.CodeNewsEntryType cnet
    WHERE EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cnet.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = d.CodeProgramRolePK);

    --Update the CodeFileUploadType table
    UPDATE cfut
    SET cfut.RolesAuthorizedToModify = REPLACE(cfut.RolesAuthorizedToModify, CONCAT(',', d.CodeProgramRolePK, ','), ',')
    FROM Deleted d
        CROSS JOIN dbo.CodeFileUploadType cfut
    WHERE EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(cfut.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = d.CodeProgramRolePK);
	
    --Update the CodeTraining table
    UPDATE ct
    SET ct.RolesAuthorizedToModify = REPLACE(ct.RolesAuthorizedToModify, CONCAT(',', d.CodeProgramRolePK, ','), ',')
    FROM Deleted d
        CROSS JOIN dbo.CodeTraining ct
    WHERE EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(ct.RolesAuthorizedToModify, ',') ssti WHERE ssti.ListItem = d.CodeProgramRolePK);

    --Update the ReportCatalog table
    UPDATE rc
    SET rc.RolesAuthorizedToRun = REPLACE(rc.RolesAuthorizedToRun, CONCAT(',', d.CodeProgramRolePK, ','), ',')
    FROM Deleted d
        CROSS JOIN dbo.ReportCatalog rc
    WHERE EXISTS (SELECT ssti.ListItem FROM dbo.SplitStringToInt(rc.RolesAuthorizedToRun, ',') ssti WHERE ssti.ListItem = d.CodeProgramRolePK);

    --Finally, delete the CodeProgramRole row
    DELETE cpr
    FROM dbo.CodeProgramRole cpr
        INNER JOIN Deleted d
            ON d.CodeProgramRolePK = cpr.CodeProgramRolePK
    WHERE d.CodeProgramRolePK IS NOT NULL;

END;
GO
ALTER TABLE [dbo].[CodeProgramRole] ADD CONSTRAINT [PK_ApplicationRole] PRIMARY KEY CLUSTERED ([CodeProgramRolePK]) ON [PRIMARY]
GO

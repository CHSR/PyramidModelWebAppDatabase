CREATE TABLE [dbo].[CodeForm]
(
[CodeFormPK] [int] NOT NULL IDENTITY(1, 1),
[AllowDueDate] [bit] NOT NULL,
[DisplayOnHelpPage] [bit] NOT NULL CONSTRAINT [DF_CodeForm_DisplayPermissionsOnHelpPage] DEFAULT ((1)),
[FormAbbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
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
-- =============================================
CREATE TRIGGER [dbo].[TGR_CodeForm_Added]
ON [dbo].[CodeForm]
AFTER INSERT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Add rows to the CodeProgramRolePermission table.
	--It should have a row for each role and this new form.
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
           i.CodeFormPK,
           cpr.CodeProgramRolePK
    FROM Inserted i
        LEFT JOIN dbo.CodeProgramRolePermission cprp
            ON cprp.CodeFormFK = i.CodeFormPK
        CROSS JOIN dbo.CodeProgramRole cpr
    WHERE cprp.CodeProgramRolePermissionPK IS NULL;

END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 10/22/2021
-- Description:	This trigger ensures that the CodeProgramRolePermission table is updated
-- when a form is deleted.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CodeForm_Deleted]
ON [dbo].[CodeForm]
INSTEAD OF DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Remove CodeProgramRolePermission rows
    DELETE cprp
    FROM dbo.CodeProgramRolePermission cprp
        INNER JOIN Deleted d
            ON d.CodeFormPK = cprp.CodeFormFK
    WHERE d.CodeFormPK IS NOT NULL;

    --Remove the CodeForm row
    DELETE cf
    FROM dbo.CodeForm cf
        INNER JOIN Deleted d
            ON d.CodeFormPK = cf.CodeFormPK
    WHERE d.CodeFormPK IS NOT NULL;

END;
GO
ALTER TABLE [dbo].[CodeForm] ADD CONSTRAINT [PK_CodeForm] PRIMARY KEY CLUSTERED ([CodeFormPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CodeForm_FormAbbreviationUnique] ON [dbo].[CodeForm] ([FormAbbreviation]) ON [PRIMARY]
GO

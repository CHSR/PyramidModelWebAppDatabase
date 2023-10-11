CREATE TABLE [dbo].[UserProgramRole]
(
[UserProgramRolePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Username] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProgramRoleCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 10/15/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_UserProgramRole_Changed]
ON [dbo].[UserProgramRole]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.UserProgramRolePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.UserProgramRoleChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        UserProgramRolePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        Username,
        ProgramFK,
        ProgramRoleCodeFK
    )
    SELECT GETDATE(),
           @ChangeType,
           NULL,
           d.UserProgramRolePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.Username,
           d.ProgramFK,
           d.ProgramRoleCodeFK
    FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        UserProgramRoleChangedPK INT NOT NULL,
        Username VARCHAR(256) NOT NULL,
        ProgramFK INT NOT NULL,
        ProgramRoleCodeFK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for all the different roles that were affected
    INSERT INTO @ExistingChangeRows
    (
        UserProgramRoleChangedPK,
        Username,
        ProgramFK,
        ProgramRoleCodeFK,
        RowNumber
    )
    SELECT uprc.UserProgramRoleChangedPK,
           uprc.Username,
           uprc.ProgramFK,
           uprc.ProgramRoleCodeFK,
           ROW_NUMBER() OVER (PARTITION BY uprc.Username, uprc.ProgramFK, uprc.ProgramRoleCodeFK
                              ORDER BY uprc.UserProgramRoleChangedPK DESC
                             ) AS RowNum
    FROM dbo.UserProgramRoleChanged uprc
    WHERE EXISTS
    (
        SELECT d.UserProgramRolePK FROM Deleted d WHERE d.Username = uprc.Username AND d.ProgramFK = uprc.ProgramFK AND d.ProgramRoleCodeFK = uprc.ProgramRoleCodeFK
    );

    --Remove all but the most recent change row
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 1;

    --Delete the excess change rows to keep the number of change rows low
    DELETE uprc
    FROM dbo.UserProgramRoleChanged uprc
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.UserProgramRoleChangedPK = uprc.UserProgramRoleChangedPK
    WHERE uprc.UserProgramRoleChangedPK = ecr.UserProgramRoleChangedPK;

END;
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [PK_UserProgramRole] PRIMARY KEY CLUSTERED  ([UserProgramRolePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [FK_UserProgramRole_CodeProgramRole] FOREIGN KEY ([ProgramRoleCodeFK]) REFERENCES [dbo].[CodeProgramRole] ([CodeProgramRolePK])
GO
ALTER TABLE [dbo].[UserProgramRole] ADD CONSTRAINT [FK_UserProgramRole_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

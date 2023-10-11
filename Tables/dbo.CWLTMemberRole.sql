CREATE TABLE [dbo].[CWLTMemberRole]
(
[CWLTMemberRolePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[CWLTMemberFK] [int] NOT NULL,
[TeamPositionCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 12/07/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CWLTMemberRole_Changed] 
   ON  [dbo].[CWLTMemberRole] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CWLTMemberRolePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTMemberRoleChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTMemberRolePK,
        Creator,
        CreateDate,
        CWLTMemberFK,
        TeamPositionCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.CWLTMemberRolePK,
        d.Creator,
        d.CreateDate,
        d.CWLTMemberFK,
        d.TeamPositionCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTMemberRoleChangedPK INT NOT NULL,
        CWLTMemberRolePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        CWLTMemberRoleChangedPK,
		CWLTMemberRolePK,
        RowNumber
    )
    SELECT smc.CWLTMemberRoleChangedPK,
		   smc.CWLTMemberRolePK,
           ROW_NUMBER() OVER (PARTITION BY smc.CWLTMemberRolePK
                              ORDER BY smc.CWLTMemberRoleChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTMemberRoleChanged smc
    WHERE EXISTS
    (
        SELECT d.CWLTMemberRolePK FROM Deleted d WHERE d.CWLTMemberRolePK = smc.CWLTMemberRolePK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.CWLTMemberRoleChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.CWLTMemberRoleChangedPK = ecr.CWLTMemberRoleChangedPK
    WHERE smc.CWLTMemberRoleChangedPK = ecr.CWLTMemberRoleChangedPK;
	
END
GO
ALTER TABLE [dbo].[CWLTMemberRole] ADD CONSTRAINT [PK_CWLTMemberRole] PRIMARY KEY CLUSTERED ([CWLTMemberRolePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMemberRole] ADD CONSTRAINT [FK_CWLTMemberRole_CodeTeamPosition] FOREIGN KEY ([TeamPositionCodeFK]) REFERENCES [dbo].[CodeTeamPosition] ([CodeTeamPositionPK])
GO
ALTER TABLE [dbo].[CWLTMemberRole] ADD CONSTRAINT [FK_CWLTMemberRole_CWLTMember] FOREIGN KEY ([CWLTMemberFK]) REFERENCES [dbo].[CWLTMember] ([CWLTMemberPK])
GO

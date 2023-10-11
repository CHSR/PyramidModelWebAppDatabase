CREATE TABLE [dbo].[PLTMemberRole]
(
[PLTMemberRolePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[PLTMemberFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_PLTMemberRole_Changed] 
   ON  [dbo].[PLTMemberRole] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.PLTMemberRolePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.PLTMemberRoleChanged
    (
        ChangeDatetime,
        ChangeType,
        PLTMemberRolePK,
        Creator,
        CreateDate,
        PLTMemberFK,
        TeamPositionCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.PLTMemberRolePK,
        d.Creator,
        d.CreateDate,
        d.PLTMemberFK,
        d.TeamPositionCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        PLTMemberRoleChangedPK INT NOT NULL,
        PLTMemberRolePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        PLTMemberRoleChangedPK,
		PLTMemberRolePK,
        RowNumber
    )
    SELECT smc.PLTMemberRoleChangedPK,
		   smc.PLTMemberRolePK,
           ROW_NUMBER() OVER (PARTITION BY smc.PLTMemberRolePK
                              ORDER BY smc.PLTMemberRoleChangedPK DESC
                             ) AS RowNum
    FROM dbo.PLTMemberRoleChanged smc
    WHERE EXISTS
    (
        SELECT d.PLTMemberRolePK FROM Deleted d WHERE d.PLTMemberRolePK = smc.PLTMemberRolePK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.PLTMemberRoleChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.PLTMemberRoleChangedPK = ecr.PLTMemberRoleChangedPK
    WHERE smc.PLTMemberRoleChangedPK = ecr.PLTMemberRoleChangedPK;
	
END
GO
ALTER TABLE [dbo].[PLTMemberRole] ADD CONSTRAINT [PK_PLTMemberRole] PRIMARY KEY CLUSTERED ([PLTMemberRolePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PLTMemberRole] ADD CONSTRAINT [FK_PLTMemberRole_CodeTeamPosition] FOREIGN KEY ([TeamPositionCodeFK]) REFERENCES [dbo].[CodeTeamPosition] ([CodeTeamPositionPK])
GO
ALTER TABLE [dbo].[PLTMemberRole] ADD CONSTRAINT [FK_PLTMemberRole_PLTMember] FOREIGN KEY ([PLTMemberFK]) REFERENCES [dbo].[PLTMember] ([PLTMemberPK])
GO

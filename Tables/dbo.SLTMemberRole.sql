CREATE TABLE [dbo].[SLTMemberRole]
(
[SLTMemberRolePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[SLTMemberFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_SLTMemberRole_Changed] 
   ON  [dbo].[SLTMemberRole] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTMemberRolePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTMemberRoleChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTMemberRolePK,
        Creator,
        CreateDate,
        SLTMemberFK,
        TeamPositionCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.SLTMemberRolePK,
        d.Creator,
        d.CreateDate,
        d.SLTMemberFK,
        d.TeamPositionCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTMemberRoleChangedPK INT NOT NULL,
        SLTMemberRolePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTMemberRoleChangedPK,
		SLTMemberRolePK,
        RowNumber
    )
    SELECT smc.SLTMemberRoleChangedPK,
		   smc.SLTMemberRolePK,
           ROW_NUMBER() OVER (PARTITION BY smc.SLTMemberRolePK
                              ORDER BY smc.SLTMemberRoleChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTMemberRoleChanged smc
    WHERE EXISTS
    (
        SELECT d.SLTMemberRolePK FROM Deleted d WHERE d.SLTMemberRolePK = smc.SLTMemberRolePK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.SLTMemberRoleChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.SLTMemberRoleChangedPK = ecr.SLTMemberRoleChangedPK
    WHERE smc.SLTMemberRoleChangedPK = ecr.SLTMemberRoleChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTMemberRole] ADD CONSTRAINT [PK_SLTMemberRole] PRIMARY KEY CLUSTERED ([SLTMemberRolePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMemberRole] ADD CONSTRAINT [FK_SLTMemberRole_CodeTeamPosition] FOREIGN KEY ([TeamPositionCodeFK]) REFERENCES [dbo].[CodeTeamPosition] ([CodeTeamPositionPK])
GO
ALTER TABLE [dbo].[SLTMemberRole] ADD CONSTRAINT [FK_SLTMemberRole_SLTMember] FOREIGN KEY ([SLTMemberFK]) REFERENCES [dbo].[SLTMember] ([SLTMemberPK])
GO

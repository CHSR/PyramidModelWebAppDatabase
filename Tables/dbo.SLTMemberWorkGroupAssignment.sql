CREATE TABLE [dbo].[SLTMemberWorkGroupAssignment]
(
[SLTMemberWorkGroupAssignmentPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[SLTWorkGroupFK] [int] NOT NULL,
[SLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/04/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_SLTMemberWorkGroupAssignment_Changed] 
   ON  [dbo].[SLTMemberWorkGroupAssignment] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTMemberWorkGroupAssignmentPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTMemberWorkGroupAssignmentChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTMemberWorkGroupAssignmentPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EndDate,
        StartDate,
        SLTWorkGroupFK,
        SLTMemberFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.SLTMemberWorkGroupAssignmentPK,
		d.Creator,
		d.CreateDate,
		d.Editor,
		d.EditDate,
		d.EndDate,
		d.StartDate,
		d.SLTWorkGroupFK,
        d.SLTMemberFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTMemberWorkGroupAssignmentChangedPK INT NOT NULL,
        SLTMemberWorkGroupAssignmentPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTMemberWorkGroupAssignmentChangedPK,
		SLTMemberWorkGroupAssignmentPK,
        RowNumber
    )
    SELECT smaac.SLTMemberWorkGroupAssignmentChangedPK,
		   smaac.SLTMemberWorkGroupAssignmentPK,
           ROW_NUMBER() OVER (PARTITION BY smaac.SLTMemberWorkGroupAssignmentPK
                              ORDER BY smaac.SLTMemberWorkGroupAssignmentChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTMemberWorkGroupAssignmentChanged smaac
    WHERE EXISTS
    (
        SELECT d.SLTMemberWorkGroupAssignmentPK FROM Deleted d WHERE d.SLTMemberWorkGroupAssignmentPK = smaac.SLTMemberWorkGroupAssignmentPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smaac
    FROM dbo.SLTMemberWorkGroupAssignmentChanged smaac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.SLTMemberWorkGroupAssignmentChangedPK = smaac.SLTMemberWorkGroupAssignmentChangedPK
    WHERE ecr.SLTMemberWorkGroupAssignmentChangedPK = smaac.SLTMemberWorkGroupAssignmentChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTMemberWorkGroupAssignment] ADD CONSTRAINT [PK_SLTMemberWorkGroupAssignment] PRIMARY KEY CLUSTERED ([SLTMemberWorkGroupAssignmentPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMemberWorkGroupAssignment] ADD CONSTRAINT [FK_SLTMemberWorkGroupAssignment_SLTMember] FOREIGN KEY ([SLTMemberFK]) REFERENCES [dbo].[SLTMember] ([SLTMemberPK])
GO
ALTER TABLE [dbo].[SLTMemberWorkGroupAssignment] ADD CONSTRAINT [FK_SLTMemberWorkGroupAssignment_SLTWorkGroup] FOREIGN KEY ([SLTWorkGroupFK]) REFERENCES [dbo].[SLTWorkGroup] ([SLTWorkGroupPK])
GO

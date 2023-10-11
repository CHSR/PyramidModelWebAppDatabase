CREATE TABLE [dbo].[ChildClassroom]
(
[ChildClassroomPK] [int] NOT NULL IDENTITY(1, 1),
[AssignDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeaveDate] [datetime] NULL,
[LeaveReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildFK] [int] NOT NULL,
[ClassroomFK] [int] NOT NULL,
[LeaveReasonCodeFK] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 08/07/2019
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ChildClassroom_Changed] 
   ON  [dbo].[ChildClassroom] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ChildClassroomPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildClassroomChanged
    (
        ChangeDatetime,
        ChangeType,
        ChildClassroomPK,
        AssignDate,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        LeaveDate,
        LeaveReasonSpecify,
        ChildFK,
        ClassroomFK,
        LeaveReasonCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ChildClassroomPK,
        d.AssignDate,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.LeaveDate,
        d.LeaveReasonSpecify,
        d.ChildFK,
        d.ClassroomFK,
        d.LeaveReasonCodeFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ChildClassroomChangedPK INT NOT NULL,
        ChildClassroomPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected child classroom rows
    INSERT INTO @ExistingChangeRows
    (
        ChildClassroomChangedPK,
		ChildClassroomPK,
        RowNumber
    )
    SELECT cc.ChildClassroomChangedPK,
		   cc.ChildClassroomPK,
           ROW_NUMBER() OVER (PARTITION BY cc.ChildClassroomPK
                              ORDER BY cc.ChildClassroomChangedPK DESC
                             ) AS RowNum
    FROM dbo.ChildClassroomChanged cc
    WHERE EXISTS
    (
        SELECT d.ChildClassroomPK FROM Deleted d WHERE d.ChildClassroomPK = cc.ChildClassroomPK
    );

	--Remove all but the most recent 5 change rows for each affected child classroom row
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.ChildClassroomChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.ChildClassroomChangedPK = ecr.ChildClassroomChangedPK
    WHERE cc.ChildClassroomChangedPK = ecr.ChildClassroomChangedPK;
	
END
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [PK_ChildClassroom] PRIMARY KEY CLUSTERED ([ChildClassroomPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_ChildClassroom_FBC2F2777E4710470BACEB3DB78B17E3] ON [dbo].[ChildClassroom] ([ChildFK], [ChildClassroomPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_CodeChildLeaveReason] FOREIGN KEY ([LeaveReasonCodeFK]) REFERENCES [dbo].[CodeChildLeaveReason] ([CodeChildLeaveReasonPK])
GO

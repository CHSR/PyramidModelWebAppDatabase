CREATE TABLE [dbo].[EmployeeClassroom]
(
[EmployeeClassroomPK] [int] NOT NULL IDENTITY(1, 1),
[AssignDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeaveDate] [datetime] NULL,
[LeaveReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassroomFK] [int] NOT NULL,
[JobTypeCodeFK] [int] NOT NULL CONSTRAINT [DF_EmployeeClassroom_JobTypeCodeFK] DEFAULT ((1)),
[LeaveReasonCodeFK] [int] NULL,
[ProgramEmployeeFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_EmployeeClassroom_Changed] 
   ON  [dbo].[EmployeeClassroom] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.EmployeeClassroomPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.EmployeeClassroomChanged
    (
        ChangeDatetime,
        ChangeType,
        EmployeeClassroomPK,
        AssignDate,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        LeaveDate,
        LeaveReasonSpecify,
        ClassroomFK,
        JobTypeCodeFK,
        LeaveReasonCodeFK,
        ProgramEmployeeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.EmployeeClassroomPK,
        d.AssignDate,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.LeaveDate,
        d.LeaveReasonSpecify,
        d.ClassroomFK,
        d.JobTypeCodeFK,
        d.LeaveReasonCodeFK,
        d.ProgramEmployeeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        EmployeeClassroomChangedPK INT NOT NULL,
        EmployeeClassroomPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee classroom rows
    INSERT INTO @ExistingChangeRows
    (
        EmployeeClassroomChangedPK,
		EmployeeClassroomPK,
        RowNumber
    )
    SELECT cc.EmployeeClassroomChangedPK,
		   cc.EmployeeClassroomPK,
           ROW_NUMBER() OVER (PARTITION BY cc.EmployeeClassroomPK
                              ORDER BY cc.EmployeeClassroomChangedPK DESC
                             ) AS RowNum
    FROM dbo.EmployeeClassroomChanged cc
    WHERE EXISTS
    (
        SELECT d.EmployeeClassroomPK FROM Deleted d WHERE d.EmployeeClassroomPK = cc.EmployeeClassroomPK
    );

	--Remove all but the most recent 5 change rows for each affected employee classroom row
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.EmployeeClassroomChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.EmployeeClassroomChangedPK = ecr.EmployeeClassroomChangedPK
    WHERE cc.EmployeeClassroomChangedPK = ecr.EmployeeClassroomChangedPK;
	
END
GO
ALTER TABLE [dbo].[EmployeeClassroom] ADD CONSTRAINT [PK_EmployeeClassroom] PRIMARY KEY CLUSTERED ([EmployeeClassroomPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeClassroom] ADD CONSTRAINT [FK_EmployeeClassroom_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[EmployeeClassroom] ADD CONSTRAINT [FK_EmployeeClassroom_CodeEmployeeLeaveReason] FOREIGN KEY ([LeaveReasonCodeFK]) REFERENCES [dbo].[CodeEmployeeLeaveReason] ([CodeEmployeeLeaveReasonPK])
GO
ALTER TABLE [dbo].[EmployeeClassroom] ADD CONSTRAINT [FK_EmployeeClassroom_CodeJobType] FOREIGN KEY ([JobTypeCodeFK]) REFERENCES [dbo].[CodeJobType] ([CodeJobTypePK])
GO
ALTER TABLE [dbo].[EmployeeClassroom] ADD CONSTRAINT [FK_EmployeeClassroom_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

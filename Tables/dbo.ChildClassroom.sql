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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildClassroomChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ChildClassroomPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ChildClassroomPK,
	    MinChangeDatetime
	)
	SELECT ac.ChildClassroomPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ChildClassroomChanged ac
	GROUP BY ac.ChildClassroomPK
	HAVING COUNT(ac.ChildClassroomPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ChildClassroomChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ChildClassroomPK = ecr.ChildClassroomPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ChildClassroomPK = ecr.ChildClassroomPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [PK_ChildClassroom] PRIMARY KEY CLUSTERED  ([ChildClassroomPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[ChildClassroom] ADD CONSTRAINT [FK_ChildClassroom_CodeChildLeaveReason] FOREIGN KEY ([LeaveReasonCodeFK]) REFERENCES [dbo].[CodeChildLeaveReason] ([CodeChildLeaveReasonPK])
GO

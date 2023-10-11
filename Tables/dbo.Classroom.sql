CREATE TABLE [dbo].[Classroom]
(
[ClassroomPK] [int] NOT NULL IDENTITY(1, 1),
[BeingServedSubstitute] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsInfantToddler] [bit] NOT NULL,
[IsPreschool] [bit] NOT NULL,
[Location] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramSpecificID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_Classroom_Changed] 
   ON  [dbo].[Classroom] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ClassroomPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ClassroomChanged
    (
        ChangeDatetime,
        ChangeType,
        ClassroomPK,
        BeingServedSubstitute,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        IsInfantToddler,
        IsPreschool,
        Location,
        Name,
        ProgramSpecificID,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ClassroomPK,
        d.BeingServedSubstitute,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.IsInfantToddler,
        d.IsPreschool,
        d.Location,
        d.Name,
        d.ProgramSpecificID,
        d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ClassroomChangedPK INT NOT NULL,
        ClassroomPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected classrooms
    INSERT INTO @ExistingChangeRows
    (
        ClassroomChangedPK,
		ClassroomPK,
        RowNumber
    )
    SELECT cc.ClassroomChangedPK,
		   cc.ClassroomPK,
           ROW_NUMBER() OVER (PARTITION BY cc.ClassroomPK
                              ORDER BY cc.ClassroomChangedPK DESC
                             ) AS RowNum
    FROM dbo.ClassroomChanged cc
    WHERE EXISTS
    (
        SELECT d.ClassroomPK FROM Deleted d WHERE d.ClassroomPK = cc.ClassroomPK
    );

	--Remove all but the most recent 5 change rows for each affected classroom
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.ClassroomChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.ClassroomChangedPK = ecr.ClassroomChangedPK
    WHERE cc.ClassroomChangedPK = ecr.ClassroomChangedPK;
	
END
GO
ALTER TABLE [dbo].[Classroom] ADD CONSTRAINT [PK_Classroom] PRIMARY KEY CLUSTERED ([ClassroomPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_Classroom_95ED841BAD90E909BAB43CD4A5243A73] ON [dbo].[Classroom] ([ProgramFK], [IsPreschool]) INCLUDE ([BeingServedSubstitute], [CreateDate], [Creator], [EditDate], [Editor], [IsInfantToddler], [Location], [Name], [ProgramSpecificID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ClassroomUnique] ON [dbo].[Classroom] ([ProgramSpecificID], [ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Classroom] ADD CONSTRAINT [FK_Classroom_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

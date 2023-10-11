CREATE TABLE [dbo].[ChildNote]
(
[ChildNotePK] [int] NOT NULL IDENTITY(1, 1),
[Contents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[NoteDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ChildFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_ChildNote_Changed] 
   ON  [dbo].[ChildNote] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ChildNotePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildNoteChanged
    (
        ChangeDatetime,
        ChangeType,
        ChildNotePK,
        Contents,
        Creator,
        CreateDate,
        NoteDate,
        Editor,
        EditDate,
        ChildFK,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ChildNotePK,
        d.Contents,
        d.Creator,
        d.CreateDate,
        d.NoteDate,
        d.Editor,
        d.EditDate,
        d.ChildFK,
        d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ChildNoteChangedPK INT NOT NULL,
        ChildNotePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected child notes
    INSERT INTO @ExistingChangeRows
    (
        ChildNoteChangedPK,
		ChildNotePK,
        RowNumber
    )
    SELECT cc.ChildNoteChangedPK,
		   cc.ChildNotePK,
           ROW_NUMBER() OVER (PARTITION BY cc.ChildNotePK
                              ORDER BY cc.ChildNoteChangedPK DESC
                             ) AS RowNum
    FROM dbo.ChildNoteChanged cc
    WHERE EXISTS
    (
        SELECT d.ChildNotePK FROM Deleted d WHERE d.ChildNotePK = cc.ChildNotePK
    );

	--Remove all but the most recent 5 change rows for each affected child note
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.ChildNoteChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.ChildNoteChangedPK = ecr.ChildNoteChangedPK
    WHERE cc.ChildNoteChangedPK = ecr.ChildNoteChangedPK;
	
END
GO
ALTER TABLE [dbo].[ChildNote] ADD CONSTRAINT [PK_ChildNote] PRIMARY KEY CLUSTERED  ([ChildNotePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildNote] ADD CONSTRAINT [FK_ChildNote_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildNote] ADD CONSTRAINT [FK_ChildNote_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

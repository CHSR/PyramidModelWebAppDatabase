CREATE TABLE [dbo].[FormDueDate]
(
[FormDueDatePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DueEndWindow] [int] NOT NULL,
[DueRecommendedDate] [datetime] NOT NULL,
[DueStartWindow] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[HelpText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodeFormFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/11/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_FormDueDate_Changed] 
   ON  [dbo].[FormDueDate] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.FormDueDatePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.FormDueDateChanged
    (
        ChangeDatetime,
        ChangeType,
        FormDueDatePK,
        Creator,
        CreateDate,
        DueEndWindow,
        DueRecommendedDate,
        DueStartWindow,
        Editor,
        EditDate,
		HelpText,
        CodeFormFK,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.FormDueDatePK,
        d.Creator,
        d.CreateDate,
        d.DueEndWindow,
        d.DueRecommendedDate,
        d.DueStartWindow,
        d.Editor,
        d.EditDate,
		d.HelpText,
        d.CodeFormFK,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        FormDueDateChangedPK INT NOT NULL,
        FormDueDatePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected form due date rows
    INSERT INTO @ExistingChangeRows
    (
        FormDueDateChangedPK,
		FormDueDatePK,
        RowNumber
    )
    SELECT cc.FormDueDateChangedPK,
		   cc.FormDueDatePK,
           ROW_NUMBER() OVER (PARTITION BY cc.FormDueDatePK
                              ORDER BY cc.FormDueDateChangedPK DESC
                             ) AS RowNum
    FROM dbo.FormDueDateChanged cc
    WHERE EXISTS
    (
        SELECT d.FormDueDatePK FROM Deleted d WHERE d.FormDueDatePK = cc.FormDueDatePK
    );

	--Remove all but the most recent 5 change rows for each affected form due date row
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.FormDueDateChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.FormDueDateChangedPK = ecr.FormDueDateChangedPK
    WHERE cc.FormDueDateChangedPK = ecr.FormDueDateChangedPK;
	
END
GO
ALTER TABLE [dbo].[FormDueDate] ADD CONSTRAINT [PK_FormDueDate] PRIMARY KEY CLUSTERED  ([FormDueDatePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FormDueDate] ADD CONSTRAINT [FK_FormDueDate_CodeForm] FOREIGN KEY ([CodeFormFK]) REFERENCES [dbo].[CodeForm] ([CodeFormPK])
GO
ALTER TABLE [dbo].[FormDueDate] ADD CONSTRAINT [FK_FormDueDate_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

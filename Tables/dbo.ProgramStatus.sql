CREATE TABLE [dbo].[ProgramStatus]
(
[ProgramStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[StatusDetails] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[StatusFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 11/17/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_Program_Status_Changed] 
   ON  [dbo].[ProgramStatus] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramStatusPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramStatusChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramStatusPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		StatusDate,
		StatusDetails,
		ProgramFK,
		StatusFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ProgramStatusPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
		d.StatusDate,
		d.StatusDetails,
		d.ProgramFK,
		d.StatusFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramStatusChangedPK INT NOT NULL,
        ProgramStatusPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected program status
    INSERT INTO @ExistingChangeRows
    (
        ProgramStatusChangedPK,
		ProgramStatusPK,
        RowNumber
    )
    SELECT pc.ProgramStatusChangedPK,
		   pc.ProgramStatusPK,
           ROW_NUMBER() OVER (PARTITION BY pc.ProgramStatusPK
                              ORDER BY pc.ProgramStatusChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramStatusChanged pc
    WHERE EXISTS
    (
        SELECT d.ProgramStatusPK FROM Deleted d WHERE d.ProgramStatusPK = pc.ProgramStatusPK
    );

	--Remove all but the most recent 5 change rows for each affected ProgramStatus
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE pc
    FROM dbo.ProgramStatusChanged pc
        INNER JOIN @ExistingChangeRows ecr
            ON pc.ProgramStatusChangedPK = ecr.ProgramStatusChangedPK
    WHERE pc.ProgramStatusChangedPK = ecr.ProgramStatusChangedPK;
	
END
GO
ALTER TABLE [dbo].[ProgramStatus] ADD CONSTRAINT [PK_ProgramStatusDate] PRIMARY KEY CLUSTERED ([ProgramStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramStatus] ADD CONSTRAINT [FK__ProgramStatusDate_CodeProgramStatus] FOREIGN KEY ([StatusFK]) REFERENCES [dbo].[CodeProgramStatus] ([CodeProgramStatusPK])
GO
ALTER TABLE [dbo].[ProgramStatus] ADD CONSTRAINT [FK__ProgramStatusDate_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

CREATE TABLE [dbo].[ProgramActionPlanActionStepStatus]
(
[ProgramActionPlanActionStepStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[ProgramActionPlanActionStepFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 09/23/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramActionPlanActionStepStatus_Changed]
ON [dbo].[ProgramActionPlanActionStepStatus]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanActionStepStatusChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanActionStepStatusPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StatusDate,
        ActionPlanActionStepStatusCodeFK,
        ProgramActionPlanActionStepFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanActionStepStatusPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.StatusDate,
           d.ActionPlanActionStepStatusCodeFK,
           d.ProgramActionPlanActionStepFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanActionStepStatusChangedPK INT NOT NULL,
        ProgramActionPlanActionStepStatusPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanActionStepStatusChangedPK,
        ProgramActionPlanActionStepStatusPK,
        RowNumber
    )
    SELECT papassc.ProgramActionPlanActionStepStatusChangedPK,
		   papassc.ProgramActionPlanActionStepStatusPK,
		   ROW_NUMBER() OVER (PARTITION BY papassc.ProgramActionPlanActionStepStatusPK
                              ORDER BY papassc.ProgramActionPlanActionStepStatusChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanActionStepStatusChanged papassc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanActionStepStatusPK FROM Deleted d WHERE d.ProgramActionPlanActionStepStatusPK = papassc.ProgramActionPlanActionStepStatusPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papassc
    FROM dbo.ProgramActionPlanActionStepStatusChanged papassc
        INNER JOIN @ExistingChangeRows ecr
            ON papassc.ProgramActionPlanActionStepStatusChangedPK = ecr.ProgramActionPlanActionStepStatusChangedPK
    WHERE papassc.ProgramActionPlanActionStepStatusChangedPK = ecr.ProgramActionPlanActionStepStatusChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramActionPlanActionStepStatus] ADD CONSTRAINT [PK_ProgramActionPlanActionStepStatus] PRIMARY KEY CLUSTERED ([ProgramActionPlanActionStepStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanActionStepStatus] ADD CONSTRAINT [FK_ProgramActionPlanActionStepStatus_CodeActionPlanActionStepStatus] FOREIGN KEY ([ProgramActionPlanActionStepFK]) REFERENCES [dbo].[ProgramActionPlanActionStep] ([ProgramActionPlanActionStepPK])
GO
ALTER TABLE [dbo].[ProgramActionPlanActionStepStatus] ADD CONSTRAINT [FK_ProgramActionPlanActionStepStatus_CodeActionPlanActionStepStatus1] FOREIGN KEY ([ActionPlanActionStepStatusCodeFK]) REFERENCES [dbo].[CodeActionPlanActionStepStatus] ([CodeActionPlanActionStepStatusPK])
GO

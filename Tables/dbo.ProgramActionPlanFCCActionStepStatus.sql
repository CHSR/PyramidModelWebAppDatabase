CREATE TABLE [dbo].[ProgramActionPlanFCCActionStepStatus]
(
[ProgramActionPlanFCCActionStepStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[ProgramActionPlanFCCActionStepFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramActionPlanFCCActionStepStatus_Changed]
ON [dbo].[ProgramActionPlanFCCActionStepStatus]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanFCCActionStepStatusChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanFCCActionStepStatusPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StatusDate,
        ActionPlanActionStepStatusCodeFK,
        ProgramActionPlanFCCActionStepFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanFCCActionStepStatusPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.StatusDate,
           d.ActionPlanActionStepStatusCodeFK,
           d.ProgramActionPlanFCCActionStepFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanFCCActionStepStatusChangedPK INT NOT NULL,
        ProgramActionPlanFCCActionStepStatusPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanFCCActionStepStatusChangedPK,
        ProgramActionPlanFCCActionStepStatusPK,
        RowNumber
    )
    SELECT papassc.ProgramActionPlanFCCActionStepStatusChangedPK,
		   papassc.ProgramActionPlanFCCActionStepStatusPK,
		   ROW_NUMBER() OVER (PARTITION BY papassc.ProgramActionPlanFCCActionStepStatusPK
                              ORDER BY papassc.ProgramActionPlanFCCActionStepStatusChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanFCCActionStepStatusChanged papassc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanFCCActionStepStatusPK FROM Deleted d WHERE d.ProgramActionPlanFCCActionStepStatusPK = papassc.ProgramActionPlanFCCActionStepStatusPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papassc
    FROM dbo.ProgramActionPlanFCCActionStepStatusChanged papassc
        INNER JOIN @ExistingChangeRows ecr
            ON papassc.ProgramActionPlanFCCActionStepStatusChangedPK = ecr.ProgramActionPlanFCCActionStepStatusChangedPK
    WHERE papassc.ProgramActionPlanFCCActionStepStatusChangedPK = ecr.ProgramActionPlanFCCActionStepStatusChangedPK;

END;

GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStepStatus] ADD CONSTRAINT [PK_ProgramActionPlanFCCActionStepStatus] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCActionStepStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStepStatus] ADD CONSTRAINT [FK_ProgramActionPlanFCCActionStepStatus_CodeActionPlanActionStepStatus] FOREIGN KEY ([ProgramActionPlanFCCActionStepFK]) REFERENCES [dbo].[ProgramActionPlanFCCActionStep] ([ProgramActionPlanFCCActionStepPK])
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStepStatus] ADD CONSTRAINT [FK_ProgramActionPlanFCCActionStepStatus_CodeActionPlanActionStepStatus1] FOREIGN KEY ([ActionPlanActionStepStatusCodeFK]) REFERENCES [dbo].[CodeActionPlanActionStepStatus] ([CodeActionPlanActionStepStatusPK])
GO

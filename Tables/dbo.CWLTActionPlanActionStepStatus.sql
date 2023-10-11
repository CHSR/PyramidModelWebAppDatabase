CREATE TABLE [dbo].[CWLTActionPlanActionStepStatus]
(
[CWLTActionPlanActionStepStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[CWLTActionPlanActionStepFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CWLTActionPlanActionStepStatus_Changed]
ON [dbo].[CWLTActionPlanActionStepStatus]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTActionPlanActionStepStatusChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTActionPlanActionStepStatusPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StatusDate,
        ActionPlanActionStepStatusCodeFK,
        CWLTActionPlanActionStepFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.CWLTActionPlanActionStepStatusPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.StatusDate,
           d.ActionPlanActionStepStatusCodeFK,
           d.CWLTActionPlanActionStepFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTActionPlanActionStepStatusChangedPK INT NOT NULL,
        CWLTActionPlanActionStepStatusPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		CWLTActionPlanActionStepStatusChangedPK,
        CWLTActionPlanActionStepStatusPK,
        RowNumber
    )
    SELECT papassc.CWLTActionPlanActionStepStatusChangedPK,
		   papassc.CWLTActionPlanActionStepStatusPK,
		   ROW_NUMBER() OVER (PARTITION BY papassc.CWLTActionPlanActionStepStatusPK
                              ORDER BY papassc.CWLTActionPlanActionStepStatusChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTActionPlanActionStepStatusChanged papassc
    WHERE EXISTS
    (
        SELECT d.CWLTActionPlanActionStepStatusPK FROM Deleted d WHERE d.CWLTActionPlanActionStepStatusPK = papassc.CWLTActionPlanActionStepStatusPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papassc
    FROM dbo.CWLTActionPlanActionStepStatusChanged papassc
        INNER JOIN @ExistingChangeRows ecr
            ON papassc.CWLTActionPlanActionStepStatusChangedPK = ecr.CWLTActionPlanActionStepStatusChangedPK
    WHERE papassc.CWLTActionPlanActionStepStatusChangedPK = ecr.CWLTActionPlanActionStepStatusChangedPK;

END;
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStepStatus] ADD CONSTRAINT [PK_CWLTActionPlanActionStepStatus] PRIMARY KEY CLUSTERED ([CWLTActionPlanActionStepStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStepStatus] ADD CONSTRAINT [FK_CWLTActionPlanActionStepStatus_CodeActionPlanActionStepStatus] FOREIGN KEY ([CWLTActionPlanActionStepFK]) REFERENCES [dbo].[CWLTActionPlanActionStep] ([CWLTActionPlanActionStepPK])
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStepStatus] ADD CONSTRAINT [FK_CWLTActionPlanActionStepStatus_CodeActionPlanActionStepStatus1] FOREIGN KEY ([ActionPlanActionStepStatusCodeFK]) REFERENCES [dbo].[CodeActionPlanActionStepStatus] ([CodeActionPlanActionStepStatusPK])
GO

CREATE TABLE [dbo].[SLTActionPlanActionStepStatus]
(
[SLTActionPlanActionStepStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ActionPlanActionStepStatusCodeFK] [int] NOT NULL,
[SLTActionPlanActionStepFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_SLTActionPlanActionStepStatus_Changed]
ON [dbo].[SLTActionPlanActionStepStatus]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTActionPlanActionStepStatusChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTActionPlanActionStepStatusPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StatusDate,
        ActionPlanActionStepStatusCodeFK,
        SLTActionPlanActionStepFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.SLTActionPlanActionStepStatusPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.StatusDate,
           d.ActionPlanActionStepStatusCodeFK,
           d.SLTActionPlanActionStepFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTActionPlanActionStepStatusChangedPK INT NOT NULL,
        SLTActionPlanActionStepStatusPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		SLTActionPlanActionStepStatusChangedPK,
        SLTActionPlanActionStepStatusPK,
        RowNumber
    )
    SELECT papassc.SLTActionPlanActionStepStatusChangedPK,
		   papassc.SLTActionPlanActionStepStatusPK,
		   ROW_NUMBER() OVER (PARTITION BY papassc.SLTActionPlanActionStepStatusPK
                              ORDER BY papassc.SLTActionPlanActionStepStatusChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTActionPlanActionStepStatusChanged papassc
    WHERE EXISTS
    (
        SELECT d.SLTActionPlanActionStepStatusPK FROM Deleted d WHERE d.SLTActionPlanActionStepStatusPK = papassc.SLTActionPlanActionStepStatusPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papassc
    FROM dbo.SLTActionPlanActionStepStatusChanged papassc
        INNER JOIN @ExistingChangeRows ecr
            ON papassc.SLTActionPlanActionStepStatusChangedPK = ecr.SLTActionPlanActionStepStatusChangedPK
    WHERE papassc.SLTActionPlanActionStepStatusChangedPK = ecr.SLTActionPlanActionStepStatusChangedPK;

END;
GO
ALTER TABLE [dbo].[SLTActionPlanActionStepStatus] ADD CONSTRAINT [PK_SLTActionPlanActionStepStatus] PRIMARY KEY CLUSTERED ([SLTActionPlanActionStepStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlanActionStepStatus] ADD CONSTRAINT [FK_SLTActionPlanActionStepStatus_CodeActionPlanActionStepStatus] FOREIGN KEY ([SLTActionPlanActionStepFK]) REFERENCES [dbo].[SLTActionPlanActionStep] ([SLTActionPlanActionStepPK])
GO
ALTER TABLE [dbo].[SLTActionPlanActionStepStatus] ADD CONSTRAINT [FK_SLTActionPlanActionStepStatus_CodeActionPlanActionStepStatus1] FOREIGN KEY ([ActionPlanActionStepStatusCodeFK]) REFERENCES [dbo].[CodeActionPlanActionStepStatus] ([CodeActionPlanActionStepStatusPK])
GO

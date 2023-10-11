CREATE TABLE [dbo].[CWLTActionPlanActionStep]
(
[CWLTActionPlanActionStepPK] [int] NOT NULL IDENTITY(1, 1),
[ActionStepActivity] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[PersonsResponsible] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProblemIssueTask] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetDate] [datetime] NOT NULL,
[BOQIndicatorCodeFK] [int] NOT NULL,
[CWLTActionPlanFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CWLTActionPlanActionStep_Changed]
ON [dbo].[CWLTActionPlanActionStep]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTActionPlanActionStepChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTActionPlanActionStepPK,
		ActionStepActivity,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        PersonsResponsible,
		ProblemIssueTask,
        TargetDate,
        BOQIndicatorCodeFK,
        CWLTActionPlanFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.CWLTActionPlanActionStepPK,
		   d.ActionStepActivity,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.PersonsResponsible,
		   d.ProblemIssueTask,
           d.TargetDate,
           d.BOQIndicatorCodeFK,
           d.CWLTActionPlanFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTActionPlanActionStepChangedPK INT NOT NULL,
        CWLTActionPlanActionStepPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		CWLTActionPlanActionStepChangedPK,
        CWLTActionPlanActionStepPK,
        RowNumber
    )
    SELECT papasc.CWLTActionPlanActionStepChangedPK,
		   papasc.CWLTActionPlanActionStepPK,
		   ROW_NUMBER() OVER (PARTITION BY papasc.CWLTActionPlanActionStepPK
                              ORDER BY papasc.CWLTActionPlanActionStepChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTActionPlanActionStepChanged papasc
    WHERE EXISTS
    (
        SELECT d.CWLTActionPlanActionStepPK FROM Deleted d WHERE d.CWLTActionPlanActionStepPK = papasc.CWLTActionPlanActionStepPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papasc
    FROM dbo.CWLTActionPlanActionStepChanged papasc
        INNER JOIN @ExistingChangeRows ecr
            ON papasc.CWLTActionPlanActionStepChangedPK = ecr.CWLTActionPlanActionStepChangedPK
    WHERE papasc.CWLTActionPlanActionStepChangedPK = ecr.CWLTActionPlanActionStepChangedPK;

END;
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStep] ADD CONSTRAINT [PK_CWLTActionPlanActionStep] PRIMARY KEY CLUSTERED ([CWLTActionPlanActionStepPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStep] ADD CONSTRAINT [FK_CWLTActionPlanActionStep_CodeBOQIndicator] FOREIGN KEY ([BOQIndicatorCodeFK]) REFERENCES [dbo].[CodeBOQIndicator] ([CodeBOQIndicatorPK])
GO
ALTER TABLE [dbo].[CWLTActionPlanActionStep] ADD CONSTRAINT [FK_CWLTActionPlanActionStep_CWLTActionPlan] FOREIGN KEY ([CWLTActionPlanFK]) REFERENCES [dbo].[CWLTActionPlan] ([CWLTActionPlanPK])
GO

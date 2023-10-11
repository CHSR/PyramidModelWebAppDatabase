CREATE TABLE [dbo].[ProgramActionPlanFCCActionStep]
(
[ProgramActionPlanFCCActionStepPK] [int] NOT NULL IDENTITY(1, 1),
[ActionStepActivity] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[PersonsResponsible] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProblemIssueTask] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetDate] [datetime] NOT NULL,
[BOQIndicatorCodeFK] [int] NOT NULL,
[ProgramActionPlanFCCFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramActionPlanFCCActionStep_Changed]
ON [dbo].[ProgramActionPlanFCCActionStep]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanFCCActionStepChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanFCCActionStepPK,
		ActionStepActivity,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        PersonsResponsible,
		ProblemIssueTask,
        TargetDate,
        BOQIndicatorCodeFK,
        ProgramActionPlanFCCFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanFCCActionStepPK,
		   d.ActionStepActivity,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.PersonsResponsible,
		   d.ProblemIssueTask,
           d.TargetDate,
           d.BOQIndicatorCodeFK,
           d.ProgramActionPlanFCCFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanFCCActionStepChangedPK INT NOT NULL,
        ProgramActionPlanFCCActionStepPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanFCCActionStepChangedPK,
        ProgramActionPlanFCCActionStepPK,
        RowNumber
    )
    SELECT papasc.ProgramActionPlanFCCActionStepChangedPK,
		   papasc.ProgramActionPlanFCCActionStepPK,
		   ROW_NUMBER() OVER (PARTITION BY papasc.ProgramActionPlanFCCActionStepPK
                              ORDER BY papasc.ProgramActionPlanFCCActionStepChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanFCCActionStepChanged papasc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanFCCActionStepPK FROM Deleted d WHERE d.ProgramActionPlanFCCActionStepPK = papasc.ProgramActionPlanFCCActionStepPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papasc
    FROM dbo.ProgramActionPlanFCCActionStepChanged papasc
        INNER JOIN @ExistingChangeRows ecr
            ON papasc.ProgramActionPlanFCCActionStepChangedPK = ecr.ProgramActionPlanFCCActionStepChangedPK
    WHERE papasc.ProgramActionPlanFCCActionStepChangedPK = ecr.ProgramActionPlanFCCActionStepChangedPK;

END;

GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStep] ADD CONSTRAINT [PK_ProgramActionPlanFCCActionStep] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCActionStepPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStep] ADD CONSTRAINT [FK_ProgramActionPlanFCCActionStep_CodeBOQIndicator] FOREIGN KEY ([BOQIndicatorCodeFK]) REFERENCES [dbo].[CodeBOQIndicator] ([CodeBOQIndicatorPK])
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCActionStep] ADD CONSTRAINT [FK_ProgramActionPlanFCCActionStep_ProgramActionPlanFCC] FOREIGN KEY ([ProgramActionPlanFCCFK]) REFERENCES [dbo].[ProgramActionPlanFCC] ([ProgramActionPlanFCCPK])
GO

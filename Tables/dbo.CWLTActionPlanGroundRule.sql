CREATE TABLE [dbo].[CWLTActionPlanGroundRule]
(
[CWLTActionPlanGroundRulePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[GroundRuleDescription] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroundRuleNumber] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_CWLTActionPlanGroundRule_Changed]
ON [dbo].[CWLTActionPlanGroundRule]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTActionPlanGroundRuleChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTActionPlanGroundRulePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        GroundRuleDescription,
		GroundRuleNumber,
        CWLTActionPlanFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.CWLTActionPlanGroundRulePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.GroundRuleDescription,
		   d.GroundRuleNumber,
           d.CWLTActionPlanFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTActionPlanGroundRuleChangedPK INT NOT NULL,
        CWLTActionPlanGroundRulePK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		CWLTActionPlanGroundRuleChangedPK,
        CWLTActionPlanGroundRulePK,
        RowNumber
    )
    SELECT papgrc.CWLTActionPlanGroundRuleChangedPK,
		   papgrc.CWLTActionPlanGroundRulePK,
		   ROW_NUMBER() OVER (PARTITION BY papgrc.CWLTActionPlanGroundRulePK
                              ORDER BY papgrc.CWLTActionPlanGroundRuleChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTActionPlanGroundRuleChanged papgrc
    WHERE EXISTS
    (
        SELECT d.CWLTActionPlanGroundRulePK FROM Deleted d WHERE d.CWLTActionPlanGroundRulePK = papgrc.CWLTActionPlanGroundRulePK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papgrc
    FROM dbo.CWLTActionPlanGroundRuleChanged papgrc
        INNER JOIN @ExistingChangeRows ecr
            ON papgrc.CWLTActionPlanGroundRuleChangedPK = ecr.CWLTActionPlanGroundRuleChangedPK
    WHERE papgrc.CWLTActionPlanGroundRuleChangedPK = ecr.CWLTActionPlanGroundRuleChangedPK;

END;
GO
ALTER TABLE [dbo].[CWLTActionPlanGroundRule] ADD CONSTRAINT [PK_CWLTActionPlanGroundRule] PRIMARY KEY CLUSTERED ([CWLTActionPlanGroundRulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanGroundRule] ADD CONSTRAINT [FK_CWLTActionPlanGroundRule_CWLTActionPlan] FOREIGN KEY ([CWLTActionPlanFK]) REFERENCES [dbo].[CWLTActionPlan] ([CWLTActionPlanPK])
GO

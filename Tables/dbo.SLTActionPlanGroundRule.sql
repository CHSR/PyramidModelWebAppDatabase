CREATE TABLE [dbo].[SLTActionPlanGroundRule]
(
[SLTActionPlanGroundRulePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[GroundRuleDescription] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroundRuleNumber] [int] NOT NULL,
[SLTActionPlanFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_SLTActionPlanGroundRule_Changed]
ON [dbo].[SLTActionPlanGroundRule]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTActionPlanGroundRuleChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTActionPlanGroundRulePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        GroundRuleDescription,
		GroundRuleNumber,
        SLTActionPlanFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.SLTActionPlanGroundRulePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.GroundRuleDescription,
		   d.GroundRuleNumber,
           d.SLTActionPlanFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTActionPlanGroundRuleChangedPK INT NOT NULL,
        SLTActionPlanGroundRulePK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		SLTActionPlanGroundRuleChangedPK,
        SLTActionPlanGroundRulePK,
        RowNumber
    )
    SELECT papgrc.SLTActionPlanGroundRuleChangedPK,
		   papgrc.SLTActionPlanGroundRulePK,
		   ROW_NUMBER() OVER (PARTITION BY papgrc.SLTActionPlanGroundRulePK
                              ORDER BY papgrc.SLTActionPlanGroundRuleChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTActionPlanGroundRuleChanged papgrc
    WHERE EXISTS
    (
        SELECT d.SLTActionPlanGroundRulePK FROM Deleted d WHERE d.SLTActionPlanGroundRulePK = papgrc.SLTActionPlanGroundRulePK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papgrc
    FROM dbo.SLTActionPlanGroundRuleChanged papgrc
        INNER JOIN @ExistingChangeRows ecr
            ON papgrc.SLTActionPlanGroundRuleChangedPK = ecr.SLTActionPlanGroundRuleChangedPK
    WHERE papgrc.SLTActionPlanGroundRuleChangedPK = ecr.SLTActionPlanGroundRuleChangedPK;

END;
GO
ALTER TABLE [dbo].[SLTActionPlanGroundRule] ADD CONSTRAINT [PK_SLTActionPlanGroundRule] PRIMARY KEY CLUSTERED ([SLTActionPlanGroundRulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlanGroundRule] ADD CONSTRAINT [FK_SLTActionPlanGroundRule_SLTActionPlan] FOREIGN KEY ([SLTActionPlanFK]) REFERENCES [dbo].[SLTActionPlan] ([SLTActionPlanPK])
GO

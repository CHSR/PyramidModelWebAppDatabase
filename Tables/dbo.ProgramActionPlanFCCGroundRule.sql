CREATE TABLE [dbo].[ProgramActionPlanFCCGroundRule]
(
[ProgramActionPlanFCCGroundRulePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[GroundRuleDescription] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroundRuleNumber] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_ProgramActionPlanFCCGroundRule_Changed]
ON [dbo].[ProgramActionPlanFCCGroundRule]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanFCCGroundRuleChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanFCCGroundRulePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        GroundRuleDescription,
		GroundRuleNumber,
        ProgramActionPlanFCCFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanFCCGroundRulePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.GroundRuleDescription,
		   d.GroundRuleNumber,
           d.ProgramActionPlanFCCFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanFCCGroundRuleChangedPK INT NOT NULL,
        ProgramActionPlanFCCGroundRulePK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanFCCGroundRuleChangedPK,
        ProgramActionPlanFCCGroundRulePK,
        RowNumber
    )
    SELECT papgrc.ProgramActionPlanFCCGroundRuleChangedPK,
		   papgrc.ProgramActionPlanFCCGroundRulePK,
		   ROW_NUMBER() OVER (PARTITION BY papgrc.ProgramActionPlanFCCGroundRulePK
                              ORDER BY papgrc.ProgramActionPlanFCCGroundRuleChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanFCCGroundRuleChanged papgrc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanFCCGroundRulePK FROM Deleted d WHERE d.ProgramActionPlanFCCGroundRulePK = papgrc.ProgramActionPlanFCCGroundRulePK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papgrc
    FROM dbo.ProgramActionPlanFCCGroundRuleChanged papgrc
        INNER JOIN @ExistingChangeRows ecr
            ON papgrc.ProgramActionPlanFCCGroundRuleChangedPK = ecr.ProgramActionPlanFCCGroundRuleChangedPK
    WHERE papgrc.ProgramActionPlanFCCGroundRuleChangedPK = ecr.ProgramActionPlanFCCGroundRuleChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCGroundRule] ADD CONSTRAINT [PK_ProgramActionPlanFCCGroundRule] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCGroundRulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCGroundRule] ADD CONSTRAINT [FK_ProgramActionPlanFCCGroundRule_ProgramActionPlanFCC] FOREIGN KEY ([ProgramActionPlanFCCFK]) REFERENCES [dbo].[ProgramActionPlanFCC] ([ProgramActionPlanFCCPK])
GO

CREATE TABLE [dbo].[CoachingLogCoachees]
(
[CoachingLogCoacheesPK] [int] NOT NULL IDENTITY(1, 1),
[CreateDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoacheeFK] [int] NOT NULL,
[CoachingLogFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 01/03/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CoachingLogCoachees_Changed] 
   ON  [dbo].[CoachingLogCoachees] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingLogCoacheesPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingLogCoacheesChanged
    (
        ChangeDatetime,
        ChangeType,
        CoachingLogCoacheesPK,
        CreateDate,
        Creator,
        EditDate,
        Editor,
        CoacheeFK,
        CoachingLogFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.CoachingLogCoacheesPK,
        d.CreateDate,
        d.Creator,
        d.EditDate,
        d.Editor,
        d.CoacheeFK,
        d.CoachingLogFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingLogCoacheesChangedPK INT NOT NULL,
        CoachingLogCoacheesPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected coaching logs
    INSERT INTO @ExistingChangeRows
    (
        CoachingLogCoacheesChangedPK,
		CoachingLogCoacheesPK,
        RowNumber
    )
    SELECT cc.CoachingLogCoacheesChangedPK,
		   cc.CoachingLogCoacheesPK,
           ROW_NUMBER() OVER (PARTITION BY cc.CoachingLogCoacheesPK
                              ORDER BY cc.CoachingLogCoacheesChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingLogCoacheesChanged cc
    WHERE EXISTS
    (
        SELECT d.CoachingLogCoacheesPK FROM Deleted d WHERE d.CoachingLogCoacheesPK = cc.CoachingLogCoacheesPK
    );

	--Remove all but the most recent 5 change rows for each affected coaching log
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.CoachingLogCoacheesChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.CoachingLogCoacheesChangedPK = ecr.CoachingLogCoacheesChangedPK
    WHERE cc.CoachingLogCoacheesChangedPK = ecr.CoachingLogCoacheesChangedPK;
	
END
GO
ALTER TABLE [dbo].[CoachingLogCoachees] ADD CONSTRAINT [PK_CoachingLogCoachees] PRIMARY KEY CLUSTERED ([CoachingLogCoacheesPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingLogCoachees] ADD CONSTRAINT [FK_CoachingLogCoachees_Coachee] FOREIGN KEY ([CoacheeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[CoachingLogCoachees] ADD CONSTRAINT [FK_CoachingLogCoachees_CoachingLog] FOREIGN KEY ([CoachingLogFK]) REFERENCES [dbo].[CoachingLog] ([CoachingLogPK])
GO

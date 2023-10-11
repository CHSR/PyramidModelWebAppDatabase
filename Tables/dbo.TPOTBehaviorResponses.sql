CREATE TABLE [dbo].[TPOTBehaviorResponses]
(
[TPOTBehaviorResponsesPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPOTFK] [int] NOT NULL,
[BehaviorResponseCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/18/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_TPOTBehaviorResponses_Changed]
   ON  [dbo].[TPOTBehaviorResponses] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPOTBehaviorResponsesPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPOTBehaviorResponsesChanged
    (
        ChangeDatetime,
        ChangeType,
        TPOTBehaviorResponsesPK,
        Creator,
        CreateDate,
        TPOTFK,
        BehaviorResponseCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPOTBehaviorResponsesPK,
        d.Creator,
        d.CreateDate,
        d.TPOTFK,
        d.BehaviorResponseCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPOTBehaviorResponsesChangedPK INT NOT NULL,
        TPOTBehaviorResponsesPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior responses
    INSERT INTO @ExistingChangeRows
    (
        TPOTBehaviorResponsesChangedPK,
		TPOTBehaviorResponsesPK,
        RowNumber
    )
    SELECT tbrc.TPOTBehaviorResponsesChangedPK,
		   tbrc.TPOTBehaviorResponsesPK,
           ROW_NUMBER() OVER (PARTITION BY tbrc.TPOTFK, tbrc.BehaviorResponseCodeFK
                              ORDER BY tbrc.TPOTBehaviorResponsesChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPOTBehaviorResponsesChanged tbrc
    WHERE EXISTS
    (
        SELECT d.TPOTBehaviorResponsesPK FROM Deleted d WHERE d.TPOTFK = tbrc.TPOTFK AND d.BehaviorResponseCodeFK = tbrc.BehaviorResponseCodeFK
    );

	--Remove all but the most recent change row since these are deleted each time
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 1;

    --Delete the excess change rows to keep the number of change rows low
    DELETE tbrc
    FROM dbo.TPOTBehaviorResponsesChanged tbrc
        INNER JOIN @ExistingChangeRows ecr
            ON tbrc.TPOTBehaviorResponsesChangedPK = ecr.TPOTBehaviorResponsesChangedPK
    WHERE tbrc.TPOTBehaviorResponsesChangedPK = ecr.TPOTBehaviorResponsesChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [PK_TPOTBehaviorResponses] PRIMARY KEY CLUSTERED  ([TPOTBehaviorResponsesPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [FK_TPOTBehaviorResponses_CodeTPOTBehaviorResponse] FOREIGN KEY ([BehaviorResponseCodeFK]) REFERENCES [dbo].[CodeTPOTBehaviorResponse] ([CodeTPOTBehaviorResponsePK])
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [FK_TPOTBehaviorResponses_TPOT] FOREIGN KEY ([TPOTFK]) REFERENCES [dbo].[TPOT] ([TPOTPK])
GO

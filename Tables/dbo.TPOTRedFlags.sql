CREATE TABLE [dbo].[TPOTRedFlags]
(
[TPOTRedFlagsPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPOTFK] [int] NOT NULL,
[RedFlagCodeFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_TPOTRedFlags_Changed]
   ON  [dbo].[TPOTRedFlags] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPOTRedFlagsPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPOTRedFlagsChanged
    (
        ChangeDatetime,
        ChangeType,
        TPOTRedFlagsPK,
        Creator,
        CreateDate,
        TPOTFK,
        RedFlagCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPOTRedFlagsPK,
        d.Creator,
        d.CreateDate,
        d.TPOTFK,
        d.RedFlagCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPOTRedFlagsChangedPK INT NOT NULL,
        TPOTRedFlagsPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected red flags
    INSERT INTO @ExistingChangeRows
    (
        TPOTRedFlagsChangedPK,
		TPOTRedFlagsPK,
        RowNumber
    )
    SELECT trfc.TPOTRedFlagsChangedPK,
		   trfc.TPOTRedFlagsPK,
           ROW_NUMBER() OVER (PARTITION BY trfc.TPOTFK, trfc.RedFlagCodeFK
                              ORDER BY trfc.TPOTRedFlagsChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPOTRedFlagsChanged trfc
    WHERE EXISTS
    (
        SELECT d.TPOTRedFlagsPK FROM Deleted d WHERE d.TPOTFK = trfc.TPOTFK AND d.RedFlagCodeFK = trfc.RedFlagCodeFK
    );

	--Remove all but the most recent change row since these are deleted each time
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 1;

    --Delete the excess change rows to keep the number of change rows low
    DELETE trfc
    FROM dbo.TPOTRedFlagsChanged trfc
        INNER JOIN @ExistingChangeRows ecr
            ON trfc.TPOTRedFlagsChangedPK = ecr.TPOTRedFlagsChangedPK
    WHERE trfc.TPOTRedFlagsChangedPK = ecr.TPOTRedFlagsChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPOTRedFlags] ADD CONSTRAINT [PK_TPOTRedFlags] PRIMARY KEY CLUSTERED  ([TPOTRedFlagsPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTRedFlags] ADD CONSTRAINT [FK_TPOTRedFlags_CodeTPOTRedFlag] FOREIGN KEY ([RedFlagCodeFK]) REFERENCES [dbo].[CodeTPOTRedFlag] ([CodeTPOTRedFlagPK])
GO
ALTER TABLE [dbo].[TPOTRedFlags] ADD CONSTRAINT [FK_TPOTRedFlags_TPOT] FOREIGN KEY ([TPOTFK]) REFERENCES [dbo].[TPOT] ([TPOTPK])
GO

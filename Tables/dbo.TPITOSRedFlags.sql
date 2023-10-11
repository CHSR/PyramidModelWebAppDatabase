CREATE TABLE [dbo].[TPITOSRedFlags]
(
[TPITOSRedFlagsPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPITOSFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_TPITOSRedFlags_Changed]
   ON  [dbo].[TPITOSRedFlags] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPITOSRedFlagsPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPITOSRedFlagsChanged
    (
        ChangeDatetime,
        ChangeType,
        TPITOSRedFlagsPK,
        Creator,
        CreateDate,
        TPITOSFK,
        RedFlagCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPITOSRedFlagsPK,
        d.Creator,
        d.CreateDate,
        d.TPITOSFK,
        d.RedFlagCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPITOSRedFlagsChangedPK INT NOT NULL,
        TPITOSRedFlagsPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected red flags
    INSERT INTO @ExistingChangeRows
    (
        TPITOSRedFlagsChangedPK,
		TPITOSRedFlagsPK,
        RowNumber
    )
    SELECT trfc.TPITOSRedFlagsChangedPK,
		   trfc.TPITOSRedFlagsPK,
           ROW_NUMBER() OVER (PARTITION BY trfc.TPITOSFK, trfc.RedFlagCodeFK
                              ORDER BY trfc.TPITOSRedFlagsChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPITOSRedFlagsChanged trfc
    WHERE EXISTS
    (
        SELECT d.TPITOSRedFlagsPK FROM Deleted d WHERE d.TPITOSFK = trfc.TPITOSFK AND d.RedFlagCodeFK = trfc.RedFlagCodeFK
    );

	--Remove all but the most recent change row since these are deleted each time
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 1;

    --Delete the excess change rows to keep the number of change rows low
    DELETE trfc
    FROM dbo.TPITOSRedFlagsChanged trfc
        INNER JOIN @ExistingChangeRows ecr
            ON trfc.TPITOSRedFlagsChangedPK = ecr.TPITOSRedFlagsChangedPK
    WHERE trfc.TPITOSRedFlagsChangedPK = ecr.TPITOSRedFlagsChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPITOSRedFlags] ADD CONSTRAINT [PK_TPITOSRedFlags] PRIMARY KEY CLUSTERED  ([TPITOSRedFlagsPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPITOSRedFlags] ADD CONSTRAINT [FK_TPITOSRedFlags_CodeTPITOSRedFlag] FOREIGN KEY ([RedFlagCodeFK]) REFERENCES [dbo].[CodeTPITOSRedFlag] ([CodeTPITOSRedFlagPK])
GO
ALTER TABLE [dbo].[TPITOSRedFlags] ADD CONSTRAINT [FK_TPITOSRedFlags_TPITOS] FOREIGN KEY ([TPITOSFK]) REFERENCES [dbo].[TPITOS] ([TPITOSPK])
GO

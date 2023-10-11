CREATE TABLE [dbo].[ProgramAddress]
(
[ProgramAddressPK] [int] NOT NULL IDENTITY(1, 1),
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMailingAddress] [bit] NOT NULL,
[LicenseNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Street] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZIPCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 02/27/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramAddressChanged] 
   ON  [dbo].[ProgramAddress] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramAddressPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramAddressChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramAddressPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		City,
		IsMailingAddress,
		LicenseNumber,
		Notes,
		State,
		Street,
		ZIPCode,
		ProgramFK
		
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ProgramAddressPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
		d.City,
		d.IsMailingAddress,
		d.LicenseNumber,
		d.Notes,
		d.State,
		d.Street,
		d.ZIPCode,
		d.ProgramFK
		
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramAddressChangedPK INT NOT NULL,
        ProgramAddressPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected program status
    INSERT INTO @ExistingChangeRows
    (
        ProgramAddressChangedPK,
		ProgramAddressPK,
        RowNumber
    )
    SELECT pc.ProgramAddressChangedPK,
		   pc.ProgramAddressPK,
           ROW_NUMBER() OVER (PARTITION BY pc.ProgramAddressPK
                              ORDER BY pc.ProgramAddressChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramAddressChanged pc
    WHERE EXISTS
    (
        SELECT d.ProgramAddressPK FROM Deleted d WHERE d.ProgramAddressPK = pc.ProgramAddressPK
    );

	--Remove all but the most recent 5 change rows for each affected ProgramAddress
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE pc
    FROM dbo.ProgramAddressChanged pc
        INNER JOIN @ExistingChangeRows ecr
            ON pc.ProgramAddressChangedPK = ecr.ProgramAddressChangedPK
    WHERE pc.ProgramAddressChangedPK = ecr.ProgramAddressChangedPK;
	
END
GO
ALTER TABLE [dbo].[ProgramAddress] ADD CONSTRAINT [PK_ProgramAddress] PRIMARY KEY CLUSTERED ([ProgramAddressPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramAddress] ADD CONSTRAINT [FK_ProgramAddress_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

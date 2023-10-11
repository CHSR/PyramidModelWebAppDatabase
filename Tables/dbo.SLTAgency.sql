CREATE TABLE [dbo].[SLTAgency]
(
[SLTAgencyPK] [int] NOT NULL IDENTITY(1, 1),
[AddressCity] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressStreet] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressZIPCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/22/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_SLTAgency_Changed] 
   ON  [dbo].[SLTAgency]
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTAgencyPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTAgencyChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTAgencyPK,
        AddressCity,
        AddressState,
        AddressStreet,
        AddressZIPCode,
		Creator,
		CreateDate,
		Editor,
		EditDate,
        [Name],
        PhoneNumber,
		Website,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.SLTAgencyPK,
        d.AddressCity,
        d.AddressState,
        d.AddressStreet,
        d.AddressZIPCode,
		d.Creator,
		d.CreateDate,
		d.Editor,
		d.EditDate,
        d.[Name],
        d.PhoneNumber,
		d.Website,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTAgencyChangedPK INT NOT NULL,
        SLTAgencyPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTAgencyChangedPK,
		SLTAgencyPK,
        RowNumber
    )
    SELECT sac.SLTAgencyChangedPK,
		   sac.SLTAgencyPK,
           ROW_NUMBER() OVER (PARTITION BY sac.SLTAgencyPK
                              ORDER BY sac.SLTAgencyChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTAgencyChanged sac
    WHERE EXISTS
    (
        SELECT d.SLTAgencyPK FROM Deleted d WHERE d.SLTAgencyPK = sac.SLTAgencyPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE sac
    FROM dbo.SLTAgencyChanged sac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.SLTAgencyChangedPK = sac.SLTAgencyChangedPK
    WHERE ecr.SLTAgencyChangedPK = sac.SLTAgencyChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTAgency] ADD CONSTRAINT [PK_SLTAgency] PRIMARY KEY CLUSTERED ([SLTAgencyPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTAgency] ADD CONSTRAINT [FK_SLTAgency_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

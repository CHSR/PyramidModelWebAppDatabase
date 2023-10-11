CREATE TABLE [dbo].[CWLTAgency]
(
[CWLTAgencyPK] [int] NOT NULL IDENTITY(1, 1),
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
[CWLTAgencyTypeFK] [int] NOT NULL,
[HubFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 12/08/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CWLTAgency_Changed] 
   ON  [dbo].[CWLTAgency]
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CWLTAgencyPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTAgencyChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTAgencyPK,
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
        CWLTAgencyTypeFK,
        HubFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.CWLTAgencyPK,
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
        d.CWLTAgencyTypeFK,
        d.HubFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTAgencyChangedPK INT NOT NULL,
        CWLTAgencyPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        CWLTAgencyChangedPK,
		CWLTAgencyPK,
        RowNumber
    )
    SELECT sac.CWLTAgencyChangedPK,
		   sac.CWLTAgencyPK,
           ROW_NUMBER() OVER (PARTITION BY sac.CWLTAgencyPK
                              ORDER BY sac.CWLTAgencyChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTAgencyChanged sac
    WHERE EXISTS
    (
        SELECT d.CWLTAgencyPK FROM Deleted d WHERE d.CWLTAgencyPK = sac.CWLTAgencyPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE sac
    FROM dbo.CWLTAgencyChanged sac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.CWLTAgencyChangedPK = sac.CWLTAgencyChangedPK
    WHERE ecr.CWLTAgencyChangedPK = sac.CWLTAgencyChangedPK;
	
END
GO
ALTER TABLE [dbo].[CWLTAgency] ADD CONSTRAINT [PK_CWLTAgency] PRIMARY KEY CLUSTERED ([CWLTAgencyPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTAgency] ADD CONSTRAINT [FK_CWLTAgency_CWLTAgencyType] FOREIGN KEY ([CWLTAgencyTypeFK]) REFERENCES [dbo].[CWLTAgencyType] ([CWLTAgencyTypePK])
GO
ALTER TABLE [dbo].[CWLTAgency] ADD CONSTRAINT [FK_CWLTAgency_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO

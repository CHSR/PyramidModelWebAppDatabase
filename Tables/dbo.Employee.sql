CREATE TABLE [dbo].[Employee]
(
[EmployeePK] [int] NOT NULL IDENTITY(1, 1),
[AspireEmail] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AspireID] [int] NULL,
[AspireVerified] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EthnicitySpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RaceSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicityCodeFK] [int] NOT NULL,
[GenderCodeFK] [int] NOT NULL,
[RaceCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/30/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_Employee_Changed] 
   ON  [dbo].[Employee] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.EmployeePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.EmployeeChanged
    (
        ChangeDatetime,
        ChangeType,
        EmployeePK,
        AspireEmail,
        AspireID,
        AspireVerified,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EmailAddress,
        EthnicitySpecify,
        FirstName,
        GenderSpecify,
        LastName,
        RaceSpecify,
        EthnicityCodeFK,
        GenderCodeFK,
        RaceCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.EmployeePK,
        d.AspireEmail,
        d.AspireID,
        d.AspireVerified,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.EmailAddress,
        d.EthnicitySpecify,
        d.FirstName,
        d.GenderSpecify,
        d.LastName,
        d.RaceSpecify,
        d.EthnicityCodeFK,
        d.GenderCodeFK,
        d.RaceCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        EmployeeChangedPK INT NOT NULL,
        EmployeePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        EmployeeChangedPK,
		EmployeePK,
        RowNumber
    )
    SELECT ec.EmployeeChangedPK,
		   ec.EmployeePK,
           ROW_NUMBER() OVER (PARTITION BY ec.EmployeePK
                              ORDER BY ec.EmployeeChangedPK DESC
                             ) AS RowNum
    FROM dbo.EmployeeChanged ec
    WHERE EXISTS
    (
        SELECT d.EmployeePK FROM Deleted d WHERE d.EmployeePK = ec.EmployeePK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ec
    FROM dbo.EmployeeChanged ec
        INNER JOIN @ExistingChangeRows ecr
            ON ec.EmployeeChangedPK = ecr.EmployeeChangedPK
    WHERE ec.EmployeeChangedPK = ecr.EmployeeChangedPK;
	
END
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([EmployeePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [FK_Employee_CodeEthnicity] FOREIGN KEY ([EthnicityCodeFK]) REFERENCES [dbo].[CodeEthnicity] ([CodeEthnicityPK])
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [FK_Employee_CodeGender] FOREIGN KEY ([GenderCodeFK]) REFERENCES [dbo].[CodeGender] ([CodeGenderPK])
GO
ALTER TABLE [dbo].[Employee] ADD CONSTRAINT [FK_Employee_CodeRace] FOREIGN KEY ([RaceCodeFK]) REFERENCES [dbo].[CodeRace] ([CodeRacePK])
GO

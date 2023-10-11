CREATE TABLE [dbo].[CWLTMember]
(
[CWLTMemberPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LeaveDate] [datetime] NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NOT NULL,
[EthnicityCodeFK] [int] NULL,
[GenderCodeFK] [int] NULL,
[HouseholdIncomeCodeFK] [int] NULL,
[RaceCodeFK] [int] NULL,
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
CREATE TRIGGER [dbo].[TGR_CWLTMember_Changed] 
   ON  [dbo].[CWLTMember] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CWLTMemberPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTMemberChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTMemberPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EmailAddress,
        FirstName,
        GenderSpecify,
        StartDate,
        IDNumber,
        LastName,
        LeaveDate,
		PhoneNumber,
        EthnicityCodeFk,
        GenderCodeFK,
        HouseholdIncomeCodeFK,
        RaceCodeFK,
        HubFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.CWLTMemberPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.EmailAddress,
        d.FirstName,
		d.GenderSpecify,
        d.StartDate,
        d.IDNumber,
        d.LastName,
        d.LeaveDate,
		d.PhoneNumber,
		d.EthnicityCodeFK,
		d.GenderCodeFK,
		d.HouseholdIncomeCodeFK,
		d.RaceCodeFK,
		d.HubFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTMemberChangedPK INT NOT NULL,
        CWLTMemberPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        CWLTMemberChangedPK,
		CWLTMemberPK,
        RowNumber
    )
    SELECT smc.CWLTMemberChangedPK,
		   smc.CWLTMemberPK,
           ROW_NUMBER() OVER (PARTITION BY smc.CWLTMemberPK
                              ORDER BY smc.CWLTMemberChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTMemberChanged smc
    WHERE EXISTS
    (
        SELECT d.CWLTMemberPK FROM Deleted d WHERE d.CWLTMemberPK = smc.CWLTMemberPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.CWLTMemberChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.CWLTMemberChangedPK = ecr.CWLTMemberChangedPK
    WHERE smc.CWLTMemberChangedPK = ecr.CWLTMemberChangedPK;
	
END
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [PK_CWLTMember] PRIMARY KEY CLUSTERED ([CWLTMemberPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [FK_CWLTMember_CodeEthnicity] FOREIGN KEY ([EthnicityCodeFK]) REFERENCES [dbo].[CodeEthnicity] ([CodeEthnicityPK])
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [FK_CWLTMember_CodeGender] FOREIGN KEY ([GenderCodeFK]) REFERENCES [dbo].[CodeGender] ([CodeGenderPK])
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [FK_CWLTMember_CodeHouseholdIncome] FOREIGN KEY ([HouseholdIncomeCodeFK]) REFERENCES [dbo].[CodeHouseholdIncome] ([CodeHouseholdIncomePK])
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [FK_CWLTMember_CodeRace] FOREIGN KEY ([RaceCodeFK]) REFERENCES [dbo].[CodeRace] ([CodeRacePK])
GO
ALTER TABLE [dbo].[CWLTMember] ADD CONSTRAINT [FK_CWLTMember_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO

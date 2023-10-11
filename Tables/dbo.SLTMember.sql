CREATE TABLE [dbo].[SLTMember]
(
[SLTMemberPK] [int] NOT NULL IDENTITY(1, 1),
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
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/05/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_SLTMember_Changed] 
   ON  [dbo].[SLTMember] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTMemberPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTMemberChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTMemberPK,
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
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.SLTMemberPK,
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
		d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTMemberChangedPK INT NOT NULL,
        SLTMemberPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTMemberChangedPK,
		SLTMemberPK,
        RowNumber
    )
    SELECT smc.SLTMemberChangedPK,
		   smc.SLTMemberPK,
           ROW_NUMBER() OVER (PARTITION BY smc.SLTMemberPK
                              ORDER BY smc.SLTMemberChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTMemberChanged smc
    WHERE EXISTS
    (
        SELECT d.SLTMemberPK FROM Deleted d WHERE d.SLTMemberPK = smc.SLTMemberPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.SLTMemberChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.SLTMemberChangedPK = ecr.SLTMemberChangedPK
    WHERE smc.SLTMemberChangedPK = ecr.SLTMemberChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [PK_SLTMember] PRIMARY KEY CLUSTERED ([SLTMemberPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [FK_SLTMember_CodeEthnicity] FOREIGN KEY ([EthnicityCodeFK]) REFERENCES [dbo].[CodeEthnicity] ([CodeEthnicityPK])
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [FK_SLTMember_CodeGender] FOREIGN KEY ([GenderCodeFK]) REFERENCES [dbo].[CodeGender] ([CodeGenderPK])
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [FK_SLTMember_CodeHouseholdIncome] FOREIGN KEY ([HouseholdIncomeCodeFK]) REFERENCES [dbo].[CodeHouseholdIncome] ([CodeHouseholdIncomePK])
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [FK_SLTMember_CodeRace] FOREIGN KEY ([RaceCodeFK]) REFERENCES [dbo].[CodeRace] ([CodeRacePK])
GO
ALTER TABLE [dbo].[SLTMember] ADD CONSTRAINT [FK_SLTMember_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

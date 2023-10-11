CREATE TABLE [dbo].[Child]
(
[ChildPK] [int] NOT NULL IDENTITY(1, 1),
[BirthDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EthnicitySpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
-- Create date: 08/07/2019
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_Child_Changed]
ON [dbo].[Child]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ChildPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildChanged
    (
        ChangeDatetime,
        ChangeType,
        ChildPK,
        BirthDate,
        Creator,
        CreateDate,
        Editor,
        EditDate,
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
           d.ChildPK,
           d.BirthDate,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
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
        ChildChangedPK INT NOT NULL,
        ChildPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected children
    INSERT INTO @ExistingChangeRows
    (
        ChildChangedPK,
		ChildPK,
        RowNumber
    )
    SELECT cc.ChildChangedPK,
		   cc.ChildPK,
           ROW_NUMBER() OVER (PARTITION BY cc.ChildPK
                              ORDER BY cc.ChildChangedPK DESC
                             ) AS RowNum
    FROM dbo.ChildChanged cc
    WHERE EXISTS
    (
        SELECT d.ChildPK FROM Deleted d WHERE d.ChildPK = cc.ChildPK
    );

	--Remove all but the most recent 5 change rows for each affected child
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.ChildChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.ChildChangedPK = ecr.ChildChangedPK
    WHERE cc.ChildChangedPK = ecr.ChildChangedPK;

END;
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [PK_Child] PRIMARY KEY CLUSTERED ([ChildPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Ethnicity] FOREIGN KEY ([EthnicityCodeFK]) REFERENCES [dbo].[CodeEthnicity] ([CodeEthnicityPK])
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Gender] FOREIGN KEY ([GenderCodeFK]) REFERENCES [dbo].[CodeGender] ([CodeGenderPK])
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Race] FOREIGN KEY ([RaceCodeFK]) REFERENCES [dbo].[CodeRace] ([CodeRacePK])
GO

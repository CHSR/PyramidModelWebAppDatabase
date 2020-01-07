CREATE TABLE [dbo].[Child]
(
[ChildPK] [int] NOT NULL IDENTITY(1, 1),
[BirthDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FirstName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
   ON  [dbo].[Child] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ChildPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ChildPK,
	    MinChangeDatetime
	)
	SELECT ac.ChildPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ChildChanged ac
	GROUP BY ac.ChildPK
	HAVING COUNT(ac.ChildPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ChildChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ChildPK = ecr.ChildPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ChildPK = ecr.ChildPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [PK_Child] PRIMARY KEY CLUSTERED  ([ChildPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Ethnicity] FOREIGN KEY ([EthnicityCodeFK]) REFERENCES [dbo].[CodeEthnicity] ([CodeEthnicityPK])
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Gender] FOREIGN KEY ([GenderCodeFK]) REFERENCES [dbo].[CodeGender] ([CodeGenderPK])
GO
ALTER TABLE [dbo].[Child] ADD CONSTRAINT [FK_Child_Race] FOREIGN KEY ([RaceCodeFK]) REFERENCES [dbo].[CodeRace] ([CodeRacePK])
GO

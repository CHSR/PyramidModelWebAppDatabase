CREATE TABLE [dbo].[OtherSEScreen]
(
[OtherSEScreenPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ScreenDate] [datetime] NOT NULL,
[Score] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ScoreTypeCodeFK] [int] NOT NULL,
[ScreenTypeCodeFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_OtherSEScreen_Changed] 
   ON  [dbo].[OtherSEScreen] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.OtherSEScreenChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		OtherSEScreenPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    OtherSEScreenPK,
	    MinChangeDatetime
	)
	SELECT ac.OtherSEScreenPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.OtherSEScreenChanged ac
	GROUP BY ac.OtherSEScreenPK
	HAVING COUNT(ac.OtherSEScreenPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.OtherSEScreenChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.OtherSEScreenPK = ecr.OtherSEScreenPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.OtherSEScreenPK = ecr.OtherSEScreenPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[OtherSEScreen] ADD CONSTRAINT [PK_OtherSEScreen] PRIMARY KEY CLUSTERED  ([OtherSEScreenPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OtherSEScreen] ADD CONSTRAINT [FK_OtherSEScreen_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[OtherSEScreen] ADD CONSTRAINT [FK_OtherSEScreen_CodeScoreType] FOREIGN KEY ([ScoreTypeCodeFK]) REFERENCES [dbo].[CodeScoreType] ([CodeScoreTypePK])
GO
ALTER TABLE [dbo].[OtherSEScreen] ADD CONSTRAINT [FK_OtherSEScreen_CodeScreenType] FOREIGN KEY ([ScreenTypeCodeFK]) REFERENCES [dbo].[CodeScreenType] ([CodeScreenTypePK])
GO
ALTER TABLE [dbo].[OtherSEScreen] ADD CONSTRAINT [FK_OtherSEScreen_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

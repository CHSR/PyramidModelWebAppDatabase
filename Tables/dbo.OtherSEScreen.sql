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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.OtherSEScreenPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.OtherSEScreenChanged
    (
        ChangeDatetime,
        ChangeType,
        OtherSEScreenPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ScreenDate,
        Score,
        ChildFK,
        ProgramFK,
        ScoreTypeCodeFK,
        ScreenTypeCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.OtherSEScreenPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.ScreenDate,
        d.Score,
        d.ChildFK,
        d.ProgramFK,
        d.ScoreTypeCodeFK,
        d.ScreenTypeCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        OtherSEScreenChangedPK INT NOT NULL,
        OtherSEScreenPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected SE screens
    INSERT INTO @ExistingChangeRows
    (
        OtherSEScreenChangedPK,
		OtherSEScreenPK,
        RowNumber
    )
    SELECT ossc.OtherSEScreenChangedPK,
		   ossc.OtherSEScreenPK,
           ROW_NUMBER() OVER (PARTITION BY ossc.OtherSEScreenPK
                              ORDER BY ossc.OtherSEScreenChangedPK DESC
                             ) AS RowNum
    FROM dbo.OtherSEScreenChanged ossc
    WHERE EXISTS
    (
        SELECT d.OtherSEScreenPK FROM Deleted d WHERE d.OtherSEScreenPK = ossc.OtherSEScreenPK
    );

	--Remove all but the most recent 5 change rows for each affected SE screen
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ossc
    FROM dbo.OtherSEScreenChanged ossc
        INNER JOIN @ExistingChangeRows ecr
            ON ossc.OtherSEScreenChangedPK = ecr.OtherSEScreenChangedPK
    WHERE ossc.OtherSEScreenChangedPK = ecr.OtherSEScreenChangedPK;
	
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

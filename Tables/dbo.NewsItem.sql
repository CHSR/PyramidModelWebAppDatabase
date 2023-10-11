CREATE TABLE [dbo].[NewsItem]
(
[NewsItemPK] [int] NOT NULL IDENTITY(1, 1),
[Contents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ItemNum] [int] NOT NULL,
[NewsEntryFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_NewsItem_Changed] 
   ON  [dbo].[NewsItem] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.NewsItemPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.NewsItemChanged
    (
        ChangeDatetime,
        ChangeType,
        NewsItemPK,
        Contents,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ItemNum,
        NewsEntryFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.NewsItemPK,
        d.Contents,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.ItemNum,
        d.NewsEntryFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        NewsItemChangedPK INT NOT NULL,
        NewsItemPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected news item
    INSERT INTO @ExistingChangeRows
    (
        NewsItemChangedPK,
		NewsItemPK,
        RowNumber
    )
    SELECT nic.NewsItemChangedPK,
		   nic.NewsItemPK,
           ROW_NUMBER() OVER (PARTITION BY nic.NewsItemPK
                              ORDER BY nic.NewsItemChangedPK DESC
                             ) AS RowNum
    FROM dbo.NewsItemChanged nic
    WHERE EXISTS
    (
        SELECT d.NewsItemPK FROM Deleted d WHERE d.NewsItemPK = nic.NewsItemPK
    );

	--Remove all but the most recent 5 change rows for each affected news item
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE nic
    FROM dbo.NewsItemChanged nic
        INNER JOIN @ExistingChangeRows ecr
            ON nic.NewsItemChangedPK = ecr.NewsItemChangedPK
    WHERE nic.NewsItemChangedPK = ecr.NewsItemChangedPK;
	
END
GO
ALTER TABLE [dbo].[NewsItem] ADD CONSTRAINT [PK_NewsItem] PRIMARY KEY CLUSTERED  ([NewsItemPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsItem] ADD CONSTRAINT [FK_NewsItem_NewsEntry] FOREIGN KEY ([NewsEntryFK]) REFERENCES [dbo].[NewsEntry] ([NewsEntryPK])
GO

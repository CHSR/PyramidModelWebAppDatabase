CREATE TABLE [dbo].[NewsEntry]
(
[NewsEntryPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EntryDate] [datetime] NOT NULL,
[NewsEntryTypeCodeFK] [int] NOT NULL,
[ProgramFK] [int] NULL,
[HubFK] [int] NULL,
[StateFK] [int] NULL,
[CohortFK] [int] NULL
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
CREATE TRIGGER [dbo].[TGR_NewsEntry_Changed] 
   ON  [dbo].[NewsEntry] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.NewsEntryPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.NewsEntryChanged
    (
        ChangeDatetime,
        ChangeType,
        NewsEntryPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EntryDate,
        NewsEntryTypeCodeFK,
        ProgramFK,
        HubFK,
        StateFK,
        CohortFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.NewsEntryPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.EntryDate,
        d.NewsEntryTypeCodeFK,
        d.ProgramFK,
        d.HubFK,
        d.StateFK,
        d.CohortFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        NewsEntryChangedPK INT NOT NULL,
        NewsEntryPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected news entry
    INSERT INTO @ExistingChangeRows
    (
        NewsEntryChangedPK,
		NewsEntryPK,
        RowNumber
    )
    SELECT nec.NewsEntryChangedPK,
		   nec.NewsEntryPK,
           ROW_NUMBER() OVER (PARTITION BY nec.NewsEntryPK
                              ORDER BY nec.NewsEntryChangedPK DESC
                             ) AS RowNum
    FROM dbo.NewsEntryChanged nec
    WHERE EXISTS
    (
        SELECT d.NewsEntryPK FROM Deleted d WHERE d.NewsEntryPK = nec.NewsEntryPK
    );

	--Remove all but the most recent 5 change rows for each affected news entry
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE nec
    FROM dbo.NewsEntryChanged nec
        INNER JOIN @ExistingChangeRows ecr
            ON nec.NewsEntryChangedPK = ecr.NewsEntryChangedPK
    WHERE nec.NewsEntryChangedPK = ecr.NewsEntryChangedPK;
	
END
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [PK_NewsEntry] PRIMARY KEY CLUSTERED  ([NewsEntryPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [FK_NewsEntry_CodeNewsEntryType] FOREIGN KEY ([NewsEntryTypeCodeFK]) REFERENCES [dbo].[CodeNewsEntryType] ([CodeNewsEntryTypePK])
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [FK_NewsEntry_Cohort] FOREIGN KEY ([CohortFK]) REFERENCES [dbo].[Cohort] ([CohortPK])
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [FK_NewsEntry_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [FK_NewsEntry_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [FK_NewsEntry_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

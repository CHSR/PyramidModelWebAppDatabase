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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.NewsEntryChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		NewsEntryPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    NewsEntryPK,
	    MinChangeDatetime
	)
	SELECT ac.NewsEntryPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.NewsEntryChanged ac
	GROUP BY ac.NewsEntryPK
	HAVING COUNT(ac.NewsEntryPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.NewsEntryChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.NewsEntryPK = ecr.NewsEntryPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.NewsEntryPK = ecr.NewsEntryPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
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

CREATE TABLE [dbo].[ChildStatus]
(
[ChildStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StatusDate] [datetime] NOT NULL,
[ChildStatusCodeFK] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ChildStatus_Changed] 
   ON  [dbo].[ChildStatus] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildStatusChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ChildStatusPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ChildStatusPK,
	    MinChangeDatetime
	)
	SELECT ac.ChildStatusPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ChildStatusChanged ac
	GROUP BY ac.ChildStatusPK
	HAVING COUNT(ac.ChildStatusPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ChildStatusChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ChildStatusPK = ecr.ChildStatusPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ChildStatusPK = ecr.ChildStatusPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[ChildStatus] ADD CONSTRAINT [PK_ChildStatus] PRIMARY KEY CLUSTERED  ([ChildStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildStatus] ADD CONSTRAINT [FK_ChildStatus_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildStatus] ADD CONSTRAINT [FK_ChildStatus_CodeChildStatus] FOREIGN KEY ([ChildStatusCodeFK]) REFERENCES [dbo].[CodeChildStatus] ([CodeChildStatusPK])
GO
ALTER TABLE [dbo].[ChildStatus] ADD CONSTRAINT [FK_ChildStatus_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

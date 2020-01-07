CREATE TABLE [dbo].[Hub]
(
[HubPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_Hub_Changed] 
   ON  [dbo].[Hub] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.HubChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		HubPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    HubPK,
	    MinChangeDatetime
	)
	SELECT ac.HubPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.HubChanged ac
	GROUP BY ac.HubPK
	HAVING COUNT(ac.HubPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.HubChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.HubPK = ecr.HubPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.HubPK = ecr.HubPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Hub] ADD CONSTRAINT [PK_Hub] PRIMARY KEY CLUSTERED  ([HubPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Hub] ADD CONSTRAINT [FK_Hub_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

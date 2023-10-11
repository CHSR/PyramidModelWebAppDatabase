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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.HubPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.HubChanged
    (
        ChangeDatetime,
        ChangeType,
        HubPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        Name,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.HubPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.Name,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        HubChangedPK INT NOT NULL,
        HubPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected hubs
    INSERT INTO @ExistingChangeRows
    (
        HubChangedPK,
		HubPK,
        RowNumber
    )
    SELECT cc.HubChangedPK,
		   cc.HubPK,
           ROW_NUMBER() OVER (PARTITION BY cc.HubPK
                              ORDER BY cc.HubChangedPK DESC
                             ) AS RowNum
    FROM dbo.HubChanged cc
    WHERE EXISTS
    (
        SELECT d.HubPK FROM Deleted d WHERE d.HubPK = cc.HubPK
    );

	--Remove all but the most recent 5 change rows for each affected hub
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.HubChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.HubChangedPK = ecr.HubChangedPK
    WHERE cc.HubChangedPK = ecr.HubChangedPK;
	
END
GO
ALTER TABLE [dbo].[Hub] ADD CONSTRAINT [PK_Hub] PRIMARY KEY CLUSTERED  ([HubPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Hub] ADD CONSTRAINT [FK_Hub_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

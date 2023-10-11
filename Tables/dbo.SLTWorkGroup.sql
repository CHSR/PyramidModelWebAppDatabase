CREATE TABLE [dbo].[SLTWorkGroup]
(
[SLTWorkGroupPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[WorkGroupName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/02/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_SLTWorkGroup_Changed] 
   ON  [dbo].[SLTWorkGroup]
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTWorkGroupPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTWorkGroupChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTWorkGroupPK,
		Creator,
		CreateDate,
		Editor,
		EditDate,
		EndDate,
		StartDate,
        WorkGroupName,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.SLTWorkGroupPK,
		d.Creator,
		d.CreateDate,
		d.Editor,
		d.EditDate,
		d.EndDate,
		d.StartDate,
        d.WorkGroupName,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTWorkGroupChangedPK INT NOT NULL,
        SLTWorkGroupPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTWorkGroupChangedPK,
		SLTWorkGroupPK,
        RowNumber
    )
    SELECT sac.SLTWorkGroupChangedPK,
		   sac.SLTWorkGroupPK,
           ROW_NUMBER() OVER (PARTITION BY sac.SLTWorkGroupPK
                              ORDER BY sac.SLTWorkGroupChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTWorkGroupChanged sac
    WHERE EXISTS
    (
        SELECT d.SLTWorkGroupPK FROM Deleted d WHERE d.SLTWorkGroupPK = sac.SLTWorkGroupPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE sac
    FROM dbo.SLTWorkGroupChanged sac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.SLTWorkGroupChangedPK = sac.SLTWorkGroupChangedPK
    WHERE ecr.SLTWorkGroupChangedPK = sac.SLTWorkGroupChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTWorkGroup] ADD CONSTRAINT [PK_SLTWorkGroup] PRIMARY KEY CLUSTERED ([SLTWorkGroupPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTWorkGroup] ADD CONSTRAINT [FK_SLTWorkGroup_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

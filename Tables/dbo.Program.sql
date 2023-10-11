CREATE TABLE [dbo].[Program]
(
[ProgramPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IDNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramEndDate] [datetime] NULL,
[ProgramName] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramStartDate] [datetime] NOT NULL,
[CohortFK] [int] NOT NULL,
[HubFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_Program_Changed] 
   ON  [dbo].[Program] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		IDNumber,
        [Location],
        ProgramEndDate,
        ProgramName,
        ProgramStartDate,
        CohortFK,
        HubFK,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ProgramPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
		d.IDNumber,
        d.[Location],
        d.ProgramEndDate,
        d.ProgramName,
        d.ProgramStartDate,
        d.CohortFK,
        d.HubFK,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramChangedPK INT NOT NULL,
        ProgramPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected program
    INSERT INTO @ExistingChangeRows
    (
        ProgramChangedPK,
		ProgramPK,
        RowNumber
    )
    SELECT pc.ProgramChangedPK,
		   pc.ProgramPK,
           ROW_NUMBER() OVER (PARTITION BY pc.ProgramPK
                              ORDER BY pc.ProgramChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramChanged pc
    WHERE EXISTS
    (
        SELECT d.ProgramPK FROM Deleted d WHERE d.ProgramPK = pc.ProgramPK
    );

	--Remove all but the most recent 5 change rows for each affected program
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE pc
    FROM dbo.ProgramChanged pc
        INNER JOIN @ExistingChangeRows ecr
            ON pc.ProgramChangedPK = ecr.ProgramChangedPK
    WHERE pc.ProgramChangedPK = ecr.ProgramChangedPK;
	
END
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED ([ProgramPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_Cohort] FOREIGN KEY ([CohortFK]) REFERENCES [dbo].[Cohort] ([CohortPK])
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

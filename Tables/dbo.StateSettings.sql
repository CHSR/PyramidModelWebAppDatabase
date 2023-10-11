CREATE TABLE [dbo].[StateSettings]
(
[StateSettingsPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DueDatesBeginDate] [datetime] NULL,
[DueDatesDaysUntilWarning] [int] NULL,
[DueDatesEnabled] [bit] NOT NULL,
[DueDatesMonthsStart] [decimal] (7, 2) NULL,
[DueDatesMonthsEnd] [decimal] (7, 2) NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/25/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_StateSettings_Changed] 
   ON  [dbo].[StateSettings] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.StateSettingsPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.StateSettingsChanged
    (
        ChangeDatetime,
        ChangeType,
        StateSettingsPK,
        Creator,
        CreateDate,
        DueDatesBeginDate,
		DueDatesDaysUntilWarning,
        DueDatesEnabled,
        DueDatesMonthsStart,
        DueDatesMonthsEnd,
        Editor,
        EditDate,
        StateFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.StateSettingsPK,
        d.Creator,
        d.CreateDate,
        d.DueDatesBeginDate,
		d.DueDatesDaysUntilWarning,
        d.DueDatesEnabled,
        d.DueDatesMonthsStart,
        d.DueDatesMonthsEnd,
        d.Editor,
        d.EditDate,
        d.StateFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        StateSettingsChangedPK INT NOT NULL,
        StateSettingsPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected state settings rows
    INSERT INTO @ExistingChangeRows
    (
        StateSettingsChangedPK,
		StateSettingsPK,
        RowNumber
    )
    SELECT ssc.StateSettingsChangedPK,
		   ssc.StateSettingsPK,
           ROW_NUMBER() OVER (PARTITION BY ssc.StateSettingsPK
                              ORDER BY ssc.StateSettingsChangedPK DESC
                             ) AS RowNum
    FROM dbo.StateSettingsChanged ssc
    WHERE EXISTS
    (
        SELECT d.StateSettingsPK FROM Deleted d WHERE d.StateSettingsPK = ssc.StateSettingsPK
    );

	--Remove all but the most recent 5 change rows for each affected state settings row
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ssc
    FROM dbo.StateSettingsChanged ssc
        INNER JOIN @ExistingChangeRows ecr
            ON ssc.StateSettingsChangedPK = ecr.StateSettingsChangedPK
    WHERE ssc.StateSettingsChangedPK = ecr.StateSettingsChangedPK;
	
END
GO
ALTER TABLE [dbo].[StateSettings] ADD CONSTRAINT [PK_StateSettings] PRIMARY KEY CLUSTERED  ([StateSettingsPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StateSettings_Unique] ON [dbo].[StateSettings] ([StateFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StateSettings] ADD CONSTRAINT [FK_StateSettings_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

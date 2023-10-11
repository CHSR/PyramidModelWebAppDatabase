CREATE TABLE [dbo].[MasterCadreTrainingTrackerItemDate]
(
[MasterCadreTrainingTrackerItemDatePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StartDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NOT NULL,
[MasterCadreTrainingTrackerItemFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 05/04/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_MasterCadreTrainingTrackerItemDate_Changed]
ON [dbo].[MasterCadreTrainingTrackerItemDate]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.MasterCadreTrainingTrackerItemDatePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.MasterCadreTrainingTrackerItemDateChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        MasterCadreTrainingTrackerItemDatePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		StartDateTime,
		EndDateTime,
		MasterCadreTrainingTrackerItemFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.MasterCadreTrainingTrackerItemDatePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
		   d.StartDateTime,
		   d.EndDateTime,
		   d.MasterCadreTrainingTrackerItemFK
		   
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        MasterCadreTrainingTrackerItemDateChangedPK INT NOT NULL,
		MasterCadreTrainingTrackerItemDatePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected MasterCadreTrainingTrackerItemDates
    INSERT INTO @ExistingChangeRows
    (
        MasterCadreTrainingTrackerItemDateChangedPK,
		MasterCadreTrainingTrackerItemDatePK,
        RowNumber
    )
    SELECT ac.MasterCadreTrainingTrackerItemDateChangedPK, 
		   ac.MasterCadreTrainingTrackerItemDatePK,
           ROW_NUMBER() OVER (PARTITION BY ac.MasterCadreTrainingTrackerItemDatePK
                              ORDER BY ac.MasterCadreTrainingTrackerItemDateChangedPK DESC
                             ) AS RowNum
    FROM dbo.MasterCadreTrainingTrackerItemDateChanged ac
    WHERE EXISTS
    (
        SELECT d.MasterCadreTrainingTrackerItemDatePK FROM Deleted d WHERE d.MasterCadreTrainingTrackerItemDatePK = ac.MasterCadreTrainingTrackerItemDatePK
    );

    --Remove all but the most recent 5 change rows for each affected MasterCadreTrainingTrackerItemDate
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.MasterCadreTrainingTrackerItemDateChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.MasterCadreTrainingTrackerItemDateChangedPK = ecr.MasterCadreTrainingTrackerItemDateChangedPK
    WHERE ac.MasterCadreTrainingTrackerItemDateChangedPK = ecr.MasterCadreTrainingTrackerItemDateChangedPK;

END;
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItemDate] ADD CONSTRAINT [PK_MasterCadreTrainingTrackerItemDate] PRIMARY KEY CLUSTERED ([MasterCadreTrainingTrackerItemDatePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItemDate] ADD CONSTRAINT [FK_MasterCadreTrainingTrackerItemDate_MasterCadreTrainingTrackerItem] FOREIGN KEY ([MasterCadreTrainingTrackerItemFK]) REFERENCES [dbo].[MasterCadreTrainingTrackerItem] ([MasterCadreTrainingTrackerItemPK])
GO

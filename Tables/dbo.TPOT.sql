CREATE TABLE [dbo].[TPOT]
(
[TPOTPK] [int] NOT NULL IDENTITY(1, 1),
[AdditionalStrategiesNumUsed] [int] NULL,
[ChallengingBehaviorsNumObserved] [int] NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsComplete] [bit] NOT NULL,
[Item1NumNo] [int] NULL,
[Item1NumYes] [int] NULL,
[Item2NumNo] [int] NULL,
[Item2NumYes] [int] NULL,
[Item3NumNo] [int] NULL,
[Item3NumYes] [int] NULL,
[Item4NumNo] [int] NULL,
[Item4NumYes] [int] NULL,
[Item5NumNo] [int] NULL,
[Item5NumYes] [int] NULL,
[Item6NumNo] [int] NULL,
[Item6NumYes] [int] NULL,
[Item7NumNo] [int] NULL,
[Item7NumYes] [int] NULL,
[Item8NumNo] [int] NULL,
[Item8NumYes] [int] NULL,
[Item9NumNo] [int] NULL,
[Item9NumYes] [int] NULL,
[Item10NumNo] [int] NULL,
[Item10NumYes] [int] NULL,
[Item11NumNo] [int] NULL,
[Item11NumYes] [int] NULL,
[Item12NumNo] [int] NULL,
[Item12NumYes] [int] NULL,
[Item13NumNo] [int] NULL,
[Item13NumYes] [int] NULL,
[Item14NumNo] [int] NULL,
[Item14NumYes] [int] NULL,
[Notes] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAdultsBegin] [int] NOT NULL,
[NumAdultsEnd] [int] NOT NULL,
[NumAdultsEntered] [int] NOT NULL,
[NumKidsBegin] [int] NOT NULL,
[NumKidsEnd] [int] NOT NULL,
[ObservationEndDateTime] [datetime] NOT NULL,
[ObservationStartDateTime] [datetime] NOT NULL,
[RedFlagsNumNo] [int] NULL,
[RedFlagsNumYes] [int] NULL,
[ClassroomFK] [int] NOT NULL,
[EssentialStrategiesUsedCodeFK] [int] NULL,
[ObserverFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_TPOT_Changed] 
   ON  [dbo].[TPOT] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPOTPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPOTChanged
    (
        ChangeDatetime,
        ChangeType,
        TPOTPK,
        AdditionalStrategiesNumUsed,
        ChallengingBehaviorsNumObserved,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        IsComplete,
        Item1NumNo,
        Item1NumYes,
        Item2NumNo,
        Item2NumYes,
        Item3NumNo,
        Item3NumYes,
        Item4NumNo,
        Item4NumYes,
        Item5NumNo,
        Item5NumYes,
        Item6NumNo,
        Item6NumYes,
        Item7NumNo,
        Item7NumYes,
        Item8NumNo,
        Item8NumYes,
        Item9NumNo,
        Item9NumYes,
        Item10NumNo,
        Item10NumYes,
        Item11NumNo,
        Item11NumYes,
        Item12NumNo,
        Item12NumYes,
        Item13NumNo,
        Item13NumYes,
        Item14NumNo,
        Item14NumYes,
        Notes,
        NumAdultsBegin,
        NumAdultsEnd,
        NumAdultsEntered,
        NumKidsBegin,
        NumKidsEnd,
        ObservationEndDateTime,
        ObservationStartDateTime,
        RedFlagsNumNo,
        RedFlagsNumYes,
        ClassroomFK,
        EssentialStrategiesUsedCodeFK,
        ObserverFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPOTPK,
        d.AdditionalStrategiesNumUsed,
        d.ChallengingBehaviorsNumObserved,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.IsComplete,
        d.Item1NumNo,
        d.Item1NumYes,
        d.Item2NumNo,
        d.Item2NumYes,
        d.Item3NumNo,
        d.Item3NumYes,
        d.Item4NumNo,
        d.Item4NumYes,
        d.Item5NumNo,
        d.Item5NumYes,
        d.Item6NumNo,
        d.Item6NumYes,
        d.Item7NumNo,
        d.Item7NumYes,
        d.Item8NumNo,
        d.Item8NumYes,
        d.Item9NumNo,
        d.Item9NumYes,
        d.Item10NumNo,
        d.Item10NumYes,
        d.Item11NumNo,
        d.Item11NumYes,
        d.Item12NumNo,
        d.Item12NumYes,
        d.Item13NumNo,
        d.Item13NumYes,
        d.Item14NumNo,
        d.Item14NumYes,
        d.Notes,
        d.NumAdultsBegin,
        d.NumAdultsEnd,
        d.NumAdultsEntered,
        d.NumKidsBegin,
        d.NumKidsEnd,
        d.ObservationEndDateTime,
        d.ObservationStartDateTime,
        d.RedFlagsNumNo,
        d.RedFlagsNumYes,
        d.ClassroomFK,
        d.EssentialStrategiesUsedCodeFK,
        d.ObserverFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPOTChangedPK INT NOT NULL,
        TPOTPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected TPOT
    INSERT INTO @ExistingChangeRows
    (
        TPOTChangedPK,
		TPOTPK,
        RowNumber
    )
    SELECT tc.TPOTChangedPK,
		   tc.TPOTPK,
           ROW_NUMBER() OVER (PARTITION BY tc.TPOTPK
                              ORDER BY tc.TPOTChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPOTChanged tc
    WHERE EXISTS
    (
        SELECT d.TPOTPK FROM Deleted d WHERE d.TPOTPK = tc.TPOTPK
    );

	--Remove all but the most recent 5 change rows for each affected TPOT
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE tc
    FROM dbo.TPOTChanged tc
        INNER JOIN @ExistingChangeRows ecr
            ON tc.TPOTChangedPK = ecr.TPOTChangedPK
    WHERE tc.TPOTChangedPK = ecr.TPOTChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPOT] ADD CONSTRAINT [PK_TPOT] PRIMARY KEY CLUSTERED ([TPOTPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_TPOT_055CDF0FE180B3D2E029642133974D4E] ON [dbo].[TPOT] ([ClassroomFK], [ObservationStartDateTime]) INCLUDE ([IsComplete], [ObservationEndDateTime]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOT] ADD CONSTRAINT [FK_TPOT_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[TPOT] ADD CONSTRAINT [FK_TPOT_CodeEssentialStrategiesUsed] FOREIGN KEY ([EssentialStrategiesUsedCodeFK]) REFERENCES [dbo].[CodeEssentialStrategiesUsed] ([CodeEssentialStrategiesUsedPK])
GO
ALTER TABLE [dbo].[TPOT] ADD CONSTRAINT [FK_TPOT_ProgramEmployee] FOREIGN KEY ([ObserverFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

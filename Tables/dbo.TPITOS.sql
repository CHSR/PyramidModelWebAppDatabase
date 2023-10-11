CREATE TABLE [dbo].[TPITOS]
(
[TPITOSPK] [int] NOT NULL IDENTITY(1, 1),
[ClassroomRedFlagsNumPossible] [int] NULL,
[ClassroomRedFlagsNumYes] [int] NULL,
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
[LeadTeacherRedFlagsNumYes] [int] NULL,
[LeadTeacherRedFlagsNumPossible] [int] NULL,
[Notes] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAdultsBegin] [int] NOT NULL,
[NumAdultsEnd] [int] NOT NULL,
[NumAdultsEntered] [int] NOT NULL,
[NumKidsBegin] [int] NOT NULL,
[NumKidsEnd] [int] NOT NULL,
[ObservationEndDateTime] [datetime] NOT NULL,
[ObservationStartDateTime] [datetime] NOT NULL,
[OtherTeacherRedFlagsNumYes] [int] NULL,
[OtherTeacherRedFlagsNumPossible] [int] NULL,
[ClassroomFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_TPITOS_Changed] 
   ON  [dbo].[TPITOS] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPITOSPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPITOSChanged
    (
        ChangeDatetime,
        ChangeType,
        TPITOSPK,
        ClassroomRedFlagsNumPossible,
        ClassroomRedFlagsNumYes,
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
        LeadTeacherRedFlagsNumYes,
        LeadTeacherRedFlagsNumPossible,
        Notes,
        NumAdultsBegin,
        NumAdultsEnd,
        NumAdultsEntered,
        NumKidsBegin,
        NumKidsEnd,
        ObservationEndDateTime,
        ObservationStartDateTime,
        OtherTeacherRedFlagsNumYes,
        OtherTeacherRedFlagsNumPossible,
        ClassroomFK,
        ObserverFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPITOSPK,
        d.ClassroomRedFlagsNumPossible,
        d.ClassroomRedFlagsNumYes,
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
        d.LeadTeacherRedFlagsNumYes,
        d.LeadTeacherRedFlagsNumPossible,
        d.Notes,
        d.NumAdultsBegin,
        d.NumAdultsEnd,
        d.NumAdultsEntered,
        d.NumKidsBegin,
        d.NumKidsEnd,
        d.ObservationEndDateTime,
        d.ObservationStartDateTime,
        d.OtherTeacherRedFlagsNumYes,
        d.OtherTeacherRedFlagsNumPossible,
        d.ClassroomFK,
        d.ObserverFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPITOSChangedPK INT NOT NULL,
        TPITOSPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected TPITOS
    INSERT INTO @ExistingChangeRows
    (
        TPITOSChangedPK,
		TPITOSPK,
        RowNumber
    )
    SELECT tc.TPITOSChangedPK,
		   tc.TPITOSPK,
           ROW_NUMBER() OVER (PARTITION BY tc.TPITOSPK
                              ORDER BY tc.TPITOSChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPITOSChanged tc
    WHERE EXISTS
    (
        SELECT d.TPITOSPK FROM Deleted d WHERE d.TPITOSPK = tc.TPITOSPK
    );

	--Remove all but the most recent 5 change rows for each affected TPITOS
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE tc
    FROM dbo.TPITOSChanged tc
        INNER JOIN @ExistingChangeRows ecr
            ON tc.TPITOSChangedPK = ecr.TPITOSChangedPK
    WHERE tc.TPITOSChangedPK = ecr.TPITOSChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [PK_TPITOS] PRIMARY KEY CLUSTERED  ([TPITOSPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [FK_TPITOS_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [FK_TPITOS_ProgramEmployee] FOREIGN KEY ([ObserverFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

CREATE TABLE [dbo].[FormSchedule]
(
[FormSchedulePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ScheduledForJan] [bit] NOT NULL,
[ScheduledForFeb] [bit] NOT NULL,
[ScheduledForMar] [bit] NOT NULL,
[ScheduledForApr] [bit] NOT NULL,
[ScheduledForMay] [bit] NOT NULL,
[ScheduledForJun] [bit] NOT NULL,
[ScheduledForJul] [bit] NOT NULL,
[ScheduledForAug] [bit] NOT NULL,
[ScheduledForSep] [bit] NOT NULL,
[ScheduledForOct] [bit] NOT NULL,
[ScheduledForNov] [bit] NOT NULL,
[ScheduledForDec] [bit] NOT NULL,
[ScheduleYear] [int] NOT NULL,
[ClassroomFK] [int] NULL,
[CodeFormFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 03/10/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_FormSchedule_Changed] 
   ON  [dbo].[FormSchedule] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.FormSchedulePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.FormScheduleChanged
    (
        ChangeDatetime,
        ChangeType,
        FormSchedulePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ScheduledForJan,
        ScheduledForFeb,
        ScheduledForMar,
        ScheduledForApr,
        ScheduledForMay,
        ScheduledForJun,
        ScheduledForJul,
        ScheduledForAug,
        ScheduledForSep,
        ScheduledForOct,
        ScheduledForNov,
        ScheduledForDec,
        ScheduleYear,
        ClassroomFK,
        CodeFormFK,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.FormSchedulePK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.ScheduledForJan,
        d.ScheduledForFeb,
        d.ScheduledForMar,
        d.ScheduledForApr,
        d.ScheduledForMay,
        d.ScheduledForJun,
        d.ScheduledForJul,
        d.ScheduledForAug,
        d.ScheduledForSep,
        d.ScheduledForOct,
        d.ScheduledForNov,
        d.ScheduledForDec,
        d.ScheduleYear,
        d.ClassroomFK,
        d.CodeFormFK,
        d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        FormScheduleChangedPK INT NOT NULL,
        FormSchedulePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        FormScheduleChangedPK,
		FormSchedulePK,
        RowNumber
    )
    SELECT cc.FormScheduleChangedPK,
		   cc.FormSchedulePK,
           ROW_NUMBER() OVER (PARTITION BY cc.FormSchedulePK
                              ORDER BY cc.FormScheduleChangedPK DESC
                             ) AS RowNum
    FROM dbo.FormScheduleChanged cc
    WHERE EXISTS
    (
        SELECT d.FormSchedulePK FROM Deleted d WHERE d.FormSchedulePK = cc.FormSchedulePK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.FormScheduleChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.FormScheduleChangedPK = ecr.FormScheduleChangedPK
    WHERE cc.FormScheduleChangedPK = ecr.FormScheduleChangedPK;
	
END
GO
ALTER TABLE [dbo].[FormSchedule] ADD CONSTRAINT [PK_FormSchedule] PRIMARY KEY CLUSTERED ([FormSchedulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FormSchedule] ADD CONSTRAINT [FK_FormSchedule_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[FormSchedule] ADD CONSTRAINT [FK_FormSchedule_CodeForm] FOREIGN KEY ([CodeFormFK]) REFERENCES [dbo].[CodeForm] ([CodeFormPK])
GO
ALTER TABLE [dbo].[FormSchedule] ADD CONSTRAINT [FK_FormSchedule_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

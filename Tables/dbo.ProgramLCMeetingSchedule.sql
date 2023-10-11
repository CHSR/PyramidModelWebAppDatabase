CREATE TABLE [dbo].[ProgramLCMeetingSchedule]
(
[ProgramLCMeetingSchedulePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[MeetingInJan] [bit] NOT NULL,
[MeetingInFeb] [bit] NOT NULL,
[MeetingInMar] [bit] NOT NULL,
[MeetingInApr] [bit] NOT NULL,
[MeetingInMay] [bit] NOT NULL,
[MeetingInJun] [bit] NOT NULL,
[MeetingInJul] [bit] NOT NULL,
[MeetingInAug] [bit] NOT NULL,
[MeetingInSep] [bit] NOT NULL,
[MeetingInOct] [bit] NOT NULL,
[MeetingInNov] [bit] NOT NULL,
[MeetingInDec] [bit] NOT NULL,
[MeetingYear] [int] NOT NULL,
[TotalMeetings] [int] NOT NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 01/28/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramLCMeetingSchedule_Changed]
ON [dbo].[ProgramLCMeetingSchedule]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramLCMeetingSchedulePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramLCMeetingScheduleChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        ProgramLCMeetingSchedulePK,
		Creator,
		CreateDate,
		Editor,
		EditDate,
        MeetingInJan,
        MeetingInFeb,
        MeetingInMar,
        MeetingInApr,
        MeetingInMay,
        MeetingInJun,
        MeetingInJul,
        MeetingInAug,
        MeetingInSep,
        MeetingInOct,
        MeetingInNov,
        MeetingInDec,
        MeetingYear,
        TotalMeetings,
        LeadershipCoachUsername,
        ProgramFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.ProgramLCMeetingSchedulePK,
		   d.Creator,
		   d.CreateDate,
		   d.Editor,
		   d.EditDate,
           d.MeetingInJan,
           d.MeetingInFeb,
           d.MeetingInMar,
           d.MeetingInApr,
           d.MeetingInMay,
           d.MeetingInJun,
           d.MeetingInJul,
           d.MeetingInAug,
           d.MeetingInSep,
           d.MeetingInOct,
           d.MeetingInNov,
           d.MeetingInDec,
           d.MeetingYear,
           d.TotalMeetings,
           d.LeadershipCoachUsername,
           d.ProgramFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramLCMeetingScheduleChangedPK INT NOT NULL,
		ProgramLCMeetingSchedulePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ProgramLCMeetingSchedules
    INSERT INTO @ExistingChangeRows
    (
        ProgramLCMeetingScheduleChangedPK,
		ProgramLCMeetingSchedulePK,
        RowNumber
    )
    SELECT ac.ProgramLCMeetingScheduleChangedPK, 
		   ac.ProgramLCMeetingSchedulePK,
           ROW_NUMBER() OVER (PARTITION BY ac.ProgramLCMeetingSchedulePK
                              ORDER BY ac.ProgramLCMeetingScheduleChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramLCMeetingScheduleChanged ac
    WHERE EXISTS
    (
        SELECT d.ProgramLCMeetingSchedulePK FROM Deleted d WHERE d.ProgramLCMeetingSchedulePK = ac.ProgramLCMeetingSchedulePK
    );

    --Remove all but the most recent 5 change rows for each affected ProgramLCMeetingSchedule
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.ProgramLCMeetingScheduleChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.ProgramLCMeetingScheduleChangedPK = ecr.ProgramLCMeetingScheduleChangedPK
    WHERE ac.ProgramLCMeetingScheduleChangedPK = ecr.ProgramLCMeetingScheduleChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramLCMeetingSchedule] ADD CONSTRAINT [PK_ProgramLCMeetingSchedule] PRIMARY KEY CLUSTERED ([ProgramLCMeetingSchedulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingSchedule] ADD CONSTRAINT [FK_ProgramLCMeetingSchedule_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

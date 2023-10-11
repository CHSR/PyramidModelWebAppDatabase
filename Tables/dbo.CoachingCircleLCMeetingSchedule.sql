CREATE TABLE [dbo].[CoachingCircleLCMeetingSchedule]
(
[CoachingCircleLCMeetingSchedulePK] [int] NOT NULL IDENTITY(1, 1),
[CoachingCircleName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
[TargetAudience] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalMeetings] [int] NOT NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CoachingCircleLCMeetingSchedule_Changed]
ON [dbo].[CoachingCircleLCMeetingSchedule]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingCircleLCMeetingSchedulePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingCircleLCMeetingScheduleChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        CoachingCircleLCMeetingSchedulePK,
		CoachingCircleName,
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
		TargetAudience,
        TotalMeetings,
        LeadershipCoachUsername,
		StateFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.CoachingCircleLCMeetingSchedulePK,
		   d.CoachingCircleName,
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
		   d.TargetAudience,
           d.TotalMeetings,
           d.LeadershipCoachUsername,
		   d.StateFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingCircleLCMeetingScheduleChangedPK INT NOT NULL,
		CoachingCircleLCMeetingSchedulePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected CoachingCircleLCMeetingSchedules
    INSERT INTO @ExistingChangeRows
    (
        CoachingCircleLCMeetingScheduleChangedPK,
		CoachingCircleLCMeetingSchedulePK,
        RowNumber
    )
    SELECT ac.CoachingCircleLCMeetingScheduleChangedPK, 
		   ac.CoachingCircleLCMeetingSchedulePK,
           ROW_NUMBER() OVER (PARTITION BY ac.CoachingCircleLCMeetingSchedulePK
                              ORDER BY ac.CoachingCircleLCMeetingScheduleChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingCircleLCMeetingScheduleChanged ac
    WHERE EXISTS
    (
        SELECT d.CoachingCircleLCMeetingSchedulePK FROM Deleted d WHERE d.CoachingCircleLCMeetingSchedulePK = ac.CoachingCircleLCMeetingSchedulePK
    );

    --Remove all but the most recent 5 change rows for each affected CoachingCircleLCMeetingSchedule
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.CoachingCircleLCMeetingScheduleChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.CoachingCircleLCMeetingScheduleChangedPK = ecr.CoachingCircleLCMeetingScheduleChangedPK
    WHERE ac.CoachingCircleLCMeetingScheduleChangedPK = ecr.CoachingCircleLCMeetingScheduleChangedPK;

END;
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingSchedule] ADD CONSTRAINT [PK_CoachingCircleLCMeetingSchedule] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingSchedulePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingSchedule] ADD CONSTRAINT [FK_CoachingCircleLCMeetingSchedule_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

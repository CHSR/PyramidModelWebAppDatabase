CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefSession]
(
[CoachingCircleLCMeetingDebriefSessionPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[SessionEndDateTime] [datetime] NOT NULL,
[SessionStartDateTime] [datetime] NOT NULL,
[SessionSummary] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CoachingCircleLCMeetingDebriefFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 01/31/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CoachingCircleLCMeetingDebriefSession_Changed]
ON [dbo].[CoachingCircleLCMeetingDebriefSession]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingCircleLCMeetingDebriefSessionPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingCircleLCMeetingDebriefSessionChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        CoachingCircleLCMeetingDebriefSessionPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        SessionEndDateTime,
        SessionStartDateTime,
        SessionSummary,
        CoachingCircleLCMeetingDebriefFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.CoachingCircleLCMeetingDebriefSessionPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.SessionEndDateTime,
           d.SessionStartDateTime,
           d.SessionSummary,
           d.CoachingCircleLCMeetingDebriefFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingCircleLCMeetingDebriefSessionChangedPK INT NOT NULL,
		CoachingCircleLCMeetingDebriefSessionPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected CoachingCircleLCMeetingDebriefSessions
    INSERT INTO @ExistingChangeRows
    (
        CoachingCircleLCMeetingDebriefSessionChangedPK,
		CoachingCircleLCMeetingDebriefSessionPK,
        RowNumber
    )
    SELECT ac.CoachingCircleLCMeetingDebriefSessionChangedPK, 
		   ac.CoachingCircleLCMeetingDebriefSessionPK,
           ROW_NUMBER() OVER (PARTITION BY ac.CoachingCircleLCMeetingDebriefSessionPK
                              ORDER BY ac.CoachingCircleLCMeetingDebriefSessionChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingCircleLCMeetingDebriefSessionChanged ac
    WHERE EXISTS
    (
        SELECT d.CoachingCircleLCMeetingDebriefSessionPK FROM Deleted d WHERE d.CoachingCircleLCMeetingDebriefSessionPK = ac.CoachingCircleLCMeetingDebriefSessionPK
    );

    --Remove all but the most recent 5 change rows for each affected CoachingCircleLCMeetingDebriefSession
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.CoachingCircleLCMeetingDebriefSessionChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.CoachingCircleLCMeetingDebriefSessionChangedPK = ecr.CoachingCircleLCMeetingDebriefSessionChangedPK
    WHERE ac.CoachingCircleLCMeetingDebriefSessionChangedPK = ecr.CoachingCircleLCMeetingDebriefSessionChangedPK;

END;
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSession] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefSession] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefSessionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSession] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebriefSession_CoachingCircleLCMeetingDebrief] FOREIGN KEY ([CoachingCircleLCMeetingDebriefFK]) REFERENCES [dbo].[CoachingCircleLCMeetingDebrief] ([CoachingCircleLCMeetingDebriefPK])
GO

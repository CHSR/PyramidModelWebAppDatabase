CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendee]
(
[CoachingCircleLCMeetingDebriefSessionAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[CoachingCircleLCMeetingDebriefSessionFK] [int] NOT NULL,
[CoachingCircleLCMeetingDebriefTeamMemberFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CoachingCircleLCMeetingDebriefSessionAttendee_Changed]
ON [dbo].[CoachingCircleLCMeetingDebriefSessionAttendee]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingCircleLCMeetingDebriefSessionAttendeePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingCircleLCMeetingDebriefSessionAttendeeChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        CoachingCircleLCMeetingDebriefSessionAttendeePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        CoachingCircleLCMeetingDebriefSessionFK,
        CoachingCircleLCMeetingDebriefTeamMemberFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.CoachingCircleLCMeetingDebriefSessionAttendeePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.CoachingCircleLCMeetingDebriefSessionFK,
           d.CoachingCircleLCMeetingDebriefTeamMemberFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK INT NOT NULL,
		CoachingCircleLCMeetingDebriefSessionAttendeePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected CoachingCircleLCMeetingDebriefSessionAttendees
    INSERT INTO @ExistingChangeRows
    (
        CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK,
		CoachingCircleLCMeetingDebriefSessionAttendeePK,
        RowNumber
    )
    SELECT ac.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK, 
		   ac.CoachingCircleLCMeetingDebriefSessionAttendeePK,
           ROW_NUMBER() OVER (PARTITION BY ac.CoachingCircleLCMeetingDebriefSessionAttendeePK
                              ORDER BY ac.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingCircleLCMeetingDebriefSessionAttendeeChanged ac
    WHERE EXISTS
    (
        SELECT d.CoachingCircleLCMeetingDebriefSessionAttendeePK FROM Deleted d WHERE d.CoachingCircleLCMeetingDebriefSessionAttendeePK = ac.CoachingCircleLCMeetingDebriefSessionAttendeePK
    );

    --Remove all but the most recent 5 change rows for each affected CoachingCircleLCMeetingDebriefSessionAttendee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.CoachingCircleLCMeetingDebriefSessionAttendeeChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK = ecr.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK
    WHERE ac.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK = ecr.CoachingCircleLCMeetingDebriefSessionAttendeeChangedPK;

END;
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefSessionAttendee] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefSessionAttendeePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebriefSessionAttendee_CoachingCircleLCMeetingDebriefSession] FOREIGN KEY ([CoachingCircleLCMeetingDebriefSessionFK]) REFERENCES [dbo].[CoachingCircleLCMeetingDebriefSession] ([CoachingCircleLCMeetingDebriefSessionPK])
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebriefSessionAttendee_CoachingCircleLCMeetingDebriefTeamMember] FOREIGN KEY ([CoachingCircleLCMeetingDebriefTeamMemberFK]) REFERENCES [dbo].[CoachingCircleLCMeetingDebriefTeamMember] ([CoachingCircleLCMeetingDebriefTeamMemberPK])
GO

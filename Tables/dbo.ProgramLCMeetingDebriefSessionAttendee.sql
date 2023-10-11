CREATE TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendee]
(
[ProgramLCMeetingDebriefSessionAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ProgramLCMeetingDebriefSessionFK] [int] NOT NULL,
[PLTMemberFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramLCMeetingDebriefSessionAttendee_Changed]
ON [dbo].[ProgramLCMeetingDebriefSessionAttendee]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramLCMeetingDebriefSessionAttendeePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramLCMeetingDebriefSessionAttendeeChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        ProgramLCMeetingDebriefSessionAttendeePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ProgramLCMeetingDebriefSessionFK,
        PLTMemberFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.ProgramLCMeetingDebriefSessionAttendeePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.ProgramLCMeetingDebriefSessionFK,
           d.PLTMemberFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramLCMeetingDebriefSessionAttendeeChangedPK INT NOT NULL,
		ProgramLCMeetingDebriefSessionAttendeePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ProgramLCMeetingDebriefSessionAttendees
    INSERT INTO @ExistingChangeRows
    (
        ProgramLCMeetingDebriefSessionAttendeeChangedPK,
		ProgramLCMeetingDebriefSessionAttendeePK,
        RowNumber
    )
    SELECT ac.ProgramLCMeetingDebriefSessionAttendeeChangedPK, 
		   ac.ProgramLCMeetingDebriefSessionAttendeePK,
           ROW_NUMBER() OVER (PARTITION BY ac.ProgramLCMeetingDebriefSessionAttendeePK
                              ORDER BY ac.ProgramLCMeetingDebriefSessionAttendeeChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramLCMeetingDebriefSessionAttendeeChanged ac
    WHERE EXISTS
    (
        SELECT d.ProgramLCMeetingDebriefSessionAttendeePK FROM Deleted d WHERE d.ProgramLCMeetingDebriefSessionAttendeePK = ac.ProgramLCMeetingDebriefSessionAttendeePK
    );

    --Remove all but the most recent 5 change rows for each affected ProgramLCMeetingDebriefSessionAttendee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.ProgramLCMeetingDebriefSessionAttendeeChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.ProgramLCMeetingDebriefSessionAttendeeChangedPK = ecr.ProgramLCMeetingDebriefSessionAttendeeChangedPK
    WHERE ac.ProgramLCMeetingDebriefSessionAttendeeChangedPK = ecr.ProgramLCMeetingDebriefSessionAttendeeChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [PK_ProgramLCMeetingDebriefSessionAttendee] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefSessionAttendeePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_ProgramLCMeetingDebriefSessionAttendee_PLTMember] FOREIGN KEY ([PLTMemberFK]) REFERENCES [dbo].[PLTMember] ([PLTMemberPK])
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_ProgramLCMeetingDebriefSessionAttendee_ProgramLCMeetingDebriefSession] FOREIGN KEY ([ProgramLCMeetingDebriefSessionFK]) REFERENCES [dbo].[ProgramLCMeetingDebriefSession] ([ProgramLCMeetingDebriefSessionPK])
GO

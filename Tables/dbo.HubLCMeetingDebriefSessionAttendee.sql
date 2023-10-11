CREATE TABLE [dbo].[HubLCMeetingDebriefSessionAttendee]
(
[HubLCMeetingDebriefSessionAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[CWLTMemberFK] [int] NOT NULL,
[HubLCMeetingDebriefSessionFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_HubLCMeetingDebriefSessionAttendee_Changed]
ON [dbo].[HubLCMeetingDebriefSessionAttendee]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.HubLCMeetingDebriefSessionAttendeePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.HubLCMeetingDebriefSessionAttendeeChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        HubLCMeetingDebriefSessionAttendeePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		CWLTMemberFK,
        HubLCMeetingDebriefSessionFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.HubLCMeetingDebriefSessionAttendeePK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
		   d.CWLTMemberFK,
           d.HubLCMeetingDebriefSessionFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        HubLCMeetingDebriefSessionAttendeeChangedPK INT NOT NULL,
		HubLCMeetingDebriefSessionAttendeePK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected HubLCMeetingDebriefSessionAttendees
    INSERT INTO @ExistingChangeRows
    (
        HubLCMeetingDebriefSessionAttendeeChangedPK,
		HubLCMeetingDebriefSessionAttendeePK,
        RowNumber
    )
    SELECT ac.HubLCMeetingDebriefSessionAttendeeChangedPK, 
		   ac.HubLCMeetingDebriefSessionAttendeePK,
           ROW_NUMBER() OVER (PARTITION BY ac.HubLCMeetingDebriefSessionAttendeePK
                              ORDER BY ac.HubLCMeetingDebriefSessionAttendeeChangedPK DESC
                             ) AS RowNum
    FROM dbo.HubLCMeetingDebriefSessionAttendeeChanged ac
    WHERE EXISTS
    (
        SELECT d.HubLCMeetingDebriefSessionAttendeePK FROM Deleted d WHERE d.HubLCMeetingDebriefSessionAttendeePK = ac.HubLCMeetingDebriefSessionAttendeePK
    );

    --Remove all but the most recent 5 change rows for each affected HubLCMeetingDebriefSessionAttendee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.HubLCMeetingDebriefSessionAttendeeChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.HubLCMeetingDebriefSessionAttendeeChangedPK = ecr.HubLCMeetingDebriefSessionAttendeeChangedPK
    WHERE ac.HubLCMeetingDebriefSessionAttendeeChangedPK = ecr.HubLCMeetingDebriefSessionAttendeeChangedPK;

END;
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [PK_HubLCMeetingDebriefSessionAttendee] PRIMARY KEY CLUSTERED ([HubLCMeetingDebriefSessionAttendeePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_HubLCMeetingDebriefSessionAttendee_CWLTMember] FOREIGN KEY ([CWLTMemberFK]) REFERENCES [dbo].[CWLTMember] ([CWLTMemberPK])
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSessionAttendee] ADD CONSTRAINT [FK_HubLCMeetingDebriefSessionAttendee_HubLCMeetingDebriefSession] FOREIGN KEY ([HubLCMeetingDebriefSessionFK]) REFERENCES [dbo].[HubLCMeetingDebriefSession] ([HubLCMeetingDebriefSessionPK])
GO

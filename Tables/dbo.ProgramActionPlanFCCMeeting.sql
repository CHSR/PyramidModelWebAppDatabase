CREATE TABLE [dbo].[ProgramActionPlanFCCMeeting]
(
[ProgramActionPlanFCCMeetingPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeadershipCoachAttendance] [bit] NOT NULL,
[MeetingDate] [datetime] NOT NULL,
[MeetingNotes] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramActionPlanFCCFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 09/23/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramActionPlanFCCMeeting_Changed]
ON [dbo].[ProgramActionPlanFCCMeeting]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanFCCMeetingChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanFCCMeetingPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        LeadershipCoachAttendance,
        MeetingDate,
        MeetingNotes,
        ProgramActionPlanFCCFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanFCCMeetingPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.LeadershipCoachAttendance,
           d.MeetingDate,
           d.MeetingNotes,
           d.ProgramActionPlanFCCFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanFCCMeetingChangedPK INT NOT NULL,
        ProgramActionPlanFCCMeetingPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanFCCMeetingChangedPK,
        ProgramActionPlanFCCMeetingPK,
        RowNumber
    )
    SELECT papmc.ProgramActionPlanFCCMeetingChangedPK,
		   papmc.ProgramActionPlanFCCMeetingPK,
		   ROW_NUMBER() OVER (PARTITION BY papmc.ProgramActionPlanFCCMeetingPK
                              ORDER BY papmc.ProgramActionPlanFCCMeetingChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanFCCMeetingChanged papmc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanFCCMeetingPK FROM Deleted d WHERE d.ProgramActionPlanFCCMeetingPK = papmc.ProgramActionPlanFCCMeetingPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papmc
    FROM dbo.ProgramActionPlanFCCMeetingChanged papmc
        INNER JOIN @ExistingChangeRows ecr
            ON papmc.ProgramActionPlanFCCMeetingChangedPK = ecr.ProgramActionPlanFCCMeetingChangedPK
    WHERE papmc.ProgramActionPlanFCCMeetingChangedPK = ecr.ProgramActionPlanFCCMeetingChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCMeeting] ADD CONSTRAINT [PK_ProgramActionPlanFCCMeeting] PRIMARY KEY CLUSTERED ([ProgramActionPlanFCCMeetingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlanFCCMeeting] ADD CONSTRAINT [FK_ProgramActionPlanFCCMeeting_ProgramActionPlanFCC] FOREIGN KEY ([ProgramActionPlanFCCFK]) REFERENCES [dbo].[ProgramActionPlanFCC] ([ProgramActionPlanFCCPK])
GO

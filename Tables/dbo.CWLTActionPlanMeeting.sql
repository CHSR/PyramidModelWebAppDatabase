CREATE TABLE [dbo].[CWLTActionPlanMeeting]
(
[CWLTActionPlanMeetingPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeadershipCoachAttendance] [bit] NOT NULL,
[MeetingDate] [datetime] NOT NULL,
[MeetingNotes] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTActionPlanFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CWLTActionPlanMeeting_Changed]
ON [dbo].[CWLTActionPlanMeeting]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTActionPlanMeetingChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTActionPlanMeetingPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        LeadershipCoachAttendance,
        MeetingDate,
        MeetingNotes,
        CWLTActionPlanFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.CWLTActionPlanMeetingPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.LeadershipCoachAttendance,
           d.MeetingDate,
           d.MeetingNotes,
           d.CWLTActionPlanFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTActionPlanMeetingChangedPK INT NOT NULL,
        CWLTActionPlanMeetingPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		CWLTActionPlanMeetingChangedPK,
        CWLTActionPlanMeetingPK,
        RowNumber
    )
    SELECT papmc.CWLTActionPlanMeetingChangedPK,
		   papmc.CWLTActionPlanMeetingPK,
		   ROW_NUMBER() OVER (PARTITION BY papmc.CWLTActionPlanMeetingPK
                              ORDER BY papmc.CWLTActionPlanMeetingChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTActionPlanMeetingChanged papmc
    WHERE EXISTS
    (
        SELECT d.CWLTActionPlanMeetingPK FROM Deleted d WHERE d.CWLTActionPlanMeetingPK = papmc.CWLTActionPlanMeetingPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papmc
    FROM dbo.CWLTActionPlanMeetingChanged papmc
        INNER JOIN @ExistingChangeRows ecr
            ON papmc.CWLTActionPlanMeetingChangedPK = ecr.CWLTActionPlanMeetingChangedPK
    WHERE papmc.CWLTActionPlanMeetingChangedPK = ecr.CWLTActionPlanMeetingChangedPK;

END;
GO
ALTER TABLE [dbo].[CWLTActionPlanMeeting] ADD CONSTRAINT [PK_CWLTActionPlanMeeting] PRIMARY KEY CLUSTERED ([CWLTActionPlanMeetingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlanMeeting] ADD CONSTRAINT [FK_CWLTActionPlanMeeting_CWLTActionPlan] FOREIGN KEY ([CWLTActionPlanFK]) REFERENCES [dbo].[CWLTActionPlan] ([CWLTActionPlanPK])
GO

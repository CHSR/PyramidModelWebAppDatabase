CREATE TABLE [dbo].[SLTActionPlanMeeting]
(
[SLTActionPlanMeetingPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[MeetingDate] [datetime] NOT NULL,
[MeetingNotes] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTActionPlanFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_SLTActionPlanMeeting_Changed]
ON [dbo].[SLTActionPlanMeeting]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTActionPlanMeetingChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTActionPlanMeetingPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        MeetingDate,
        MeetingNotes,
        SLTActionPlanFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.SLTActionPlanMeetingPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.MeetingDate,
           d.MeetingNotes,
           d.SLTActionPlanFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTActionPlanMeetingChangedPK INT NOT NULL,
        SLTActionPlanMeetingPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		SLTActionPlanMeetingChangedPK,
        SLTActionPlanMeetingPK,
        RowNumber
    )
    SELECT papmc.SLTActionPlanMeetingChangedPK,
		   papmc.SLTActionPlanMeetingPK,
		   ROW_NUMBER() OVER (PARTITION BY papmc.SLTActionPlanMeetingPK
                              ORDER BY papmc.SLTActionPlanMeetingChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTActionPlanMeetingChanged papmc
    WHERE EXISTS
    (
        SELECT d.SLTActionPlanMeetingPK FROM Deleted d WHERE d.SLTActionPlanMeetingPK = papmc.SLTActionPlanMeetingPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papmc
    FROM dbo.SLTActionPlanMeetingChanged papmc
        INNER JOIN @ExistingChangeRows ecr
            ON papmc.SLTActionPlanMeetingChangedPK = ecr.SLTActionPlanMeetingChangedPK
    WHERE papmc.SLTActionPlanMeetingChangedPK = ecr.SLTActionPlanMeetingChangedPK;

END;
GO
ALTER TABLE [dbo].[SLTActionPlanMeeting] ADD CONSTRAINT [PK_SLTActionPlanMeeting] PRIMARY KEY CLUSTERED ([SLTActionPlanMeetingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlanMeeting] ADD CONSTRAINT [FK_SLTActionPlanMeeting_SLTActionPlan] FOREIGN KEY ([SLTActionPlanFK]) REFERENCES [dbo].[SLTActionPlan] ([SLTActionPlanPK])
GO

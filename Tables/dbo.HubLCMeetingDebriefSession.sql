CREATE TABLE [dbo].[HubLCMeetingDebriefSession]
(
[HubLCMeetingDebriefSessionPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[NextSessionEndDateTime] [datetime] NOT NULL,
[NextSessionStartDateTime] [datetime] NOT NULL,
[ReviewedActionPlan] [bit] NOT NULL,
[ReviewedBOQ] [bit] NOT NULL,
[ReviewedOtherItem] [bit] NOT NULL,
[ReviewedOtherItemSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionEndDateTime] [datetime] NOT NULL,
[SessionNextSteps] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SessionStartDateTime] [datetime] NOT NULL,
[SessionSummary] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HubLCMeetingDebriefFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_HubLCMeetingDebriefSession_Changed]
ON [dbo].[HubLCMeetingDebriefSession]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.HubLCMeetingDebriefSessionPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.HubLCMeetingDebriefSessionChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        HubLCMeetingDebriefSessionPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        NextSessionEndDateTime,
        NextSessionStartDateTime,
        ReviewedActionPlan,
        ReviewedBOQ,
        ReviewedOtherItem,
        ReviewedOtherItemSpecify,
        SessionEndDateTime,
		SessionNextSteps,
        SessionStartDateTime,
        SessionSummary,
        HubLCMeetingDebriefFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.HubLCMeetingDebriefSessionPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.NextSessionEndDateTime,
           d.NextSessionStartDateTime,
           d.ReviewedActionPlan,
           d.ReviewedBOQ,
           d.ReviewedOtherItem,
           d.ReviewedOtherItemSpecify,
           d.SessionEndDateTime,
		   d.SessionNextSteps,
           d.SessionStartDateTime,
           d.SessionSummary,
           d.HubLCMeetingDebriefFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        HubLCMeetingDebriefSessionChangedPK INT NOT NULL,
		HubLCMeetingDebriefSessionPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected HubLCMeetingDebriefSessions
    INSERT INTO @ExistingChangeRows
    (
        HubLCMeetingDebriefSessionChangedPK,
		HubLCMeetingDebriefSessionPK,
        RowNumber
    )
    SELECT ac.HubLCMeetingDebriefSessionChangedPK, 
		   ac.HubLCMeetingDebriefSessionPK,
           ROW_NUMBER() OVER (PARTITION BY ac.HubLCMeetingDebriefSessionPK
                              ORDER BY ac.HubLCMeetingDebriefSessionChangedPK DESC
                             ) AS RowNum
    FROM dbo.HubLCMeetingDebriefSessionChanged ac
    WHERE EXISTS
    (
        SELECT d.HubLCMeetingDebriefSessionPK FROM Deleted d WHERE d.HubLCMeetingDebriefSessionPK = ac.HubLCMeetingDebriefSessionPK
    );

    --Remove all but the most recent 5 change rows for each affected HubLCMeetingDebriefSession
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.HubLCMeetingDebriefSessionChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.HubLCMeetingDebriefSessionChangedPK = ecr.HubLCMeetingDebriefSessionChangedPK
    WHERE ac.HubLCMeetingDebriefSessionChangedPK = ecr.HubLCMeetingDebriefSessionChangedPK;

END;
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSession] ADD CONSTRAINT [PK_HubLCMeetingDebriefSession] PRIMARY KEY CLUSTERED ([HubLCMeetingDebriefSessionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubLCMeetingDebriefSession] ADD CONSTRAINT [FK_HubLCMeetingDebriefSession_HubLCMeetingDebrief] FOREIGN KEY ([HubLCMeetingDebriefFK]) REFERENCES [dbo].[HubLCMeetingDebrief] ([HubLCMeetingDebriefPK])
GO

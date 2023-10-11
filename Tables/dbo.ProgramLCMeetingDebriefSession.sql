CREATE TABLE [dbo].[ProgramLCMeetingDebriefSession]
(
[ProgramLCMeetingDebriefSessionPK] [int] NOT NULL IDENTITY(1, 1),
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
[ReviewedTPITOS] [bit] NOT NULL,
[ReviewedTPOT] [bit] NOT NULL,
[SessionEndDateTime] [datetime] NOT NULL,
[SessionNextSteps] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SessionStartDateTime] [datetime] NOT NULL,
[SessionSummary] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramLCMeetingDebriefFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramLCMeetingDebriefSession_Changed]
ON [dbo].[ProgramLCMeetingDebriefSession]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramLCMeetingDebriefSessionPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramLCMeetingDebriefSessionChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        ProgramLCMeetingDebriefSessionPK,
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
        ReviewedTPITOS,
        ReviewedTPOT,
        SessionEndDateTime,
		SessionNextSteps,
        SessionStartDateTime,
        SessionSummary,
        ProgramLCMeetingDebriefFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.ProgramLCMeetingDebriefSessionPK,
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
           d.ReviewedTPITOS,
           d.ReviewedTPOT,
           d.SessionEndDateTime,
		   d.SessionNextSteps,
           d.SessionStartDateTime,
           d.SessionSummary,
           d.ProgramLCMeetingDebriefFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramLCMeetingDebriefSessionChangedPK INT NOT NULL,
		ProgramLCMeetingDebriefSessionPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ProgramLCMeetingDebriefSessions
    INSERT INTO @ExistingChangeRows
    (
        ProgramLCMeetingDebriefSessionChangedPK,
		ProgramLCMeetingDebriefSessionPK,
        RowNumber
    )
    SELECT ac.ProgramLCMeetingDebriefSessionChangedPK, 
		   ac.ProgramLCMeetingDebriefSessionPK,
           ROW_NUMBER() OVER (PARTITION BY ac.ProgramLCMeetingDebriefSessionPK
                              ORDER BY ac.ProgramLCMeetingDebriefSessionChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramLCMeetingDebriefSessionChanged ac
    WHERE EXISTS
    (
        SELECT d.ProgramLCMeetingDebriefSessionPK FROM Deleted d WHERE d.ProgramLCMeetingDebriefSessionPK = ac.ProgramLCMeetingDebriefSessionPK
    );

    --Remove all but the most recent 5 change rows for each affected ProgramLCMeetingDebriefSession
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.ProgramLCMeetingDebriefSessionChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.ProgramLCMeetingDebriefSessionChangedPK = ecr.ProgramLCMeetingDebriefSessionChangedPK
    WHERE ac.ProgramLCMeetingDebriefSessionChangedPK = ecr.ProgramLCMeetingDebriefSessionChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSession] ADD CONSTRAINT [PK_ProgramLCMeetingDebriefSession] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefSessionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebriefSession] ADD CONSTRAINT [FK_ProgramLCMeetingDebriefSession_ProgramLCMeetingDebrief] FOREIGN KEY ([ProgramLCMeetingDebriefFK]) REFERENCES [dbo].[ProgramLCMeetingDebrief] ([ProgramLCMeetingDebriefPK])
GO

CREATE TABLE [dbo].[CoachingCircleLCMeetingDebrief]
(
[CoachingCircleLCMeetingDebriefPK] [int] NOT NULL IDENTITY(1, 1),
[CoachingCircleName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DebriefYear] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[TargetAudience] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
-- Create date: 01/31/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CoachingCircleLCMeetingDebrief_Changed]
ON [dbo].[CoachingCircleLCMeetingDebrief]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingCircleLCMeetingDebriefPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingCircleLCMeetingDebriefChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        CoachingCircleLCMeetingDebriefPK,
        CoachingCircleName,
        Creator,
        CreateDate,
        DebriefYear,
        Editor,
        EditDate,
        TargetAudience,
        LeadershipCoachUsername,
		StateFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.CoachingCircleLCMeetingDebriefPK,
           d.CoachingCircleName,
           d.Creator,
           d.CreateDate,
           d.DebriefYear,
           d.Editor,
           d.EditDate,
           d.TargetAudience,
           d.LeadershipCoachUsername,
		   d.StateFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingCircleLCMeetingDebriefChangedPK INT NOT NULL,
		CoachingCircleLCMeetingDebriefPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected CoachingCircleLCMeetingDebriefs
    INSERT INTO @ExistingChangeRows
    (
        CoachingCircleLCMeetingDebriefChangedPK,
		CoachingCircleLCMeetingDebriefPK,
        RowNumber
    )
    SELECT ac.CoachingCircleLCMeetingDebriefChangedPK, 
		   ac.CoachingCircleLCMeetingDebriefPK,
           ROW_NUMBER() OVER (PARTITION BY ac.CoachingCircleLCMeetingDebriefPK
                              ORDER BY ac.CoachingCircleLCMeetingDebriefChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingCircleLCMeetingDebriefChanged ac
    WHERE EXISTS
    (
        SELECT d.CoachingCircleLCMeetingDebriefPK FROM Deleted d WHERE d.CoachingCircleLCMeetingDebriefPK = ac.CoachingCircleLCMeetingDebriefPK
    );

    --Remove all but the most recent 5 change rows for each affected CoachingCircleLCMeetingDebrief
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.CoachingCircleLCMeetingDebriefChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.CoachingCircleLCMeetingDebriefChangedPK = ecr.CoachingCircleLCMeetingDebriefChangedPK
    WHERE ac.CoachingCircleLCMeetingDebriefChangedPK = ecr.CoachingCircleLCMeetingDebriefChangedPK;

END;
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebrief] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebrief] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebrief] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebrief_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

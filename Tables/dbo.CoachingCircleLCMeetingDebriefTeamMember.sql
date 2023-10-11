CREATE TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMember]
(
[CoachingCircleLCMeetingDebriefTeamMemberPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeamPositionCodeFK] [int] NOT NULL,
[CoachingCircleLCMeetingDebriefFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CoachingCircleLCMeetingDebriefTeamMember_Changed]
ON [dbo].[CoachingCircleLCMeetingDebriefTeamMember]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingCircleLCMeetingDebriefTeamMemberPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingCircleLCMeetingDebriefTeamMemberChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        CoachingCircleLCMeetingDebriefTeamMemberPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        FirstName,
        LastName,
        EmailAddress,
        PhoneNumber,
        TeamPositionCodeFK,
        CoachingCircleLCMeetingDebriefFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.CoachingCircleLCMeetingDebriefTeamMemberPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.FirstName,
           d.LastName,
           d.EmailAddress,
           d.PhoneNumber,
           d.TeamPositionCodeFK,
           d.CoachingCircleLCMeetingDebriefFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingCircleLCMeetingDebriefTeamMemberChangedPK INT NOT NULL,
		CoachingCircleLCMeetingDebriefTeamMemberPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected CoachingCircleLCMeetingDebriefTeamMembers
    INSERT INTO @ExistingChangeRows
    (
        CoachingCircleLCMeetingDebriefTeamMemberChangedPK,
		CoachingCircleLCMeetingDebriefTeamMemberPK,
        RowNumber
    )
    SELECT ac.CoachingCircleLCMeetingDebriefTeamMemberChangedPK, 
		   ac.CoachingCircleLCMeetingDebriefTeamMemberPK,
           ROW_NUMBER() OVER (PARTITION BY ac.CoachingCircleLCMeetingDebriefTeamMemberPK
                              ORDER BY ac.CoachingCircleLCMeetingDebriefTeamMemberChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingCircleLCMeetingDebriefTeamMemberChanged ac
    WHERE EXISTS
    (
        SELECT d.CoachingCircleLCMeetingDebriefTeamMemberPK FROM Deleted d WHERE d.CoachingCircleLCMeetingDebriefTeamMemberPK = ac.CoachingCircleLCMeetingDebriefTeamMemberPK
    );

    --Remove all but the most recent 5 change rows for each affected CoachingCircleLCMeetingDebriefTeamMember
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.CoachingCircleLCMeetingDebriefTeamMemberChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.CoachingCircleLCMeetingDebriefTeamMemberChangedPK = ecr.CoachingCircleLCMeetingDebriefTeamMemberChangedPK
    WHERE ac.CoachingCircleLCMeetingDebriefTeamMemberChangedPK = ecr.CoachingCircleLCMeetingDebriefTeamMemberChangedPK;

END;
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMember] ADD CONSTRAINT [PK_CoachingCircleLCMeetingDebriefTeamMember] PRIMARY KEY CLUSTERED ([CoachingCircleLCMeetingDebriefTeamMemberPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMember] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebriefTeamMember_CoachingCircleLCMeetingDebrief] FOREIGN KEY ([CoachingCircleLCMeetingDebriefFK]) REFERENCES [dbo].[CoachingCircleLCMeetingDebrief] ([CoachingCircleLCMeetingDebriefPK])
GO
ALTER TABLE [dbo].[CoachingCircleLCMeetingDebriefTeamMember] ADD CONSTRAINT [FK_CoachingCircleLCMeetingDebriefTeamMember_CodeTeamPosition] FOREIGN KEY ([TeamPositionCodeFK]) REFERENCES [dbo].[CodeTeamPosition] ([CodeTeamPositionPK])
GO

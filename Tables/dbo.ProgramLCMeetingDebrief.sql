CREATE TABLE [dbo].[ProgramLCMeetingDebrief]
(
[ProgramLCMeetingDebriefPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DebriefYear] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LocationAddress] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactEmail] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactPhone] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramLCMeetingDebrief_Changed]
ON [dbo].[ProgramLCMeetingDebrief]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramLCMeetingDebriefPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramLCMeetingDebriefChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        ProgramLCMeetingDebriefPK,
        Creator,
        CreateDate,
		DebriefYear,
        Editor,
        EditDate,
        LocationAddress,
        PrimaryContactEmail,
        PrimaryContactPhone,
        LeadershipCoachUsername,
        ProgramFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.ProgramLCMeetingDebriefPK,
           d.Creator,
           d.CreateDate,
		   d.DebriefYear,
           d.Editor,
           d.EditDate,
           d.LocationAddress,
           d.PrimaryContactEmail,
           d.PrimaryContactPhone,
           d.LeadershipCoachUsername,
           d.ProgramFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramLCMeetingDebriefChangedPK INT NOT NULL,
		ProgramLCMeetingDebriefPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ProgramLCMeetingDebriefs
    INSERT INTO @ExistingChangeRows
    (
        ProgramLCMeetingDebriefChangedPK,
		ProgramLCMeetingDebriefPK,
        RowNumber
    )
    SELECT ac.ProgramLCMeetingDebriefChangedPK, 
		   ac.ProgramLCMeetingDebriefPK,
           ROW_NUMBER() OVER (PARTITION BY ac.ProgramLCMeetingDebriefPK
                              ORDER BY ac.ProgramLCMeetingDebriefChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramLCMeetingDebriefChanged ac
    WHERE EXISTS
    (
        SELECT d.ProgramLCMeetingDebriefPK FROM Deleted d WHERE d.ProgramLCMeetingDebriefPK = ac.ProgramLCMeetingDebriefPK
    );

    --Remove all but the most recent 5 change rows for each affected ProgramLCMeetingDebrief
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.ProgramLCMeetingDebriefChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.ProgramLCMeetingDebriefChangedPK = ecr.ProgramLCMeetingDebriefChangedPK
    WHERE ac.ProgramLCMeetingDebriefChangedPK = ecr.ProgramLCMeetingDebriefChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebrief] ADD CONSTRAINT [PK_ProgramLCMeetingDebrief] PRIMARY KEY CLUSTERED ([ProgramLCMeetingDebriefPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramLCMeetingDebrief] ADD CONSTRAINT [FK_ProgramLCMeetingDebrief_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

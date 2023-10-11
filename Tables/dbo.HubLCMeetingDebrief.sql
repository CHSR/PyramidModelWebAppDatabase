CREATE TABLE [dbo].[HubLCMeetingDebrief]
(
[HubLCMeetingDebriefPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DebriefYear] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeadOrganization] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationAddress] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactEmail] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryContactPhone] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HubFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_HubLCMeetingDebrief_Changed]
ON [dbo].[HubLCMeetingDebrief]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.HubLCMeetingDebriefPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.HubLCMeetingDebriefChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        HubLCMeetingDebriefPK,
        Creator,
        CreateDate,
        DebriefYear,
        Editor,
        EditDate,
        LeadOrganization,
        LocationAddress,
        PrimaryContactEmail,
        PrimaryContactPhone,
        LeadershipCoachUsername,
        HubFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.HubLCMeetingDebriefPK,
           d.Creator,
           d.CreateDate,
           d.DebriefYear,
           d.Editor,
           d.EditDate,
           d.LeadOrganization,
           d.LocationAddress,
           d.PrimaryContactEmail,
           d.PrimaryContactPhone,
           d.LeadershipCoachUsername,
           d.HubFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        HubLCMeetingDebriefChangedPK INT NOT NULL,
		HubLCMeetingDebriefPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected HubLCMeetingDebriefs
    INSERT INTO @ExistingChangeRows
    (
        HubLCMeetingDebriefChangedPK,
		HubLCMeetingDebriefPK,
        RowNumber
    )
    SELECT ac.HubLCMeetingDebriefChangedPK, 
		   ac.HubLCMeetingDebriefPK,
           ROW_NUMBER() OVER (PARTITION BY ac.HubLCMeetingDebriefPK
                              ORDER BY ac.HubLCMeetingDebriefChangedPK DESC
                             ) AS RowNum
    FROM dbo.HubLCMeetingDebriefChanged ac
    WHERE EXISTS
    (
        SELECT d.HubLCMeetingDebriefPK FROM Deleted d WHERE d.HubLCMeetingDebriefPK = ac.HubLCMeetingDebriefPK
    );

    --Remove all but the most recent 5 change rows for each affected HubLCMeetingDebrief
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.HubLCMeetingDebriefChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.HubLCMeetingDebriefChangedPK = ecr.HubLCMeetingDebriefChangedPK
    WHERE ac.HubLCMeetingDebriefChangedPK = ecr.HubLCMeetingDebriefChangedPK;

END;
GO
ALTER TABLE [dbo].[HubLCMeetingDebrief] ADD CONSTRAINT [PK_HubLCMeetingDebrief] PRIMARY KEY CLUSTERED ([HubLCMeetingDebriefPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubLCMeetingDebrief] ADD CONSTRAINT [FK_HubLCMeetingDebrief_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO

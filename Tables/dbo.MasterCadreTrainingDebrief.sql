CREATE TABLE [dbo].[MasterCadreTrainingDebrief]
(
[MasterCadreTrainingDebriefPK] [int] NOT NULL IDENTITY(1, 1),
[AspireEventNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssistanceNeeded] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingInterest] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseIDNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DateCompleted] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[MeetingLocation] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAttendees] [int] NOT NULL,
[NumEvalsReceived] [int] NOT NULL,
[Reflection] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WasUploadedToAspire] [bit] NULL,
[MasterCadreMemberUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeetingFormatCodeFK] [int] NOT NULL,
[StateFK] [int] NOT NULL,
[MasterCadreActivityCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 02/01/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_MasterCadreTrainingDebrief_Changed]
ON [dbo].[MasterCadreTrainingDebrief]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.MasterCadreTrainingDebriefPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.MasterCadreTrainingDebriefChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        MasterCadreTrainingDebriefPK,
        AspireEventNum,
        AssistanceNeeded,
        CoachingInterest,
		CourseIDNum,
        Creator,
        CreateDate,
        DateCompleted,
        Editor,
        EditDate,
        MeetingLocation,
        NumAttendees,
        NumEvalsReceived,
        Reflection,
        WasUploadedToAspire,
		MasterCadreMemberUsername,
        MeetingFormatCodeFK,
		StateFK,
		MasterCadreActivityCodeFK
		
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.MasterCadreTrainingDebriefPK,
           d.AspireEventNum,
           d.AssistanceNeeded,
           d.CoachingInterest,
		   d.CourseIDNum,
           d.Creator,
           d.CreateDate,
           d.DateCompleted,
           d.Editor,
           d.EditDate,
           d.MeetingLocation,
           d.NumAttendees,
           d.NumEvalsReceived,
           d.Reflection,
           d.WasUploadedToAspire,
		   d.MasterCadreMemberUsername,
           d.MeetingFormatCodeFK,
		   d.StateFK,
		   d.MasterCadreActivityCodeFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        MasterCadreTrainingDebriefChangedPK INT NOT NULL,
		MasterCadreTrainingDebriefPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected MasterCadreTrainingDebriefs
    INSERT INTO @ExistingChangeRows
    (
        MasterCadreTrainingDebriefChangedPK,
		MasterCadreTrainingDebriefPK,
        RowNumber
    )
    SELECT ac.MasterCadreTrainingDebriefChangedPK, 
		   ac.MasterCadreTrainingDebriefPK,
           ROW_NUMBER() OVER (PARTITION BY ac.MasterCadreTrainingDebriefPK
                              ORDER BY ac.MasterCadreTrainingDebriefChangedPK DESC
                             ) AS RowNum
    FROM dbo.MasterCadreTrainingDebriefChanged ac
    WHERE EXISTS
    (
        SELECT d.MasterCadreTrainingDebriefPK FROM Deleted d WHERE d.MasterCadreTrainingDebriefPK = ac.MasterCadreTrainingDebriefPK
    );

    --Remove all but the most recent 5 change rows for each affected MasterCadreTrainingDebrief
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.MasterCadreTrainingDebriefChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.MasterCadreTrainingDebriefChangedPK = ecr.MasterCadreTrainingDebriefChangedPK
    WHERE ac.MasterCadreTrainingDebriefChangedPK = ecr.MasterCadreTrainingDebriefChangedPK;

END;
GO
ALTER TABLE [dbo].[MasterCadreTrainingDebrief] ADD CONSTRAINT [PK_MasterCadreTrainingDebrief] PRIMARY KEY CLUSTERED ([MasterCadreTrainingDebriefPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingDebrief] ADD CONSTRAINT [FK_MasterCadreTrainingDebrief_CodeMasterCadreActivity] FOREIGN KEY ([MasterCadreActivityCodeFK]) REFERENCES [dbo].[CodeMasterCadreActivity] ([CodeMasterCadreActivityPK])
GO
ALTER TABLE [dbo].[MasterCadreTrainingDebrief] ADD CONSTRAINT [FK_MasterCadreTrainingDebrief_CodeMeetingFormat] FOREIGN KEY ([MeetingFormatCodeFK]) REFERENCES [dbo].[CodeMeetingFormat] ([CodeMeetingFormatPK])
GO
ALTER TABLE [dbo].[MasterCadreTrainingDebrief] ADD CONSTRAINT [FK_MasterCadreTrainingDebrief_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

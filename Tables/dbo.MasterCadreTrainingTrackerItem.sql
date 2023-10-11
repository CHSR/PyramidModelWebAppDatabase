CREATE TABLE [dbo].[MasterCadreTrainingTrackerItem]
(
[MasterCadreTrainingTrackerItemPK] [int] NOT NULL IDENTITY(1, 1),
[AspireEventNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseIDNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DidEventOccur] [bit] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsOpenToPublic] [bit] NOT NULL,
[MeetingLocation] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumHours] [decimal] (18, 2) NOT NULL,
[ParticipantFee] [decimal] (18, 2) NOT NULL,
[TargetAudience] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MasterCadreActivityCodeFK] [int] NOT NULL,
[MasterCadreFundingSourceCodeFK] [int] NOT NULL,
[MasterCadreMemberUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeetingFormatCodeFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_MasterCadreTrainingTrackerItem_Changed]
ON [dbo].[MasterCadreTrainingTrackerItem]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.MasterCadreTrainingTrackerItemPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.MasterCadreTrainingTrackerItemChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
        MasterCadreTrainingTrackerItemPK,
        AspireEventNum,
		CourseIDNum,
		Creator,
		CreateDate,
        DidEventOccur,
		Editor,
		EditDate,
        IsOpenToPublic,
        MeetingLocation,
        NumHours,
        ParticipantFee,
        TargetAudience,
		MasterCadreActivityCodeFK,
        MasterCadreFundingSourceCodeFK,
		MasterCadreMemberUsername,
        MeetingFormatCodeFK,
		StateFK
    )
	SELECT GETDATE(),
		   @ChangeType,
		   NULL,
		   d.MasterCadreTrainingTrackerItemPK,
           d.AspireEventNum,
		   d.CourseIDNum,
		   d.Creator,
		   d.CreateDate,
           d.DidEventOccur,
		   d.Editor,
		   d.EditDate,
           d.IsOpenToPublic,
           d.MeetingLocation,
           d.NumHours,
           d.ParticipantFee,
           d.TargetAudience,
		   d.MasterCadreActivityCodeFK,
           d.MasterCadreFundingSourceCodeFK,
		   d.MasterCadreMemberUsername,
           d.MeetingFormatCodeFK,
		   d.StateFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        MasterCadreTrainingTrackerItemChangedPK INT NOT NULL,
		MasterCadreTrainingTrackerItemPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected MasterCadreTrainingTrackerItems
    INSERT INTO @ExistingChangeRows
    (
        MasterCadreTrainingTrackerItemChangedPK,
		MasterCadreTrainingTrackerItemPK,
        RowNumber
    )
    SELECT ac.MasterCadreTrainingTrackerItemChangedPK, 
		   ac.MasterCadreTrainingTrackerItemPK,
           ROW_NUMBER() OVER (PARTITION BY ac.MasterCadreTrainingTrackerItemPK
                              ORDER BY ac.MasterCadreTrainingTrackerItemChangedPK DESC
                             ) AS RowNum
    FROM dbo.MasterCadreTrainingTrackerItemChanged ac
    WHERE EXISTS
    (
        SELECT d.MasterCadreTrainingTrackerItemPK FROM Deleted d WHERE d.MasterCadreTrainingTrackerItemPK = ac.MasterCadreTrainingTrackerItemPK
    );

    --Remove all but the most recent 5 change rows for each affected MasterCadreTrainingTrackerItem
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.MasterCadreTrainingTrackerItemChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.MasterCadreTrainingTrackerItemChangedPK = ecr.MasterCadreTrainingTrackerItemChangedPK
    WHERE ac.MasterCadreTrainingTrackerItemChangedPK = ecr.MasterCadreTrainingTrackerItemChangedPK;

END;
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItem] ADD CONSTRAINT [PK_MasterCadreTrainingTrackerItem] PRIMARY KEY CLUSTERED ([MasterCadreTrainingTrackerItemPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItem] ADD CONSTRAINT [FK_MasterCadreTrainingTrackerItem_CodeMasterCadreActivity] FOREIGN KEY ([MasterCadreActivityCodeFK]) REFERENCES [dbo].[CodeMasterCadreActivity] ([CodeMasterCadreActivityPK])
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItem] ADD CONSTRAINT [FK_MasterCadreTrainingTrackerItem_CodeMasterCadreFundingSource] FOREIGN KEY ([MasterCadreFundingSourceCodeFK]) REFERENCES [dbo].[CodeMasterCadreFundingSource] ([CodeMasterCadreFundingSourcePK])
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItem] ADD CONSTRAINT [FK_MasterCadreTrainingTrackerItem_CodeMeetingFormat] FOREIGN KEY ([MeetingFormatCodeFK]) REFERENCES [dbo].[CodeMeetingFormat] ([CodeMeetingFormatPK])
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItem] ADD CONSTRAINT [FK_MasterCadreTrainingTrackerItem_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

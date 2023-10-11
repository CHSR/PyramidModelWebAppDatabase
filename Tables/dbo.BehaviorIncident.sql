CREATE TABLE [dbo].[BehaviorIncident]
(
[BehaviorIncidentPK] [int] NOT NULL IDENTITY(1, 1),
[ActivitySpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminFollowUpSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BehaviorDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IncidentDatetime] [datetime] NOT NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OthersInvolvedSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PossibleMotivationSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProblemBehaviorSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StrategyResponseSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActivityCodeFK] [int] NOT NULL,
[AdminFollowUpCodeFK] [int] NOT NULL,
[OthersInvolvedCodeFK] [int] NOT NULL,
[PossibleMotivationCodeFK] [int] NOT NULL,
[ProblemBehaviorCodeFK] [int] NOT NULL,
[StrategyResponseCodeFK] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[ClassroomFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 08/07/2019
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_BehaviorIncident_Changed]
ON [dbo].[BehaviorIncident]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BehaviorIncidentChanged
    (
        ChangeDatetime,
        ChangeType,
        BehaviorIncidentPK,
        ActivitySpecify,
        AdminFollowUpSpecify,
        BehaviorDescription,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        IncidentDatetime,
        Notes,
        OthersInvolvedSpecify,
        PossibleMotivationSpecify,
        ProblemBehaviorSpecify,
        StrategyResponseSpecify,
        ActivityCodeFK,
        AdminFollowUpCodeFK,
        OthersInvolvedCodeFK,
        PossibleMotivationCodeFK,
        ProblemBehaviorCodeFK,
        StrategyResponseCodeFK,
        ChildFK,
        ClassroomFK
    )
    SELECT GETDATE(),
           @ChangeType,
           d.BehaviorIncidentPK,
           d.ActivitySpecify,
           d.AdminFollowUpSpecify,
           d.BehaviorDescription,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.IncidentDatetime,
           d.Notes,
           d.OthersInvolvedSpecify,
           d.PossibleMotivationSpecify,
           d.ProblemBehaviorSpecify,
           d.StrategyResponseSpecify,
           d.ActivityCodeFK,
           d.AdminFollowUpCodeFK,
           d.OthersInvolvedCodeFK,
           d.PossibleMotivationCodeFK,
           d.ProblemBehaviorCodeFK,
           d.StrategyResponseCodeFK,
           d.ChildFK,
           d.ClassroomFK
    FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        BehaviorIncidentChangedPK INT NOT NULL,
        BehaviorIncidentPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		BehaviorIncidentChangedPK,
        BehaviorIncidentPK,
        RowNumber
    )
    SELECT bic.BehaviorIncidentChangedPK,
		   bic.BehaviorIncidentPK,
		   ROW_NUMBER() OVER (PARTITION BY bic.BehaviorIncidentPK
                              ORDER BY bic.BehaviorIncidentChangedPK DESC
                             ) AS RowNum
    FROM dbo.BehaviorIncidentChanged bic
    WHERE EXISTS
    (
        SELECT d.BehaviorIncidentPK FROM Deleted d WHERE d.BehaviorIncidentPK = bic.BehaviorIncidentPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE bic
    FROM dbo.BehaviorIncidentChanged bic
        INNER JOIN @ExistingChangeRows ecr
            ON bic.BehaviorIncidentChangedPK = ecr.BehaviorIncidentChangedPK
    WHERE bic.BehaviorIncidentChangedPK = ecr.BehaviorIncidentChangedPK;

END;
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [PK_BehaviorIncident] PRIMARY KEY CLUSTERED ([BehaviorIncidentPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_BehaviorIncident_F192D94579DB6AAA3BD2D5405B72FFA2] ON [dbo].[BehaviorIncident] ([ClassroomFK], [IncidentDatetime]) INCLUDE ([ChildFK], [CreateDate], [Creator], [ProblemBehaviorCodeFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_BehaviorIncident] FOREIGN KEY ([ProblemBehaviorCodeFK]) REFERENCES [dbo].[CodeProblemBehavior] ([CodeProblemBehaviorPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_CodeActivity] FOREIGN KEY ([ActivityCodeFK]) REFERENCES [dbo].[CodeActivity] ([CodeActivityPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_CodeAdminFollowUp] FOREIGN KEY ([AdminFollowUpCodeFK]) REFERENCES [dbo].[CodeAdminFollowUp] ([CodeAdminFollowUpPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_OthersInvolvedCode] FOREIGN KEY ([OthersInvolvedCodeFK]) REFERENCES [dbo].[CodeOthersInvolved] ([CodeOthersInvolvedPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_PossibleMoticationCode] FOREIGN KEY ([PossibleMotivationCodeFK]) REFERENCES [dbo].[CodePossibleMotivation] ([CodePossibleMotivationPK])
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [FK_BehaviorIncident_StrategyResponseCode] FOREIGN KEY ([StrategyResponseCodeFK]) REFERENCES [dbo].[CodeStrategyResponse] ([CodeStrategyResponsePK])
GO

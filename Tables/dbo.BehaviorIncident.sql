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
   ON  [dbo].[BehaviorIncident] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BehaviorIncidentChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		BehaviorIncidentPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    BehaviorIncidentPK,
	    MinChangeDatetime
	)
	SELECT ac.BehaviorIncidentPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.BehaviorIncidentChanged ac
	GROUP BY ac.BehaviorIncidentPK
	HAVING COUNT(ac.BehaviorIncidentPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.BehaviorIncidentChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.BehaviorIncidentPK = ecr.BehaviorIncidentPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.BehaviorIncidentPK = ecr.BehaviorIncidentPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[BehaviorIncident] ADD CONSTRAINT [PK_BehaviorIncident] PRIMARY KEY CLUSTERED  ([BehaviorIncidentPK]) ON [PRIMARY]
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

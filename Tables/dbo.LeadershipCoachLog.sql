CREATE TABLE [dbo].[LeadershipCoachLog]
(
[LeadershipCoachLogPK] [int] NOT NULL IDENTITY(1, 1),
[ActNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[CyclePhase] [int] NULL,
[DateCompleted] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[HighlightsNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsComplete] [bit] NOT NULL,
[IsMonthly] [bit] NULL,
[NumberOfAttemptedEngagements] [int] NULL,
[NumberOfEngagements] [int] NULL,
[OtherDomainTwoSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherEngagementSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherSiteResourcesSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherTopicsDiscussedSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherTrainingsCoveredSpecify] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetedTrainingHours] [int] NULL,
[TargetedTrainingMinutes] [int] NULL,
[ThinkNarrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalDurationHours] [int] NULL,
[TotalDurationMinutes] [int] NULL,
[GoalCompletionLikelihoodCodeFK] [int] NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[TimelyProgressionLikelihoodCodeFK] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 02/17/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_LeadershipCoachLog_Changed] 
   ON  [dbo].[LeadershipCoachLog] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.LeadershipCoachLogPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.LeadershipCoachLogChanged
    (
        ChangeDatetime,
        ChangeType,
        LeadershipCoachLogPK,
        ActNarrative,
        Creator,
        CreateDate,
        CyclePhase,
        DateCompleted,
        Editor,
        EditDate,
		HighlightsNarrative,
		IsComplete,
        IsMonthly,
        NumberOfAttemptedEngagements,
        NumberOfEngagements,
        OtherDomainTwoSpecify,
        OtherEngagementSpecify,
        OtherSiteResourcesSpecify,
        OtherTopicsDiscussedSpecify,
        OtherTrainingsCoveredSpecify,
        TargetedTrainingHours,
        TargetedTrainingMinutes,
        ThinkNarrative,
        TotalDurationHours,
        TotalDurationMinutes,
        GoalCompletionLikelihoodCodeFK,
        LeadershipCoachUsername,
        ProgramFK,
        TimelyProgressionLikelihoodCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.LeadershipCoachLogPK,
        d.ActNarrative,
        d.Creator,
        d.CreateDate,
        d.CyclePhase,
        d.DateCompleted,
        d.Editor,
        d.EditDate,
		d.HighlightsNarrative,
		d.IsComplete,
        d.IsMonthly,
        d.NumberOfAttemptedEngagements,
        d.NumberOfEngagements,
        d.OtherDomainTwoSpecify,
        d.OtherEngagementSpecify,
        d.OtherSiteResourcesSpecify,
        d.OtherTopicsDiscussedSpecify,
        d.OtherTrainingsCoveredSpecify,
        d.TargetedTrainingHours,
        d.TargetedTrainingMinutes,
        d.ThinkNarrative,
        d.TotalDurationHours,
        d.TotalDurationMinutes,
        d.GoalCompletionLikelihoodCodeFK,
        d.LeadershipCoachUsername,
        d.ProgramFK,
        d.TimelyProgressionLikelihoodCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        LeadershipCoachLogChangedPK INT NOT NULL,
        LeadershipCoachLogPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        LeadershipCoachLogChangedPK,
		LeadershipCoachLogPK,
        RowNumber
    )
    SELECT cc.LeadershipCoachLogChangedPK,
		   cc.LeadershipCoachLogPK,
           ROW_NUMBER() OVER (PARTITION BY cc.LeadershipCoachLogPK
                              ORDER BY cc.LeadershipCoachLogChangedPK DESC
                             ) AS RowNum
    FROM dbo.LeadershipCoachLogChanged cc
    WHERE EXISTS
    (
        SELECT d.LeadershipCoachLogPK FROM Deleted d WHERE d.LeadershipCoachLogPK = cc.LeadershipCoachLogPK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.LeadershipCoachLogChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.LeadershipCoachLogChangedPK = ecr.LeadershipCoachLogChangedPK
    WHERE cc.LeadershipCoachLogChangedPK = ecr.LeadershipCoachLogChangedPK;
	
END
GO
ALTER TABLE [dbo].[LeadershipCoachLog] ADD CONSTRAINT [PK_LeadershipCoachLog] PRIMARY KEY CLUSTERED ([LeadershipCoachLogPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LeadershipCoachLog] ADD CONSTRAINT [FK_LeadershipCoachLog_GoalCompletionLikelihood] FOREIGN KEY ([GoalCompletionLikelihoodCodeFK]) REFERENCES [dbo].[CodeLCLResponse] ([CodeLCLResponsePK])
GO
ALTER TABLE [dbo].[LeadershipCoachLog] ADD CONSTRAINT [FK_LeadershipCoachLog_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[LeadershipCoachLog] ADD CONSTRAINT [FK_LeadershipCoachLog_TimelyProgressionLikelihood] FOREIGN KEY ([TimelyProgressionLikelihoodCodeFK]) REFERENCES [dbo].[CodeLCLResponse] ([CodeLCLResponsePK])
GO

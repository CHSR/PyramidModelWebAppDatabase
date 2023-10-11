CREATE TABLE [dbo].[ProgramActionPlan]
(
[ProgramActionPlanPK] [int] NOT NULL IDENTITY(1, 1),
[ActionPlanEndDate] [datetime] NOT NULL,
[ActionPlanStartDate] [datetime] NOT NULL,
[AdditionalNotes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsFullyReviewed] AS (CONVERT([bit],case  when [IsPrefilled]=(0) then (1) when [ReviewedActionSteps]=(1) AND [ReviewedBasicInfo]=(1) AND [ReviewedGroundRules]=(1) then (1) else (0) end,(0))),
[IsLeadershipCoachInvolved] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlan_IsLeadershipCoachInvolved] DEFAULT ((0)),
[IsPrefilled] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlan_IsPrefilled] DEFAULT ((0)),
[MissionStatement] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewedActionSteps] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlan_ReviewedActionSteps] DEFAULT ((0)),
[ReviewedBasicInfo] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlan_ReviewedBasicInfo] DEFAULT ((0)),
[ReviewedGroundRules] [bit] NOT NULL CONSTRAINT [DF_ProgramActionPlan_ReviewedGroundRules] DEFAULT ((0)),
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 09/23/2022
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramActionPlan_Changed]
ON [dbo].[ProgramActionPlan]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramActionPlanChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramActionPlanPK,
        ActionPlanEndDate,
        ActionPlanStartDate,
        AdditionalNotes,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        IsLeadershipCoachInvolved,
        IsPrefilled,
        MissionStatement,
        ReviewedActionSteps,
        ReviewedBasicInfo,
        ReviewedGroundRules,
        LeadershipCoachUsername,
        ProgramFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.ProgramActionPlanPK,
		   d.ActionPlanEndDate,
		   d.ActionPlanStartDate,
           d.AdditionalNotes,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
		   d.IsLeadershipCoachInvolved,
		   d.IsPrefilled,
           d.MissionStatement,
		   d.ReviewedActionSteps,
		   d.ReviewedBasicInfo,
		   d.ReviewedGroundRules,
           d.LeadershipCoachUsername,
           d.ProgramFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramActionPlanChangedPK INT NOT NULL,
        ProgramActionPlanPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		ProgramActionPlanChangedPK,
        ProgramActionPlanPK,
        RowNumber
    )
    SELECT papc.ProgramActionPlanChangedPK,
		   papc.ProgramActionPlanPK,
		   ROW_NUMBER() OVER (PARTITION BY papc.ProgramActionPlanPK
                              ORDER BY papc.ProgramActionPlanChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramActionPlanChanged papc
    WHERE EXISTS
    (
        SELECT d.ProgramActionPlanPK FROM Deleted d WHERE d.ProgramActionPlanPK = papc.ProgramActionPlanPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papc
    FROM dbo.ProgramActionPlanChanged papc
        INNER JOIN @ExistingChangeRows ecr
            ON papc.ProgramActionPlanChangedPK = ecr.ProgramActionPlanChangedPK
    WHERE papc.ProgramActionPlanChangedPK = ecr.ProgramActionPlanChangedPK;

END;
GO
ALTER TABLE [dbo].[ProgramActionPlan] ADD CONSTRAINT [PK_ProgramActionPlan] PRIMARY KEY CLUSTERED ([ProgramActionPlanPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramActionPlan] ADD CONSTRAINT [FK_ProgramActionPlan_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

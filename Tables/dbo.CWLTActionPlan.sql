CREATE TABLE [dbo].[CWLTActionPlan]
(
[CWLTActionPlanPK] [int] NOT NULL IDENTITY(1, 1),
[ActionPlanEndDate] [datetime] NOT NULL,
[ActionPlanStartDate] [datetime] NOT NULL,
[AdditionalNotes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsFullyReviewed] AS (CONVERT([bit],case  when [IsPrefilled]=(0) then (1) when [ReviewedActionSteps]=(1) AND [ReviewedBasicInfo]=(1) AND [ReviewedGroundRules]=(1) then (1) else (0) end,(0))),
[IsLeadershipCoachInvolved] [bit] NOT NULL CONSTRAINT [DF_CWLTActionPlan_IsLeadershipCoachInvolved] DEFAULT ((0)),
[IsPrefilled] [bit] NOT NULL CONSTRAINT [DF_CWLTActionPlan_IsPrefilled] DEFAULT ((0)),
[MissionStatement] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewedActionSteps] [bit] NOT NULL CONSTRAINT [DF_CWLTActionPlan_ReviewedActionSteps] DEFAULT ((0)),
[ReviewedBasicInfo] [bit] NOT NULL CONSTRAINT [DF_CWLTActionPlan_ReviewedBasicInfo] DEFAULT ((0)),
[ReviewedGroundRules] [bit] NOT NULL CONSTRAINT [DF_CWLTActionPlan_ReviewedGroundRules] DEFAULT ((0)),
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HubCoordinatorFK] [int] NOT NULL,
[HubFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CWLTActionPlan_Changed]
ON [dbo].[CWLTActionPlan]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTActionPlanChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTActionPlanPK,
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
		HubCoordinatorFK,
        HubFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.CWLTActionPlanPK,
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
		   d.HubCoordinatorFK,
           d.HubFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTActionPlanChangedPK INT NOT NULL,
        CWLTActionPlanPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		CWLTActionPlanChangedPK,
        CWLTActionPlanPK,
        RowNumber
    )
    SELECT papc.CWLTActionPlanChangedPK,
		   papc.CWLTActionPlanPK,
		   ROW_NUMBER() OVER (PARTITION BY papc.CWLTActionPlanPK
                              ORDER BY papc.CWLTActionPlanChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTActionPlanChanged papc
    WHERE EXISTS
    (
        SELECT d.CWLTActionPlanPK FROM Deleted d WHERE d.CWLTActionPlanPK = papc.CWLTActionPlanPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papc
    FROM dbo.CWLTActionPlanChanged papc
        INNER JOIN @ExistingChangeRows ecr
            ON papc.CWLTActionPlanChangedPK = ecr.CWLTActionPlanChangedPK
    WHERE papc.CWLTActionPlanChangedPK = ecr.CWLTActionPlanChangedPK;

END;
GO
ALTER TABLE [dbo].[CWLTActionPlan] ADD CONSTRAINT [PK_CWLTActionPlan] PRIMARY KEY CLUSTERED ([CWLTActionPlanPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTActionPlan] ADD CONSTRAINT [FK_CWLTActionPlan_CWLTMember] FOREIGN KEY ([HubCoordinatorFK]) REFERENCES [dbo].[CWLTMember] ([CWLTMemberPK])
GO
ALTER TABLE [dbo].[CWLTActionPlan] ADD CONSTRAINT [FK_CWLTActionPlan_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO

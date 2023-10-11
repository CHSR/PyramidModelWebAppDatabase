CREATE TABLE [dbo].[SLTActionPlan]
(
[SLTActionPlanPK] [int] NOT NULL IDENTITY(1, 1),
[ActionPlanEndDate] [datetime] NOT NULL,
[ActionPlanStartDate] [datetime] NOT NULL,
[AdditionalNotes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsFullyReviewed] AS (CONVERT([bit],case  when [IsPrefilled]=(0) then (1) when [ReviewedActionSteps]=(1) AND [ReviewedBasicInfo]=(1) AND [ReviewedGroundRules]=(1) then (1) else (0) end,(0))),
[IsPrefilled] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlan_IsPrefilled] DEFAULT ((0)),
[MissionStatement] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReviewedActionSteps] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlan_ReviewedActionSteps] DEFAULT ((0)),
[ReviewedBasicInfo] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlan_ReviewedBasicInfo] DEFAULT ((0)),
[ReviewedGroundRules] [bit] NOT NULL CONSTRAINT [DF_SLTActionPlan_ReviewedGroundRules] DEFAULT ((0)),
[StateFK] [int] NOT NULL,
[WorkGroupFK] [int] NOT NULL,
[WorkGroupLeadFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_SLTActionPlan_Changed]
ON [dbo].[SLTActionPlan]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTActionPlanChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTActionPlanPK,
		ActionPlanEndDate,
		ActionPlanStartDate,
        AdditionalNotes,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		IsPrefilled,
        MissionStatement,
		ReviewedActionSteps,
		ReviewedBasicInfo,
		ReviewedGroundRules,
		StateFK,
		WorkGroupFK,
        WorkGroupLeadFK
    )
	SELECT GETDATE(),
           @ChangeType,
		   d.SLTActionPlanPK,
		   d.ActionPlanEndDate,
		   d.ActionPlanStartDate,
           d.AdditionalNotes,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
		   d.IsPrefilled,
           d.MissionStatement,
		   d.ReviewedActionSteps,
		   d.ReviewedBasicInfo,
		   d.ReviewedGroundRules,
		   d.StateFK,
           d.WorkGroupFK,
		   d.WorkGroupLeadFK
	FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTActionPlanChangedPK INT NOT NULL,
        SLTActionPlanPK INT NOT NULL,
		RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected behavior incident reports
    INSERT INTO @ExistingChangeRows
    (
		SLTActionPlanChangedPK,
        SLTActionPlanPK,
        RowNumber
    )
    SELECT papc.SLTActionPlanChangedPK,
		   papc.SLTActionPlanPK,
		   ROW_NUMBER() OVER (PARTITION BY papc.SLTActionPlanPK
                              ORDER BY papc.SLTActionPlanChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTActionPlanChanged papc
    WHERE EXISTS
    (
        SELECT d.SLTActionPlanPK FROM Deleted d WHERE d.SLTActionPlanPK = papc.SLTActionPlanPK
    );

    --Remove all but the most recent 5 change rows for each behavior incident report
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;
	
    --Delete the excess change rows to keep the number of change rows at 5
    DELETE papc
    FROM dbo.SLTActionPlanChanged papc
        INNER JOIN @ExistingChangeRows ecr
            ON papc.SLTActionPlanChangedPK = ecr.SLTActionPlanChangedPK
    WHERE papc.SLTActionPlanChangedPK = ecr.SLTActionPlanChangedPK;

END;
GO
ALTER TABLE [dbo].[SLTActionPlan] ADD CONSTRAINT [PK_SLTActionPlan] PRIMARY KEY CLUSTERED ([SLTActionPlanPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTActionPlan] ADD CONSTRAINT [FK_SLTActionPlan_SLTMember] FOREIGN KEY ([WorkGroupLeadFK]) REFERENCES [dbo].[SLTMember] ([SLTMemberPK])
GO
ALTER TABLE [dbo].[SLTActionPlan] ADD CONSTRAINT [FK_SLTActionPlan_SLTWorkGroup] FOREIGN KEY ([WorkGroupFK]) REFERENCES [dbo].[SLTWorkGroup] ([SLTWorkGroupPK])
GO
ALTER TABLE [dbo].[SLTActionPlan] ADD CONSTRAINT [FK_SLTActionPlan_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

CREATE TABLE [dbo].[CoachingLog]
(
[CoachingLogPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LogDate] [datetime] NOT NULL,
[DurationMinutes] [int] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FUEmail] [bit] NOT NULL,
[FUInPerson] [bit] NOT NULL,
[FUNone] [bit] NOT NULL,
[FUPhone] [bit] NOT NULL,
[MEETDemonstration] [bit] NOT NULL,
[MEETEnvironment] [bit] NOT NULL,
[MEETGoalSetting] [bit] NOT NULL,
[MEETGraphic] [bit] NOT NULL,
[MEETMaterial] [bit] NOT NULL,
[MEETOther] [bit] NOT NULL,
[MEETOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEETPerformance] [bit] NOT NULL,
[MEETProblemSolving] [bit] NOT NULL,
[MEETReflectiveConversation] [bit] NOT NULL,
[MEETRoleplay] [bit] NOT NULL,
[MEETVideo] [bit] NOT NULL,
[Narrative] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBSConductTPITOS] [bit] NOT NULL,
[OBSConductTPOT] [bit] NOT NULL,
[OBSEnvironment] [bit] NOT NULL,
[OBSModeling] [bit] NOT NULL,
[OBSObserving] [bit] NOT NULL,
[OBSOther] [bit] NOT NULL,
[OBSOtherHelp] [bit] NOT NULL,
[OBSOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBSProblemSolving] [bit] NOT NULL,
[OBSReflectiveConversation] [bit] NOT NULL,
[OBSSideBySide] [bit] NOT NULL,
[OBSVerbalSupport] [bit] NOT NULL,
[CoachFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_CoachingLog_Changed] 
   ON  [dbo].[CoachingLog] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CoachingLogPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingLogChanged
    (
        ChangeDatetime,
        ChangeType,
        CoachingLogPK,
        Creator,
        CreateDate,
        LogDate,
        DurationMinutes,
        Editor,
        EditDate,
        FUEmail,
        FUInPerson,
        FUNone,
        FUPhone,
        MEETDemonstration,
        MEETEnvironment,
        MEETGoalSetting,
        MEETGraphic,
        MEETMaterial,
        MEETOther,
        MEETOtherSpecify,
        MEETPerformance,
        MEETProblemSolving,
        MEETReflectiveConversation,
        MEETRoleplay,
        MEETVideo,
		Narrative,
        OBSConductTPITOS,
        OBSConductTPOT,
        OBSEnvironment,
        OBSModeling,
        OBSObserving,
        OBSOther,
        OBSOtherHelp,
        OBSOtherSpecify,
        OBSProblemSolving,
        OBSReflectiveConversation,
        OBSSideBySide,
        OBSVerbalSupport,
        CoachFK,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.CoachingLogPK,
        d.Creator,
        d.CreateDate,
        d.LogDate,
        d.DurationMinutes,
        d.Editor,
        d.EditDate,
        d.FUEmail,
        d.FUInPerson,
        d.FUNone,
        d.FUPhone,
        d.MEETDemonstration,
        d.MEETEnvironment,
        d.MEETGoalSetting,
        d.MEETGraphic,
        d.MEETMaterial,
        d.MEETOther,
        d.MEETOtherSpecify,
        d.MEETPerformance,
        d.MEETProblemSolving,
        d.MEETReflectiveConversation,
        d.MEETRoleplay,
        d.MEETVideo,
		d.Narrative,
        d.OBSConductTPITOS,
        d.OBSConductTPOT,
        d.OBSEnvironment,
        d.OBSModeling,
        d.OBSObserving,
        d.OBSOther,
        d.OBSOtherHelp,
        d.OBSOtherSpecify,
        d.OBSProblemSolving,
        d.OBSReflectiveConversation,
        d.OBSSideBySide,
        d.OBSVerbalSupport,
        d.CoachFK,
        d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CoachingLogChangedPK INT NOT NULL,
        CoachingLogPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected coaching logs
    INSERT INTO @ExistingChangeRows
    (
        CoachingLogChangedPK,
		CoachingLogPK,
        RowNumber
    )
    SELECT cc.CoachingLogChangedPK,
		   cc.CoachingLogPK,
           ROW_NUMBER() OVER (PARTITION BY cc.CoachingLogPK
                              ORDER BY cc.CoachingLogChangedPK DESC
                             ) AS RowNum
    FROM dbo.CoachingLogChanged cc
    WHERE EXISTS
    (
        SELECT d.CoachingLogPK FROM Deleted d WHERE d.CoachingLogPK = cc.CoachingLogPK
    );

	--Remove all but the most recent 5 change rows for each affected coaching log
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.CoachingLogChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.CoachingLogChangedPK = ecr.CoachingLogChangedPK
    WHERE cc.CoachingLogChangedPK = ecr.CoachingLogChangedPK;
	
END
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [PK_CoachingLog] PRIMARY KEY CLUSTERED ([CoachingLogPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_CoachingLog_A92A5E017E6B5783A0F1189A35F2D0FB] ON [dbo].[CoachingLog] ([ProgramFK], [LogDate]) INCLUDE ([CoachFK], [DurationMinutes]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [FK_CoachingLog_Coach] FOREIGN KEY ([CoachFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [FK_CoachingLog_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

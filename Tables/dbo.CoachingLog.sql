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
[TeacherFK] [int] NOT NULL,
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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CoachingLogChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		CoachingLogPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    CoachingLogPK,
	    MinChangeDatetime
	)
	SELECT ac.CoachingLogPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.CoachingLogChanged ac
	GROUP BY ac.CoachingLogPK
	HAVING COUNT(ac.CoachingLogPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.CoachingLogChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.CoachingLogPK = ecr.CoachingLogPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.CoachingLogPK = ecr.CoachingLogPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [PK_CoachingLog] PRIMARY KEY CLUSTERED  ([CoachingLogPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [FK_CoachingLog_Coach] FOREIGN KEY ([CoachFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [FK_CoachingLog_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[CoachingLog] ADD CONSTRAINT [FK_CoachingLog_Teacher] FOREIGN KEY ([TeacherFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

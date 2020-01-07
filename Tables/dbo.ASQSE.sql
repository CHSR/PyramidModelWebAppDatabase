CREATE TABLE [dbo].[ASQSE]
(
[ASQSEPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[HasDemographicInfoSheet] [bit] NOT NULL,
[HasPhysicianInfoLetter] [bit] NOT NULL,
[TotalScore] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[IntervalCodeFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Version] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ASQSE_Changed] 
   ON  [dbo].[ASQSE] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ASQSEChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ASQSEPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ASQSEPK,
	    MinChangeDatetime
	)
	SELECT ac.ASQSEPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ASQSEChanged ac
	GROUP BY ac.ASQSEPK
	HAVING COUNT(ac.ASQSEPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ASQSEChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ASQSEPK = ecr.ASQSEPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ASQSEPK = ecr.ASQSEPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [PK_ASQSE] PRIMARY KEY CLUSTERED  ([ASQSEPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_CodeASQSEInterval] FOREIGN KEY ([IntervalCodeFK]) REFERENCES [dbo].[CodeASQSEInterval] ([CodeASQSEIntervalPK])
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

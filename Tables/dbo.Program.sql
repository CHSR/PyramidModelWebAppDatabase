CREATE TABLE [dbo].[Program]
(
[ProgramPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Location] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramEndDate] [datetime] NULL,
[ProgramName] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramStartDate] [datetime] NOT NULL,
[CohortFK] [int] NOT NULL,
[HubFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_Program_Changed] 
   ON  [dbo].[Program] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ProgramPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ProgramPK,
	    MinChangeDatetime
	)
	SELECT ac.ProgramPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ProgramChanged ac
	GROUP BY ac.ProgramPK
	HAVING COUNT(ac.ProgramPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ProgramChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ProgramPK = ecr.ProgramPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ProgramPK = ecr.ProgramPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [PK_Program] PRIMARY KEY CLUSTERED  ([ProgramPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_Cohort] FOREIGN KEY ([CohortFK]) REFERENCES [dbo].[Cohort] ([CohortPK])
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO
ALTER TABLE [dbo].[Program] ADD CONSTRAINT [FK_Program_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

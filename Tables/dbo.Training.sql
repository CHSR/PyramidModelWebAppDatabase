CREATE TABLE [dbo].[Training]
(
[TrainingPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[TrainingDate] [datetime] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL,
[TrainingCodeFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_Training_Changed] 
   ON  [dbo].[Training] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TrainingChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		TrainingPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    TrainingPK,
	    MinChangeDatetime
	)
	SELECT ac.TrainingPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.TrainingChanged ac
	GROUP BY ac.TrainingPK
	HAVING COUNT(ac.TrainingPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.TrainingChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.TrainingPK = ecr.TrainingPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.TrainingPK = ecr.TrainingPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [PK_Training] PRIMARY KEY CLUSTERED  ([TrainingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [FK_Training_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [FK_Training_TrainingCode] FOREIGN KEY ([TrainingCodeFK]) REFERENCES [dbo].[CodeTraining] ([CodeTrainingPK])
GO

CREATE TABLE [dbo].[Training]
(
[TrainingPK] [int] NOT NULL IDENTITY(1, 1),
[AspireEventAttendeeID] [int] NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ExpirationDate] AS (CONVERT([datetime],case  when ([TrainingCodeFK]=(3) OR [TrainingCodeFK]=(4)) AND [TrainingDate]>='01/01/2023' then dateadd(year,(3),[TrainingDate]) end,(0))),
[IsAspireTraining] [bit] NOT NULL CONSTRAINT [DF_Training_IsAspireTraining] DEFAULT ((0)),
[TrainingDate] [datetime] NOT NULL,
[EmployeeFK] [int] NOT NULL,
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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TrainingPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TrainingChanged
    (
        ChangeDatetime,
        ChangeType,
        TrainingPK,
		AspireEventAttendeeID,
        Creator,
        CreateDate,
        Editor,
        EditDate,
		IsAspireTraining,
        TrainingDate,
		EmployeeFK,
        TrainingCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TrainingPK,
		d.AspireEventAttendeeID,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
		d.IsAspireTraining,
        d.TrainingDate,
		d.EmployeeFK,
        d.TrainingCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TrainingChangedPK INT NOT NULL,
        TrainingPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected trainings
    INSERT INTO @ExistingChangeRows
    (
        TrainingChangedPK,
		TrainingPK,
        RowNumber
    )
    SELECT tc.TrainingChangedPK,
		   tc.TrainingPK,
           ROW_NUMBER() OVER (PARTITION BY tc.TrainingPK
                              ORDER BY tc.TrainingChangedPK DESC
                             ) AS RowNum
    FROM dbo.TrainingChanged tc
    WHERE EXISTS
    (
        SELECT d.TrainingPK FROM Deleted d WHERE d.TrainingPK = tc.TrainingPK
    );

	--Remove all but the most recent 5 change rows for each affected training
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE tc
    FROM dbo.TrainingChanged tc
        INNER JOIN @ExistingChangeRows ecr
            ON tc.TrainingChangedPK = ecr.TrainingChangedPK
    WHERE tc.TrainingChangedPK = ecr.TrainingChangedPK;
	
END
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [PK_Training] PRIMARY KEY CLUSTERED ([TrainingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [FK_Training_Employee] FOREIGN KEY ([EmployeeFK]) REFERENCES [dbo].[Employee] ([EmployeePK])
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [FK_Training_TrainingCode] FOREIGN KEY ([TrainingCodeFK]) REFERENCES [dbo].[CodeTraining] ([CodeTrainingPK])
GO

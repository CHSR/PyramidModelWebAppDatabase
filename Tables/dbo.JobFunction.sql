CREATE TABLE [dbo].[JobFunction]
(
[JobFunctionPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NULL,
[JobTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_JobFunction_Changed] 
   ON  [dbo].[JobFunction] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.JobFunctionPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.JobFunctionChanged
    (
        ChangeDatetime,
        ChangeType,
        JobFunctionPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StartDate,
        EndDate,
        JobTypeCodeFK,
        ProgramEmployeeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.JobFunctionPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.StartDate,
        d.EndDate,
        d.JobTypeCodeFK,
        d.ProgramEmployeeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        JobFunctionChangedPK INT NOT NULL,
        JobFunctionPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        JobFunctionChangedPK,
		JobFunctionPK,
        RowNumber
    )
    SELECT cc.JobFunctionChangedPK,
		   cc.JobFunctionPK,
           ROW_NUMBER() OVER (PARTITION BY cc.JobFunctionPK
                              ORDER BY cc.JobFunctionChangedPK DESC
                             ) AS RowNum
    FROM dbo.JobFunctionChanged cc
    WHERE EXISTS
    (
        SELECT d.JobFunctionPK FROM Deleted d WHERE d.JobFunctionPK = cc.JobFunctionPK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.JobFunctionChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.JobFunctionChangedPK = ecr.JobFunctionChangedPK
    WHERE cc.JobFunctionChangedPK = ecr.JobFunctionChangedPK;
	
END
GO
ALTER TABLE [dbo].[JobFunction] ADD CONSTRAINT [PK_JobFunction] PRIMARY KEY CLUSTERED  ([JobFunctionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JobFunction] ADD CONSTRAINT [FK_JobFunction_JobTypeCode] FOREIGN KEY ([JobTypeCodeFK]) REFERENCES [dbo].[CodeJobType] ([CodeJobTypePK])
GO
ALTER TABLE [dbo].[JobFunction] ADD CONSTRAINT [FK_JobFunction_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

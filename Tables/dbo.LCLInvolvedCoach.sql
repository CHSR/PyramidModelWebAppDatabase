CREATE TABLE [dbo].[LCLInvolvedCoach]
(
[LCLInvolvedCoachPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Andy Vuu
-- Create date: 02/17/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_LCLInvolvedCoach_Changed] 
   ON  [dbo].[LCLInvolvedCoach] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.LCLInvolvedCoachPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.LCLInvolvedCoachChanged
    (
        ChangeDatetime,
        ChangeType,
        LCLInvolvedCoachPK,
        Creator,
        CreateDate,
		LeadershipCoachLogFK,
		ProgramEmployeeFK

		
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.LCLInvolvedCoachPK,
        d.Creator,
        d.CreateDate,
		d.LeadershipCoachLogFK,
		d.ProgramEmployeeFK


	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        LCLInvolvedCoachChangedPK INT NOT NULL,
        LCLInvolvedCoachPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        LCLInvolvedCoachChangedPK,
		LCLInvolvedCoachPK,
        RowNumber
    )
    SELECT cc.LCLInvolvedCoachChangedPK,
		   cc.LCLInvolvedCoachPK,
           ROW_NUMBER() OVER (PARTITION BY cc.LCLInvolvedCoachPK
                              ORDER BY cc.LCLInvolvedCoachChangedPK DESC
                             ) AS RowNum
    FROM dbo.LCLInvolvedCoachChanged cc
    WHERE EXISTS
    (
        SELECT d.LCLInvolvedCoachPK FROM Deleted d WHERE d.LCLInvolvedCoachPK = cc.LCLInvolvedCoachPK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.LCLInvolvedCoachChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.LCLInvolvedCoachChangedPK = ecr.LCLInvolvedCoachChangedPK
    WHERE cc.LCLInvolvedCoachChangedPK = ecr.LCLInvolvedCoachChangedPK;
	
END
GO
ALTER TABLE [dbo].[LCLInvolvedCoach] ADD CONSTRAINT [PK_LCLInvolvedCoach] PRIMARY KEY CLUSTERED ([LCLInvolvedCoachPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLInvolvedCoach] ADD CONSTRAINT [FK_LCLInvolvedCoach_LeadershipCoachLog] FOREIGN KEY ([LeadershipCoachLogFK]) REFERENCES [dbo].[LeadershipCoachLog] ([LeadershipCoachLogPK])
GO
ALTER TABLE [dbo].[LCLInvolvedCoach] ADD CONSTRAINT [FK_LCLInvolvedCoach_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

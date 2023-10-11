CREATE TABLE [dbo].[LCLResponse]
(
[LCLResponsePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LCLResponseCodeFK] [int] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_LCLResponse_Changed] 
   ON  [dbo].[LCLResponse] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.LCLResponsePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.LCLResponseChanged
    (
        ChangeDatetime,
        ChangeType,
        LCLResponsePK,
        Creator,
        CreateDate,
		LCLResponseCodeFK,
		LeadershipCoachLogFK

		
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.LCLResponsePK,
        d.Creator,
        d.CreateDate,
		d.LCLResponseCodeFK,
		d.LeadershipCoachLogFK



	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        LCLResponseChangedPK INT NOT NULL,
        LCLResponsePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        LCLResponseChangedPK,
		LCLResponsePK,
        RowNumber
    )
    SELECT cc.LCLResponseChangedPK,
		   cc.LCLResponsePK,
           ROW_NUMBER() OVER (PARTITION BY cc.LCLResponsePK
                              ORDER BY cc.LCLResponseChangedPK DESC
                             ) AS RowNum
    FROM dbo.LCLResponseChanged cc
    WHERE EXISTS
    (
        SELECT d.LCLResponsePK FROM Deleted d WHERE d.LCLResponsePK = cc.LCLResponsePK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.LCLResponseChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.LCLResponseChangedPK = ecr.LCLResponseChangedPK
    WHERE cc.LCLResponseChangedPK = ecr.LCLResponseChangedPK;
	
END
GO
ALTER TABLE [dbo].[LCLResponse] ADD CONSTRAINT [PK_LCLResponse] PRIMARY KEY CLUSTERED ([LCLResponsePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLResponse] ADD CONSTRAINT [FK_LCLResponse_CodeLCLResponse] FOREIGN KEY ([LCLResponseCodeFK]) REFERENCES [dbo].[CodeLCLResponse] ([CodeLCLResponsePK])
GO
ALTER TABLE [dbo].[LCLResponse] ADD CONSTRAINT [FK_LCLResponse_LeadershipCoachLog] FOREIGN KEY ([LeadershipCoachLogFK]) REFERENCES [dbo].[LeadershipCoachLog] ([LeadershipCoachLogPK])
GO

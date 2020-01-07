CREATE TABLE [dbo].[Cohort]
(
[CohortPK] [int] NOT NULL IDENTITY(1, 1),
[CohortName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_Cohort_Changed] 
   ON  [dbo].[Cohort] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CohortChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		CohortPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    CohortPK,
	    MinChangeDatetime
	)
	SELECT ac.CohortPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.CohortChanged ac
	GROUP BY ac.CohortPK
	HAVING COUNT(ac.CohortPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.CohortChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.CohortPK = ecr.CohortPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.CohortPK = ecr.CohortPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Cohort] ADD CONSTRAINT [PK_Cohort] PRIMARY KEY CLUSTERED  ([CohortPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Cohort] ADD CONSTRAINT [FK_Cohort_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

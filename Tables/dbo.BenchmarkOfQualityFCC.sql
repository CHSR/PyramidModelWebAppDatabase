CREATE TABLE [dbo].[BenchmarkOfQualityFCC]
(
[BenchmarkOfQualityFCCPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[Indicator1] [int] NULL,
[Indicator2] [int] NULL,
[Indicator3] [int] NULL,
[Indicator4] [int] NULL,
[Indicator5] [int] NULL,
[Indicator6] [int] NULL,
[Indicator7] [int] NULL,
[Indicator8] [int] NULL,
[Indicator9] [int] NULL,
[Indicator10] [int] NULL,
[Indicator11] [int] NULL,
[Indicator12] [int] NULL,
[Indicator13] [int] NULL,
[Indicator14] [int] NULL,
[Indicator15] [int] NULL,
[Indicator16] [int] NULL,
[Indicator17] [int] NULL,
[Indicator18] [int] NULL,
[Indicator19] [int] NULL,
[Indicator20] [int] NULL,
[Indicator21] [int] NULL,
[Indicator22] [int] NULL,
[Indicator23] [int] NULL,
[Indicator24] [int] NULL,
[Indicator25] [int] NULL,
[Indicator26] [int] NULL,
[Indicator27] [int] NULL,
[Indicator28] [int] NULL,
[Indicator29] [int] NULL,
[Indicator30] [int] NULL,
[Indicator31] [int] NULL,
[Indicator32] [int] NULL,
[Indicator33] [int] NULL,
[Indicator34] [int] NULL,
[Indicator35] [int] NULL,
[Indicator36] [int] NULL,
[Indicator37] [int] NULL,
[Indicator38] [int] NULL,
[Indicator39] [int] NULL,
[Indicator40] [int] NULL,
[Indicator41] [int] NULL,
[Indicator42] [int] NULL,
[Indicator43] [int] NULL,
[Indicator44] [int] NULL,
[Indicator45] [int] NULL,
[Indicator46] [int] NULL,
[Indicator47] [int] NULL,
[TeamMembers] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_BenchmarkOfQualityFCC_Changed] 
   ON  [dbo].[BenchmarkOfQualityFCC] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BenchmarkOfQualityFCCChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		BenchmarkOfQualityFCCPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    BenchmarkOfQualityFCCPK,
	    MinChangeDatetime
	)
	SELECT ac.BenchmarkOfQualityFCCPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.BenchmarkOfQualityFCCChanged ac
	GROUP BY ac.BenchmarkOfQualityFCCPK
	HAVING COUNT(ac.BenchmarkOfQualityFCCPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.BenchmarkOfQualityFCCChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.BenchmarkOfQualityFCCPK = ecr.BenchmarkOfQualityFCCPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.BenchmarkOfQualityFCCPK = ecr.BenchmarkOfQualityFCCPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[BenchmarkOfQualityFCC] ADD CONSTRAINT [PK_BenchmarkOfQualityFCC] PRIMARY KEY CLUSTERED  ([BenchmarkOfQualityFCCPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BenchmarkOfQualityFCC] ADD CONSTRAINT [FK_BenchmarkOfQualityFCC_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

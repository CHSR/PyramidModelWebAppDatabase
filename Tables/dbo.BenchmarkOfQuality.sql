CREATE TABLE [dbo].[BenchmarkOfQuality]
(
[BenchmarkOfQualityPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[Indicator1] [int] NOT NULL,
[Indicator2] [int] NOT NULL,
[Indicator3] [int] NOT NULL,
[Indicator4] [int] NOT NULL,
[Indicator5] [int] NOT NULL,
[Indicator6] [int] NOT NULL,
[Indicator7] [int] NOT NULL,
[Indicator8] [int] NOT NULL,
[Indicator9] [int] NOT NULL,
[Indicator10] [int] NOT NULL,
[Indicator11] [int] NOT NULL,
[Indicator12] [int] NOT NULL,
[Indicator13] [int] NOT NULL,
[Indicator14] [int] NOT NULL,
[Indicator15] [int] NOT NULL,
[Indicator16] [int] NOT NULL,
[Indicator17] [int] NOT NULL,
[Indicator18] [int] NOT NULL,
[Indicator19] [int] NOT NULL,
[Indicator20] [int] NOT NULL,
[Indicator21] [int] NOT NULL,
[Indicator22] [int] NOT NULL,
[Indicator23] [int] NOT NULL,
[Indicator24] [int] NOT NULL,
[Indicator25] [int] NOT NULL,
[Indicator26] [int] NOT NULL,
[Indicator27] [int] NOT NULL,
[Indicator28] [int] NOT NULL,
[Indicator29] [int] NOT NULL,
[Indicator30] [int] NOT NULL,
[Indicator31] [int] NOT NULL,
[Indicator32] [int] NOT NULL,
[Indicator33] [int] NOT NULL,
[Indicator34] [int] NOT NULL,
[Indicator35] [int] NOT NULL,
[Indicator36] [int] NOT NULL,
[Indicator37] [int] NOT NULL,
[Indicator38] [int] NOT NULL,
[Indicator39] [int] NOT NULL,
[Indicator40] [int] NOT NULL,
[Indicator41] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_BenchmarkOfQuality_Changed] 
   ON  [dbo].[BenchmarkOfQuality] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BenchmarkOfQualityChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		BenchmarkOfQualityPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    BenchmarkOfQualityPK,
	    MinChangeDatetime
	)
	SELECT ac.BenchmarkOfQualityPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.BenchmarkOfQualityChanged ac
	GROUP BY ac.BenchmarkOfQualityPK
	HAVING COUNT(ac.BenchmarkOfQualityPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.BenchmarkOfQualityChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.BenchmarkOfQualityPK = ecr.BenchmarkOfQualityPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.BenchmarkOfQualityPK = ecr.BenchmarkOfQualityPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[BenchmarkOfQuality] ADD CONSTRAINT [PK_BenchmarkOfQuality] PRIMARY KEY CLUSTERED  ([BenchmarkOfQualityPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BenchmarkOfQuality] ADD CONSTRAINT [FK_BenchmarkOfQuality_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

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
[IsComplete] [bit] NOT NULL CONSTRAINT [DF_BenchmarkOfQualityFCC_IsComplete] DEFAULT ((1)),
[TeamMembers] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VersionNumber] [int] NOT NULL CONSTRAINT [DF_BenchmarkOfQualityFCC_VersionNumber] DEFAULT ((1)),
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
ON [dbo].[BenchmarkOfQualityFCC]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.BenchmarkOfQualityFCCPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BenchmarkOfQualityFCCChanged
    (
        ChangeDatetime,
        ChangeType,
        BenchmarkOfQualityFCCPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        FormDate,
        Indicator1,
        Indicator2,
        Indicator3,
        Indicator4,
        Indicator5,
        Indicator6,
        Indicator7,
        Indicator8,
        Indicator9,
        Indicator10,
        Indicator11,
        Indicator12,
        Indicator13,
        Indicator14,
        Indicator15,
        Indicator16,
        Indicator17,
        Indicator18,
        Indicator19,
        Indicator20,
        Indicator21,
        Indicator22,
        Indicator23,
        Indicator24,
        Indicator25,
        Indicator26,
        Indicator27,
        Indicator28,
        Indicator29,
        Indicator30,
        Indicator31,
        Indicator32,
        Indicator33,
        Indicator34,
        Indicator35,
        Indicator36,
        Indicator37,
        Indicator38,
        Indicator39,
        Indicator40,
        Indicator41,
        Indicator42,
        Indicator43,
        Indicator44,
        Indicator45,
        Indicator46,
        Indicator47,
		IsComplete,
        TeamMembers,
		VersionNumber,
        ProgramFK
    )
    SELECT GETDATE(),
           @ChangeType,
           d.BenchmarkOfQualityFCCPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.FormDate,
           d.Indicator1,
           d.Indicator2,
           d.Indicator3,
           d.Indicator4,
           d.Indicator5,
           d.Indicator6,
           d.Indicator7,
           d.Indicator8,
           d.Indicator9,
           d.Indicator10,
           d.Indicator11,
           d.Indicator12,
           d.Indicator13,
           d.Indicator14,
           d.Indicator15,
           d.Indicator16,
           d.Indicator17,
           d.Indicator18,
           d.Indicator19,
           d.Indicator20,
           d.Indicator21,
           d.Indicator22,
           d.Indicator23,
           d.Indicator24,
           d.Indicator25,
           d.Indicator26,
           d.Indicator27,
           d.Indicator28,
           d.Indicator29,
           d.Indicator30,
           d.Indicator31,
           d.Indicator32,
           d.Indicator33,
           d.Indicator34,
           d.Indicator35,
           d.Indicator36,
           d.Indicator37,
           d.Indicator38,
           d.Indicator39,
           d.Indicator40,
           d.Indicator41,
           d.Indicator42,
           d.Indicator43,
           d.Indicator44,
           d.Indicator45,
           d.Indicator46,
           d.Indicator47,
		   d.IsComplete,
           d.TeamMembers,
		   d.VersionNumber,
           d.ProgramFK
    FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        BenchmarkOfQualityFCCChangedPK INT NOT NULL,
        BenchmarkOfQualityFCCPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected BOQFCCs
    INSERT INTO @ExistingChangeRows
    (
        BenchmarkOfQualityFCCChangedPK,
		BenchmarkOfQualityFCCPK,
        RowNumber
    )
    SELECT boqc.BenchmarkOfQualityFCCChangedPK,
		   boqc.BenchmarkOfQualityFCCPK,
           ROW_NUMBER() OVER (PARTITION BY boqc.BenchmarkOfQualityFCCPK
                              ORDER BY boqc.BenchmarkOfQualityFCCChangedPK DESC
                             ) AS RowNum
    FROM dbo.BenchmarkOfQualityFCCChanged boqc
    WHERE EXISTS
    (
        SELECT d.BenchmarkOfQualityFCCPK FROM Deleted d WHERE d.BenchmarkOfQualityFCCPK = boqc.BenchmarkOfQualityFCCPK
    );

	--Remove all but the most recent 5 change rows for each affected BOQFCC
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE boqc
    FROM dbo.BenchmarkOfQualityFCCChanged boqc
        INNER JOIN @ExistingChangeRows ecr
            ON boqc.BenchmarkOfQualityFCCChangedPK = ecr.BenchmarkOfQualityFCCChangedPK
    WHERE boqc.BenchmarkOfQualityFCCChangedPK = ecr.BenchmarkOfQualityFCCChangedPK

END;
GO
ALTER TABLE [dbo].[BenchmarkOfQualityFCC] ADD CONSTRAINT [PK_BenchmarkOfQualityFCC] PRIMARY KEY CLUSTERED ([BenchmarkOfQualityFCCPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BenchmarkOfQualityFCC] ADD CONSTRAINT [FK_BenchmarkOfQualityFCC_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

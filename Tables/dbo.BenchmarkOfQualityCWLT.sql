CREATE TABLE [dbo].[BenchmarkOfQualityCWLT]
(
[BenchmarkOfQualityCWLTPK] [int] NOT NULL IDENTITY(1, 1),
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
[HubFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 12/08/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_BenchmarkOfQualityCWLT_Changed]
ON [dbo].[BenchmarkOfQualityCWLT]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.BenchmarkOfQualityCWLTPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BenchmarkOfQualityCWLTChanged
    (
        ChangeDatetime,
        ChangeType,
        BenchmarkOfQualityCWLTPK,
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
        HubFK
    )
    SELECT GETDATE(),
           @ChangeType,
           d.BenchmarkOfQualityCWLTPK,
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
           d.HubFK
    FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        BenchmarkOfQualityCWLTChangedPK INT NOT NULL,
        BenchmarkOfQualityCWLTPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected BOQs
    INSERT INTO @ExistingChangeRows
    (
        BenchmarkOfQualityCWLTChangedPK,
		BenchmarkOfQualityCWLTPK,
        RowNumber
    )
    SELECT boqc.BenchmarkOfQualityCWLTChangedPK,
		   boqc.BenchmarkOfQualityCWLTPK,
           ROW_NUMBER() OVER (PARTITION BY boqc.BenchmarkOfQualityCWLTPK
                              ORDER BY boqc.BenchmarkOfQualityCWLTChangedPK DESC
                             ) AS RowNum
    FROM dbo.BenchmarkOfQualityCWLTChanged boqc
    WHERE EXISTS
    (
        SELECT d.BenchmarkOfQualityCWLTPK FROM Deleted d WHERE d.BenchmarkOfQualityCWLTPK = boqc.BenchmarkOfQualityCWLTPK
    );

	--Remove all but the most recent 5 change rows for each affected BOQ
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE boqc
    FROM dbo.BenchmarkOfQualityCWLTChanged boqc
        INNER JOIN @ExistingChangeRows ecr
            ON boqc.BenchmarkOfQualityCWLTChangedPK = ecr.BenchmarkOfQualityCWLTChangedPK
    WHERE boqc.BenchmarkOfQualityCWLTChangedPK = ecr.BenchmarkOfQualityCWLTChangedPK

END;
GO
ALTER TABLE [dbo].[BenchmarkOfQualityCWLT] ADD CONSTRAINT [PK_BenchmarkOfQualityCWLT] PRIMARY KEY CLUSTERED ([BenchmarkOfQualityCWLTPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BenchmarkOfQualityCWLT] ADD CONSTRAINT [FK_BenchmarkOfQualityCWLT_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO

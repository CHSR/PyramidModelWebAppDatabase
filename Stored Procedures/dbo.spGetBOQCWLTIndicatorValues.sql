SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 10/25/2022
-- Description:	This stored procedure returns the BOQ CWLT indicator
-- information for a specific BOQ CWLT.
-- =============================================
CREATE PROC [dbo].[spGetBOQCWLTIndicatorValues] @BOQPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the indicator information
    SELECT pivotedTable.BenchmarkOfQualityCWLTPK,
		   cbce.Abbreviation CriticalElementAbbreviation,
		   cbce.[Description] CriticalElementDescription,
           TRY_CONVERT(INT, REPLACE(pivotedTable.Indicator, 'Indicator', '')) IndicatorNumber,
		   cbi.[Description] IndicatorDescription,
           pivotedTable.IndicatorValue,
		   cbiv.Abbreviation IndicatorValueAbbreviation,
		   cbiv.[Description] IndicatorValueDescription
    FROM
    (
        SELECT *
        FROM dbo.BenchmarkOfQualityCWLT boqc
        WHERE boqc.BenchmarkOfQualityCWLTPK = @BOQPK
    ) boq
        UNPIVOT
        (
            IndicatorValue
            FOR Indicator IN (Indicator1, Indicator2, Indicator3, Indicator4, Indicator5, Indicator6, Indicator7,
                              Indicator8, Indicator9, Indicator10, Indicator11, Indicator12, Indicator13, Indicator14,
                              Indicator15, Indicator16, Indicator17, Indicator18, Indicator19, Indicator20,
                              Indicator21, Indicator22, Indicator23, Indicator24, Indicator25, Indicator26,
                              Indicator27, Indicator28, Indicator29, Indicator30, Indicator31, Indicator32,
                              Indicator33, Indicator34, Indicator35, Indicator36, Indicator37, Indicator38,
                              Indicator39
                             )
        ) AS pivotedTable
	INNER JOIN dbo.CodeBOQIndicator cbi
		ON cbi.IndicatorNumber = REPLACE(pivotedTable.Indicator, 'Indicator', '')
	INNER JOIN dbo.CodeBOQCriticalElement cbce
		ON cbce.CodeBOQCriticalElementPK = cbi.BOQCriticalElementCodeFK
			AND cbce.BOQTypeCodeFK = 3 --Only want BOQ CWLT critical elements and indicators
	INNER JOIN dbo.CodeBOQIndicatorValue cbiv
		ON cbiv.IndicatorValue = pivotedTable.IndicatorValue
			AND cbiv.BOQTypeCodeFK = 3;  --Only want BOQ CWLT indicator values

END;
GO

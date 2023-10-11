SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/19/2022
-- Description:	This stored procedure returns all the necessary information
-- for the SLT BOQ Change Report.
-- =============================================
CREATE PROC [dbo].[rspBOQCWLTChange]
(
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @tblFormsInRange TABLE
    (
        BenchmarkOfQualityCWLTPK INT NOT NULL,
        FormDate DATETIME NOT NULL,
        HubFK INT NOT NULL,
        HubName VARCHAR(400) NOT NULL,
        Indicator1 INT NOT NULL,
        Indicator2 INT NOT NULL,
        Indicator3 INT NOT NULL,
        Indicator4 INT NOT NULL,
        Indicator5 INT NOT NULL,
        Indicator6 INT NOT NULL,
        Indicator7 INT NOT NULL,
        Indicator8 INT NOT NULL,
        Indicator9 INT NOT NULL,
        Indicator10 INT NOT NULL,
        Indicator11 INT NOT NULL,
        Indicator12 INT NOT NULL,
        Indicator13 INT NOT NULL,
        Indicator14 INT NOT NULL,
        Indicator15 INT NOT NULL,
        Indicator16 INT NOT NULL,
        Indicator17 INT NOT NULL,
        Indicator18 INT NOT NULL,
        Indicator19 INT NOT NULL,
        Indicator20 INT NOT NULL,
        Indicator21 INT NOT NULL,
        Indicator22 INT NOT NULL,
        Indicator23 INT NOT NULL,
        Indicator24 INT NOT NULL,
        Indicator25 INT NOT NULL,
        Indicator26 INT NOT NULL,
        Indicator27 INT NOT NULL,
        Indicator28 INT NOT NULL,
        Indicator29 INT NOT NULL,
        Indicator30 INT NOT NULL,
        Indicator31 INT NOT NULL,
        Indicator32 INT NOT NULL,
        Indicator33 INT NOT NULL,
        Indicator34 INT NOT NULL,
        Indicator35 INT NOT NULL,
        Indicator36 INT NOT NULL,
        Indicator37 INT NOT NULL,
        Indicator38 INT NOT NULL,
        Indicator39 INT NOT NULL,
        RowNumber INT NOT NULL
    );

	--Get the 5 most recent BOQs for each state
	--that match the passed parameters
    INSERT INTO @tblFormsInRange
    (
        BenchmarkOfQualityCWLTPK,
        FormDate,
        HubFK,
        HubName,
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
        RowNumber
    )
    SELECT boq.BenchmarkOfQualityCWLTPK,
           boq.FormDate,
		   boq.HubFK,
		   h.[Name],
           boq.Indicator1,
           boq.Indicator2,
           boq.Indicator3,
           boq.Indicator4,
           boq.Indicator5,
           boq.Indicator6,
           boq.Indicator7,
           boq.Indicator8,
           boq.Indicator9,
           boq.Indicator10,
           boq.Indicator11,
           boq.Indicator12,
           boq.Indicator13,
           boq.Indicator14,
           boq.Indicator15,
           boq.Indicator16,
           boq.Indicator17,
           boq.Indicator18,
           boq.Indicator19,
           boq.Indicator20,
           boq.Indicator21,
           boq.Indicator22,
           boq.Indicator23,
           boq.Indicator24,
           boq.Indicator25,
           boq.Indicator26,
           boq.Indicator27,
           boq.Indicator28,
           boq.Indicator29,
           boq.Indicator30,
           boq.Indicator31,
           boq.Indicator32,
           boq.Indicator33,
           boq.Indicator34,
           boq.Indicator35,
           boq.Indicator36,
           boq.Indicator37,
           boq.Indicator38,
           boq.Indicator39,
           ROW_NUMBER() OVER (PARTITION BY boq.HubFK ORDER BY boq.FormDate DESC) AS RowNumber
    FROM dbo.BenchmarkOfQualityCWLT boq
        INNER JOIN dbo.Hub h
			ON h.HubPK = boq.HubFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = boq.HubFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = h.StateFK
	WHERE (hubList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL) AND  --At least one of the options must be utilized 
		boq.FormDate BETWEEN @StartDate AND @EndDate
    ORDER BY h.[Name] ASC,
             boq.FormDate DESC;

	--Final select
    SELECT tfir.*
    FROM @tblFormsInRange tfir
	WHERE tfir.RowNumber <= 5;

END;
GO

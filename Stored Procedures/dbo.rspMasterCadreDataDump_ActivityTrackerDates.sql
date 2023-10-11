SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/06/2023
-- Description:	This stored procedure returns the necessary information for the
-- activity tracker dates section of the Master Cadre Data Dump report
-- =============================================
CREATE PROC [dbo].[rspMasterCadreDataDump_ActivityTrackerDates]
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the relevant activity tracker dates
	SELECT tid.MasterCadreTrainingTrackerItemDatePK,
           tid.Creator,
           tid.CreateDate,
           tid.Editor,
           tid.EditDate,
           tid.StartDateTime,
           tid.EndDateTime,
           tid.MasterCadreTrainingTrackerItemFK,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.MasterCadreTrainingTrackerItemDate tid
		INNER JOIN dbo.MasterCadreTrainingTrackerItem mctti
			ON mctti.MasterCadreTrainingTrackerItemPK = tid.MasterCadreTrainingTrackerItemFK
        INNER JOIN dbo.[State] s
            ON s.StatePK = mctti.StateFK
        INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList
            ON stateList.ListItem = mctti.StateFK
	WHERE tid.StartDateTime BETWEEN @StartDate AND @EndDate
	ORDER BY tid.StartDateTime

END;
GO

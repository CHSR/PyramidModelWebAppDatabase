SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 09/15/2022
-- Description:	This stored procedure returns the necessary information for the
-- SLT BOQ Participants section of the State Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspSLTDataDump_BOQParticipants]
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT bp.BOQSLTParticipantPK,
           bp.Creator,
           bp.CreateDate,
           bp.Editor,
           bp.EditDate,
           sm.SLTMemberPK,
		   sm.IDNumber ParticipantIDNumber,
		   sm.FirstName ParticipantFirstName,
		   sm.LastName ParticipantLastName,
		   boqs.BenchmarkOfQualitySLTPK,
		   boqs.FormDate BOQFormDate,
		   s.StatePK,
		   s.[Name] StateName
	FROM dbo.BOQSLTParticipant bp
		INNER JOIN dbo.BenchmarkOfQualitySLT boqs
			ON boqs.BenchmarkOfQualitySLTPK = bp.BenchmarksOfQualitySLTFK
		INNER JOIN dbo.SLTMember sm
			ON sm.SLTMemberPK = bp.SLTMemberFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = boqs.StateFK
		INNER JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = boqs.StateFK
	WHERE boqs.FormDate BETWEEN @StartDate AND @EndDate;

END;
GO

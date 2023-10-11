SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 11/22/2021
-- Description:	This stored procedure returns all the items in the database
-- that have dates that are before the start date or after the leave date for
-- this SLT Member
-- =============================================
CREATE PROC [dbo].[spValidateSLTMemberStartLeaveDates] 
	@SLTMemberPK INT = NULL,
	@StateFK INT = NULL,
	@StartDate DATETIME = NULL,
	@LeaveDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		SLTMemberPK INT NULL,
		ObjectName VARCHAR(500) NULL,
		ObjectDate DATETIME NULL,
		StateFK INT NULL
	)

	--================= SLTMemberAgencyAssignment =====================
	INSERT INTO @tblFinalSelect
	(
	    SLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    StateFK
	)
	SELECT smaa.SLTMemberFK, 'Agency Assignment - ' + sa.[Name], smaa.StartDate, sa.StateFK 
	FROM dbo.SLTMemberAgencyAssignment smaa
	INNER JOIN dbo.SLTAgency sa ON sa.SLTAgencyPK = smaa.SLTAgencyFK
	WHERE smaa.SLTMemberFK = @SLTMemberPK AND sa.StateFK = @StateFK
	AND ((smaa.StartDate > ISNULL(@LeaveDate, smaa.StartDate) OR smaa.EndDate > ISNULL(@LeaveDate, smaa.EndDate))
	OR (smaa.StartDate < ISNULL(@StartDate, smaa.StartDate) OR smaa.EndDate < ISNULL(@StartDate, smaa.EndDate)))
	
	--================= SLTMemberWorkGroupAssignment =====================
	INSERT INTO @tblFinalSelect
	(
	    SLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    StateFK
	)
	SELECT smwga.SLTMemberFK, 'Work Group Assignment - ' + swg.WorkGroupName, smwga.StartDate, swg.StateFK 
	FROM dbo.SLTMemberWorkGroupAssignment smwga
	INNER JOIN dbo.SLTWorkGroup swg ON swg.SLTWorkGroupPK = smwga.SLTWorkGroupFK 
	WHERE smwga.SLTMemberFK = @SLTMemberPK AND swg.StateFK = @StateFK
	AND ((smwga.StartDate > ISNULL(@LeaveDate, smwga.StartDate) OR smwga.EndDate > ISNULL(@LeaveDate, smwga.EndDate))
	OR (smwga.StartDate < ISNULL(@StartDate, smwga.StartDate) OR smwga.EndDate < ISNULL(@StartDate, smwga.EndDate)))


	--================= SLT BOQ =====================
	INSERT INTO @tblFinalSelect
	(
	    SLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    StateFK
	)
	SELECT bp.SLTMemberFK, 'SLT BOQ', boqs.FormDate, boqs.StateFK 
	FROM dbo.BOQSLTParticipant bp
	INNER JOIN dbo.BenchmarkOfQualitySLT boqs ON boqs.BenchmarkOfQualitySLTPK = bp.BenchmarksOfQualitySLTFK
	WHERE bp.SLTMemberFK = @SLTMemberPK
	AND boqs.StateFK = @StateFK
	AND (boqs.FormDate > ISNULL(@LeaveDate, boqs.FormDate)
	OR boqs.FormDate < ISNULL(@StartDate, boqs.FormDate))


	--================= SLT Action Plan =====================
	INSERT INTO @tblFinalSelect
	(
	    SLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    StateFK
	)
	SELECT sap.WorkGroupLeadFK, 'Action Plan', sap.ActionPlanStartDate, sap.StateFK 
	FROM dbo.SLTActionPlan sap
	WHERE sap.WorkGroupLeadFK = @SLTMemberPK
	AND sap.StateFK = @StateFK
	AND (sap.ActionPlanStartDate > ISNULL(@LeaveDate, sap.ActionPlanStartDate)
	OR sap.ActionPlanEndDate < ISNULL(@StartDate, sap.ActionPlanEndDate))
	
	--Final select
	SELECT * 
	FROM @tblFinalSelect tfs 
	ORDER BY tfs.ObjectDate ASC

END
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/08/2021
-- Description:	This stored procedure returns all the items in the database
-- that have dates that are before the start date or after the leave date for
-- this CWLT Member
-- =============================================
CREATE PROC [dbo].[spValidateCWLTMemberStartLeaveDates] 
	@CWLTMemberPK INT = NULL,
	@HubFK INT = NULL,
	@StartDate DATETIME = NULL,
	@LeaveDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblFinalSelect TABLE (
		CWLTMemberPK INT NULL,
		ObjectName VARCHAR(500) NULL,
		ObjectDate DATETIME NULL,
		HubFK INT NULL
	)

	--================= CWLTMemberAgencyAssignment =====================
	INSERT INTO @tblFinalSelect
	(
	    CWLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    HubFK
	)
	SELECT cmaa.CWLTMemberFK, 'Agency Assignment - ' + sa.[Name], cmaa.StartDate, sa.HubFK 
	FROM dbo.CWLTMemberAgencyAssignment cmaa
	INNER JOIN dbo.CWLTAgency sa ON sa.CWLTAgencyPK = cmaa.CWLTAgencyFK
	WHERE cmaa.CWLTMemberFK = @CWLTMemberPK AND sa.HubFK = @HubFK
	AND ((cmaa.StartDate > ISNULL(@LeaveDate, cmaa.StartDate) OR cmaa.EndDate > ISNULL(@LeaveDate, cmaa.EndDate))
	OR (cmaa.StartDate < ISNULL(@StartDate, cmaa.StartDate) OR cmaa.EndDate < ISNULL(@StartDate, cmaa.EndDate)))


	--================= CWLT BOQ =====================
	INSERT INTO @tblFinalSelect
	(
	    CWLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    HubFK
	)
	SELECT bp.CWLTMemberFK, 'CW BOQ', boqc.FormDate, boqc.HubFK 
	FROM dbo.BOQCWLTParticipant bp
	INNER JOIN dbo.BenchmarkOfQualityCWLT boqc ON boqc.BenchmarkOfQualityCWLTPK = bp.BenchmarksOfQualityCWLTFK
	WHERE bp.CWLTMemberFK = @CWLTMemberPK
	AND boqc.HubFK = @HubFK
	AND (boqc.FormDate > ISNULL(@LeaveDate, boqc.FormDate)
	OR boqc.FormDate < ISNULL(@StartDate, boqc.FormDate))


	--================= CW Action Plan =====================
	INSERT INTO @tblFinalSelect
	(
	    CWLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    HubFK
	)
	SELECT cap.HubCoordinatorFK, 'Action Plan', cap.ActionPlanStartDate, cap.HubFK 
	FROM dbo.CWLTActionPlan cap
	WHERE cap.HubCoordinatorFK = @CWLTMemberPK
	AND cap.HubFK = @HubFK
	AND (cap.ActionPlanStartDate > ISNULL(@LeaveDate, cap.ActionPlanStartDate)
	OR cap.ActionPlanEndDate < ISNULL(@StartDate, cap.ActionPlanEndDate))


	--================= Hub LC debrief session attendee =====================
	INSERT INTO @tblFinalSelect
	(
	    CWLTMemberPK,
	    ObjectName,
	    ObjectDate,
	    HubFK
	)
	SELECT hlmdsa.CWLTMemberFK, 'Leadership Coach Meeting Debrief Session', hlmds.SessionStartDateTime, hlmd.HubFK 
	FROM dbo.HubLCMeetingDebriefSessionAttendee hlmdsa
	INNER JOIN dbo.HubLCMeetingDebriefSession hlmds ON hlmds.HubLCMeetingDebriefSessionPK = hlmdsa.HubLCMeetingDebriefSessionFK
	INNER JOIN dbo.HubLCMeetingDebrief hlmd ON hlmd.HubLCMeetingDebriefPK = hlmds.HubLCMeetingDebriefFK
	WHERE hlmdsa.CWLTMemberFK = @CWLTMemberPK
	AND hlmd.HubFK = @HubFK
	AND (hlmd.DebriefYear > ISNULL(DATEPART(YEAR, @LeaveDate), hlmd.DebriefYear)
	OR hlmd.DebriefYear < ISNULL(DATEPART(YEAR, @StartDate), hlmd.DebriefYear))
	
	--Final select
	SELECT * 
	FROM @tblFinalSelect tfs 
	ORDER BY tfs.ObjectDate ASC

END
GO

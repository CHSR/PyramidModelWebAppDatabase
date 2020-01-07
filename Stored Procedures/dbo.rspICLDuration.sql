SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 09/09/2019
-- Description:	ICL Duration Report
-- =============================================
CREATE PROC [dbo].[rspICLDuration]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@TeacherFKs VARCHAR(MAX) = NULL,
	@CoachFKs varchar(MAX) = null,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		  cl.CoachingLogPK
		, cl.LogDate
		, cl.DurationMinutes
	FROM dbo.CoachingLog cl
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList ON cl.ProgramFK = programList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@TeacherFKs, ',') teacherList on cl.TeacherFK = teacherList.ListItem
	LEFT JOIN dbo.SplitStringToInt(@CoachFKs, ',') coachList on cl.CoachFK = coachList.ListItem
	WHERE cl.LogDate BETWEEN @StartDate AND @EndDate
		AND (@TeacherFKs IS NULL OR @TeacherFKs = '' OR teacherList.ListItem IS NOT NULL) --Optional teacher criteria
		AND (@CoachFKs IS NULL OR @CoachFKs = '' OR coachList.ListItem IS NOT NULL); --Optional coach criteria

END
GO

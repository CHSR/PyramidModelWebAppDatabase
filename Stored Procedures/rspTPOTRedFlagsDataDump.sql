-- =============================================
-- Author:		Andy Vuu
-- Create date: 09/22/2022
-- Description:	This stored procedure returns the necessary information for the
-- Red Flags section of the TPOT Data Dump report
-- =============================================
ALTER PROC dbo.rspTPOTRedFlagsDataDump
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ProgramFKs VARCHAR(8000) = NULL,
    @HubFKs VARCHAR(8000) = NULL,
    @CohortFKs VARCHAR(8000) = NULL,
    @StateFKs VARCHAR(8000) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the necessary information
    SELECT rf.TPOTRedFlagsPK,
		   rf.Creator,
		   rf.CreateDate,
		   rf.TPOTFK,
		   rf.RedFlagCodeFK,
		   tp.classroomfk,
		   tp.ObservationStartDateTime,
		   p.ProgramPK,
		   p.ProgramName,
		   st.StatePK,
		   st.Name StateName,
		   crf.Description RedFlagDescription
	FROM dbo.TPOTRedFlags rf
		INNER JOIN dbo.CodeTPOTRedFlag crf
			ON crf.CodeTPOTRedFlagPK = rf.RedFlagCodeFK
		INNER JOIN dbo.TPOT tp
			ON tp.TPOTPK= rf.TPOTFK
		INNER JOIN dbo.Classroom cl
			ON cl.ClassroomPK=tp.ClassroomFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK=cl.ProgramFK
		INNER JOIN dbo.State st
			ON st.StatePK=p.StateFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = p.ProgramPK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
	WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL)  --At least one of the options must be utilized
		AND tp.ObservationStartDateTime BETWEEN @StartDate AND @EndDate

END;
GO

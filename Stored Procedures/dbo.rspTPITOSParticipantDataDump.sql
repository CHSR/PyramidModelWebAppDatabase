SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 09/22/2022
-- Description:	This stored procedure returns the necessary information for the
-- Participant section of the TPITOS Data Dump report
-- =============================================
CREATE PROC [dbo].[rspTPITOSParticipantDataDump]
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
    SELECT pt.TPITOSParticipantPK,
	       pt.Creator,
		   pt.CreateDate,
		   pt.Editor,
		   pt.EditDate,
		   pt.ParticipantTypeCodeFK,
		   pt.ProgramEmployeeFK,
		   pt.TPITOSFK,
		   cpt.[Description] ParticipantType,
		   e.FirstName,
		   e.LastName,
		   pe.ProgramSpecificID ParticipantID,
		   pe.ProgramEmployeePK ParticipantEmployeeKey,
		   p.ProgramName,
		   p.ProgramPK,
		   st.StatePK,
		   st.[Name] StateName,
		   tp.TPITOSPK,
		   tp.ObservationStartDateTime
	FROM dbo.TPITOSParticipant pt
		INNER JOIN dbo.TPITOS tp
			ON tp.TPITOSPK = pt.TPITOSFK
		INNER JOIN dbo.CodeParticipantType cpt
			ON cpt.CodeParticipantTypePK = pt.ParticipantTypeCodeFK
		INNER JOIN dbo.ProgramEmployee pe
			ON pe.ProgramEmployeePK = pt.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
		INNER JOIN dbo.Classroom cl
			ON cl.ClassroomPK = tp.ClassroomFK
		INNER JOIN dbo.Program p
			ON p.ProgramPK = cl.ProgramFK
		INNER JOIN dbo.[State] st
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

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/12/2020
-- Description:	This stored procedure returns the necessary information for the
-- participants section of the TPITOS report
-- =============================================
CREATE PROC [dbo].[rspTPITOS_Participants] 
	@TPITOSPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the TPITOS participant information
    SELECT tp.TPITOSFK,
		   pe.ProgramSpecificID ParticipantID,
           e.FirstName ParticipantFirstName,
           e.LastName ParticipantLastName,
           cpt.[Description] ParticipantType
    FROM dbo.TPITOSParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
    WHERE tp.TPITOSFK = @TPITOSPK
    ORDER BY e.FirstName ASC, e.LastName ASC;

END;
GO

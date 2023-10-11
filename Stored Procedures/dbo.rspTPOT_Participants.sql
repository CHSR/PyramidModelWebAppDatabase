SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 05/12/2020
-- Description:	This stored procedure returns the necessary information for the
-- participants section of the TPOT report
-- =============================================
CREATE PROC [dbo].[rspTPOT_Participants] 
	@TPOTPK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the TPOT participant information
    SELECT tp.TPOTFK,
		   pe.ProgramSpecificID ParticipantID,
           e.FirstName ParticipantFirstName,
           e.LastName ParticipantLastName,
           cpt.Description ParticipantType
    FROM dbo.TPOTParticipant tp
        INNER JOIN dbo.ProgramEmployee pe
            ON pe.ProgramEmployeePK = tp.ProgramEmployeeFK
		INNER JOIN dbo.Employee e
			ON e.EmployeePK = pe.EmployeeFK
        INNER JOIN dbo.CodeParticipantType cpt
            ON cpt.CodeParticipantTypePK = tp.ParticipantTypeCodeFK
    WHERE tp.TPOTFK = @TPOTPK
    ORDER BY e.FirstName ASC, e.LastName ASC;

END;
GO

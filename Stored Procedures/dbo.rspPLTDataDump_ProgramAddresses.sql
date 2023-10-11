SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 04/27/2023
-- Description:	This stored procedure returns the necessary information for the program addresses section of the
-- Program Leadership Team Data Dump report
-- =============================================
CREATE PROC [dbo].[rspPLTDataDump_ProgramAddresses]
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
    SELECT pa.ProgramAddressPK,
           pa.City,
           pa.CreateDate,
		   pa.Creator,
           pa.Editor,
           pa.EditDate,
           pa.IsMailingAddress,
           pa.LicenseNumber,
           pa.Notes,
           pa.State,
           pa.Street,
           pa.ZIPCode,
           pa.ProgramFK,
		   p.ProgramName,
		   s.[Name] StateName,
		   s.StatePK
	FROM dbo.ProgramAddress pa
		INNER JOIN dbo.Program p 
			ON p.ProgramPK = pa.ProgramFK
		INNER JOIN dbo.[State] s
			ON s.StatePK = p.StateFK
		LEFT JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList 
			ON programList.ListItem = pa.ProgramFK
		LEFT JOIN dbo.SplitStringToInt(@HubFKs, ',') hubList 
			ON hubList.ListItem = p.HubFK
		LEFT JOIN dbo.SplitStringToInt(@CohortFKs, ',') cohortList 
			ON cohortList.ListItem = p.CohortFK
		LEFT JOIN dbo.SplitStringToInt(@StateFKs, ',') stateList 
			ON stateList.ListItem = p.StateFK
		WHERE (programList.ListItem IS NOT NULL OR 
			hubList.ListItem IS NOT NULL OR 
			cohortList.ListItem IS NOT NULL OR
			stateList.ListItem IS NOT NULL);  --At least one of the options must be utilized
		

		

END;
GO

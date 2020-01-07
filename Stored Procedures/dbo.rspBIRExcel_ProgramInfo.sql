SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/21/2019
-- Description:	This stored procedure returns the necessary information for the
-- BIR Excel file's Program Information tab.
-- The Excel file was created by Myra Veguilla (veguilla@usf.edu) for the Pyramid Model Consortium
-- =============================================
CREATE PROC [dbo].[rspBIRExcel_ProgramInfo]
	@ProgramFKs VARCHAR(MAX) = NULL,
	@SchoolYear DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--This table holds each month, the number of months to add to January to get that month, and the 
	--a number representing where that month is on the BIR spreadheet (zero-based)
	DECLARE @tblMonths TABLE (
		NumMonthsToAdd INT NOT NULL,
		CurrentMonthName VARCHAR(100) NOT NULL,
		NumOnSpreadsheet INT NOT NULL,
		INDEX IX_tblMonths_NumMonthsToAdd (NumMonthsToAdd),
		INDEX IX_tblMonths_CurrentMonthName (CurrentMonthName),
		INDEX IX_tblMonths_NumOnSpreadsheet (NumOnSpreadsheet)
	)
	
	--This table will hold the PKs of the children that are in classrooms by month
	--and it has the month name and month location on the BIR spreadsheet as well
	DECLARE @tblChildrenInClassrooms TABLE (
		ChildPK INT NOT NULL,
		MonthActiveName VARCHAR(100) NOT NULL,
		MonthNumOnSpreadsheet INT NOT NULL,
		INDEX IX_tblChildrenInClassrooms_ChildPK (ChildPK),
		INDEX IX_tblChildrenInClassrooms_MonthNumOnSpreadsheet (MonthNumOnSpreadsheet)
	)

	--Get the months
	INSERT INTO @tblMonths
	(
		NumMonthsToAdd,
		CurrentMonthName,
		NumOnSpreadsheet
	)
	VALUES
	(7, 'August', 0), (8, 'September', 1), (9, 'October', 2), (10, 'November', 3), (11, 'December', 4), 
	(12, 'January', 5), (13, 'February', 6), (14, 'March', 7), (15, 'April', 8), (16, 'May', 9), 
	(17, 'June', 10), (18, 'July', 11)

	--Get all the children enrolled in classrooms by month
	INSERT INTO @tblChildrenInClassrooms
	(
	    ChildPK,
	    MonthActiveName,
		MonthNumOnSpreadsheet
	)
	SELECT DISTINCT cc.ChildFK, tm.CurrentMonthName, tm.NumOnSpreadsheet
	FROM dbo.ChildClassroom cc 
	INNER JOIN dbo.Classroom c ON c.ClassroomPK = cc.ClassroomFK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON c.ProgramFK = ssti.ListItem
	INNER JOIN @tblMonths tm ON 1 = 1 --Join is arbitrary, but necessary
	WHERE cc.AssignDate <= DATEADD(DAY, -1, DATEADD(MONTH, (tm.NumMonthsToAdd + 1), @SchoolYear)) 
		AND (cc.LeaveDate IS NULL OR cc.LeaveDate > DATEADD(MONTH, tm.NumMonthsToAdd, @SchoolYear))

	--Select all the necessary information for the BIR spreadsheet
	SELECT tc.ChildPK, tc.MonthActiveName, tc.MonthNumOnSpreadsheet,
		c.FirstName, c.LastName,
		cp.ProgramSpecificID, cp.ProgramFK, cp.HasIEP, cp.IsDLL,
		cg.Description Gender, 
		ce.Description Ethnicity,
		CASE WHEN cr.Description LIKE '%Hawaiian%' OR cr.Description LIKE '%Pacific Islander%' THEN 'Native Hawaiian or Other Pacific Islander'
			 WHEN cr.Description LIKE '%Alaskan%' OR cr.Description LIKE '%American Indian%' THEN 'American Indian or Alaskan Native' 
			 ELSE cr.Description END Race
	FROM @tblChildrenInClassrooms tc
	INNER JOIN dbo.Child c ON c.ChildPK = tc.ChildPK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
	INNER JOIN dbo.CodeGender cg ON cg.CodeGenderPK = c.GenderCodeFK
	INNER JOIN dbo.CodeEthnicity ce ON ce.CodeEthnicityPK = c.EthnicityCodeFK
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	ORDER BY tc.MonthNumOnSpreadsheet ASC, c.LastName ASC, c.FirstName ASC
END
GO

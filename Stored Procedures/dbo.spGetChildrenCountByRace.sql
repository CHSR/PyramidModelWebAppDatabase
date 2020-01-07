SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 06/04/2019
-- Description:	This stored procedure returns the number of kids
-- for each race in the database
-- =============================================
CREATE PROC [dbo].[spGetChildrenCountByRace] 
	@ProgramFKs VARCHAR(MAX) = NULL,
	@PointInTime DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the childrens' racial information for all children active as of this point in time
    SELECT cr.Description RaceName, COUNT(c.ChildPK) NumKids FROM dbo.Child c 
	INNER JOIN dbo.CodeRace cr ON cr.CodeRacePK = c.RaceCodeFK
	INNER JOIN dbo.ChildProgram cp ON cp.ChildFK = c.ChildPK
	INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') ssti ON cp.ProgramFK = ssti.ListItem
	WHERE cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime
	GROUP BY cr.Description
END
GO

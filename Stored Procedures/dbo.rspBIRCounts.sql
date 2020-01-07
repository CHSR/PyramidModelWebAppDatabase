SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Derek Cacciotti
-- Create date: 09/17/2019
-- Description:	This stored procedure returns the necessary information for the
-- BIR Counts report
-- =============================================
CREATE PROC [dbo].[rspBIRCounts]
    @StartDate DATETIME,
    @EndDate DATETIME,
    @ProgramFKs VARCHAR(MAX),
    @ClassroomsFKs VARCHAR(MAX)
AS
BEGIN

    DECLARE @tblAllBIRs TABLE
    (
        BIRPK INT NOT NULL,
        BIRDate DATETIME NOT NULL,
        ActivityCodeFK INT NOT NULL,
        AdminFollowUpFK INT NOT NULL,
        OthersInvolvedFK INT NOT NULL,
        PossableMotivationFK INT NOT NULL,
        ProbelmBehaviorFK INT NOT NULL,
        StrategyResponseCode INT NOT NULL
    );

    DECLARE @tblAllBIRData TABLE
    (
        ItemName VARCHAR(MAX) NOT NULL,
        Total INT NOT NULL,
        ItemType VARCHAR(MAX) NOT NULL,
        MinDate DATETIME NULL,
        MaxDate DATETIME NULL,
        TotalBirs INT NULL
    );

    INSERT INTO @tblAllBIRs
    (
        BIRPK,
        BIRDate,
        ActivityCodeFK,
        AdminFollowUpFK,
        OthersInvolvedFK,
        PossableMotivationFK,
        ProbelmBehaviorFK,
        StrategyResponseCode
    )
    SELECT b.BehaviorIncidentPK,
           b.IncidentDatetime,
           b.ActivityCodeFK,
           b.AdminFollowUpCodeFK,
           b.OthersInvolvedCodeFK,
           b.PossibleMotivationCodeFK,
           b.ProblemBehaviorCodeFK,
           b.StrategyResponseCodeFK
    FROM dbo.BehaviorIncident b
        INNER JOIN dbo.Classroom c
            ON c.ClassroomPK = b.ClassroomFK
        INNER JOIN dbo.SplitStringToInt(@ProgramFKs, ',') programList
            ON c.ProgramFK = programList.ListItem
        LEFT JOIN dbo.SplitStringToInt(@ClassroomsFKs, ',') classroomList
            ON c.ClassroomPK = classroomList.ListItem
    WHERE b.IncidentDatetime
    BETWEEN @StartDate AND @EndDate
	AND (@ClassroomsFKs IS NULL OR @ClassroomsFKs = '' OR classroomList.ListItem IS NOT NULL); --Optional classroom criteria


    --probelm behaviors
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT codeprobelmbehaviors.Description,
           COUNT(allbirs.BIRPK),
           'Problem Behaviors'
    FROM dbo.CodeProblemBehavior codeprobelmbehaviors
        LEFT JOIN @tblAllBIRs allbirs
            ON codeprobelmbehaviors.CodeProblemBehaviorPK = allbirs.ProbelmBehaviorFK
    GROUP BY codeprobelmbehaviors.Description;

    --activity
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT ca.Description,
           COUNT(allbirs.BIRPK),
           'Activity'
    FROM dbo.CodeActivity ca
        LEFT JOIN @tblAllBIRs allbirs
            ON ca.CodeActivityPK = allbirs.ActivityCodeFK
    GROUP BY ca.Description;
	
    --others invloved 
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT coi.Description,
           COUNT(allbirs.BIRPK),
           'Others Involved'
    FROM dbo.CodeOthersInvolved coi
        LEFT JOIN @tblAllBIRs allbirs
            ON coi.CodeOthersInvolvedPK = allbirs.OthersInvolvedFK
    GROUP BY coi.Description;
	
    --possible motivation 
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT cpm.Description,
           COUNT(aLLbirs.BIRPK),
           'Possible Motivation'
    FROM dbo.CodePossibleMotivation cpm
        LEFT JOIN @tblAllBIRs aLLbirs
            ON cpm.CodePossibleMotivationPK = aLLbirs.PossableMotivationFK
    GROUP BY cpm.Description;

    --strategy response
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT csr.Description,
           COUNT(allbirs.BIRPK),
           'Strategy Response'
    FROM dbo.CodeStrategyResponse csr
        LEFT JOIN @tblAllBIRs allbirs
            ON csr.CodeStrategyResponsePK = allbirs.StrategyResponseCode
    GROUP BY csr.Description;

    --admin follow up
    INSERT @tblAllBIRData
    (
        ItemName,
        Total,
        ItemType
    )
    SELECT codeadmin.Description,
           COUNT(allbirs.BIRPK),
           'Admin Follow Up'
    FROM dbo.CodeAdminFollowUp codeadmin
        LEFT JOIN @tblAllBIRs allbirs
            ON codeadmin.CodeAdminFollowUpPK = allbirs.AdminFollowUpFK
    GROUP BY codeadmin.Description;

    UPDATE @tblAllBIRData
    SET MinDate =
        (
            SELECT MIN(tb.BIRDate) FROM @tblAllBIRs tb
        );

    UPDATE @tblAllBIRData
    SET MaxDate =
        (
            SELECT MAX(tb.BIRDate) FROM @tblAllBIRs tb
        );

    UPDATE @tblAllBIRData
    SET TotalBirs =
        (
            SELECT COUNT(DISTINCT tb.BIRPK) FROM @tblAllBIRs tb
        );

    SELECT *
    FROM @tblAllBIRData
    ORDER BY Total ASC;

END;
GO

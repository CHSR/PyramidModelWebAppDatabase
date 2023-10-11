SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[BOQSLTView]
AS
SELECT boqs.BenchmarkOfQualitySLTPK,
       boqs.FormDate,
	   boqs.StateFK,
       s.Name StateName,
       STRING_AGG(CONCAT('(', sm.IDNumber, ') ', sm.FirstName, ' ', sm.LastName), ', ') TeamMembers
FROM dbo.BenchmarkOfQualitySLT boqs
    INNER JOIN dbo.State s
        ON s.StatePK = boqs.StateFK
    LEFT JOIN dbo.BOQSLTParticipant bp
        ON bp.BenchmarksOfQualitySLTFK = boqs.BenchmarkOfQualitySLTPK
    LEFT JOIN dbo.SLTMember sm
        ON sm.SLTMemberPK = bp.SLTMemberFK
GROUP BY boqs.BenchmarkOfQualitySLTPK,
         boqs.FormDate,
		 boqs.StateFK,
         s.Name;
GO

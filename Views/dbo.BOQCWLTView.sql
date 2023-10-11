SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[BOQCWLTView]
AS
SELECT boq.BenchmarkOfQualityCWLTPK,
       boq.FormDate,
	   boq.HubFK,
       h.[Name] HubName,
	   s.[Name] StateName,
       STRING_AGG(CONCAT('(', cm.IDNumber, ') ', cm.FirstName, ' ', cm.LastName), ', ') TeamMembers
FROM dbo.BenchmarkOfQualityCWLT boq
    INNER JOIN dbo.Hub h
        ON h.HubPK = boq.HubFK
	INNER JOIN dbo.[State] s
		ON s.StatePK = h.StateFK
    LEFT JOIN dbo.BOQCWLTParticipant bp
        ON bp.BenchmarksOfQualityCWLTFK = boq.BenchmarkOfQualityCWLTPK
    LEFT JOIN dbo.CWLTMember cm
        ON cm.CWLTMemberPK = bp.CWLTMemberFK
GROUP BY boq.BenchmarkOfQualityCWLTPK,
         boq.FormDate,
		 boq.HubFK,
         h.[Name],
		 s.[Name];
GO

CREATE TABLE [dbo].[LCLTeamMemberEngagement]
(
[LCLTeamMemberEngagementPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL,
[PLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Andy Vuu
-- Create date: 02/17/2023
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_LCLTeamMemberEngagement_Changed] 
   ON  [dbo].[LCLTeamMemberEngagement] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.LCLTeamMemberEngagementPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.LCLTeamMemberEngagementChanged
    (
        ChangeDatetime,
        ChangeType,
        LCLTeamMemberEngagementPK,
        Creator,
        CreateDate,
		LeadershipCoachLogFK,
		PLTMemberFK

		
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.LCLTeamMemberEngagementPK,
        d.Creator,
        d.CreateDate,
		d.LeadershipCoachLogFK,
		d.PLTMemberFK


	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        LCLTeamMemberEngagementChangedPK INT NOT NULL,
        LCLTeamMemberEngagementPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected job functions
    INSERT INTO @ExistingChangeRows
    (
        LCLTeamMemberEngagementChangedPK,
		LCLTeamMemberEngagementPK,
        RowNumber
    )
    SELECT cc.LCLTeamMemberEngagementChangedPK,
		   cc.LCLTeamMemberEngagementPK,
           ROW_NUMBER() OVER (PARTITION BY cc.LCLTeamMemberEngagementPK
                              ORDER BY cc.LCLTeamMemberEngagementChangedPK DESC
                             ) AS RowNum
    FROM dbo.LCLTeamMemberEngagementChanged cc
    WHERE EXISTS
    (
        SELECT d.LCLTeamMemberEngagementPK FROM Deleted d WHERE d.LCLTeamMemberEngagementPK = cc.LCLTeamMemberEngagementPK
    );

	--Remove all but the most recent 5 change rows for each affected job function
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.LCLTeamMemberEngagementChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.LCLTeamMemberEngagementChangedPK = ecr.LCLTeamMemberEngagementChangedPK
    WHERE cc.LCLTeamMemberEngagementChangedPK = ecr.LCLTeamMemberEngagementChangedPK;
	
END
GO
ALTER TABLE [dbo].[LCLTeamMemberEngagement] ADD CONSTRAINT [PK_LCLTeamMemberEngagement] PRIMARY KEY CLUSTERED ([LCLTeamMemberEngagementPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLTeamMemberEngagement] ADD CONSTRAINT [FK_LCLTeamMemberEngagement_LeadershipCoachLog] FOREIGN KEY ([LeadershipCoachLogFK]) REFERENCES [dbo].[LeadershipCoachLog] ([LeadershipCoachLogPK])
GO
ALTER TABLE [dbo].[LCLTeamMemberEngagement] ADD CONSTRAINT [FK_LCLTeamMemberEngagement_PLTMember] FOREIGN KEY ([PLTMemberFK]) REFERENCES [dbo].[PLTMember] ([PLTMemberPK])
GO

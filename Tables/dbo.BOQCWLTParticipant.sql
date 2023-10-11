CREATE TABLE [dbo].[BOQCWLTParticipant]
(
[BOQCWLTParticipantPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[BenchmarksOfQualityCWLTFK] [int] NOT NULL,
[CWLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 12/08/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_BOQCWLTParticipant_Changed] 
   ON  [dbo].[BOQCWLTParticipant] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.BOQCWLTParticipantPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BOQCWLTParticipantChanged
    (
        ChangeDatetime,
        ChangeType,
        BOQCWLTParticipantPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        BenchmarksOfQualityCWLTFK,
        CWLTMemberFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.BOQCWLTParticipantPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.BenchmarksOfQualityCWLTFK,
        d.CWLTMemberFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        BOQCWLTParticipantChangedPK INT NOT NULL,
        BOQCWLTParticipantPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        BOQCWLTParticipantChangedPK,
		BOQCWLTParticipantPK,
        RowNumber
    )
    SELECT smc.BOQCWLTParticipantChangedPK,
		   smc.BOQCWLTParticipantPK,
           ROW_NUMBER() OVER (PARTITION BY smc.BOQCWLTParticipantPK
                              ORDER BY smc.BOQCWLTParticipantChangedPK DESC
                             ) AS RowNum
    FROM dbo.BOQCWLTParticipantChanged smc
    WHERE EXISTS
    (
        SELECT d.BOQCWLTParticipantPK FROM Deleted d WHERE d.BOQCWLTParticipantPK = smc.BOQCWLTParticipantPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.BOQCWLTParticipantChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.BOQCWLTParticipantChangedPK = ecr.BOQCWLTParticipantChangedPK
    WHERE smc.BOQCWLTParticipantChangedPK = ecr.BOQCWLTParticipantChangedPK;
	
END
GO
ALTER TABLE [dbo].[BOQCWLTParticipant] ADD CONSTRAINT [PK_BOQCWLTParticipant] PRIMARY KEY CLUSTERED ([BOQCWLTParticipantPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOQCWLTParticipant] ADD CONSTRAINT [FK_BOQCWLTParticipant_BenchmarkOfQualityCWLT] FOREIGN KEY ([BenchmarksOfQualityCWLTFK]) REFERENCES [dbo].[BenchmarkOfQualityCWLT] ([BenchmarkOfQualityCWLTPK])
GO
ALTER TABLE [dbo].[BOQCWLTParticipant] ADD CONSTRAINT [FK_BOQCWLTParticipant_CWLTMember] FOREIGN KEY ([CWLTMemberFK]) REFERENCES [dbo].[CWLTMember] ([CWLTMemberPK])
GO

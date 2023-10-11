CREATE TABLE [dbo].[BOQSLTParticipant]
(
[BOQSLTParticipantPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[BenchmarksOfQualitySLTFK] [int] NOT NULL,
[SLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/05/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_BOQSLTParticipant_Changed] 
   ON  [dbo].[BOQSLTParticipant] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.BOQSLTParticipantPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.BOQSLTParticipantChanged
    (
        ChangeDatetime,
        ChangeType,
        BOQSLTParticipantPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        BenchmarksOfQualitySLTFK,
        SLTMemberFK
    )
    SELECT GETDATE(), 
		@ChangeType,
		d.BOQSLTParticipantPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.BenchmarksOfQualitySLTFK,
        d.SLTMemberFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        BOQSLTParticipantChangedPK INT NOT NULL,
        BOQSLTParticipantPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        BOQSLTParticipantChangedPK,
		BOQSLTParticipantPK,
        RowNumber
    )
    SELECT smc.BOQSLTParticipantChangedPK,
		   smc.BOQSLTParticipantPK,
           ROW_NUMBER() OVER (PARTITION BY smc.BOQSLTParticipantPK
                              ORDER BY smc.BOQSLTParticipantChangedPK DESC
                             ) AS RowNum
    FROM dbo.BOQSLTParticipantChanged smc
    WHERE EXISTS
    (
        SELECT d.BOQSLTParticipantPK FROM Deleted d WHERE d.BOQSLTParticipantPK = smc.BOQSLTParticipantPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.BOQSLTParticipantChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.BOQSLTParticipantChangedPK = ecr.BOQSLTParticipantChangedPK
    WHERE smc.BOQSLTParticipantChangedPK = ecr.BOQSLTParticipantChangedPK;
	
END
GO
ALTER TABLE [dbo].[BOQSLTParticipant] ADD CONSTRAINT [PK_BOQSLTParticipant] PRIMARY KEY CLUSTERED ([BOQSLTParticipantPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_BOQSLTParticipantUnique] ON [dbo].[BOQSLTParticipant] ([BenchmarksOfQualitySLTFK], [SLTMemberFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BOQSLTParticipant] ADD CONSTRAINT [FK_BOQSLTParticipant_BenchmarkOfQualitySLT] FOREIGN KEY ([BenchmarksOfQualitySLTFK]) REFERENCES [dbo].[BenchmarkOfQualitySLT] ([BenchmarkOfQualitySLTPK])
GO
ALTER TABLE [dbo].[BOQSLTParticipant] ADD CONSTRAINT [FK_BOQSLTParticipant_SLTMember] FOREIGN KEY ([SLTMemberFK]) REFERENCES [dbo].[SLTMember] ([SLTMemberPK])
GO

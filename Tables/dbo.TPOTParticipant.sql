CREATE TABLE [dbo].[TPOTParticipant]
(
[TPOTParticipantPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ParticipantTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL,
[TPOTFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 08/07/2019
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_TPOTParticipant_Changed] 
   ON  [dbo].[TPOTParticipant] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPOTParticipantPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPOTParticipantChanged
    (
        ChangeDatetime,
        ChangeType,
        TPOTParticipantPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ParticipantTypeCodeFK,
        ProgramEmployeeFK,
        TPOTFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPOTParticipantPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.ParticipantTypeCodeFK,
        d.ProgramEmployeeFK,
        d.TPOTFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPOTParticipantChangedPK INT NOT NULL,
        TPOTParticipantPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected participants
    INSERT INTO @ExistingChangeRows
    (
        TPOTParticipantChangedPK,
		TPOTParticipantPK,
        RowNumber
    )
    SELECT tpc.TPOTParticipantChangedPK,
		   tpc.TPOTParticipantPK,
           ROW_NUMBER() OVER (PARTITION BY tpc.TPOTParticipantPK
                              ORDER BY tpc.TPOTParticipantChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPOTParticipantChanged tpc
    WHERE EXISTS
    (
        SELECT d.TPOTParticipantPK FROM Deleted d WHERE d.TPOTParticipantPK = tpc.TPOTParticipantPK
    );

	--Remove all but the most recent 5 change rows for each affected participant
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE tpc
    FROM dbo.TPOTParticipantChanged tpc
        INNER JOIN @ExistingChangeRows ecr
            ON tpc.TPOTParticipantChangedPK = ecr.TPOTParticipantChangedPK
    WHERE tpc.TPOTParticipantChangedPK = ecr.TPOTParticipantChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPOTParticipant] ADD CONSTRAINT [PK_TPOTParticipant] PRIMARY KEY CLUSTERED  ([TPOTParticipantPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTParticipant] ADD CONSTRAINT [FK_TPOTParticipant_CodeParticipantType] FOREIGN KEY ([ParticipantTypeCodeFK]) REFERENCES [dbo].[CodeParticipantType] ([CodeParticipantTypePK])
GO
ALTER TABLE [dbo].[TPOTParticipant] ADD CONSTRAINT [FK_TPOTParticipant_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[TPOTParticipant] ADD CONSTRAINT [FK_TPOTParticipant_TPOT] FOREIGN KEY ([TPOTFK]) REFERENCES [dbo].[TPOT] ([TPOTPK])
GO

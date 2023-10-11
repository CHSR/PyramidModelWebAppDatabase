CREATE TABLE [dbo].[TPITOSParticipant]
(
[TPITOSParticipantPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ParticipantTypeCodeFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL,
[TPITOSFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_TPITOSParticipant_Changed] 
   ON  [dbo].[TPITOSParticipant] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.TPITOSParticipantPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPITOSParticipantChanged
    (
        ChangeDatetime,
        ChangeType,
        TPITOSParticipantPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        ParticipantTypeCodeFK,
        ProgramEmployeeFK,
        TPITOSFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.TPITOSParticipantPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.ParticipantTypeCodeFK,
        d.ProgramEmployeeFK,
        d.TPITOSFK
	FROM Deleted d

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        TPITOSParticipantChangedPK INT NOT NULL,
        TPITOSParticipantPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected participant
    INSERT INTO @ExistingChangeRows
    (
        TPITOSParticipantChangedPK,
		TPITOSParticipantPK,
        RowNumber
    )
    SELECT tpc.TPITOSParticipantChangedPK,
		   tpc.TPITOSParticipantPK,
           ROW_NUMBER() OVER (PARTITION BY tpc.TPITOSParticipantPK
                              ORDER BY tpc.TPITOSParticipantChangedPK DESC
                             ) AS RowNum
    FROM dbo.TPITOSParticipantChanged tpc
    WHERE EXISTS
    (
        SELECT d.TPITOSParticipantPK FROM Deleted d WHERE d.TPITOSParticipantPK = tpc.TPITOSParticipantPK
    );

	--Remove all but the most recent 5 change rows for each affected participant
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE tpc
    FROM dbo.TPITOSParticipantChanged tpc
        INNER JOIN @ExistingChangeRows ecr
            ON tpc.TPITOSParticipantChangedPK = ecr.TPITOSParticipantChangedPK
    WHERE tpc.TPITOSParticipantChangedPK = ecr.TPITOSParticipantChangedPK;
	
END
GO
ALTER TABLE [dbo].[TPITOSParticipant] ADD CONSTRAINT [PK_TPITOSParticipant] PRIMARY KEY CLUSTERED  ([TPITOSParticipantPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPITOSParticipant] ADD CONSTRAINT [FK_TPITOSParticipant_CodeParticipantType] FOREIGN KEY ([ParticipantTypeCodeFK]) REFERENCES [dbo].[CodeParticipantType] ([CodeParticipantTypePK])
GO
ALTER TABLE [dbo].[TPITOSParticipant] ADD CONSTRAINT [FK_TPITOSParticipant_ProgramEmployee] FOREIGN KEY ([ProgramEmployeeFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO
ALTER TABLE [dbo].[TPITOSParticipant] ADD CONSTRAINT [FK_TPITOSParticipant_TPITOS] FOREIGN KEY ([TPITOSFK]) REFERENCES [dbo].[TPITOS] ([TPITOSPK])
GO

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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPITOSParticipantChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		TPITOSParticipantPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    TPITOSParticipantPK,
	    MinChangeDatetime
	)
	SELECT ac.TPITOSParticipantPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.TPITOSParticipantChanged ac
	GROUP BY ac.TPITOSParticipantPK
	HAVING COUNT(ac.TPITOSParticipantPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.TPITOSParticipantChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.TPITOSParticipantPK = ecr.TPITOSParticipantPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.TPITOSParticipantPK = ecr.TPITOSParticipantPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
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

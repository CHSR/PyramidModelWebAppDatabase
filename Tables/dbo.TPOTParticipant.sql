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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPOTParticipantChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		TPOTParticipantPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    TPOTParticipantPK,
	    MinChangeDatetime
	)
	SELECT ac.TPOTParticipantPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.TPOTParticipantChanged ac
	GROUP BY ac.TPOTParticipantPK
	HAVING COUNT(ac.TPOTParticipantPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.TPOTParticipantChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.TPOTParticipantPK = ecr.TPOTParticipantPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.TPOTParticipantPK = ecr.TPOTParticipantPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
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

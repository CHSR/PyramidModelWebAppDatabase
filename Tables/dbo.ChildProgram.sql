CREATE TABLE [dbo].[ChildProgram]
(
[ChildProgramPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[DischargeDate] [datetime] NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentDate] [datetime] NOT NULL,
[HasIEP] [bit] NOT NULL,
[IsDLL] [bit] NOT NULL,
[ProgramSpecificID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildFK] [int] NOT NULL,
[DischargeCodeFK] [int] NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ChildProgram_Changed] 
   ON  [dbo].[ChildProgram] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildProgramChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ChildProgramPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ChildProgramPK,
	    MinChangeDatetime
	)
	SELECT ac.ChildProgramPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ChildProgramChanged ac
	GROUP BY ac.ChildProgramPK
	HAVING COUNT(ac.ChildProgramPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ChildProgramChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ChildProgramPK = ecr.ChildProgramPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ChildProgramPK = ecr.ChildProgramPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [PK_ChildProgram] PRIMARY KEY CLUSTERED  ([ChildProgramPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ChildProgram] ON [dbo].[ChildProgram] ([ProgramSpecificID], [ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_CodeDischargeReason] FOREIGN KEY ([DischargeCodeFK]) REFERENCES [dbo].[CodeDischargeReason] ([CodeDischargeReasonPK])
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

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
[HasParentPermission] [bit] NOT NULL CONSTRAINT [DF_ChildProgram_HasParentPermission] DEFAULT ((1)),
[IsDLL] [bit] NOT NULL,
[ParentPermissionDocumentFileName] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentPermissionDocumentFilePath] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ChildProgramPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ChildProgramChanged
    (
        ChangeDatetime,
        ChangeType,
        ChildProgramPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        DischargeDate,
        DischargeReasonSpecify,
        EnrollmentDate,
        HasIEP,
		HasParentPermission,
        IsDLL,
		ParentPermissionDocumentFileName,
		ParentPermissionDocumentFilePath,
        ProgramSpecificID,
        ChildFK,
        DischargeCodeFK,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ChildProgramPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.DischargeDate,
        d.DischargeReasonSpecify,
        d.EnrollmentDate,
        d.HasIEP,
		d.HasParentPermission,
        d.IsDLL,
		d.ParentPermissionDocumentFileName,
		d.ParentPermissionDocumentFilePath,
        d.ProgramSpecificID,
        d.ChildFK,
        d.DischargeCodeFK,
        d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ChildProgramChangedPK INT NOT NULL,
        ChildProgramPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ChildProgramren
    INSERT INTO @ExistingChangeRows
    (
        ChildProgramChangedPK,
		ChildProgramPK,
        RowNumber
    )
    SELECT cc.ChildProgramChangedPK,
		   cc.ChildProgramPK,
           ROW_NUMBER() OVER (PARTITION BY cc.ChildProgramPK
                              ORDER BY cc.ChildProgramChangedPK DESC
                             ) AS RowNum
    FROM dbo.ChildProgramChanged cc
    WHERE EXISTS
    (
        SELECT d.ChildProgramPK FROM Deleted d WHERE d.ChildProgramPK = cc.ChildProgramPK
    );

	--Remove all but the most recent 5 change rows for each affected ChildProgram
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE cc
    FROM dbo.ChildProgramChanged cc
        INNER JOIN @ExistingChangeRows ecr
            ON cc.ChildProgramChangedPK = ecr.ChildProgramChangedPK
    WHERE cc.ChildProgramChangedPK = ecr.ChildProgramChangedPK;
	
END
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [PK_ChildProgram] PRIMARY KEY CLUSTERED ([ChildProgramPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_ChildProgram_7BBE21EC456D20637280F45550BD90A4] ON [dbo].[ChildProgram] ([DischargeDate]) INCLUDE ([ChildFK], [ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_ChildProgram_E42AA7D1AEF2F80F18C7D1B0F3F267F1] ON [dbo].[ChildProgram] ([ProgramFK], [DischargeDate]) INCLUDE ([ChildFK], [DischargeCodeFK], [DischargeReasonSpecify], [EnrollmentDate], [HasIEP], [IsDLL], [ProgramSpecificID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ChildProgramUnique] ON [dbo].[ChildProgram] ([ProgramSpecificID], [ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_CodeDischargeReason] FOREIGN KEY ([DischargeCodeFK]) REFERENCES [dbo].[CodeDischargeReason] ([CodeDischargeReasonPK])
GO
ALTER TABLE [dbo].[ChildProgram] ADD CONSTRAINT [FK_ChildProgram_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

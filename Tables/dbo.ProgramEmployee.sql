CREATE TABLE [dbo].[ProgramEmployee]
(
[ProgramEmployeePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[HireDate] [datetime] NOT NULL,
[IsEmployeeOfProgram] [bit] NOT NULL CONSTRAINT [DF_ProgramEmployee_IsEmployeeOfProgram] DEFAULT ((1)),
[ProgramSpecificID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProgramEmployee_ProgramSpecificID] DEFAULT ('SID-Example'),
[TermDate] [datetime] NULL,
[TermReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeeFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TermReasonCodeFK] [int] NULL
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
CREATE TRIGGER [dbo].[TGR_ProgramEmployee_Changed] 
   ON  [dbo].[ProgramEmployee] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramEmployeePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramEmployeeChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramEmployeePK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        HireDate,
		IsEmployeeOfProgram,
		ProgramSpecificID,
        TermDate,
        TermReasonSpecify,
		EmployeeFK,
        ProgramFK,
        TermReasonCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ProgramEmployeePK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.HireDate,
		d.IsEmployeeOfProgram,
		d.ProgramSpecificID,
        d.TermDate,
        d.TermReasonSpecify,
		d.EmployeeFK,
        d.ProgramFK,
        d.TermReasonCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramEmployeeChangedPK INT NOT NULL,
        ProgramEmployeePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        ProgramEmployeeChangedPK,
		ProgramEmployeePK,
        RowNumber
    )
    SELECT pec.ProgramEmployeeChangedPK,
		   pec.ProgramEmployeePK,
           ROW_NUMBER() OVER (PARTITION BY pec.ProgramEmployeePK
                              ORDER BY pec.ProgramEmployeeChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramEmployeeChanged pec
    WHERE EXISTS
    (
        SELECT d.ProgramEmployeePK FROM Deleted d WHERE d.ProgramEmployeePK = pec.ProgramEmployeePK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE pec
    FROM dbo.ProgramEmployeeChanged pec
        INNER JOIN @ExistingChangeRows ecr
            ON pec.ProgramEmployeeChangedPK = ecr.ProgramEmployeeChangedPK
    WHERE pec.ProgramEmployeeChangedPK = ecr.ProgramEmployeeChangedPK;
	
END
GO
ALTER TABLE [dbo].[ProgramEmployee] ADD CONSTRAINT [PK_ProgramEmployee] PRIMARY KEY CLUSTERED ([ProgramEmployeePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_ProgramEmployee_5034598479D14A1795AB94FF5F7F7F8F] ON [dbo].[ProgramEmployee] ([ProgramFK], [TermDate]) INCLUDE ([ProgramSpecificID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramEmployee] ADD CONSTRAINT [FK_ProgramEmployee_Employee] FOREIGN KEY ([EmployeeFK]) REFERENCES [dbo].[Employee] ([EmployeePK])
GO
ALTER TABLE [dbo].[ProgramEmployee] ADD CONSTRAINT [FK_ProgramEmployee_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[ProgramEmployee] ADD CONSTRAINT [FK_ProgramEmployee_TermReasonCode] FOREIGN KEY ([TermReasonCodeFK]) REFERENCES [dbo].[CodeTermReason] ([CodeTermReasonPK])
GO

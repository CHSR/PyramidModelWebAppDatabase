CREATE TABLE [dbo].[CWLTMemberAgencyAssignment]
(
[CWLTMemberAgencyAssignmentPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[CWLTAgencyFK] [int] NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_CWLTMemberAgencyAssignment_Changed] 
   ON  [dbo].[CWLTMemberAgencyAssignment] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.CWLTMemberAgencyAssignmentPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.CWLTMemberAgencyAssignmentChanged
    (
        ChangeDatetime,
        ChangeType,
        CWLTMemberAgencyAssignmentPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EndDate,
        StartDate,
        CWLTAgencyFK,
        CWLTMemberFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.CWLTMemberAgencyAssignmentPK,
		d.Creator,
		d.CreateDate,
		d.Editor,
		d.EditDate,
		d.EndDate,
		d.StartDate,
		d.CWLTAgencyFK,
        d.CWLTMemberFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        CWLTMemberAgencyAssignmentChangedPK INT NOT NULL,
        CWLTMemberAgencyAssignmentPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        CWLTMemberAgencyAssignmentChangedPK,
		CWLTMemberAgencyAssignmentPK,
        RowNumber
    )
    SELECT smaac.CWLTMemberAgencyAssignmentChangedPK,
		   smaac.CWLTMemberAgencyAssignmentPK,
           ROW_NUMBER() OVER (PARTITION BY smaac.CWLTMemberAgencyAssignmentPK
                              ORDER BY smaac.CWLTMemberAgencyAssignmentChangedPK DESC
                             ) AS RowNum
    FROM dbo.CWLTMemberAgencyAssignmentChanged smaac
    WHERE EXISTS
    (
        SELECT d.CWLTMemberAgencyAssignmentPK FROM Deleted d WHERE d.CWLTMemberAgencyAssignmentPK = smaac.CWLTMemberAgencyAssignmentPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smaac
    FROM dbo.CWLTMemberAgencyAssignmentChanged smaac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.CWLTMemberAgencyAssignmentChangedPK = smaac.CWLTMemberAgencyAssignmentChangedPK
    WHERE ecr.CWLTMemberAgencyAssignmentChangedPK = smaac.CWLTMemberAgencyAssignmentChangedPK;
	
END
GO
ALTER TABLE [dbo].[CWLTMemberAgencyAssignment] ADD CONSTRAINT [PK_CWLTMemberAgencyAssignment] PRIMARY KEY CLUSTERED ([CWLTMemberAgencyAssignmentPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMemberAgencyAssignment] ADD CONSTRAINT [FK_CWLTMemberAgencyAssignment_CWLTAgency] FOREIGN KEY ([CWLTAgencyFK]) REFERENCES [dbo].[CWLTAgency] ([CWLTAgencyPK])
GO
ALTER TABLE [dbo].[CWLTMemberAgencyAssignment] ADD CONSTRAINT [FK_CWLTMemberAgencyAssignment_CWLTMember] FOREIGN KEY ([CWLTMemberFK]) REFERENCES [dbo].[CWLTMember] ([CWLTMemberPK])
GO

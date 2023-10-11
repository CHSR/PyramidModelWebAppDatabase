CREATE TABLE [dbo].[SLTMemberAgencyAssignment]
(
[SLTMemberAgencyAssignmentPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[SLTAgencyFK] [int] NOT NULL,
[SLTMemberFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/22/2021
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last 5 actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_SLTMemberAgencyAssignment_Changed] 
   ON  [dbo].[SLTMemberAgencyAssignment] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.SLTMemberAgencyAssignmentPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.SLTMemberAgencyAssignmentChanged
    (
        ChangeDatetime,
        ChangeType,
        SLTMemberAgencyAssignmentPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EndDate,
        StartDate,
        SLTAgencyFK,
        SLTMemberFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.SLTMemberAgencyAssignmentPK,
		d.Creator,
		d.CreateDate,
		d.Editor,
		d.EditDate,
		d.EndDate,
		d.StartDate,
		d.SLTAgencyFK,
        d.SLTMemberFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        SLTMemberAgencyAssignmentChangedPK INT NOT NULL,
        SLTMemberAgencyAssignmentPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        SLTMemberAgencyAssignmentChangedPK,
		SLTMemberAgencyAssignmentPK,
        RowNumber
    )
    SELECT smaac.SLTMemberAgencyAssignmentChangedPK,
		   smaac.SLTMemberAgencyAssignmentPK,
           ROW_NUMBER() OVER (PARTITION BY smaac.SLTMemberAgencyAssignmentPK
                              ORDER BY smaac.SLTMemberAgencyAssignmentChangedPK DESC
                             ) AS RowNum
    FROM dbo.SLTMemberAgencyAssignmentChanged smaac
    WHERE EXISTS
    (
        SELECT d.SLTMemberAgencyAssignmentPK FROM Deleted d WHERE d.SLTMemberAgencyAssignmentPK = smaac.SLTMemberAgencyAssignmentPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smaac
    FROM dbo.SLTMemberAgencyAssignmentChanged smaac
        INNER JOIN @ExistingChangeRows ecr
            ON ecr.SLTMemberAgencyAssignmentChangedPK = smaac.SLTMemberAgencyAssignmentChangedPK
    WHERE ecr.SLTMemberAgencyAssignmentChangedPK = smaac.SLTMemberAgencyAssignmentChangedPK;
	
END
GO
ALTER TABLE [dbo].[SLTMemberAgencyAssignment] ADD CONSTRAINT [PK_SLTMemberAgencyAssignment] PRIMARY KEY CLUSTERED ([SLTMemberAgencyAssignmentPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTMemberAgencyAssignment] ADD CONSTRAINT [FK_SLTMemberAgencyAssignment_SLTAgency] FOREIGN KEY ([SLTAgencyFK]) REFERENCES [dbo].[SLTAgency] ([SLTAgencyPK])
GO
ALTER TABLE [dbo].[SLTMemberAgencyAssignment] ADD CONSTRAINT [FK_SLTMemberAgencyAssignment_SLTMember] FOREIGN KEY ([SLTMemberFK]) REFERENCES [dbo].[SLTMember] ([SLTMemberPK])
GO

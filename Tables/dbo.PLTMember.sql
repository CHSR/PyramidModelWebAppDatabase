CREATE TABLE [dbo].[PLTMember]
(
[PLTMemberPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IDNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LeaveDate] [datetime] NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_PLTMember_Changed] 
   ON  [dbo].[PLTMember] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.PLTMemberPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.PLTMemberChanged
    (
        ChangeDatetime,
        ChangeType,
        PLTMemberPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        EmailAddress,
        FirstName,
        StartDate,
        IDNumber,
        LastName,
        LeaveDate,
		PhoneNumber,
        ProgramFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.PLTMemberPK,
        d.Creator,
        d.CreateDate,
        d.Editor,
        d.EditDate,
        d.EmailAddress,
        d.FirstName,
        d.StartDate,
        d.IDNumber,
        d.LastName,
        d.LeaveDate,
		d.PhoneNumber,
		d.ProgramFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        PLTMemberChangedPK INT NOT NULL,
        PLTMemberPK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected employee
    INSERT INTO @ExistingChangeRows
    (
        PLTMemberChangedPK,
		PLTMemberPK,
        RowNumber
    )
    SELECT smc.PLTMemberChangedPK,
		   smc.PLTMemberPK,
           ROW_NUMBER() OVER (PARTITION BY smc.PLTMemberPK
                              ORDER BY smc.PLTMemberChangedPK DESC
                             ) AS RowNum
    FROM dbo.PLTMemberChanged smc
    WHERE EXISTS
    (
        SELECT d.PLTMemberPK FROM Deleted d WHERE d.PLTMemberPK = smc.PLTMemberPK
    );

	--Remove all but the most recent 5 change rows for each affected employee
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE smc
    FROM dbo.PLTMemberChanged smc
        INNER JOIN @ExistingChangeRows ecr
            ON smc.PLTMemberChangedPK = ecr.PLTMemberChangedPK
    WHERE smc.PLTMemberChangedPK = ecr.PLTMemberChangedPK;
	
END
GO
ALTER TABLE [dbo].[PLTMember] ADD CONSTRAINT [PK_PLTMember] PRIMARY KEY CLUSTERED ([PLTMemberPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PLTMember] ADD CONSTRAINT [FK_PLTMember_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

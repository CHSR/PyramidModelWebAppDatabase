CREATE TABLE [dbo].[ProgramType]
(
[ProgramTypePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/15/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the last actions on this table
-- record.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ProgramType_Changed]
   ON  [dbo].[ProgramType] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ProgramTypePK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ProgramTypeChanged
    (
        ChangeDatetime,
        ChangeType,
        ProgramTypePK,
        Creator,
        CreateDate,
        ProgramFK,
        TypeCodeFK
    )
    SELECT GETDATE(), 
		@ChangeType,
        d.ProgramTypePK,
        d.Creator,
        d.CreateDate,
        d.ProgramFK,
        d.TypeCodeFK
	FROM Deleted d;

	--To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ProgramTypeChangedPK INT NOT NULL,
        ProgramTypePK INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected program type rows
    INSERT INTO @ExistingChangeRows
    (
        ProgramTypeChangedPK,
		ProgramTypePK,
        RowNumber
    )
    SELECT ptc.ProgramTypeChangedPK,
		   ptc.ProgramTypePK,
           ROW_NUMBER() OVER (PARTITION BY ptc.ProgramFK, ptc.TypeCodeFK
                              ORDER BY ptc.ProgramTypeChangedPK DESC
                             ) AS RowNum
    FROM dbo.ProgramTypeChanged ptc
    WHERE EXISTS
    (
        SELECT d.ProgramTypePK FROM Deleted d WHERE d.ProgramFK = ptc.ProgramFK AND d.TypeCodeFK = ptc.TypeCodeFK
    );

	--Remove all but the most recent change row for each program type since these are deleted each time
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 1;

    --Delete the excess change rows to keep the number of change rows low
    DELETE ptc
    FROM dbo.ProgramTypeChanged ptc
        INNER JOIN @ExistingChangeRows ecr
            ON ptc.ProgramTypeChangedPK = ecr.ProgramTypeChangedPK
    WHERE ptc.ProgramTypeChangedPK = ecr.ProgramTypeChangedPK;
	
END
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [PK_ProgramType] PRIMARY KEY CLUSTERED  ([ProgramTypePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [FK_ProgramType_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [FK_ProgramType_TypeCode] FOREIGN KEY ([TypeCodeFK]) REFERENCES [dbo].[CodeProgramType] ([CodeProgramTypePK])
GO

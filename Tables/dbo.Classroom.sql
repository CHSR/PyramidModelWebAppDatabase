CREATE TABLE [dbo].[Classroom]
(
[ClassroomPK] [int] NOT NULL IDENTITY(1, 1),
[BeingServedSubstitute] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsInfantToddler] [bit] NOT NULL,
[IsPreschool] [bit] NOT NULL,
[Location] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramSpecificID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
CREATE TRIGGER [dbo].[TGR_Classroom_Changed] 
   ON  [dbo].[Classroom] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ClassroomChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		ClassroomPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    ClassroomPK,
	    MinChangeDatetime
	)
	SELECT ac.ClassroomPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.ClassroomChanged ac
	GROUP BY ac.ClassroomPK
	HAVING COUNT(ac.ClassroomPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.ClassroomChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.ClassroomPK = ecr.ClassroomPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.ClassroomPK = ecr.ClassroomPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[Classroom] ADD CONSTRAINT [PK_Classroom] PRIMARY KEY CLUSTERED  ([ClassroomPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Classroom] ON [dbo].[Classroom] ([ProgramSpecificID], [ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Classroom] ADD CONSTRAINT [FK_Classroom_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

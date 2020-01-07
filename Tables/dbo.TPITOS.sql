CREATE TABLE [dbo].[TPITOS]
(
[TPITOSPK] [int] NOT NULL IDENTITY(1, 1),
[ClassroomRedFlagsNumPossible] [int] NULL,
[ClassroomRedFlagsNumYes] [int] NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsValid] [bit] NOT NULL,
[Item1NumNo] [int] NULL,
[Item1NumYes] [int] NULL,
[Item2NumNo] [int] NULL,
[Item2NumYes] [int] NULL,
[Item3NumNo] [int] NULL,
[Item3NumYes] [int] NULL,
[Item4NumNo] [int] NULL,
[Item4NumYes] [int] NULL,
[Item5NumNo] [int] NULL,
[Item5NumYes] [int] NULL,
[Item6NumNo] [int] NULL,
[Item6NumYes] [int] NULL,
[Item7NumNo] [int] NULL,
[Item7NumYes] [int] NULL,
[Item8NumNo] [int] NULL,
[Item8NumYes] [int] NULL,
[Item9NumNo] [int] NULL,
[Item9NumYes] [int] NULL,
[Item10NumNo] [int] NULL,
[Item10NumYes] [int] NULL,
[Item11NumNo] [int] NULL,
[Item11NumYes] [int] NULL,
[Item12NumNo] [int] NULL,
[Item12NumYes] [int] NULL,
[Item13NumNo] [int] NULL,
[Item13NumYes] [int] NULL,
[LeadTeacherRedFlagsNumYes] [int] NULL,
[LeadTeacherRedFlagsNumPossible] [int] NULL,
[Notes] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAdultsBegin] [int] NOT NULL,
[NumAdultsEnd] [int] NOT NULL,
[NumAdultsEntered] [int] NOT NULL,
[NumKidsBegin] [int] NOT NULL,
[NumKidsEnd] [int] NOT NULL,
[ObservationEndDateTime] [datetime] NOT NULL,
[ObservationStartDateTime] [datetime] NOT NULL,
[OtherTeacherRedFlagsNumYes] [int] NULL,
[OtherTeacherRedFlagsNumPossible] [int] NULL,
[ClassroomFK] [int] NOT NULL,
[ObserverFK] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_TPITOS_Changed] 
   ON  [dbo].[TPITOS] 
   AFTER UPDATE, DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get the change type
	DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT * FROM Inserted) THEN 'Update' ELSE 'Delete' END

	--Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.TPITOSChanged
    SELECT GETDATE(), @ChangeType, d.*
	FROM Deleted d

	--To hold any existing change rows
	DECLARE @ExistingChangeRows TABLE (
		TPITOSPK INT,
		MinChangeDatetime DATETIME
	)

	--Get the existing change rows if there are more than 5
	INSERT INTO @ExistingChangeRows
	(
	    TPITOSPK,
	    MinChangeDatetime
	)
	SELECT ac.TPITOSPK, CAST(MIN(ac.ChangeDatetime) AS DATETIME)
	FROM dbo.TPITOSChanged ac
	GROUP BY ac.TPITOSPK
	HAVING COUNT(ac.TPITOSPK) > 5

	--Delete the excess change rows to keep the number of change rows at 5
	DELETE ac
	FROM dbo.TPITOSChanged ac
	INNER JOIN @ExistingChangeRows ecr ON ac.TPITOSPK = ecr.TPITOSPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	WHERE ac.TPITOSPK = ecr.TPITOSPK AND ac.ChangeDatetime = ecr.MinChangeDatetime
	
END
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [PK_TPITOS] PRIMARY KEY CLUSTERED  ([TPITOSPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [FK_TPITOS_Classroom] FOREIGN KEY ([ClassroomFK]) REFERENCES [dbo].[Classroom] ([ClassroomPK])
GO
ALTER TABLE [dbo].[TPITOS] ADD CONSTRAINT [FK_TPITOS_ProgramEmployee] FOREIGN KEY ([ObserverFK]) REFERENCES [dbo].[ProgramEmployee] ([ProgramEmployeePK])
GO

CREATE TABLE [dbo].[ASQSE]
(
[ASQSEPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[HasDemographicInfoSheet] [bit] NOT NULL,
[HasPhysicianInfoLetter] [bit] NOT NULL,
[TotalScore] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[IntervalCodeFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Version] [int] NOT NULL
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
CREATE TRIGGER [dbo].[TGR_ASQSE_Changed]
ON [dbo].[ASQSE]
AFTER UPDATE, DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the change type
    DECLARE @ChangeType VARCHAR(100) = CASE WHEN EXISTS (SELECT i.ASQSEPK FROM Inserted i) THEN 'Update' ELSE 'Delete' END;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.ASQSEChanged
    (
        ChangeDatetime,
        ChangeType,
        ASQSEPK,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        FormDate,
        HasDemographicInfoSheet,
        HasPhysicianInfoLetter,
        TotalScore,
        ChildFK,
        IntervalCodeFK,
        ProgramFK,
        Version
    )
    SELECT GETDATE(),
           @ChangeType,
           d.ASQSEPK,
           d.Creator,
           d.CreateDate,
           d.Editor,
           d.EditDate,
           d.FormDate,
           d.HasDemographicInfoSheet,
           d.HasPhysicianInfoLetter,
           d.TotalScore,
           d.ChildFK,
           d.IntervalCodeFK,
           d.ProgramFK,
           d.Version
    FROM Deleted d;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        ASQSEChangedPK INT NOT NULL,
		ASQSEPK	INT NOT NULL,
        RowNumber INT NOT NULL
    );

    --Get the existing change rows for affected ASQSEs
    INSERT INTO @ExistingChangeRows
    (
        ASQSEChangedPK,
		ASQSEPK,
        RowNumber
    )
    SELECT ac.ASQSEChangedPK, 
		   ac.ASQSEPK,
           ROW_NUMBER() OVER (PARTITION BY ac.ASQSEPK
                              ORDER BY ac.ASQSEChangedPK DESC
                             ) AS RowNum
    FROM dbo.ASQSEChanged ac
    WHERE EXISTS
    (
        SELECT d.ASQSEPK FROM Deleted d WHERE d.ASQSEPK = ac.ASQSEPK
    );

    --Remove all but the most recent 5 change rows for each affected ASQSE
    DELETE FROM @ExistingChangeRows
    WHERE RowNumber <= 5;

    --Delete the excess change rows to keep the number of change rows at 5
    DELETE ac
    FROM dbo.ASQSEChanged ac
        INNER JOIN @ExistingChangeRows ecr
            ON ac.ASQSEChangedPK = ecr.ASQSEChangedPK
    WHERE ac.ASQSEChangedPK = ecr.ASQSEChangedPK;

END;
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [PK_ASQSE] PRIMARY KEY CLUSTERED ([ASQSEPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_ASQSE_DBAF1E38FFBBD26CFA463ED8018DF7E8] ON [dbo].[ASQSE] ([ProgramFK], [FormDate]) INCLUDE ([ChildFK], [IntervalCodeFK], [TotalScore], [Version]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_Child] FOREIGN KEY ([ChildFK]) REFERENCES [dbo].[Child] ([ChildPK])
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_CodeASQSEInterval] FOREIGN KEY ([IntervalCodeFK]) REFERENCES [dbo].[CodeASQSEInterval] ([CodeASQSEIntervalPK])
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [FK_ASQSE_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

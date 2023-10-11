CREATE TABLE [dbo].[CodeTraining]
(
[CodeTrainingPK] [int] NOT NULL,
[Abbreviation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 05/23/2022
-- Description:	This trigger ensures that the CodeTrainingAccess table is populated
-- and that other fields that utilize CodeTraining PKs are populated.
-- =============================================
CREATE TRIGGER [dbo].[TGR_CodeTraining_Added]
ON [dbo].[CodeTraining]
AFTER INSERT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Add rows to the CodeTrainingAccess table.
    --It should have a row for each state and this new training.
    INSERT INTO dbo.CodeTrainingAccess
    (
        AllowedAccess,
        Creator,
        CreateDate,
        Editor,
        EditDate,
        StateFK,
        TrainingCodeFK
    )
    SELECT 1,
		   'TRIGGER',
		   GETDATE(),
		   NULL,
		   NULL,
           s.StatePK,
           i.CodeTrainingPK
    FROM Inserted i
        LEFT JOIN dbo.CodeTrainingAccess cta
            ON cta.TrainingCodeFK = i.CodeTrainingPK
        CROSS JOIN dbo.[State] s
    WHERE cta.CodeTrainingAccessPK IS NULL;

END;
GO
ALTER TABLE [dbo].[CodeTraining] ADD CONSTRAINT [PK_CodeTrainingType] PRIMARY KEY CLUSTERED ([CodeTrainingPK]) ON [PRIMARY]
GO

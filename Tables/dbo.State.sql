CREATE TABLE [dbo].[State]
(
[StatePK] [int] NOT NULL IDENTITY(1, 1),
[Abbreviation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Catchphrase] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConfidentialityChangeDate] [datetime] NULL,
[ConfidentialityEnabled] [bit] NOT NULL CONSTRAINT [DF_State_ConfidentialityEnabled] DEFAULT ((0)),
[ConfidentialityFilename] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Disclaimer] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[HomePageLogoOption] [int] NOT NULL CONSTRAINT [DF_State_HomePageDisplayOption] DEFAULT ((1)),
[LockEndedPrograms] [bit] NOT NULL CONSTRAINT [DF_State_LockEndedPrograms] DEFAULT ((1)),
[LogoFilename] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaxNumberOfPrograms] [int] NOT NULL CONSTRAINT [DF_State_MaxNumberOfPrograms] DEFAULT ((100)),
[Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ShareDataNationally] [bit] NOT NULL CONSTRAINT [DF_State_ShareDataNationally] DEFAULT ((0)),
[ThumbnailLogoFilename] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_State_ThumbnailLogoFilename] DEFAULT ('CustomPIDSLogo.png'),
[UtilizingPIDS] [bit] NOT NULL CONSTRAINT [DF_State_UtilizingPIDS] DEFAULT ((0))
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
-- and that other fields that utilize State PKs are populated.
-- =============================================
CREATE TRIGGER [dbo].[TGR_State_Added]
ON [dbo].[State]
AFTER INSERT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Add rows to the CodeTrainingAccess table.
    --It should have a row for each training and this new state.
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
           i.StatePK,
           ct.CodeTrainingPK
    FROM Inserted i
        LEFT JOIN dbo.CodeTrainingAccess cta
            ON cta.StateFK = i.StatePK
        CROSS JOIN dbo.CodeTraining ct
    WHERE cta.CodeTrainingAccessPK IS NULL;

END;
GO
ALTER TABLE [dbo].[State] ADD CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED ([StatePK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StateAbbreviationUnique] ON [dbo].[State] ([Abbreviation]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_StateNameUnique] ON [dbo].[State] ([Name]) ON [PRIMARY]
GO

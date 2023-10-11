CREATE TABLE [dbo].[CodeTrainingAccess]
(
[CodeTrainingAccessPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedAccess] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StateFK] [int] NOT NULL,
[TrainingCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTrainingAccess] ADD CONSTRAINT [PK_CodeTrainingAccess] PRIMARY KEY CLUSTERED ([CodeTrainingAccessPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTrainingAccess] ADD CONSTRAINT [FK_CodeTrainingAccess_CodeTraining] FOREIGN KEY ([TrainingCodeFK]) REFERENCES [dbo].[CodeTraining] ([CodeTrainingPK])
GO
ALTER TABLE [dbo].[CodeTrainingAccess] ADD CONSTRAINT [FK_CodeTrainingAccess_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

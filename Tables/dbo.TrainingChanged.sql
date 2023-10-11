CREATE TABLE [dbo].[TrainingChanged]
(
[TrainingChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingPK] [int] NOT NULL,
[AspireEventAttendeeID] [int] NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsAspireTraining] [bit] NOT NULL CONSTRAINT [DF_TrainingChanged_IsAspireTraining] DEFAULT ((0)),
[TrainingDate] [datetime] NOT NULL,
[EmployeeFK] [int] NOT NULL,
[TrainingCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingChanged] ADD CONSTRAINT [PK_TrainingChanged] PRIMARY KEY CLUSTERED ([TrainingChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingChanged_TrainingPK_ChangeDatetime] ON [dbo].[TrainingChanged] ([TrainingPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

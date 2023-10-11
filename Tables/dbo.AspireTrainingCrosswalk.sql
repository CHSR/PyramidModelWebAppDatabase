CREATE TABLE [dbo].[AspireTrainingCrosswalk]
(
[AspireTrainingCrosswalkPK] [int] NOT NULL IDENTITY(1, 1),
[AspireCourseID] [int] NOT NULL,
[AspireCourseTitle] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTrainingFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspireTrainingCrosswalk] ADD CONSTRAINT [PK_AspireTrainingCrosswalk] PRIMARY KEY CLUSTERED ([AspireTrainingCrosswalkPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspireTrainingCrosswalk] ADD CONSTRAINT [FK_AspireTrainingCrosswalk_CodeTraining] FOREIGN KEY ([CodeTrainingFK]) REFERENCES [dbo].[CodeTraining] ([CodeTrainingPK])
GO

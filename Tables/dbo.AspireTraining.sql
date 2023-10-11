CREATE TABLE [dbo].[AspireTraining]
(
[AspireTrainingPK] [int] NOT NULL IDENTITY(1, 1),
[EventAttendeeID] [int] NULL,
[CourseID] [int] NULL,
[CourseTitle] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventID] [int] NULL,
[EventTitle] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventStartDate] [datetime] NULL,
[EventCompletionDate] [datetime] NULL,
[AspireID] [int] NULL,
[FullName] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Attended] [bit] NULL,
[TPOTReliability] [bit] NULL,
[TPOTReliabilityExpirationDate] [datetime] NULL,
[TPITOSReliability] [bit] NULL,
[TPITOSReliabilityExpirationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspireTraining] ADD CONSTRAINT [PK_AspireTraining] PRIMARY KEY CLUSTERED ([AspireTrainingPK]) ON [PRIMARY]
GO

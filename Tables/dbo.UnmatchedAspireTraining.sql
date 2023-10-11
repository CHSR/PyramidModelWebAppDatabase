CREATE TABLE [dbo].[UnmatchedAspireTraining]
(
[UnmatchedAspireTrainingPK] [int] NOT NULL IDENTITY(1, 1),
[CreateDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
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
ALTER TABLE [dbo].[UnmatchedAspireTraining] ADD CONSTRAINT [PK_UnmatchedAspireTraining] PRIMARY KEY CLUSTERED ([UnmatchedAspireTrainingPK]) ON [PRIMARY]
GO

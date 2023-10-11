CREATE TABLE [dbo].[MasterCadreTrainingDebriefChanged]
(
[MasterCadreTrainingDebriefChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterCadreTrainingDebriefPK] [int] NOT NULL,
[AspireEventNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssistanceNeeded] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingInterest] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseIDNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DateCompleted] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[MeetingLocation] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAttendees] [int] NOT NULL,
[NumEvalsReceived] [int] NOT NULL,
[Reflection] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WasUploadedToAspire] [bit] NULL,
[MasterCadreMemberUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeetingFormatCodeFK] [int] NOT NULL,
[StateFK] [int] NOT NULL,
[MasterCadreActivityCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingDebriefChanged] ADD CONSTRAINT [PK_MasterCadreTrainingDebriefChanged] PRIMARY KEY CLUSTERED ([MasterCadreTrainingDebriefChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[HubLCMeetingScheduleChanged]
(
[HubLCMeetingScheduleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HubLCMeetingSchedulePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[MeetingInJan] [bit] NOT NULL,
[MeetingInFeb] [bit] NOT NULL,
[MeetingInMar] [bit] NOT NULL,
[MeetingInApr] [bit] NOT NULL,
[MeetingInMay] [bit] NOT NULL,
[MeetingInJun] [bit] NOT NULL,
[MeetingInJul] [bit] NOT NULL,
[MeetingInAug] [bit] NOT NULL,
[MeetingInSep] [bit] NOT NULL,
[MeetingInOct] [bit] NOT NULL,
[MeetingInNov] [bit] NOT NULL,
[MeetingInDec] [bit] NOT NULL,
[MeetingYear] [int] NOT NULL,
[TotalMeetings] [int] NOT NULL,
[LeadershipCoachUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HubFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubLCMeetingScheduleChanged] ADD CONSTRAINT [PK_HubLCMeetingScheduleChanged] PRIMARY KEY CLUSTERED ([HubLCMeetingScheduleChangedPK]) ON [PRIMARY]
GO

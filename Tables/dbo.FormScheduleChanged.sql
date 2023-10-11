CREATE TABLE [dbo].[FormScheduleChanged]
(
[FormScheduleChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormSchedulePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[ScheduledForJan] [bit] NOT NULL,
[ScheduledForFeb] [bit] NOT NULL,
[ScheduledForMar] [bit] NOT NULL,
[ScheduledForApr] [bit] NOT NULL,
[ScheduledForMay] [bit] NOT NULL,
[ScheduledForJun] [bit] NOT NULL,
[ScheduledForJul] [bit] NOT NULL,
[ScheduledForAug] [bit] NOT NULL,
[ScheduledForSep] [bit] NOT NULL,
[ScheduledForOct] [bit] NOT NULL,
[ScheduledForNov] [bit] NOT NULL,
[ScheduledForDec] [bit] NOT NULL,
[ScheduleYear] [int] NOT NULL,
[ClassroomFK] [int] NULL,
[CodeFormFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FormScheduleChanged] ADD CONSTRAINT [PK_FormScheduleChanged] PRIMARY KEY CLUSTERED ([FormScheduleChangedPK]) ON [PRIMARY]
GO

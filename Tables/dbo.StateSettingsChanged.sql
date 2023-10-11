CREATE TABLE [dbo].[StateSettingsChanged]
(
[StateSettingsChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateSettingsPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DueDatesBeginDate] [datetime] NULL,
[DueDatesDaysUntilWarning] [int] NULL,
[DueDatesEnabled] [bit] NOT NULL,
[DueDatesMonthsStart] [decimal] (7, 2) NULL,
[DueDatesMonthsEnd] [decimal] (7, 2) NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StateSettingsChanged] ADD CONSTRAINT [PK_StateSettingsChanged] PRIMARY KEY CLUSTERED  ([StateSettingsChangedPK]) ON [PRIMARY]
GO

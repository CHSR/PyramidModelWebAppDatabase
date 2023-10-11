CREATE TABLE [dbo].[MasterCadreTrainingTrackerItemDateChanged]
(
[MasterCadreTrainingTrackerItemDateChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (246) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterCadreTrainingTrackerItemDatePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[StartDateTime] [datetime] NOT NULL,
[EndDateTime] [datetime] NOT NULL,
[MasterCadreTrainingTrackerItemFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItemDateChanged] ADD CONSTRAINT [PK_MasterCadreTrainingTrackerItemDateChanged] PRIMARY KEY CLUSTERED ([MasterCadreTrainingTrackerItemDateChangedPK]) ON [PRIMARY]
GO

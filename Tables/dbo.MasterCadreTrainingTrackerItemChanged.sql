CREATE TABLE [dbo].[MasterCadreTrainingTrackerItemChanged]
(
[MasterCadreTrainingTrackerItemChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MasterCadreTrainingTrackerItemPK] [int] NOT NULL,
[AspireEventNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CourseIDNum] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DidEventOccur] [bit] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[IsOpenToPublic] [bit] NOT NULL,
[MeetingLocation] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NumHours] [decimal] (18, 2) NOT NULL,
[ParticipantFee] [decimal] (18, 2) NOT NULL,
[TargetAudience] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MasterCadreActivityCodeFK] [int] NOT NULL,
[MasterCadreFundingSourceCodeFK] [int] NOT NULL,
[MasterCadreMemberUsername] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeetingFormatCodeFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterCadreTrainingTrackerItemChanged] ADD CONSTRAINT [PK_MasterCadreTrainingTrackerItemChanged] PRIMARY KEY CLUSTERED ([MasterCadreTrainingTrackerItemChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[SLTWorkGroupChanged]
(
[SLTWorkGroupChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTWorkGroupPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[WorkGroupName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTWorkGroupChanged] ADD CONSTRAINT [PK_SLTWorkGroupChanged] PRIMARY KEY CLUSTERED ([SLTWorkGroupChangedPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ChildClassroomChanged]
(
[ChildClassroomChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildClassroomPK] [int] NOT NULL,
[AssignDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeaveDate] [datetime] NULL,
[LeaveReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChildFK] [int] NOT NULL,
[ClassroomFK] [int] NOT NULL,
[LeaveReasonCodeFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChildClassroomChanged] ADD CONSTRAINT [PK_ChildClassroomChanged] PRIMARY KEY CLUSTERED  ([ChildClassroomChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ChildClassroomChanged_ChildClassroomPK_ChangeDatetime] ON [dbo].[ChildClassroomChanged] ([ChildClassroomPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

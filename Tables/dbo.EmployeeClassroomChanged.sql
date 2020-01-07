CREATE TABLE [dbo].[EmployeeClassroomChanged]
(
[EmployeeClassroomChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmployeeClassroomPK] [int] NOT NULL,
[AssignDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[LeaveDate] [datetime] NULL,
[LeaveReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassroomFK] [int] NOT NULL,
[JobTypeFK] [int] NULL,
[LeaveReasonCodeFK] [int] NULL,
[EmployeeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeClassroomChanged] ADD CONSTRAINT [PK_EmployeeClassroomChanged] PRIMARY KEY CLUSTERED  ([EmployeeClassroomChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EmployeeClassroomChanged_EmployeeClassroomPK_ChangeDatetime] ON [dbo].[EmployeeClassroomChanged] ([EmployeeClassroomPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

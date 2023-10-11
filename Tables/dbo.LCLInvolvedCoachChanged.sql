CREATE TABLE [dbo].[LCLInvolvedCoachChanged]
(
[LCLInvolvedCoachChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LCLInvolvedCoachPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL,
[ProgramEmployeeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLInvolvedCoachChanged] ADD CONSTRAINT [PK_LCLInvolvedCoachChanged] PRIMARY KEY CLUSTERED ([LCLInvolvedCoachChangedPK]) ON [PRIMARY]
GO

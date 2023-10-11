CREATE TABLE [dbo].[LCLResponseChanged]
(
[LCLResponseChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LCLResponsePK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LCLResponseCodeFK] [int] NOT NULL,
[LeadershipCoachLogFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LCLResponseChanged] ADD CONSTRAINT [PK_LCLResponseChanged] PRIMARY KEY CLUSTERED ([LCLResponseChangedPK]) ON [PRIMARY]
GO

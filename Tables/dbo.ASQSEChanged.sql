CREATE TABLE [dbo].[ASQSEChanged]
(
[ASQSEChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASQSEPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[HasDemographicInfoSheet] [bit] NOT NULL,
[HasPhysicianInfoLetter] [bit] NOT NULL,
[TotalScore] [int] NOT NULL,
[ChildFK] [int] NOT NULL,
[IntervalCodeFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Version] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQSEChanged] ADD CONSTRAINT [PK_ASQSEChanged] PRIMARY KEY CLUSTERED  ([ASQSEChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ASQSEChanged_ASQSEPK_ChangeDatetime] ON [dbo].[ASQSEChanged] ([ASQSEPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

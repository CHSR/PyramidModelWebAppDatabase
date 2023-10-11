CREATE TABLE [dbo].[CodeTeamPosition]
(
[CodeTeamPositionPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTeamPosition] ADD CONSTRAINT [PK_CodeTeamPosition] PRIMARY KEY CLUSTERED ([CodeTeamPositionPK]) ON [PRIMARY]
GO

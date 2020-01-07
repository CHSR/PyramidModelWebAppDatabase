CREATE TABLE [dbo].[CodeTPOTRedFlag]
(
[CodeTPOTRedFlagPK] [int] NOT NULL,
[Abbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTPOTRedFlag] ADD CONSTRAINT [PK_CodeTPOTRedFlag] PRIMARY KEY CLUSTERED  ([CodeTPOTRedFlagPK]) ON [PRIMARY]
GO

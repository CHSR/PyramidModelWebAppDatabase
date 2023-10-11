CREATE TABLE [dbo].[CodeTPITOSRedFlag]
(
[CodeTPITOSRedFlagPK] [int] NOT NULL,
[Abbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[Type] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypeAbbreviation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeTPITOSRedFlag_TypeAbbreviation] DEFAULT ('ABBR')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTPITOSRedFlag] ADD CONSTRAINT [PK_CodeTPITOSRedFlag] PRIMARY KEY CLUSTERED  ([CodeTPITOSRedFlagPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CodeAdminFollowUp]
(
[CodeAdminFollowUpPK] [int] NOT NULL,
[Abbreviation] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_CodeAdminFollowUp_Abbreviation] DEFAULT ('Abbr'),
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeAdminFollowUp] ADD CONSTRAINT [PK_CodeAdminFollowUp] PRIMARY KEY CLUSTERED  ([CodeAdminFollowUpPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CodeHouseholdIncome]
(
[CodeHouseholdIncomePK] [int] NOT NULL,
[BeginningValue] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[EndingValue] [int] NOT NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeHouseholdIncome] ADD CONSTRAINT [PK_CodeHouseholdIncome] PRIMARY KEY CLUSTERED ([CodeHouseholdIncomePK]) ON [PRIMARY]
GO

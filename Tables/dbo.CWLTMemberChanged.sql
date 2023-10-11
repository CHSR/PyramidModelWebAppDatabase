CREATE TABLE [dbo].[CWLTMemberChanged]
(
[CWLTMemberChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CWLTMemberPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDNumber] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LeaveDate] [datetime] NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NOT NULL,
[EthnicityCodeFk] [int] NULL,
[GenderCodeFK] [int] NULL,
[HouseholdIncomeCodeFK] [int] NULL,
[RaceCodeFK] [int] NULL,
[HubFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CWLTMemberChanged] ADD CONSTRAINT [PK_CWLTMemberChanged] PRIMARY KEY CLUSTERED ([CWLTMemberChangedPK]) ON [PRIMARY]
GO

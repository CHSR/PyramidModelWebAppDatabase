CREATE TABLE [dbo].[EmployeeChanged]
(
[EmployeeChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmployeePK] [int] NOT NULL,
[AspireEmail] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AspireID] [int] NULL,
[AspireVerified] [bit] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[EmailAddress] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EthnicitySpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenderSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RaceSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EthnicityCodeFK] [int] NOT NULL,
[GenderCodeFK] [int] NOT NULL,
[RaceCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EmployeeChanged] ADD CONSTRAINT [PK_EmployeeChanged] PRIMARY KEY CLUSTERED ([EmployeeChangedPK]) ON [PRIMARY]
GO

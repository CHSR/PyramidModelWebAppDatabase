CREATE TABLE [dbo].[SLTAgencyChanged]
(
[SLTAgencyChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SLTAgencyPK] [int] NOT NULL,
[AddressCity] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressStreet] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressZIPCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Name] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhoneNumber] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Website] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SLTAgencyChanged] ADD CONSTRAINT [PK_SLTAgencyChanged] PRIMARY KEY CLUSTERED ([SLTAgencyChangedPK]) ON [PRIMARY]
GO

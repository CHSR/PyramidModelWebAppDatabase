CREATE TABLE [dbo].[ProgramAddressChanged]
(
[ProgramAddressChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramAddressPK] [int] NOT NULL,
[City] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMailingAddress] [bit] NOT NULL,
[LicenseNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Street] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZIPCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramAddressChanged] ADD CONSTRAINT [PK_ProgramAddressChanged] PRIMARY KEY CLUSTERED ([ProgramAddressChangedPK]) ON [PRIMARY]
GO

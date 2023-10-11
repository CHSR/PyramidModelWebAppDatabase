CREATE TABLE [dbo].[AspireReliability]
(
[AspireReliabilityPK] [int] NOT NULL IDENTITY(1, 1),
[AspireID] [int] NULL,
[EligibilityDate] [datetime] NULL,
[EmailAddress] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [datetime] NULL,
[FullName] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL,
[ReliabilityType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspireReliability] ADD CONSTRAINT [PK_AspireReliability] PRIMARY KEY CLUSTERED ([AspireReliabilityPK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ConfidentialityAgreement]
(
[ConfidentialityAgreementPK] [int] NOT NULL IDENTITY(1, 1),
[AgreementDate] [datetime] NOT NULL,
[Username] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConfidentialityAgreement] ADD CONSTRAINT [PK_ConfidentialityAgreement] PRIMARY KEY CLUSTERED  ([ConfidentialityAgreementPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConfidentialityAgreement] ADD CONSTRAINT [FK_ConfidentialityAgreement_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

CREATE TABLE [dbo].[UserCustomizationOption]
(
[UserCustomizationOptionPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Username] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomizationOptionTypeCodeFK] [int] NOT NULL,
[CustomizationOptionValueCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserCustomizationOption] ADD CONSTRAINT [PK_UserCustomizationOption] PRIMARY KEY CLUSTERED  ([UserCustomizationOptionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserCustomizationOption] ADD CONSTRAINT [FK_UserCustomizationOption_CodeCustomizationOptionType] FOREIGN KEY ([CustomizationOptionTypeCodeFK]) REFERENCES [dbo].[CodeCustomizationOptionType] ([CodeCustomizationOptionTypePK])
GO
ALTER TABLE [dbo].[UserCustomizationOption] ADD CONSTRAINT [FK_UserCustomizationOption_CodeCustomizationOptionValue] FOREIGN KEY ([CustomizationOptionValueCodeFK]) REFERENCES [dbo].[CodeCustomizationOptionValue] ([CodeCustomizationOptionValuePK])
GO

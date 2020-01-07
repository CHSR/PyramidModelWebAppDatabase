CREATE TABLE [dbo].[CodeCustomizationOptionValue]
(
[CodeCustomizationOptionValuePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[IsDefault] [bit] NOT NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[Value] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomizationOptionTypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeCustomizationOptionValue] ADD CONSTRAINT [PK_CodeCustomizationOptionValue] PRIMARY KEY CLUSTERED  ([CodeCustomizationOptionValuePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeCustomizationOptionValue] ADD CONSTRAINT [FK_CodeCustomizationOptionValue_CodeCustomizationOptionType] FOREIGN KEY ([CustomizationOptionTypeCodeFK]) REFERENCES [dbo].[CodeCustomizationOptionType] ([CodeCustomizationOptionTypePK])
GO

CREATE TABLE [dbo].[CodeNewsEntryType]
(
[CodeNewsEntryTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeNewsEntryType] ADD CONSTRAINT [PK_CodeNewsEntryType] PRIMARY KEY CLUSTERED  ([CodeNewsEntryTypePK]) ON [PRIMARY]
GO

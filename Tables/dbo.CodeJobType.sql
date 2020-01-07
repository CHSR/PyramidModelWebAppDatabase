CREATE TABLE [dbo].[CodeJobType]
(
[CodeJobTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeJobType] ADD CONSTRAINT [PK_CodeJobType] PRIMARY KEY CLUSTERED  ([CodeJobTypePK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CodeFileUploadType]
(
[CodeFileUploadTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[RolesAuthorizedToModify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeFileUploadType] ADD CONSTRAINT [PK_CodeAttachmentType] PRIMARY KEY CLUSTERED  ([CodeFileUploadTypePK]) ON [PRIMARY]
GO

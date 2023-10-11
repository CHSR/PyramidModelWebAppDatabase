CREATE TABLE [dbo].[UserFileUploadChanged]
(
[UserFileUploadChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Deleter] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserFileUploadPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayFileName] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[FileType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePath] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CohortFK] [int] NULL,
[HubFK] [int] NULL,
[ProgramFK] [int] NULL,
[StateFK] [int] NULL,
[TypeCodeFK] [int] NOT NULL,
[UploadedBy] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserFileUploadChanged] ADD CONSTRAINT [PK_UserFileUploadChanged] PRIMARY KEY CLUSTERED  ([UserFileUploadChangedPK]) ON [PRIMARY]
GO

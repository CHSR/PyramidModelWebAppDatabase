CREATE TABLE [dbo].[UserFileUpload]
(
[UserFileUploadPK] [int] NOT NULL IDENTITY(1, 1),
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
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [PK_UserFileUpload] PRIMARY KEY CLUSTERED  ([UserFileUploadPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [FK_UserFileUpload_CodeFileUploadType] FOREIGN KEY ([TypeCodeFK]) REFERENCES [dbo].[CodeFileUploadType] ([CodeFileUploadTypePK])
GO
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [FK_UserFileUpload_Cohort] FOREIGN KEY ([CohortFK]) REFERENCES [dbo].[Cohort] ([CohortPK])
GO
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [FK_UserFileUpload_Hub] FOREIGN KEY ([HubFK]) REFERENCES [dbo].[Hub] ([HubPK])
GO
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [FK_UserFileUpload_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[UserFileUpload] ADD CONSTRAINT [FK_UserFileUpload_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO

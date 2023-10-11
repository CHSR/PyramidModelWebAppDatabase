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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 09/29/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of deletions.
-- =============================================
CREATE TRIGGER [dbo].[TGR_UserFileUpload_Changed]
ON [dbo].[UserFileUpload]
AFTER DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Insert the deleted rows
    INSERT INTO dbo.UserFileUploadChanged
    (
        ChangeDatetime,
        ChangeType,
        Deleter,
		UserFileUploadPK,
        Creator,
        CreateDate,
        Description,
        DisplayFileName,
        Editor,
        EditDate,
        FileType,
        FileName,
        FilePath,
        CohortFK,
        HubFK,
        ProgramFK,
        StateFK,
        TypeCodeFK,
        UploadedBy
    )
    SELECT GETDATE(),
           'Delete',
           NULL, --Can't get the deleter yet
           d.UserFileUploadPK,
           d.Creator,
           d.CreateDate,
           d.Description,
           d.DisplayFileName,
           d.Editor,
           d.EditDate,
           d.FileType,
           d.FileName,
           d.FilePath,
           d.CohortFK,
           d.HubFK,
           d.ProgramFK,
           d.StateFK,
           d.TypeCodeFK,
           d.UploadedBy
    FROM Deleted d;

END;
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

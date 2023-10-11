CREATE TABLE [dbo].[ReportCatalog]
(
[ReportCatalogPK] [int] NOT NULL IDENTITY(1, 1),
[CriteriaOptions] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CriteriaDefaults] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DocumentationLink] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Keywords] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OnlyExportAllowed] [bit] NOT NULL CONSTRAINT [DF_ReportCatalog_IsExportOnlyReport] DEFAULT ((0)),
[OptionalCriteriaOptions] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportClass] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RolesAuthorizedToRun] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/23/2020
-- Description:	This trigger takes over the delete of the report catalog
-- so that it can remove UserReportHistory rows before the delete of the
-- report catalog rows themselves.
-- =============================================
CREATE TRIGGER [dbo].[TGR_ReportCatalog_Delete]
ON [dbo].[ReportCatalog]
INSTEAD OF DELETE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Delete the UserReportHistory rows
    DELETE urh
    FROM dbo.UserReportHistory urh
        INNER JOIN Deleted d
            ON d.ReportCatalogPK = urh.ReportCatalogFK
    WHERE urh.UserReportHistoryPK IS NOT NULL;

    --Delete the ReportCatalog rows
    DELETE rc
    FROM dbo.ReportCatalog rc
        INNER JOIN Deleted d
            ON d.ReportCatalogPK = rc.ReportCatalogPK
    WHERE rc.ReportCatalogPK IS NOT NULL;

END;
GO
ALTER TABLE [dbo].[ReportCatalog] ADD CONSTRAINT [PK_ReportCatalog] PRIMARY KEY CLUSTERED ([ReportCatalogPK]) ON [PRIMARY]
GO

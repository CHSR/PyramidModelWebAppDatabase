CREATE TABLE [dbo].[ReportCatalog]
(
[ReportCatalogPK] [int] NOT NULL IDENTITY(1, 1),
[CriteriaOptions] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CriteriaDefaults] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[DocumentationLink] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Keywords] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OptionalCriteriaOptions] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportCategory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportClass] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RolesAuthorizedToRun] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportCatalog] ADD CONSTRAINT [PK_ReportCatalog] PRIMARY KEY CLUSTERED  ([ReportCatalogPK]) ON [PRIMARY]
GO

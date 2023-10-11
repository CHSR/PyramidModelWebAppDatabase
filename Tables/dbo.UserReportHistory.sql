CREATE TABLE [dbo].[UserReportHistory]
(
[UserReportHistoryPK] [int] NOT NULL IDENTITY(1, 1),
[Username] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunDate] [datetime] NOT NULL,
[ReportCatalogFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserReportHistory] ADD CONSTRAINT [PK_UserReportHistory] PRIMARY KEY CLUSTERED  ([UserReportHistoryPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserReportHistory] ADD CONSTRAINT [FK_UserReportHistory_ReportCatalog] FOREIGN KEY ([ReportCatalogFK]) REFERENCES [dbo].[ReportCatalog] ([ReportCatalogPK])
GO

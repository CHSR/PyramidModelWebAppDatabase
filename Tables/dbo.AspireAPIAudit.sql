CREATE TABLE [dbo].[AspireAPIAudit]
(
[AspireAPIAuditPK] [int] NOT NULL IDENTITY(1, 1),
[APICall] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CalledBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateCalled] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspireAPIAudit] ADD CONSTRAINT [PK_AspireAPIAudit] PRIMARY KEY CLUSTERED  ([AspireAPIAuditPK]) ON [PRIMARY]
GO

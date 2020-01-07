CREATE TABLE [dbo].[LoginHistory]
(
[LoginHistoryPK] [int] NOT NULL IDENTITY(1, 1),
[LoginTime] [datetime] NOT NULL,
[LogoutTime] [datetime] NULL,
[LogoutType] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Role] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Username] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoginHistory] ADD CONSTRAINT [PK_LoginHistory] PRIMARY KEY CLUSTERED  ([LoginHistoryPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoginHistory] ADD CONSTRAINT [FK_LoginHistory_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO

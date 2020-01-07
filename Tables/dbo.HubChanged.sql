CREATE TABLE [dbo].[HubChanged]
(
[HubChangedPK] [int] NOT NULL IDENTITY(1, 1),
[ChangeDatetime] [datetime] NOT NULL,
[ChangeType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HubPK] [int] NOT NULL,
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EditDate] [datetime] NULL,
[Name] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HubChanged] ADD CONSTRAINT [PK_HubChanged] PRIMARY KEY CLUSTERED  ([HubChangedPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HubChanged_HubPK_ChangeDatetime] ON [dbo].[HubChanged] ([HubPK], [ChangeDatetime] DESC) ON [PRIMARY]
GO

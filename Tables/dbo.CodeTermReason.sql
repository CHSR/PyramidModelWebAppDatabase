CREATE TABLE [dbo].[CodeTermReason]
(
[CodeTermReasonPK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeTermReason] ADD CONSTRAINT [PK_CodeTermReason] PRIMARY KEY CLUSTERED  ([CodeTermReasonPK]) ON [PRIMARY]
GO

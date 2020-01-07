CREATE TABLE [dbo].[TPOTBehaviorResponses]
(
[TPOTBehaviorResponsesPK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[TPOTFK] [int] NOT NULL,
[BehaviorResponseCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [PK_TPOTBehaviorResponses] PRIMARY KEY CLUSTERED  ([TPOTBehaviorResponsesPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [FK_TPOTBehaviorResponses_CodeTPOTBehaviorResponse] FOREIGN KEY ([BehaviorResponseCodeFK]) REFERENCES [dbo].[CodeTPOTBehaviorResponse] ([CodeTPOTBehaviorResponsePK])
GO
ALTER TABLE [dbo].[TPOTBehaviorResponses] ADD CONSTRAINT [FK_TPOTBehaviorResponses_TPOT] FOREIGN KEY ([TPOTFK]) REFERENCES [dbo].[TPOT] ([TPOTPK])
GO

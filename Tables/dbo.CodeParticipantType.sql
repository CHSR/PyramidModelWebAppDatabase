CREATE TABLE [dbo].[CodeParticipantType]
(
[CodeParticipantTypePK] [int] NOT NULL,
[Description] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[OrderBy] [int] NOT NULL,
[StartDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CodeParticipantType] ADD CONSTRAINT [PK_CodeParticipantType] PRIMARY KEY CLUSTERED  ([CodeParticipantTypePK]) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ProgramType]
(
[ProgramTypePK] [int] NOT NULL IDENTITY(1, 1),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TypeCodeFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [PK_ProgramType] PRIMARY KEY CLUSTERED  ([ProgramTypePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [FK_ProgramType_Program] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[Program] ([ProgramPK])
GO
ALTER TABLE [dbo].[ProgramType] ADD CONSTRAINT [FK_ProgramType_TypeCode] FOREIGN KEY ([TypeCodeFK]) REFERENCES [dbo].[CodeProgramType] ([CodeProgramTypePK])
GO

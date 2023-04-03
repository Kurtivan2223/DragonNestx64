USE [DNMembership]
GO

/****** Object:  DdlTrigger [DDL_TRG_SQLSafe]    Script Date: 4/3/2023 7:53:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [DDL_TRG_SQLSafe] ON DATABASE
FOR DDL_TABLE_EVENTS, DDL_VIEW_EVENTS, DDL_INDEX_EVENTS, DDL_FUNCTION_EVENTS, DDL_PROCEDURE_EVENTS, DDL_TRIGGER_EVENTS
AS
SET NOCOUNT ON;

DECLARE
    @xmlData xml,
    @nvcEventType nvarchar(128),
    @nvcObjectName nvarchar(128),
    @nvcStmt nvarchar(4000);

IF CURRENT_USER = N'SPExecutor'
    RETURN;

SET @xmlData = EVENTDATA();
SET @nvcEventType = @xmlData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(128)');
SET @nvcObjectName = @xmlData.value('(EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)');

IF @nvcEventType IN (N'CREATE_PROCEDURE') AND @nvcObjectName NOT LIKE N'sp/_%' ESCAPE(N'/')
BEGIN
    SET @nvcStmt = N'GRANT EXECUTE ON OBJECT::[' + @nvcObjectName + N'] TO [AppServer];'
    EXEC (@nvcStmt);
END;
GO

ENABLE TRIGGER [DDL_TRG_SQLSafe] ON DATABASE
GO

-------------------------------------------------------------------

USE [DNWorld]
GO

/****** Object:  DdlTrigger [DDL_TRG_SQLSafe]    Script Date: 4/3/2023 7:54:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TRIGGER [DDL_TRG_SQLSafe] ON DATABASE
FOR DDL_TABLE_EVENTS, DDL_VIEW_EVENTS, DDL_INDEX_EVENTS, DDL_FUNCTION_EVENTS, DDL_PROCEDURE_EVENTS, DDL_TRIGGER_EVENTS
AS
SET NOCOUNT ON;

DECLARE
	@xmlData xml,
	@nvcInstanceName nvarchar(128),
	@nvcDatabaseName nvarchar(128),
	@nvcLoginName nvarchar(128),
	@nvcHostName nvarchar(128),
	@nvcEventType nvarchar(128),
	@nvcObjectType nvarchar(128),
	@nvcSchemaName nvarchar(128),
	@nvcObjectName nvarchar(128),
	@nvcCommandText nvarchar(max),
	@dtmPostDate datetime,
	@intObjectSN int,
	@intReturnValue int,
	@nvcMessage nvarchar(4000),
	@nvcStmt nvarchar(4000),
	@nvcCurrentUser nvarchar(128),
	@i int,
	@j int,
	@nvcComment nvarchar(max),
	@nvcComment2 nvarchar(4000);

DECLARE @tblTemp table (seq int IDENTITY(1, 1) NOT NULL, stmt nvarchar(4000) NOT NULL);

SET @xmlData = EVENTDATA();

SET @nvcDatabaseName = @xmlData.value('(EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(128)');
SET @nvcLoginName = @xmlData.value('(EVENT_INSTANCE/LoginName)[1]', 'nvarchar(128)');
SET @nvcHostName = HOST_NAME();
SET @nvcEventType = @xmlData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(128)');
SET @nvcObjectType = @xmlData.value('(EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(128)');
SET @nvcSchemaName = @xmlData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'nvarchar(128)');
SET @nvcObjectName = @xmlData.value('(EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)');
SET @nvcCommandText = @xmlData.value('(EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)');
SET @dtmPostDate = @xmlData.value('(EVENT_INSTANCE/PostTime)[1]', 'datetime');

IF @nvcObjectName IN (N'sysdiagrams', N'fn_diagramobjects') OR (@nvcObjectType = N'PROCEDURE' AND @nvcObjectName LIKE N'sp/_%' ESCAPE(N'/'))
BEGIN
	ROLLBACK;
	RAISERROR(N'DB에서 ERD생성을 금지합니다.', 16, 1);
	RETURN
END;

IF APP_NAME() = N'Microsoft SQL Server Management Studio'
BEGIN
	ROLLBACK;
	RAISERROR(N'테이블 디자이너 사용을 금지합니다."', 16, 1);
	RETURN;
END;

IF @nvcEventType IN (N'ALTER_PROCEDURE', N'ALTER_FUNCTION', N'ALTER_TRIGGER')
BEGIN
	ROLLBACK;
	RAISERROR(N'Procedure, Function, Trigger에 대한 ALTER문 사용을 금지합니다.', 16, 1);
	RETURN;
END;

IF @nvcEventType IN (N'CREATE_PROCEDURE', N'CREATE_FUNCTION', N'CREATE_TRIGGER')
BEGIN
	SET @nvcStmt = N'
		GRANT VIEW DEFINITION ON OBJECT::[' + @nvcObjectName + N'] TO [AppServer];
		GRANT VIEW DEFINITION ON OBJECT::[' + @nvcObjectName + N'] TO [Developer];'
	EXEC (@nvcStmt);
END;

IF @nvcEventType IN (N'CREATE_PROCEDURE')
BEGIN
	SET @nvcStmt = N'
		GRANT EXECUTE ON OBJECT::[' + @nvcObjectName + N'] TO [AppServer];
		GRANT EXECUTE ON OBJECT::[' + @nvcObjectName + N'] TO [Developer];'
	EXEC (@nvcStmt);

	SET @i = CHARINDEX(N'description :', @nvcCommandText);
	SET @j = CHARINDEX(N'return value :', @nvcCommandText);

	IF @i = 0 OR @j = 0
		RETURN;

	SET @nvcComment = RTRIM(LTRIM(SUBSTRING(@nvcCommandText, @i + 13, @j - @i - 15)));
	SET @nvcComment2 = @nvcComment;

	EXEC sp_addextendedproperty N'MS_Description', @nvcComment2, N'user', N'dbo', N'procedure', @nvcObjectName

	SET @i = CHARINDEX(N'@', @nvcCommandText, CHARINDEX(N'CREATE PROCEDURE', @nvcCommandText));
	SET @j = CHARINDEX(N'WITH EXECUTE AS', @nvcCommandText);
	SET @i = CASE WHEN @i > @j THEN 0 ELSE @i END;

	IF @i = 0 OR @j = 0
		RETURN;

	SET @nvcComment = REPLACE(REPLACE(SUBSTRING(@nvcCommandText, @i, @j - @i - 2), N'	', N' '), NCHAR(13) + NCHAR(10), NCHAR(1));

	INSERT @tblTemp (stmt)
	SELECT N'EXEC sp_addextendedproperty N''MS_Description'', N''' +
		CASE CHARINDEX(N'--//', string)
			WHEN 0 THEN N''
			ELSE REPLACE(LTRIM(RTRIM(SUBSTRING(string, CHARINDEX(N'--//', string) + 4, DATALENGTH(string) / 2 - CHARINDEX(N'--//', string) - 3))), N'''', N'''''')
		END +
		N''', N''user'', N''dbo'', N''procedure'', N''' + @nvcObjectName + N''', N''parameter'', N''' +
		LTRIM(RTRIM(SUBSTRING(string, CHARINDEX(N'@', string), CHARINDEX(N' ', string, CHARINDEX(N'@', string)) - CHARINDEX(N'@', string)))) +
		N''''
	FROM (
		SELECT ROW_NUMBER() OVER(ORDER BY number) AS seq, SUBSTRING(NCHAR(1) + @nvcComment + NCHAR(1), number + 1, CHARINDEX(NCHAR(1), NCHAR(1) + @nvcComment + NCHAR(1), number + 1) - number - 1) AS string
		FROM master.dbo.spt_values WITH (NOLOCK)
		WHERE [type] = 'P' AND number < (DATALENGTH(NCHAR(1) + @nvcComment + NCHAR(1)) / 2) AND SUBSTRING(NCHAR(1) + @nvcComment + NCHAR(1), number, 1) = NCHAR(1)
	) S
	WHERE LTRIM(RTRIM(REPLACE(string, N'	', N' '))) > N'';

	SELECT @i = 1, @j = @@ROWCOUNT;

	WHILE @i <= @j
	BEGIN
		SELECT @nvcStmt = stmt FROM @tblTemp WHERE seq = @i;

		EXEC (@nvcStmt);

		SET @i = @i + 1;
	END;
END;
GO

ENABLE TRIGGER [DDL_TRG_SQLSafe] ON DATABASE
GO



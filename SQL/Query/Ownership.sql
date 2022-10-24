--SQL 2019 Dev
----------------------------------------------------------------------------

--Creating SQL User
USE [master]
GO
    IF NOT EXISTS (SELECT * FROM [master].[dbo].[syslogins] WHERE name = 'DragonNest') 
    BEGIN 
        EXEC sp_addlogin 'DragonNest', 'E6h7HsRXJbH8ays'  
    END

    IF NOT EXISTS (SELECT * FROM [sysusers] WHERE name = 'DragonNest')
    BEGIN
        EXEC sp_adduser 'DragonNest', 'DragonNest'
    END

    IF NOT EXISTS (SELECT * FROM [master].[dbo].[syslogins] WHERE name = 'SPExecutor') 
    BEGIN 
        EXEC sp_addlogin 'SPExecutor', 'E6h7HsRXJbH8ays'
    END

    IF NOT EXISTS (SELECT * FROM [sysusers] WHERE name = 'SPExecutor')
    BEGIN
        EXEC sp_adduser 'SPExecutor', 'SPExecutor'
    END

    IF NOT EXISTS (SELECT * FROM [master].[dbo].[syslogins] WHERE name = 'GSMAdmin') 
    BEGIN 
        EXEC sp_addlogin 'GSMAdmin', 'E6h7HsRXJbH8ays'
    END

    IF NOT EXISTS (SELECT * FROM [sysusers] WHERE name = 'GSMAdmin')
    BEGIN
        EXEC sp_adduser 'GSMAdmin', 'GSMAdmin'
    END

    IF NOT EXISTS (SELECT * FROM [master].[dbo].[syslogins] WHERE name = 'program_server') 
    BEGIN 
        EXEC sp_addlogin 'program_server', 'E6h7HsRXJbH8ays'
    END

    IF NOT EXISTS (SELECT * FROM [sysusers] WHERE name = 'program_server')
    BEGIN
        EXEC sp_adduser 'program_server', 'program_server'
    END
GO

--Creating user login for Databases
----------------------------------------------------------------------------

USE [DNMembership]
GO
CREATE USER [DragonNest] FOR LOGIN [DragonNest] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNServerLog]
GO
CREATE USER [DragonNest] FOR LOGIN [DragonNest] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNWorld]
GO
CREATE USER [DragonNest] FOR LOGIN [DragonNest] WITH DEFAULT_SCHEMA=[dbo]
GO

--creating SPExecutor user
USE [DNMembership]
GO
CREATE USER [SPExecutor] FOR LOGIN [SPExecutor] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNServerLog]
GO
CREATE USER [SPExecutor] FOR LOGIN [SPExecutor] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNWorld]
GO
CREATE USER [SPExecutor] FOR LOGIN [SPExecutor] WITH DEFAULT_SCHEMA=[dbo]
GO

--creating GSMAdmin user
USE [DNMembership]
GO
CREATE USER [GSMAdmin] FOR LOGIN [GSMAdmin] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNServerLog]
GO
CREATE USER [GSMAdmin] FOR LOGIN [GSMAdmin] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNWorld]
GO
CREATE USER [GSMAdmin] FOR LOGIN [GSMAdmin] WITH DEFAULT_SCHEMA=[dbo]
GO

--creating program_server user
USE [DNMembership]
GO
CREATE USER [program_server] FOR LOGIN [program_server] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNServerLog]
GO
CREATE USER [program_server] FOR LOGIN [program_server] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [DNWorld]
GO
CREATE USER [program_server] FOR LOGIN [program_server] WITH DEFAULT_SCHEMA=[dbo]
GO

--Ownership role
USE [DNMembership]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'SPExecutor'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'GSMAdmin'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'program_server'
GO

USE [DNServerLog]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'SPExecutor'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'GSMAdmin'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'program_server'
GO

USE [DNWorld]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'SPExecutor'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'GSMAdmin'
EXEC [dbo].[sp_addrolemember] 'db_owner', 'program_server'
GO

--If Database already has ownership from previous SQL Server
----------------------------------------------------------------------------
USE [DNMembership]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'SPExecutor', 'SPExecutor'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'GSMAdmin', 'GSMAdmin'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'program_server', 'program_server'
GO

USE [DNServerLog]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'SPExecutor', 'SPExecutor'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'GSMAdmin', 'GSMAdmin'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'program_server', 'program_server'
GO

USE [DNWorld]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'SPExecutor', 'SPExecutor'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'GSMAdmin', 'GSMAdmin'
EXEC [dbo].[sp_change_users_login] 'Update_One', 'program_server', 'program_server'
GO

--Resetting Password
sp_password NULL, 'E6h7HsRXJbH8ays', 'DragonNest';
GO

sp_password NULL, 'E6h7HsRXJbH8ays', 'SPExecutor';
GO

sp_password NULL, 'E6h7HsRXJbH8ays', 'GSMAdmin';
GO

sp_password NULL, 'E6h7HsRXJbH8ays', 'program_server';
GO
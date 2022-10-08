--SQL 2019 Dev
----------------------------------------------------------------------------

--Creating SQL User
use master
go
 if not exists (select * from master.dbo.syslogins where name = 'DragonNest') 
 begin 
  exec sp_addlogin 'DragonNest', 'E6h7HsRXJbH8ays'  
 end

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
CREATE USER [SPExecutor] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[SPExecutor]
GO

USE [DNServerLog]
GO
CREATE USER [SPExecutor] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[SPExecutor]
GO

USE [DNWorld]
GO
CREATE USER [SPExecutor] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[SPExecutor]
GO

--Ownership role
USE [DNMembership]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
GO

USE [DNServerLog]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
GO

USE [DNWorld]
GO
EXEC [dbo].[sp_addrolemember] 'db_owner', 'DragonNest'
GO

--If Database already has ownership from previous SQL Server
----------------------------------------------------------------------------
USE [DNMembership]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
GO

USE [DNServerLog]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
GO

USE [DNWorld]
GO
EXEC [dbo].[sp_change_users_login] 'Update_One', 'DragonNest', 'DragonNest'
GO
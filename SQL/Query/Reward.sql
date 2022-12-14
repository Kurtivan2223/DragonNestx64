USE [dnmembership]
GO
/****** Object:  StoredProcedure [dbo].[P_AddEventReward]    Script Date: 2022/9/29 14:29:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
/**
version : 20
author : 김완건 & 旋转手风琴
e-mail : wgkim@eyedentitygames.com
QQ : 873104974
created date : 2012-08-23
 
description :
	이벤트 보상 입력
return value :
	0 = 에러가 없습니다.
	1 = 트랜잭션을 Commit할 수 없는 상태입니다. 트랜잭션을 Rollback합니다.
	100 = 시스템 에러가 발생하였습니다. dbo.ErrorLogs 테이블을 조회하세요.
	101205 = 이벤트 보상 대상 계정 목록이 없습니다.
	101206 = 이벤트 보상 대상 캐릭터 목록이 없습니다.
	101204 = 이벤트 보상 지급 조건이 없습니다.
	101231 = 이벤트 보상 대상 정보(월드+계정지정) 조건이 없습니다.
	101232 = 이벤트 보상 대상 정보(월드) 조건이 없습니다. 
history :
	5 = TargetTypeCode 2,4,5일 경우에 캐릭터의 레벨, 직업 저장 되도록 수정 by 오윤택 at 2012-09-13
	6 = 아이템 보상 목록의 완료일자는 LifeSpan으로 계산하도록 수정 by 오윤택 at 2012-09-13
	9~11 = input parameter 추가 (@bitAccountRegisterDateCheck) by 김완건 at 2015-08-03
	12~15 = 출석이벤트 보상이 일반우편에서 특수창고로 전환되어 TargetTypeCode에 6번이 추가됩니다. by 박성원 at 2015-11-04
	16~17 = 특수보관함에 월드로 아이템을 지급하는 코드(7번)를 추가합니다. by 박성원 at 2015-11-09 
	18 = 특수 보관함 이후 생성 계정에 대한 선물 지급 추가 by 장경훈 at 2018-08-06
	20 = by旋转手风琴，修复礼物箱不支持PotentialEx问题 at 2022-09-30
**/
  
ALTER PROCEDURE [dbo].[P_AddEventReward]
	  @inyReceiveTypeCode tinyint --// 받기 구분 (1=전체받기, 2=선택받기)
	, @inyTargetTypeCode tinyint --// 대상 구분 (1=계정전체, 2=계정지정, 3=캐릭터전체, 4=캐릭터지정, 5=조건지정, 6=월드+계정지정, 7=월드조건)
	, @xmlAccountIDs xml = NULL --// (@inyTargetTypeCode in (2, 6) 인 경우 사용) 계정 ID 목록   <root><Account AccountID="" /></root>
	, @xmlAccountNames xml = NULL --// (@inyTargetTypeCode in (2, 6) 인 경우 사용) 계정 이름 목록   <root><Account AccountName="" /></root>
	, @xmlCharacterIDs xml = NULL --// (@inyTargetTypeCode=4 인 경우 사용) 캐릭터 ID 목록   <root><Character CharacterID="" /></root>
	, @xmlCharacterNames xml = NULL --// (@inyTargetTypeCode=4 인 경우 사용) 캐릭터 이름 목록   <root><Character CharacterName="" /></root>
	, @inyTargetWorldID tinyint = NULL --// (@inyTargetTypeCode in (5,6,7) 인 경우 사용) 월드 ID
	, @inyTargetClassCode tinyint = NULL --// (@inyTargetTypeCode=5 인 경우 사용) 직업코드 (1=워리어, 2=아처, 3=소서리스, 4=클레릭, 5=아카데믹, 6=칼리)
	, @inyTargetMinLevel tinyint = NULL --// (@inyTargetTypeCode=5 인 경우 사용) 최소 레벨
	, @inyTargetMaxLevel tinyint = NULL --// (@inyTargetTypeCode=5 인 경우 사용) 최대 레벨
	, @inyExpirationDay tinyint = 7 --// 만료일
	, @nvcEventName nvarchar(50) = NULL --// 이벤트 이름
	, @nvcSenderName nvarchar(50) --// 보내는 사람 이름
	, @nvcContent nvarchar(200) --// 내용
	, @inbRewardCoin bigint --// 보상 게임머니
	, @xmlEventRewardItems xml = NULL --// 이벤트 보상 아이템 목록   <root><Item ProductFlag="" ItemID="" ItemCount="" ItemDurability="" RandomSeed="" ItemLevel="" ItemPotential="" SoulBoundFlag="" SealCount="" ItemOption="" ItemLifespan="" EternityFlag=""  DragonJewelType="" PotentialEx=""/></root>
	, @inyEventRewardTypeCode tinyint --// 1=관리자 지급, 2=시스템 이벤트 지급
	, @intEventRewardID int = NULL OUTPUT --// 이벤트 보상 ID
	, @bitAccountRegisterDateCheck bit = 0 --// 계정 생성 일자 체크 여부 (0=체크 안함, 1=체크 함)
	, @inyAccountRegisterDateCheckCode tinyint = NULL --// 1=생성일자체크안함, 2=생성일자체크, 3=신규계정만체크
WITH EXECUTE AS 'SPExecutor'
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
 
DECLARE @intReturnValue int, @sdtNow smalldatetime = GETDATE();
 
/**_# Rollback and return if inside an uncommittable transaction.*/
IF XACT_STATE() = -1
BEGIN
	SET @intReturnValue = 1;
	GOTO ErrorHandler;
END
 
BEGIN TRY
 
	-- @inyTargetTypeCode 값이 (2=계정지정) 이면서 계정 목록이 없는 경우 체크
	IF @inyTargetTypeCode = 2 AND @xmlAccountIDs IS NULL AND @xmlAccountNames IS NULL
	BEGIN
		SET @intReturnValue = 101205;
		GOTO ErrorHandler;
	END
 
	-- @inyTargetTypeCode 값이 (4=캐릭터지정) 이면서 캐릭터 목록이 없는 경우 체크
	IF @inyTargetTypeCode = 4 AND @xmlCharacterIDs IS NULL AND @xmlCharacterNames IS NULL
	BEGIN
		SET @intReturnValue = 101206;
		GOTO ErrorHandler;
	END
 
	-- @inyTargetTypeCode 값이 (5=조건지정) 이면서 지급 조건이 없는 경우 체크
	IF @inyTargetTypeCode = 5 AND @inyTargetWorldID IS NULL AND @inyTargetClassCode IS NULL AND @inyTargetMinLevel IS NULL AND @inyTargetMaxLevel IS NULL
	BEGIN
		SET @intReturnValue = 101204;
		GOTO ErrorHandler;
	END
 
	-- @inyTargetCode 값이 (6=월드+계정지정) 이면서 지급 조건이 없는 경우 체크
	IF @inyTargetTypeCode = 6 AND ((@xmlAccountIDs IS NULL AND @xmlAccountNames IS NULL) OR @inyTargetWorldID IS NULL)
	BEGIN
		SET @intReturnValue = 101231; 
		GOTO ErrorHandler;
	END
 
 	-- @inyTargetCode 값이 (7=월드지정) 이면서 지급 조건이 없는 경우 체크
	IF @inyTargetTypeCode = 7 AND @inyTargetWorldID IS NULL
	BEGIN
		SET @intReturnValue = 101232; 
		GOTO ErrorHandler;
	END
 
 
	/**_# 이벤트 보상 입력 */
	INSERT dbo.EventRewards (ReceiveTypeCode, TargetTypeCode, TargetWorldID, TargetClassCode, TargetMinLevel, TargetMaxLevel, DeleteFlag, RegistrationDate, ReserveSendDate, ExpirationDate, EventName, SenderName, Content, RewardCoin, SystemSendFlag, EventRewardTypeCode, AccountRegisterDateCheck, AccountRegisterDateCheckCode)
	SELECT @inyReceiveTypeCode
		 , @inyTargetTypeCode
		 , CASE WHEN @inyTargetTypeCode IN (2, 4, 5, 6, 7) THEN @inyTargetWorldID ELSE NULL END
		 , CASE WHEN @inyTargetTypeCode IN (2, 4, 5) THEN @inyTargetClassCode ELSE NULL END
		 , CASE WHEN @inyTargetTypeCode IN (2, 4, 5) THEN @inyTargetMinLevel ELSE NULL END
		 , CASE WHEN @inyTargetTypeCode IN (2, 4, 5) THEN @inyTargetMaxLevel ELSE NULL END
		 , CONVERT(bit, 0)
		 , @sdtNow
		 , @sdtNow
		 , DATEADD(DAY, @inyExpirationDay, @sdtNow)
		 , @nvcEventName
		 , @nvcSenderName
		 , @nvcContent
		 , @inbRewardCoin
		 , CONVERT(bit, 1)
		 , @inyEventRewardTypeCode
		 , @bitAccountRegisterDateCheck
		 , @inyAccountRegisterDateCheckCode;
	 
	SET @intEventRewardID = SCOPE_IDENTITY();
 
	/**_# 이벤트 보상 아이템 입력 */
	IF @xmlEventRewardItems IS NOT NULL
	BEGIN
		WITH T AS (
			SELECT T.col.value('@ProductFlag', 'bit') AS ProductFlag
				 , T.col.value('@ItemID', 'bigint') AS ItemID
				 , T.col.value('@ItemCount', 'smallint') AS ItemCount
				 , T.col.value('@ItemDurability', 'smallint') AS ItemDurability
				 , T.col.value('@RandomSeed', 'int') AS RandomSeed
				 , T.col.value('@ItemLevel', 'tinyint') AS ItemLevel
				 , T.col.value('@ItemPotential', 'tinyint') AS ItemPotential
				 , T.col.value('@SoulBoundFlag', 'bit') AS SoulBoundFlag
				 , T.col.value('@SealCount', 'tinyint') AS SealCount
				 , T.col.value('@ItemOption', 'tinyint') AS ItemOption
				 , T.col.value('@ItemLifespan', 'int') AS ItemLifespan
				 , T.col.value('@EternityFlag', 'bit') AS EternityFlag
				 , DATEADD(MINUTE, CASE T.col.value('@EternityFlag', 'bit') WHEN 0 THEN T.col.value('@ItemLifespan', 'int') ELSE 525600 END, @sdtNow) AS ItemExpireDate
				 , T.col.value('@DragonJewelType', 'tinyint') AS DragonJewelType
				 , T.col.value('@PotentialEx', 'varchar(59)') AS PotentialEx
			  FROM @xmlEventRewardItems.nodes('/root/Item') T(col)
		)
		INSERT dbo.EventRewardItems (EventRewardID, ProductFlag, ItemID, ItemCount, ItemDurability, RandomSeed, ItemLevel, ItemPotential, SoulBoundFlag, SealCount, ItemOption, ItemLifespan, EternityFlag, ItemExpireDate, DragonJewelType, PotentialEx)
		SELECT @intEventRewardID
			 , ProductFlag
			 , ItemID
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemCount END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemDurability END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE RandomSeed END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemLevel END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemPotential END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE SoulBoundFlag END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE SealCount END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemOption END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemLifespan END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE EternityFlag END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE ItemExpireDate END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE DragonJewelType END
			 , CASE WHEN ProductFlag = CONVERT(bit, 1) THEN NULL ELSE PotentialEx END
		  FROM T;
	END
 
	/**_# 이벤트 보상 대상 입력 */
	IF @inyTargetTypeCode = 2
	BEGIN
		IF @xmlAccountIDs IS NOT NULL
		BEGIN
			WITH T AS (
				SELECT T.col.value('@AccountID', 'int') AS AccountID
				  FROM @xmlAccountIDs.nodes('/root/Account') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, A.AccountID, NULL, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Accounts A WITH (NOLOCK) ON (T.AccountID = A.AccountID);
		END
		ELSE
		BEGIN
			WITH T AS (
				SELECT T.col.value('@AccountName', 'nvarchar(50)') AS AccountName
				  FROM @xmlAccountNames.nodes('/root/Account') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, A.AccountID, NULL, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Accounts A WITH (NOLOCK) ON (T.AccountName = A.AccountName);
		END
	END
	ELSE IF @inyTargetTypeCode = 4
	BEGIN
		IF @xmlCharacterIDs IS NOT NULL
		BEGIN
			WITH T AS (
				SELECT T.col.value('@CharacterID', 'bigint') AS CharacterID
				  FROM @xmlCharacterIDs.nodes('/root/Character') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, C.AccountID, C.CharacterID, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Characters C WITH (NOLOCK) ON (T.CharacterID = C.CharacterID)
			 WHERE C.DeleteFlag = 0;
		END
		ELSE
		BEGIN
			WITH T AS (
				SELECT T.col.value('@CharacterName', 'nvarchar(30)') AS CharacterName
				  FROM @xmlCharacterNames.nodes('/root/Character') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, C.AccountID, C.CharacterID, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Characters C WITH (NOLOCK) ON (T.CharacterName = C.CharacterName)
			 WHERE C.DeleteFlag = 0
			   AND C.CharacterName IS NOT NULL;
		END
	END
	ELSE IF @inyTargetTypeCode = 6
	BEGIN
		IF @xmlAccountIDs IS NOT NULL
		BEGIN
			WITH T AS (
				SELECT T.col.value('@AccountID', 'int') AS AccountID
				  FROM @xmlAccountIDs.nodes('/root/Account') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, A.AccountID, NULL, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Accounts A WITH (NOLOCK) ON (T.AccountID = A.AccountID);
		END
		ELSE
		BEGIN
			WITH T AS (
				SELECT T.col.value('@AccountName', 'nvarchar(50)') AS AccountName
				  FROM @xmlAccountNames.nodes('/root/Account') T(col)
			)
			INSERT dbo.EventRewardTargets (EventRewardID, AccountID, CharacterID, DeleteFlag)
			SELECT @intEventRewardID, A.AccountID, NULL, CONVERT(bit, 0)
			  FROM T
				   INNER JOIN dbo.Accounts A WITH (NOLOCK) ON (T.AccountName = A.AccountName);
		END
	END
 
END TRY
BEGIN CATCH
	GOTO ErrorHandler;
END CATCH;
 
RETURN 0;
ErrorHandler:
IF XACT_STATE() <> 0
	ROLLBACK TRANSACTION;
 
IF @intReturnValue IS NULL OR @intReturnValue = 0
	EXEC @intReturnValue = dbo.P_AddErrorLog;
 
RETURN @intReturnValue;

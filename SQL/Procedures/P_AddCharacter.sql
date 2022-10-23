/**
version : 45
author : 김도열
e-mail : purumae@eyedentitygames.com
created date : 2010-01-12
description : 캐릭터를 추가합니다.
return value :
0 = 에러가 없습니다.
1 = 트랜잭션을 Commit할 수 없는 상태입니다. 트랜잭션을 Rollback합니다.
100 = 시스템 에러가 발생하였습니다. dbo.ErrorLogs 테이블을 조회하세요.
103150 = 캐릭터의 WorldID와 DB의 담당 World가 일치하지 않습니다.
103185 = 이미 등록된 캐릭터 이름입니다.
history :
24 = WorldID를 선택하여 캐릭터를 생성하도록 수정 at 2010-10-21
27 = (50729) 인덱스 이름 변경으로 인한 수정 by 오윤택 at 2012-01-30
29 = 초보자 길드 가입시 길드ID 반환하도록 수정 by 김원상 at 2012-09-06 
30 ~ 31 = 캐릭터 스타터 아이템이 있을 경우 인벤토리에 넣어주는 로직 추가 by 김원상 at 2013-05-08
32 = 모바일 인증된 계정일 경우 인증 플래그를 넣어주는 로직 추가 by 김원상 at 2013-08-21
33~37 = 다크 어벤저 캐릭터 추가로 인한 @inyCharacterLevel/@intCharacterExp/@insSkillPoint 파라미터 추가 by 이용준 at 2014-12-15
39~41 = 크로니클 캐릭터를 생성하는 구문을 추가합니다. by 박성원 at 2016-01-27
42 = 크로니클 캐릭터 생성일자를 추가합니다. by 박성원 at 2016-04-01
43~44 = 머리 색상 B 타입 컬럼 (HairColorB) 추가. by 장경훈 at 2016-08-02
45 = 아이템 생성시 랜덤으로 결정된 포텐셜 인덱스 컬럼 (PotentialEx) 추가. by 김명규 at 2021-06-15
**/
 
ALTER PROCEDURE [dbo].[P_AddCharacter]
	  @inbCharacterID bigint --// 캐릭터 ID
	, @intAccountID int --// 로그인 계정 ID
	, @nvcAccountName nvarchar(50) --// 로그인 계정 이름
	, @inyAccountLevelCode tinyint --// 0=일반 유저, 10=신입(넥슨), 20=모니터링(넥슨), 30=마스터(넥슨), 99=QA, 100=개발자
	, @intWorldID int --// 월드 ID
	, @nvcCharacterName nvarchar(30) --// 캐릭터 이름
	, @inyCharacterClassCode tinyint --// 1=WARRIER, 2=ARCHER, 3=SOCERESS, 4=CLERIC
	, @inyCharacterIndex tinyint --// 캐릭터 배열 인덱스
	, @intDefaultBody int --// 기본 Body
	, @intDefaultLeg int --// 기본 Leg
	, @intDefaultHand int --// 기본 Hand
	, @intDefaultFoot int --// 기본 Foot
	, @intHairColor int --// 머리 색상
	, @intEyeColor int --// 눈 색상
	, @intSkinColor int --// 피부 색상
	, @intLastMapID int --// 최근 맵 ID
	, @intPositionX int --// X 좌표
	, @intPositionY int --// Y 좌표
	, @intPositionZ int --// Z 좌표
	, @fltRotate float --// 로테이트
	, @inyRebirthCoin tinyint --// 보유 부활 코인
	, @inyPCRoomRebirthCoin tinyint --// PC방 부활 코인
	, @bitBeginnerGuildFlag bit = NULL --// 초보자길드 가입여부
	, @intBeginnerGuildMaxMemberCount int  = NULL--// 초보자길드 가입 최대 인원
	, @nvcBeginnerGuildTitle nvarchar(45) = NULL --// 초보자길드 기본이름
	, @nvcBeginnerGuildMemo nvarchar(200) = NULL --// 초보자길드 소개말		
	, @intJoinedGuildID int = NULL OUTPUT --// 가입된 초보자 길드ID
	, @inyCharacterLevel tinyint = 1 --// 캐릭터 생성 레벨
	, @intCharacterExp int = 0 --// 캐릭터 생성 경험치
	, @insSkillPoint smallint = 0 --// 1레벨이 아닌 캐릭터(다크 캐릭터) 의 초기 스킬 포인트 값
	, @inyChronicleFlag tinyint = NULL --// NULL or 0=일반(크로니클 퀘스트 완료 캐릭터 포함), 1=크로니클캐릭터
	, @intHairColorB int = NULL --// 머리 색상 B
	
WITH EXECUTE AS 'SPExecutor'
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
 
DECLARE @intReturnValue int
	, @dtmNow datetime = GETDATE()
	, @nvcGuildName nvarchar(50)
	, @nvcStmt nvarchar(4000)
	, @bitMobileAuthenticationFlag bit = CAST (0 AS bit)
	, @dtmChronicleCreateDate datetime;
	
/**_# Rollback and return if inside an uncommittable transaction.*/
IF XACT_STATE() = -1
BEGIN
	SET @intReturnValue = 1;
	GOTO ErrorHandler;
END
 
BEGIN TRY
	IF NOT EXISTS (SELECT * FROM dbo.WorldCoverage WITH (NOLOCK) WHERE WorldID = @intWorldID)
	BEGIN
		SET @intReturnValue = 103150;
		GOTO ErrorHandler;
	END
	
	SELECT TOP 1 @bitMobileAuthenticationFlag = ISNULL(MobileAuthenticationFlag, CAST(0 AS bit))
	FROM dbo.Characters WITH (NOLOCK, INDEX(IX_NNI_Characters_AccountID), FORCESEEK)
	WHERE AccountID = @intAccountID
	ORDER BY MobileAuthenticationFlag DESC;
 
 	/**_# 크로니클 캐릭터를 생성할 경우 생성일자를 지정합니다.*/	
	IF @inyChronicleFlag = 1
		SET @dtmChronicleCreateDate = GETDATE()
	ELSE
		SET @dtmChronicleCreateDate = NULL			
 
	BEGIN TRANSACTION;
 
	/**_# [Characters] 테이블에 INSERT합니다.*/	
	INSERT dbo.Characters (CharacterID, AccountID, AccountName, AccountLevelCode, CharacterName, CharacterClassCode, CharacterIndex, VillageFirstVisitFlag, DefaultBody, DefaultLeg, DefaultHand, DefaultFoot, DeleteFlag, SkillResetFlag, WorldID, MobileAuthenticationFlag, ChronicleTypeCode, ChronicleCreateDate)
	VALUES (@inbCharacterID, @intAccountID, @nvcAccountName, @inyAccountLevelCode, @nvcCharacterName, @inyCharacterClassCode, @inyCharacterIndex, 0, @intDefaultBody, @intDefaultLeg, @intDefaultHand, @intDefaultFoot, 0, 0, @intWorldID, @bitMobileAuthenticationFlag, ISNULL(@inyChronicleFlag,0), @dtmChronicleCreateDate);
				
	/**_# [CharacterStatus] 테이블에 INSERT합니다.*/
	INSERT dbo.CharacterStatus (CharacterID, CharacterLevel, CharacterExp, MissionScore, JobCode, HairColor, HairColorB, EyeColor, SkinColor, LastMapID, LastVillageMapID, LastVillageGateNumber, PositionX, PositionY, PositionZ, Rotate, Coin, WarehouseCoin, LastRebirthCoinDate, RebirthCoin, PCRoomRebirthCoin, SkillPoint, LastFatigueDate, Fatigue, PCRoomFatigue, WeeklyFatigue, CheckSumBin, LastDarkLairVillageMapID, ViewCashEquip1Flag, ViewCashEquip2Flag, ViewCashEquipmentBitmap)
	VALUES (@inbCharacterID, 95, @intCharacterExp, 0, @inyCharacterClassCode, @intHairColor, ISNULL(@intHairColorB,@intHairColor), @intEyeColor, @intSkinColor, @intLastMapID, 0, 0, @intPositionX, @intPositionY, @intPositionZ, @fltRotate, 0, 0, CAST(DATEADD(HOUR, 4, DATEADD(DAY, DATEDIFF(DAY, 0, @dtmNow) + CASE WHEN DATEPART(HOUR, @dtmNow) BETWEEN 0 AND 3 THEN 0 ELSE 1 END, 0)) AS smalldatetime), @inyRebirthCoin, @inyPCRoomRebirthCoin, @insSkillPoint, '1900-01-01', 0, 0, 0, 0, 0, 0, 0, 65535);
		
	/**_# [JobChangeLogs] 테이블에 INSERT합니다.*/
	INSERT dbo.JobChangeLogs (CharacterID, JobCode, LogDate)
	VALUES (@inbCharacterID, @inyCharacterClassCode, @dtmNow);
 
	COMMIT TRANSACTION;	

	INSERT INTO dbo.CharacterAwakenForceLevel(CharacterID, AwakenForceLevel)
	VALUES(@inbCharacterID, 1);
	
	--Enable hero skills
	INSERT INTO dbo.CharacterStatus(CharacterID, HeroSkillStep)
	VALUES(@inbCharacterID, 2);
 
	/**_# 초보자 길드에 가입할 경우 가입처리 합니다.*/	
	IF (@bitBeginnerGuildFlag IS NOT NULL AND @bitBeginnerGuildFlag = 1)
	BEGIN
		EXEC P_AddBeginnerGuildMember 
				@inbCharacterID = @inbCharacterID
			  , @inyCharacterLevel = 1
			  , @intGuildMaxMemberCount = @intBeginnerGuildMaxMemberCount
			  , @nvcGuildTitle = @nvcBeginnerGuildTitle
			  , @nvcGuildMemo = @nvcBeginnerGuildMemo
			  , @intJoinedGuildID = @intJoinedGuildID OUTPUT;
	END
 
	/**_# CharacterStarterItem이 있을 경우 지급합니다.*/
	INSERT dbo.MaterializedItems (ItemSerial, ItemID, ItemRemainCount, PayMethodCode, SenderCharacterID, ItemMaterializeCode, ItemMaterializeFKey, ItemDurability, RandomSeed, CoolTime, ItemLevel, ItemPotential, SoulBoundFlag, SealCount, ItemOption, ItemMaterializeDate, ItemLifespan, EternityFlag, ItemExpireDate, OwnerCharacterID, OwnershipStartDate, ExpireCompleteFlag, TradeItemFlag, AdditiveItemID, ItemLocationCode, ItemLocationIndex, ItemPotentialMoveCount, ItemCount, ItemPrice, DragonJewelType, PotentialEx)
	SELECT ABS(CAST(CAST(NEWID() AS binary(8)) AS bigint)), ItemID, ItemCount, 5, NULL, 10, NULL, ItemDurability, RandomSeed, CoolTime, ItemLevel, ItemPotential, SoulBoundFlag, SealCount, ItemOption, @dtmNow, ItemLifespan, EternityFlag, CASE EternityFlag WHEN 0 THEN CASE WHEN ItemLifespan > 0 THEN DATEADD(MINUTE, ItemLifespan, @dtmNow) ELSE DATEADD(YEAR, 1, @dtmNow) END ELSE DATEADD(YEAR, 1, @dtmNow) END, @inbCharacterID, @dtmNow, 0, NULL, NULL, ItemLocationCode, ItemLocationIndex, 0, ItemCount, 0, NULL, PotentialEx
	FROM dbo.CharacterStarterItems WITH (NOLOCK)
	WHERE (ProvideStartDate IS NULL AND ProvideEndDate IS NULL) 
		OR (ProvideStartDate <= @dtmNow AND ProvideEndDate >= @dtmNow)
		OR (ProvideStartDate IS NULL AND ProvideEndDate >= @dtmNow)
		OR (ProvideEndDate IS NULL AND ProvideStartDate <= @dtmNow);	
 
END TRY
BEGIN CATCH
	IF ERROR_NUMBER() = 2601 AND ERROR_MESSAGE() LIKE N'%IX_UNF_Characters_CharacterName%'
		SET @intReturnValue = 103185;
 
	GOTO ErrorHandler;
END CATCH;
 
RETURN 0;
ErrorHandler:
IF XACT_STATE() <> 0
	ROLLBACK TRANSACTION;
 
IF @intReturnValue IS NULL OR @intReturnValue = 0
	EXEC @intReturnValue = dbo.P_AddErrorLog;
 
RETURN @intReturnValue;
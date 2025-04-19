if exists (select * from sysobjects where id = object_id(N'[dbo].[AllianceScores]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[AllianceScores]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[BattleScores]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[BattleScores]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[multies]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[multies]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[ThePMessages]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[ThePMessages]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[aidLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[aidLog]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[aiPlayer]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[aiPlayer]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[Alliance]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Alliance]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[attackNews]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[attackNews]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[attackQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[attackQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[autoLocalTrade]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[autoLocalTrade]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[blockMessages]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[blockMessages]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[buildQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[buildQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[exploreQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[exploreQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[ForumMessage]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ForumMessage]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[ForumTopic]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[ForumTopic]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[gameLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[gameLog]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[gameNews]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[gameNews]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[loginEntry]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[loginEntry]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[Player]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[Player]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[PlayerMessage]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[PlayerMessage]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[tradeQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tradeQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[trainQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[trainQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[transferQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[transferQueue]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[vote]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[vote]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[voteAnswer]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[voteAnswer]
GO

if exists (select * from sysobjects where id = object_id(N'[dbo].[voteChoice]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[voteChoice]
GO

CREATE TABLE [dbo].[aidLog] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[fromPlayerID] [int] NULL ,
	[toPlayerID] [int] NULL ,
	[wood] [int] NULL ,
	[food] [int] NULL ,
	[iron] [int] NULL ,
	[gold] [int] NULL ,
	[swords] [int] NULL ,
	[bows] [int] NULL ,
	[horses] [int] NULL ,
	[tools] [int] NULL ,
	[maces] [int] NULL ,
	[createdOn] [datetime] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[aiPlayer] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Alliance] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[name] [nvarchar] (50) NULL ,
	[tag] [nvarchar] (20) NULL ,
	[ally1] [int] NULL ,
	[ally2] [int] NULL ,
	[ally3] [int] NULL ,
	[war1] [int] NULL ,
	[war2] [int] NULL ,
	[war3] [int] NULL ,
	[leaderID] [int] NULL ,
	[passwd] [nvarchar] (20) NULL ,
	[news] [ntext] NULL ,
	[ally4] [int] NULL ,
	[ally5] [int] NULL ,
	[war4] [int] NULL ,
	[war5] [int] NULL ,
	[description] [text] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[attackNews] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[attackID] [int] NULL ,
	[defenseID] [int] NULL ,
	[attackSwordsman] [int] NULL ,
	[attackHorseman] [int] NULL ,
	[attackArchers] [int] NULL ,
	[defenseSwordsman] [int] NULL ,
	[defenseHorseman] [int] NULL ,
	[defenseArchers] [int] NULL ,
	[message] [ntext] NULL ,
	[createdOn] [smalldatetime] NULL ,
	[attackerWins] [int] NULL ,
	[deleted] [int] NULL ,
	[attackAlliance] [nvarchar] (50) NULL ,
	[defenseAlliance] [nvarchar] (50) NULL ,
	[attackMacemen] [int] NULL ,
	[attackCatapults] [int] NULL ,
	[attackPeasants] [int] NULL ,
	[attackThieves] [int] NULL ,
	[defenseMacemen] [int] NULL ,
	[defensePeasants] [int] NULL ,
	[defenseCatapults] [int] NULL ,
	[defenseThieves] [int] NULL ,
	[battleDetails] [text] NULL ,
	[attackAllianceID] [int] NULL ,
	[defenseAllianceID] [int] NULL ,
	[attackUunit] [int] NULL ,
	[defenseUunit] [int] NULL ,
	[attackType] [int] NULL ,
	[debugInfo] [text] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[attackQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[attackPlayerID] [int] NULL ,
	[swordsman] [int] NULL ,
	[archers] [int] NULL ,
	[horseman] [int] NULL ,
	[turn] [int] NULL ,
	[status] [int] NULL ,
	[attackType] [int] NULL ,
	[catapults] [int] NULL ,
	[macemen] [int] NULL ,
	[trainedPeasants] [int] NULL ,
	[thieves] [int] NULL ,
	[uunit] [int] NULL ,
	[costWine] [numeric](18, 0) NULL ,
	[costFood] [numeric](18, 0) NULL ,
	[costGold] [numeric](18, 0) NULL ,
	[costWood] [numeric](18, 0) NULL ,
	[costIron] [numeric](18, 0) NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[autoLocalTrade] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[tradeWood] [int] NULL ,
	[tradeIron] [int] NULL ,
	[tradeFood] [int] NULL ,
	[tradeTools] [int] NULL ,
	[tradeType] [int] NULL ,
	[playerID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[blockMessages] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[blockPlayerID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[buildQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[turnAdded] [int] NULL ,
	[iron] [int] NULL ,
	[wood] [int] NULL ,
	[gold] [int] NULL ,
	[buildingNo] [int] NULL ,
	[mission] [int] NULL ,
	[pos] [int] NULL ,
	[qty] [int] NULL ,
	[timeNeeded] [int] NULL ,
	[onHold] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[exploreQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[turn] [int] NULL ,
	[people] [int] NULL ,
	[food] [numeric](18, 0) NULL ,
	[mLand] [int] NULL ,
	[pLand] [int] NULL ,
	[fLand] [int] NULL ,
	[seekLand] [int] NULL ,
	[createdOn] [datetime] NULL ,
	[horses] [int] NULL ,
	[turnsUsed] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ForumMessage] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[topicID] [int] NULL ,
	[allianceID] [int] NULL ,
	[createdOn] [datetime] NULL ,
	[createdBy] [varchar] (60) NULL ,
	[playerID] [int] NULL ,
	[message] [text] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[ForumTopic] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[allianceID] [int] NULL ,
	[topic] [varchar] (80) NULL ,
	[author] [varchar] (60) NULL ,
	[createdOn] [datetime] NULL ,
	[messageCount] [int] NULL ,
	[lastPostOn] [datetime] NULL ,
	[lastPostBy] [varchar] (60) NULL ,
	[playerID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[gameLog] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[createdOn] [datetime] NULL ,
	[numOn] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[gameNews] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[createdOn] [datetime] NULL ,
	[message] [text] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[loginEntry] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[createdOn] [datetime] NULL ,
	[playerID] [int] NULL ,
	[IPAddress] [nvarchar] (20) NULL ,
	[http_referer] [nvarchar] (50) NULL ,
	[http_user_agent] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Player] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[Name] [nvarchar] (50) NULL ,
	[score] [numeric](18, 0) NULL ,
	[woodCutter] [int] NULL ,
	[Hunter] [int] NULL ,
	[Farmer] [int] NULL ,
	[House] [int] NULL ,
	[IronMine] [int] NULL ,
	[GoldMine] [int] NULL ,
	[ToolMaker] [int] NULL ,
	[WeaponSmith] [int] NULL ,
	[Fort] [int] NULL ,
	[Tower] [int] NULL ,
	[TownCenter] [int] NULL ,
	[Market] [int] NULL ,
	[Warehouse] [int] NULL ,
	[Stable] [int] NULL ,
	[FLand] [int] NULL ,
	[MLand] [int] NULL ,
	[PLand] [int] NULL ,
	[swordsman] [int] NULL ,
	[archers] [int] NULL ,
	[horseman] [int] NULL ,
	[people] [numeric](18, 0) NULL ,
	[wood] [numeric](18, 0) NULL ,
	[food] [numeric](18, 0) NULL ,
	[iron] [numeric](18, 0) NULL ,
	[gold] [numeric](18, 0) NULL ,
	[tools] [numeric](18, 0) NULL ,
	[bows] [int] NULL ,
	[swords] [int] NULL ,
	[horses] [int] NULL ,
	[turn] [int] NULL ,
	[lastTurn] [smalldatetime] NULL ,
	[turnsFree] [int] NULL ,
	[builder] [int] NULL ,
	[bowWeaponSmith] [int] NULL ,
	[swordWeaponSmith] [int] NULL ,
	[passwd] [nvarchar] (50) NULL ,
	[email] [nvarchar] (50) NULL ,
	[message] [ntext] NULL ,
	[isAdmin] [int] NULL ,
	[civ] [int] NULL ,
	[tradesThisTurn] [int] NULL ,
	[numAttacks] [int] NULL ,
	[lastAttack] [smalldatetime] NULL ,
	[militaryScore] [int] NULL ,
	[landScore] [int] NULL ,
	[goodScore] [int] NULL ,
	[autoSellWood] [int] NULL ,
	[autoBuyWood] [int] NULL ,
	[autoSellFood] [int] NULL ,
	[autoBuyFood] [int] NULL ,
	[autoSellIron] [int] NULL ,
	[autoBuyIron] [int] NULL ,
	[autoSellTools] [int] NULL ,
	[autoBuyTools] [int] NULL ,
	[lastLoad] [smalldatetime] NULL ,
	[allianceID] [int] NULL ,
	[hasAllianceNews] [int] NULL ,
	[loginName] [nvarchar] (50) NULL ,
	[hasMainNews] [int] NULL ,
	[hunterStatus] [int] NULL ,
	[farmerStatus] [int] NULL ,
	[ironMineStatus] [int] NULL ,
	[goldMineStatus] [int] NULL ,
	[toolMakerStatus] [int] NULL ,
	[weaponSmithStatus] [int] NULL ,
	[stableStatus] [int] NULL ,
	[woodCutterStatus] [int] NULL ,
	[catapults] [int] NULL ,
	[macemen] [int] NULL ,
	[maces] [int] NULL ,
	[trainedPeasants] [int] NULL ,
	[maceWeaponsmith] [int] NULL ,
	[thieves] [int] NULL ,
	[research1] [int] NULL ,
	[research2] [int] NULL ,
	[research3] [int] NULL ,
	[research4] [int] NULL ,
	[research5] [int] NULL ,
	[research6] [int] NULL ,
	[research7] [int] NULL ,
	[research8] [int] NULL ,
	[research9] [int] NULL ,
	[research10] [int] NULL ,
	[currentResearch] [int] NULL ,
	[mageTower] [int] NULL ,
	[mageTowerStatus] [int] NULL ,
	[researchPoints] [numeric](18, 0) NULL ,
	[allianceMemberType] [int] NULL ,
	[uunit] [int] NULL ,
	[foodRatio] [int] NULL ,
	[killedBy] [int] NULL ,
	[killedByName] [varchar] (50) NULL ,
	[hasNewMessages] [bit] NOT NULL ,
	[validationCode] [varchar] (50) NULL ,
	[createdOn] [datetime] NULL ,
	[research11] [int] NULL ,
	[research12] [int] NULL ,
	[winery] [int] NULL ,
	[wine] [numeric](18, 0) NULL ,
	[wineryStatus] [int] NULL ,
	[wall] [int] NULL ,
	[wallBuildPerTurn] [int] NULL ,
	[validated] [int] NULL ,
	[hasAllianceMessages] [int] NULL ,
	[vacationEnd] [datetime] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[PlayerMessage] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[fromPlayerID] [int] NULL ,
	[toPlayerID] [int] NULL ,
	[fromPlayerName] [nvarchar] (50) NULL ,
	[toPlayerName] [nvarchar] (50) NULL ,
	[message] [ntext] NULL ,
	[viewed] [int] NULL ,
	[createdOn] [smalldatetime] NULL ,
	[messageType] [int] NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[tradeQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[wood] [int] NULL ,
	[food] [int] NULL ,
	[iron] [int] NULL ,
	[tools] [int] NULL ,
	[swords] [int] NULL ,
	[bows] [int] NULL ,
	[horses] [int] NULL ,
	[cityID] [int] NULL ,
	[totalGoods] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[trainQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[playerID] [int] NULL ,
	[soldierType] [int] NULL ,
	[turnsRemaining] [int] NULL ,
	[qty] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[transferQueue] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[fromPlayerID] [int] NULL ,
	[toPlayerID] [int] NULL ,
	[wood] [int] NULL ,
	[food] [int] NULL ,
	[iron] [int] NULL ,
	[gold] [int] NULL ,
	[swords] [int] NULL ,
	[bows] [int] NULL ,
	[horses] [int] NULL ,
	[tools] [int] NULL ,
	[transferType] [int] NULL ,
	[turnsRemaining] [int] NULL ,
	[woodPrice] [int] NULL ,
	[ironPrice] [int] NULL ,
	[foodPrice] [int] NULL ,
	[toolsPrice] [int] NULL ,
	[swordsPrice] [int] NULL ,
	[bowsPrice] [int] NULL ,
	[horsesPrice] [int] NULL ,
	[maces] [int] NULL ,
	[macesPrice] [int] NULL ,
	[createdOn] [datetime] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[vote] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[question] [varchar] (200) NULL ,
	[createdOn] [datetime] NULL ,
	[status] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[voteAnswer] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[voteID] [int] NULL ,
	[playerID] [int] NULL ,
	[createdOn] [datetime] NULL ,
	[choiceID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[voteChoice] (
	[id] [int] IDENTITY (1, 1) NOT NULL ,
	[voteID] [int] NULL ,
	[choice] [varchar] (200) NULL ,
	[pos] [int] NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[aidLog] WITH NOCHECK ADD 
	CONSTRAINT [PK_aidLog] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[aiPlayer] WITH NOCHECK ADD 
	CONSTRAINT [PK_aiPlayer] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Alliance] WITH NOCHECK ADD 
	CONSTRAINT [DF_Alliance_ally1] DEFAULT (0) FOR [ally1],
	CONSTRAINT [DF_Alliance_ally2] DEFAULT (0) FOR [ally2],
	CONSTRAINT [DF_Alliance_ally3] DEFAULT (0) FOR [ally3],
	CONSTRAINT [DF_Alliance_war1] DEFAULT (0) FOR [war1],
	CONSTRAINT [DF_Alliance_war2] DEFAULT (0) FOR [war2],
	CONSTRAINT [DF_Alliance_war3] DEFAULT (0) FOR [war3],
	CONSTRAINT [DF_Alliance_leaderID] DEFAULT (0) FOR [leaderID],
	CONSTRAINT [DF_Alliance_ally4] DEFAULT (0) FOR [ally4],
	CONSTRAINT [DF_Alliance_ally5] DEFAULT (0) FOR [ally5],
	CONSTRAINT [DF_Alliance_war4] DEFAULT (0) FOR [war4],
	CONSTRAINT [DF_Alliance_war5] DEFAULT (0) FOR [war5],
	CONSTRAINT [PK_Alliance] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[attackNews] WITH NOCHECK ADD 
	CONSTRAINT [DF_attackNews_attackID] DEFAULT (0) FOR [attackID],
	CONSTRAINT [DF_attackNews_defenseID] DEFAULT (0) FOR [defenseID],
	CONSTRAINT [DF_attackNews_attackSwordsman] DEFAULT (0) FOR [attackSwordsman],
	CONSTRAINT [DF_attackNews_attackHorseman] DEFAULT (0) FOR [attackHorseman],
	CONSTRAINT [DF_attackNews_attackArchers] DEFAULT (0) FOR [attackArchers],
	CONSTRAINT [DF_attackNews_defenseSwordsman] DEFAULT (0) FOR [defenseSwordsman],
	CONSTRAINT [DF_attackNews_defenseHorseman] DEFAULT (0) FOR [defenseHorseman],
	CONSTRAINT [DF_attackNews_defenseArchers] DEFAULT (0) FOR [defenseArchers],
	CONSTRAINT [DF_attackNews_attackerWins] DEFAULT (0) FOR [attackerWins],
	CONSTRAINT [DF_attackNews_deleted] DEFAULT (0) FOR [deleted],
	CONSTRAINT [DF__attackNew__attac__23F3538A] DEFAULT (0) FOR [attackMacemen],
	CONSTRAINT [DF__attackNew__attac__24E777C3] DEFAULT (0) FOR [attackCatapults],
	CONSTRAINT [DF__attackNew__attac__25DB9BFC] DEFAULT (0) FOR [attackPeasants],
	CONSTRAINT [DF__attackNew__attac__26CFC035] DEFAULT (0) FOR [attackThieves],
	CONSTRAINT [DF__attackNew__defen__27C3E46E] DEFAULT (0) FOR [defenseMacemen],
	CONSTRAINT [DF__attackNew__defen__28B808A7] DEFAULT (0) FOR [defensePeasants],
	CONSTRAINT [DF__attackNew__defen__29AC2CE0] DEFAULT (0) FOR [defenseCatapults],
	CONSTRAINT [DF__attackNew__defen__2AA05119] DEFAULT (0) FOR [defenseThieves],
	CONSTRAINT [DF_attackNews_attackAllianceID] DEFAULT (0) FOR [attackAllianceID],
	CONSTRAINT [DF_attackNews_defenseAllianceID] DEFAULT (0) FOR [defenseAllianceID],
	CONSTRAINT [DF_attackNews_attackUunit] DEFAULT (0) FOR [attackUunit],
	CONSTRAINT [DF_attackNews_defenseUunit] DEFAULT (0) FOR [defenseUunit],
	CONSTRAINT [DF_attackNews_attackType] DEFAULT (0) FOR [attackType],
	CONSTRAINT [PK_attackNews] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[attackQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_attackQueue_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [DF_attackQueue_attackPlayerID] DEFAULT (0) FOR [attackPlayerID],
	CONSTRAINT [DF_attackQueue_swordsman] DEFAULT (0) FOR [swordsman],
	CONSTRAINT [DF_attackQueue_archers] DEFAULT (0) FOR [archers],
	CONSTRAINT [DF_attackQueue_horseman] DEFAULT (0) FOR [horseman],
	CONSTRAINT [DF_attackQueue_turn] DEFAULT (0) FOR [turn],
	CONSTRAINT [DF_attackQueue_status] DEFAULT (0) FOR [status],
	CONSTRAINT [DF_attackQueue_attackType] DEFAULT (0) FOR [attackType],
	CONSTRAINT [DF__attackQue__catap__2B947552] DEFAULT (0) FOR [catapults],
	CONSTRAINT [DF__attackQue__macem__2C88998B] DEFAULT (0) FOR [macemen],
	CONSTRAINT [DF__attackQue__train__2D7CBDC4] DEFAULT (0) FOR [trainedPeasants],
	CONSTRAINT [DF__attackQue__thiev__2E70E1FD] DEFAULT (0) FOR [thieves],
	CONSTRAINT [DF_attackQueue_uunit] DEFAULT (0) FOR [uunit],
	CONSTRAINT [DF_attackQueue_wine] DEFAULT (0) FOR [costWine],
	CONSTRAINT [DF_attackQueue_costFood] DEFAULT (0) FOR [costFood],
	CONSTRAINT [DF_attackQueue_costGold] DEFAULT (0) FOR [costGold],
	CONSTRAINT [DF_attackQueue_costWood] DEFAULT (0) FOR [costWood],
	CONSTRAINT [DF_attackQueue_costIron] DEFAULT (0) FOR [costIron],
	CONSTRAINT [PK_attackQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[autoLocalTrade] WITH NOCHECK ADD 
	CONSTRAINT [DF_autoLocalTrade_tradeWood] DEFAULT (0) FOR [tradeWood],
	CONSTRAINT [DF_autoLocalTrade_tradeIron] DEFAULT (0) FOR [tradeIron],
	CONSTRAINT [DF_autoLocalTrade_tradeFood] DEFAULT (0) FOR [tradeFood],
	CONSTRAINT [DF_autoLocalTrade_tradeTools] DEFAULT (0) FOR [tradeTools],
	CONSTRAINT [DF_autoLocalTrade_tradeType] DEFAULT (0) FOR [tradeType],
	CONSTRAINT [DF_autoLocalTrade_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [PK_autoLocalTrade] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[blockMessages] WITH NOCHECK ADD 
	CONSTRAINT [PK_blockMessages] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[buildQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_buildQueue_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [DF_buildQueue_turnAdded] DEFAULT (0) FOR [turnAdded],
	CONSTRAINT [DF_buildQueue_iron] DEFAULT (0) FOR [iron],
	CONSTRAINT [DF_buildQueue_wood] DEFAULT (0) FOR [wood],
	CONSTRAINT [DF_buildQueue_gold] DEFAULT (0) FOR [gold],
	CONSTRAINT [DF_buildQueue_buildingNo] DEFAULT (0) FOR [buildingNo],
	CONSTRAINT [DF_buildQueue_mission] DEFAULT (0) FOR [mission],
	CONSTRAINT [DF_buildQueue_pos] DEFAULT (0) FOR [pos],
	CONSTRAINT [DF_buildQueue_qty] DEFAULT (0) FOR [qty],
	CONSTRAINT [DF_buildQueue_timeNeeded] DEFAULT (0) FOR [timeNeeded],
	CONSTRAINT [DF_buildQueue_onHold] DEFAULT (0) FOR [onHold],
	CONSTRAINT [PK_buildQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[exploreQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_exploreQueue_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [DF_exploreQueue_turn] DEFAULT (0) FOR [turn],
	CONSTRAINT [DF_exploreQueue_people] DEFAULT (0) FOR [people],
	CONSTRAINT [DF_exploreQueue_food] DEFAULT (0) FOR [food],
	CONSTRAINT [DF_exploreQueue_mLand] DEFAULT (0) FOR [mLand],
	CONSTRAINT [DF_exploreQueue_pLand] DEFAULT (0) FOR [pLand],
	CONSTRAINT [DF_exploreQueue_fLand] DEFAULT (0) FOR [fLand],
	CONSTRAINT [DF__exploreQu__seekL__2F650636] DEFAULT (0) FOR [seekLand],
	CONSTRAINT [DF_exploreQueue_horses] DEFAULT (0) FOR [horses],
	CONSTRAINT [DF_exploreQueue_turnsUsed] DEFAULT (0) FOR [turnsUsed],
	CONSTRAINT [PK_exploreQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[ForumMessage] WITH NOCHECK ADD 
	CONSTRAINT [PK_ForumMessage] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[ForumTopic] WITH NOCHECK ADD 
	CONSTRAINT [PK_ForumTopic] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[gameLog] WITH NOCHECK ADD 
	CONSTRAINT [PK_gameLog] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[gameNews] WITH NOCHECK ADD 
	CONSTRAINT [PK_gameNews] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[loginEntry] WITH NOCHECK ADD 
	CONSTRAINT [PK_loginEntry] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Player] WITH NOCHECK ADD 
	CONSTRAINT [DF_Player_score] DEFAULT (0) FOR [score],
	CONSTRAINT [DF_Player_woodCutter] DEFAULT (0) FOR [woodCutter],
	CONSTRAINT [DF_Player_Hunter] DEFAULT (0) FOR [Hunter],
	CONSTRAINT [DF_Player_Farmer] DEFAULT (0) FOR [Farmer],
	CONSTRAINT [DF_Player_House] DEFAULT (0) FOR [House],
	CONSTRAINT [DF_Player_IronMine] DEFAULT (0) FOR [IronMine],
	CONSTRAINT [DF_Player_GoldMine] DEFAULT (0) FOR [GoldMine],
	CONSTRAINT [DF_Player_ToolMaker] DEFAULT (0) FOR [ToolMaker],
	CONSTRAINT [DF_Player_WeaponSmith] DEFAULT (0) FOR [WeaponSmith],
	CONSTRAINT [DF_Player_Fort] DEFAULT (0) FOR [Fort],
	CONSTRAINT [DF_Player_Tower] DEFAULT (0) FOR [Tower],
	CONSTRAINT [DF_Player_TownCenter] DEFAULT (0) FOR [TownCenter],
	CONSTRAINT [DF_Player_Market] DEFAULT (0) FOR [Market],
	CONSTRAINT [DF_Player_Warehouse] DEFAULT (0) FOR [Warehouse],
	CONSTRAINT [DF_Player_Stable] DEFAULT (0) FOR [Stable],
	CONSTRAINT [DF_Player_FLand] DEFAULT (0) FOR [FLand],
	CONSTRAINT [DF_Player_MLand] DEFAULT (0) FOR [MLand],
	CONSTRAINT [DF_Player_PLand] DEFAULT (0) FOR [PLand],
	CONSTRAINT [DF_Player_swordsman] DEFAULT (0) FOR [swordsman],
	CONSTRAINT [DF_Player_archers] DEFAULT (0) FOR [archers],
	CONSTRAINT [DF_Player_horseman] DEFAULT (0) FOR [horseman],
	CONSTRAINT [DF_Player_people] DEFAULT (0) FOR [people],
	CONSTRAINT [DF_Player_wood] DEFAULT (0) FOR [wood],
	CONSTRAINT [DF_Player_food] DEFAULT (0) FOR [food],
	CONSTRAINT [DF_Player_iron] DEFAULT (0) FOR [iron],
	CONSTRAINT [DF_Player_gold] DEFAULT (0) FOR [gold],
	CONSTRAINT [DF_Player_tools] DEFAULT (0) FOR [tools],
	CONSTRAINT [DF_Player_bows] DEFAULT (0) FOR [bows],
	CONSTRAINT [DF_Player_swords] DEFAULT (0) FOR [swords],
	CONSTRAINT [DF_Player_horses] DEFAULT (0) FOR [horses],
	CONSTRAINT [DF_Player_turn] DEFAULT (0) FOR [turn],
	CONSTRAINT [DF_Player_turnsFree] DEFAULT (0) FOR [turnsFree],
	CONSTRAINT [DF_Player_builder] DEFAULT (0) FOR [builder],
	CONSTRAINT [DF_Player_bowWeaponSmith] DEFAULT (0) FOR [bowWeaponSmith],
	CONSTRAINT [DF_Player_swordWeaponSmith] DEFAULT (0) FOR [swordWeaponSmith],
	CONSTRAINT [DF_Player_isAdmin] DEFAULT (0) FOR [isAdmin],
	CONSTRAINT [DF_Player_civ] DEFAULT (0) FOR [civ],
	CONSTRAINT [DF_Player_tradesThisTurn] DEFAULT (0) FOR [tradesThisTurn],
	CONSTRAINT [DF_Player_numAttacks] DEFAULT (0) FOR [numAttacks],
	CONSTRAINT [DF_Player_militaryScore] DEFAULT (0) FOR [militaryScore],
	CONSTRAINT [DF_Player_landScore] DEFAULT (0) FOR [landScore],
	CONSTRAINT [DF_Player_goodScore] DEFAULT (0) FOR [goodScore],
	CONSTRAINT [DF_Player_autoSellWood] DEFAULT (0) FOR [autoSellWood],
	CONSTRAINT [DF_Player_autoBuyWood] DEFAULT (0) FOR [autoBuyWood],
	CONSTRAINT [DF_Player_autoSellFood] DEFAULT (0) FOR [autoSellFood],
	CONSTRAINT [DF_Player_autoBuyFood] DEFAULT (0) FOR [autoBuyFood],
	CONSTRAINT [DF_Player_autoSellIron] DEFAULT (0) FOR [autoSellIron],
	CONSTRAINT [DF_Player_autoBuyIron] DEFAULT (0) FOR [autoBuyIron],
	CONSTRAINT [DF_Player_autoSellTools] DEFAULT (0) FOR [autoSellTools],
	CONSTRAINT [DF_Player_autoBuyTools] DEFAULT (0) FOR [autoBuyTools],
	CONSTRAINT [DF_Player_allianceID] DEFAULT (0) FOR [allianceID],
	CONSTRAINT [DF_Player_hasAllianceNews] DEFAULT (0) FOR [hasAllianceNews],
	CONSTRAINT [DF_Player_hasMainNews] DEFAULT (0) FOR [hasMainNews],
	CONSTRAINT [DF__Player__hunterSt__30592A6F] DEFAULT (0) FOR [hunterStatus],
	CONSTRAINT [DF__Player__farmerSt__314D4EA8] DEFAULT (0) FOR [farmerStatus],
	CONSTRAINT [DF__Player__ironMine__324172E1] DEFAULT (0) FOR [ironMineStatus],
	CONSTRAINT [DF__Player__goldMine__3335971A] DEFAULT (0) FOR [goldMineStatus],
	CONSTRAINT [DF__Player__toolMake__3429BB53] DEFAULT (0) FOR [toolMakerStatus],
	CONSTRAINT [DF__Player__weaponSm__351DDF8C] DEFAULT (0) FOR [weaponSmithStatus],
	CONSTRAINT [DF__Player__stableSt__361203C5] DEFAULT (0) FOR [stableStatus],
	CONSTRAINT [DF__Player__woodCutt__370627FE] DEFAULT (0) FOR [woodCutterStatus],
	CONSTRAINT [DF__Player__catapult__37FA4C37] DEFAULT (0) FOR [catapults],
	CONSTRAINT [DF__Player__macemen__38EE7070] DEFAULT (0) FOR [macemen],
	CONSTRAINT [DF__Player__maces__39E294A9] DEFAULT (0) FOR [maces],
	CONSTRAINT [DF__Player__trainedP__3AD6B8E2] DEFAULT (0) FOR [trainedPeasants],
	CONSTRAINT [DF__Player__maceWeap__3BCADD1B] DEFAULT (0) FOR [maceWeaponsmith],
	CONSTRAINT [DF__Player__thieves__3CBF0154] DEFAULT (0) FOR [thieves],
	CONSTRAINT [DF_Player_research1] DEFAULT (0) FOR [research1],
	CONSTRAINT [DF_Player_research2] DEFAULT (0) FOR [research2],
	CONSTRAINT [DF_Player_research3] DEFAULT (0) FOR [research3],
	CONSTRAINT [DF_Player_research4] DEFAULT (0) FOR [research4],
	CONSTRAINT [DF_Player_research5] DEFAULT (0) FOR [research5],
	CONSTRAINT [DF_Player_research6] DEFAULT (0) FOR [research6],
	CONSTRAINT [DF_Player_research7] DEFAULT (0) FOR [research7],
	CONSTRAINT [DF_Player_research8] DEFAULT (0) FOR [research8],
	CONSTRAINT [DF_Player_research9] DEFAULT (0) FOR [research9],
	CONSTRAINT [DF_Player_research10] DEFAULT (0) FOR [research10],
	CONSTRAINT [DF_Player_currentResearch] DEFAULT (0) FOR [currentResearch],
	CONSTRAINT [DF_Player_mageTower] DEFAULT (0) FOR [mageTower],
	CONSTRAINT [DF_Player_mageTowerStatus] DEFAULT (0) FOR [mageTowerStatus],
	CONSTRAINT [DF_Player_researchPoints] DEFAULT (0) FOR [researchPoints],
	CONSTRAINT [DF_Player_allianceMemberType] DEFAULT (0) FOR [allianceMemberType],
	CONSTRAINT [DF_Player_uunit] DEFAULT (0) FOR [uunit],
	CONSTRAINT [DF_Player_foodRatio] DEFAULT (0) FOR [foodRatio],
	CONSTRAINT [DF_Player_killedBy] DEFAULT (0) FOR [killedBy],
	CONSTRAINT [DF_Player_hasNewMessages] DEFAULT (0) FOR [hasNewMessages],
	CONSTRAINT [DF_Player_research11] DEFAULT (0) FOR [research11],
	CONSTRAINT [DF_Player_research12] DEFAULT (0) FOR [research12],
	CONSTRAINT [DF_Player_winery] DEFAULT (0) FOR [winery],
	CONSTRAINT [DF_Player_wine] DEFAULT (0) FOR [wine],
	CONSTRAINT [DF_Player_wineryStatus] DEFAULT (0) FOR [wineryStatus],
	CONSTRAINT [DF_Player_wall] DEFAULT (0) FOR [wall],
	CONSTRAINT [DF_Player_walluseWood] DEFAULT (0) FOR [wallBuildPerTurn],
	CONSTRAINT [DF_Player_validated] DEFAULT (0) FOR [validated],
	CONSTRAINT [DF_Player_hasAllianceMessages] DEFAULT (0) FOR [hasAllianceMessages],
	CONSTRAINT [PK_Player] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PlayerMessage] WITH NOCHECK ADD 
	CONSTRAINT [DF_PlayerMessage_fromPlayerID] DEFAULT (0) FOR [fromPlayerID],
	CONSTRAINT [DF_PlayerMessage_toPlayerID] DEFAULT (0) FOR [toPlayerID],
	CONSTRAINT [DF_PlayerMessage_viewed] DEFAULT (0) FOR [viewed],
	CONSTRAINT [DF_PlayerMessage_messageType] DEFAULT (0) FOR [messageType],
	CONSTRAINT [PK_PlayerMessage] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[tradeQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_tradeQueue_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [DF_tradeQueue_wood] DEFAULT (0) FOR [wood],
	CONSTRAINT [DF_tradeQueue_food] DEFAULT (0) FOR [food],
	CONSTRAINT [DF_tradeQueue_iron] DEFAULT (0) FOR [iron],
	CONSTRAINT [DF_tradeQueue_tools] DEFAULT (0) FOR [tools],
	CONSTRAINT [DF_tradeQueue_swords] DEFAULT (0) FOR [swords],
	CONSTRAINT [DF_tradeQueue_bows] DEFAULT (0) FOR [bows],
	CONSTRAINT [DF_tradeQueue_horses] DEFAULT (0) FOR [horses],
	CONSTRAINT [DF_tradeQueue_cityID] DEFAULT (0) FOR [cityID],
	CONSTRAINT [DF_tradeQueue_totalGoods] DEFAULT (0) FOR [totalGoods],
	CONSTRAINT [PK_tradeQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[trainQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_trainQueue_playerID] DEFAULT (0) FOR [playerID],
	CONSTRAINT [DF_trainQueue_soldierType] DEFAULT (0) FOR [soldierType],
	CONSTRAINT [DF_trainQueue_turnsRemaining] DEFAULT (0) FOR [turnsRemaining],
	CONSTRAINT [DF_trainQueue_qty] DEFAULT (0) FOR [qty],
	CONSTRAINT [PK_trainQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[transferQueue] WITH NOCHECK ADD 
	CONSTRAINT [DF_transferQueue_fromPlayerID] DEFAULT (0) FOR [fromPlayerID],
	CONSTRAINT [DF_transferQueue_toPlayerID] DEFAULT (0) FOR [toPlayerID],
	CONSTRAINT [DF_transferQueue_wood] DEFAULT (0) FOR [wood],
	CONSTRAINT [DF_transferQueue_food] DEFAULT (0) FOR [food],
	CONSTRAINT [DF_transferQueue_iron] DEFAULT (0) FOR [iron],
	CONSTRAINT [DF_transferQueue_gold] DEFAULT (0) FOR [gold],
	CONSTRAINT [DF_transferQueue_swords] DEFAULT (0) FOR [swords],
	CONSTRAINT [DF_transferQueue_bows] DEFAULT (0) FOR [bows],
	CONSTRAINT [DF_transferQueue_horses] DEFAULT (0) FOR [horses],
	CONSTRAINT [DF_transferQueue_tools] DEFAULT (0) FOR [tools],
	CONSTRAINT [DF_transferQueue_transferType] DEFAULT (0) FOR [transferType],
	CONSTRAINT [DF_transferQueue_turnsRemaining] DEFAULT (0) FOR [turnsRemaining],
	CONSTRAINT [DF_transferQueue_woodPrice] DEFAULT (0) FOR [woodPrice],
	CONSTRAINT [DF_transferQueue_ironPrice] DEFAULT (0) FOR [ironPrice],
	CONSTRAINT [DF_transferQueue_foodPrice] DEFAULT (0) FOR [foodPrice],
	CONSTRAINT [DF_transferQueue_toolsPrice] DEFAULT (0) FOR [toolsPrice],
	CONSTRAINT [DF_transferQueue_swordsPrice] DEFAULT (0) FOR [swordsPrice],
	CONSTRAINT [DF_transferQueue_bowsPrice] DEFAULT (0) FOR [bowsPrice],
	CONSTRAINT [DF_transferQueue_horsesPrice] DEFAULT (0) FOR [horsesPrice],
	CONSTRAINT [DF_transferQueue_maces] DEFAULT (0) FOR [maces],
	CONSTRAINT [DF_transferQueue_macesPrice] DEFAULT (0) FOR [macesPrice],
	CONSTRAINT [PK_transferQueue] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[vote] WITH NOCHECK ADD 
	CONSTRAINT [DF_vote_status] DEFAULT (0) FOR [status],
	CONSTRAINT [PK_vote] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[voteAnswer] WITH NOCHECK ADD 
	CONSTRAINT [PK_voteAnswer] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[voteChoice] WITH NOCHECK ADD 
	CONSTRAINT [PK_voteQuestion] PRIMARY KEY  NONCLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

SET QUOTED_IDENTIFIER  ON    SET ANSI_NULLS  ON 
GO

CREATE VIEW dbo.AllianceScores
AS
SELECT tag,
        (SELECT COUNT(*)
      FROM player
      WHERE allianceID = alliance.id) AS members,
        (SELECT SUM(score)
      FROM player
      WHERE allianceID = alliance.id) AS total_score,
        (SELECT AVG(score)
      FROM player
      WHERE allianceID = alliance.id) AS avg_score, id
FROM Alliance

GO
SET QUOTED_IDENTIFIER  OFF    SET ANSI_NULLS  ON 
GO

SET QUOTED_IDENTIFIER  ON    SET ANSI_NULLS  ON 
GO














CREATE VIEW dbo.BattleScores
AS
SELECT player.id, player.name, player.civ, player.turn, 
    player.score, (mLand + fLand + pLand) AS totalLand, lastLoad, 
    militaryScore, landScore, goodScore, alliance.tag, 
    alliance.leaderID, player.allianceID,
        (SELECT COUNT(*)
      FROM attackNews
      WHERE attackNews.attackID = player.id) AS num_attacks,
        (SELECT COUNT(*)
      FROM attackNews
      WHERE attackNews.attackID = player.id AND 
           attackerWins = 1) AS num_attack_wins,
        (SELECT COUNT(*)
      FROM attackNews
      WHERE attackNews.defenseID = player.id) 
    AS num_defenses,
        (SELECT COUNT(*)
      FROM attackNews
      WHERE attackNews.defenseID = player.id AND 
           attackerWins = 0) AS num_defense_wins
FROM player LEFT OUTER JOIN
    alliance ON player.allianceID = alliance.id














GO
SET QUOTED_IDENTIFIER  OFF    SET ANSI_NULLS  ON 
GO

SET QUOTED_IDENTIFIER  ON    SET ANSI_NULLS  ON 
GO










CREATE VIEW dbo.multies
AS
SELECT e1.*, Player.Name AS Expr1
FROM loginEntry e1 INNER JOIN
    Player ON e1.playerID = Player.id
WHERE ((SELECT COUNT(*)
        FROM loginEntry e2
        WHERE e1.ipaddress = e2.ipaddress AND 
            e1.playerID <> e2.playerID AND 
            e2.createdON > '2001-4-18') > 0) AND 
    e1.createdON > '2001-4-18'










GO
SET QUOTED_IDENTIFIER  OFF    SET ANSI_NULLS  ON 
GO

SET QUOTED_IDENTIFIER  ON    SET ANSI_NULLS  ON 
GO








CREATE VIEW dbo.ThePMessages
AS
SELECT fromPlayerName, toPlayerName, message, 
    createdOn
FROM PlayerMessage
WHERE (messageType = 0 OR
    messageType = 2) AND (createdOn > '2001-06-5 9:57:00')








GO
SET QUOTED_IDENTIFIER  OFF    SET ANSI_NULLS  ON 
GO


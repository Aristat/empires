<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000, 2001
--->

<cfapplication sessionmanagement="Yes" clientmanagement="Yes" name="TestGame" SESSIONTIMEOUT=#CreateTimeSpan(0, 2, 0, 0)#>

<cfset dsn = "testgame1">
<cfset dsn_login = "">
<cfset dsn_pw = "">

<cfset ader_dsn = "adersoftware"><!--- used for league and news --->

<cfset gameVersion = "1.7.3">

<cfset filePath = "d:\htdocs\andrew\thegame3\">
<cfset required_host = "test.1000ad.net">
<cfset webpath = "http://#required_host#/">
<cfset gameName = "Test Game">
<cfset veritySearch = "ad1000_docs">

<cfset empireNames = arrayNew(1)>
<cfset empireNames[1] = "Vikings">
<cfset empireNames[2] = "Franks">
<cfset empireNames[3] = "Japanese">
<cfset empireNames[4] = "Byzantines">
<cfset empirenames[5] = "Mongols">
<cfset empirenames[6] = "Incas">
<cfset empirenames[7] = "Chinese">
<cfset empirenames[8] = "Barbarians">

<cfset uunitNames = arrayNew(1)>
<cfset uunitNames[1] = "Berserker">
<cfset uunitNames[2] = "Paladin">
<cfset uunitNames[3] = "Samurai">
<cfset uunitNames[4] = "Cataphract">
<cfset uunitNames[5] = "Horse Archer">
<cfset uunitNames[6] = "Shaman">
<cfset uunitNames[7] = "Kung Fu Warrior">
<cfset uunitNames[8] = "Giant Warrior">

<cfparam name="session.playerID" default="0">
<cfparam name="session.started" default="false">

<cfset maxAttacks = 5>
<cfset maxBuilds = 50>

<cfset mailserver = "adersoftware.com">
<cfset adminEmail = "andrew@c3chicago.com">
<cfset localTradeMulti = 0.05><!--- used when calculating prices on local market --->

<cfset maxTurnsStored = 500>
<cfset minutesPerTurn = 5><!--- 15 minutes --->
<cfset startTurns = 100>
<cfset gameCode = "GTST">

<cfset allianceMaxMembers = 5>

<cfset startGameDate = createDateTime(2001, 10, 17, 9, 0, 0)>
<cfset endGameDate = createDateTime(2001, 11, 7, 9, 0, 0)>

<cfset deathmatchMode = false>
<cfset deathMatchStarted = false><!--- do not change --->
<cfset deathmatchStart = createDateTime(2001, 3, 18, 15, 0, 0)>
<cfif deathmatchMode>
	<cfif dateDiff("s", deathMatchStart, now()) gt 0>
		<cfset deathMatchStarted = true>
	</cfif>
</cfif>

<cfif cgi.http_host is not required_host>
	<cflocation url="#webpath#" addtoken="No">
</cfif>

<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<meta HTTP-EQUIV="Expires" CONTENT="Mon, 06 Jan 1990 00:00:01 GMT"> 
<style type="text/css">
	TD {
		font-family:verdana;
		font-size:xx-small;
	}  
	TD.HEADER {
		font-family:verdana;
		font-size:xx-small;
		background-color: darkslategray;
		color: white;	
	}
</style>
	<title>The Game</title>
</head>
<body bgcolor="Black" alink="Aqua" link="Aqua" text="White" vlink="Aqua">
<cfset war1 = 0>
<cfset war2 = 0>
<cfset war3 = 0>
<cfset war4 = 0>
<cfset war5 = 0>
<cfset ally1 = 0>
<cfset ally2 = 0>
<cfset ally3 = 0>
<cfset ally4 = 0>
<cfset ally5 = 0>
<cfset myAllianceID = 0>
<cfparam name="rank" default="top10">

<cfif rank is "top10">
<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select player.id, player.name, player.civ, player.turn, player.score, (mLand+fLand+pLand) as totalLand, 
	lastLoad,	militaryScore, landScore, goodScore, alliance.tag, alliance.leaderID, player.allianceID,
	(research1+research2+research3+research4+research5+research6+research7+research8+research9+research10+research11+research12) as researchLevels,
	player.killedBy, player.killedByName, player.vacationEnd
	from player left outer join alliance on player.allianceID = alliance.id 
	order by killedBy, score desc, player.id
</cfquery>

<cfset needLastLoad = createODBCDateTime(dateAdd("n", -10, now()))>

<font face="verdana" size=2>
<cfoutput>
<b>1000 AD Top 10 Empires for #gamename#</b><br>
from #DateFormat(startGameDate, "mm/dd/yyyy")# to #DateFormat(endGameDate, "mm/dd/yyyy")#<br>
There are #p.recordcount# players in the game.<br>
</font>
</cfoutput>
<br>
<cfset playerID = 0>
<cfset iAmAdmin = false>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
<tr>
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">&nbsp;</td>
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Player</td>
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Civilization</td>
	<cfif not deathmatchMode and allianceMaxMembers gt 0><td bgcolor="darkslategray"><font face=verdana size=2 color="White">Alliance</td></cfif>
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">R/L</td>	
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Land</td>
	<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Score</td>
	<!---<td bgcolor="darkslategray" colspan="3"><font face=verdana size=1 color="White">Score<br>Breakdown</td>--->
</tr>
<cfset iArray = arrayNew(1)>
<cfset iArray[1] = "##CCCCCC">
<cfset iArray[2] = "##BBBBBB">
<cfset iArray[3] = "##AAAAAA">
<Cfset iArray[4] = "##999999">
<Cfset iArray[5] = "##888888">
<Cfset iArray[6] = "##777777">
<Cfset iArray[7] = "##666666">
<cfset iArray[8] = "##555555">
<cfset iArray[9] = "##444444">
<cfset iArray[10] = "##333333">
<cfset iArray[11] = "##222222">
<cfset rankView = true>
<cfoutput query="p" startrow="1" maxrows="10">
	<cfinclude template="scores_show.cfm">
</cfoutput>   
<tr><td colspan="9" bgcolor="darkslategray" height="10"></td></tr>
</table>
<br>
<cfelse>
<font face="verdana" size=3><B>Alliance Scores</b></font>
<br>
<font face="verdana" size=2>(with at least 3 members)</font>
<br>
<br>

<cfif rank is "alliance_by_score">
	<cfset orderString = "total_score desc">
<cfelseif rank is "alliance_by_avgscore">
	<cfset orderString = "avg_score desc">
<cfelse>
	<cfset orderString = "members desc">
</cfif>

<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select top 10 * 
	from allianceScores 
	where members >= 3
	order by #orderString#
</cfquery>

<cfif alliance.recordcount gt 0>
<table border="1" cellpadding="2" cellspacing="0">
<tr>
	<td class="HEADER">#</td>
	<td class="HEADER">Alliance</a></td>
	<td class="HEADER">Members</a></td>	
	<td class="HEADER">Avg. Score</a></td>	
	<td class="HEADER">Total Score</a></td>	
</tr>
<cfoutput query="alliance">
<tr>
	<td nowrap align="right">#alliance.currentrow#&nbsp;</td>
	<td nowrap>#alliance.tag#</td>
	<td nowrap>#alliance.members#</td>
	<td nowrap>#NumberFormat(alliance.avg_score)#</td>
	<td nowrap>#numberFormat(alliance.total_score)#</td>
</tr>
</cfoutput>
</table>
<cfelse>
	<font face="verdana" size=2>There are no alliaces with at lease 3 members.</font>
</cfif>
</cfif>

</body>
</html>
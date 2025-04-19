<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="100%"><font face="verdana" size="3"><b>Scores</td>

</tr>
</table>


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
<cfif player.allianceID gt 0>
	<cfset myAllianceID = player.allianceID>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select war1, war2, war3, war4, war5, ally1, ally2, ally3, ally4, ally5 from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<cfset war1 = alliance.war1>
		<cfset war2 = alliance.war2>
		<cfset war3 = alliance.war3>
		<cfset war4 = alliance.war4>
		<cfset war5 = alliance.war5>
		<cfset ally1 = alliance.ally1>
		<cfset ally2 = alliance.ally2>
		<cfset ally3 = alliance.ally3>
		<cfset ally4 = alliance.ally4>
		<cfset ally5 = alliance.ally5>
	</cfif>
<cfelse>
	<cfset myAllianceID = -1>
</cfif>

<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select player.id, player.name, player.civ, player.turn, player.score, (mLand+fLand+pLand) as totalLand, 
	lastLoad,	militaryScore, landScore, goodScore, alliance.tag, alliance.leaderID, player.allianceID,
	(research1+research2+research3+research4+research5+research6+research7+research8+research9+research10+research11+research12) as researchLevels,
	player.killedBy, player.killedByName, player.vacationend
	from player left outer join alliance on player.allianceID = alliance.id 
	order by killedBy, score desc, player.id
</cfquery>

<cfset needLastLoad = createODBCDateTime(dateAdd("n", -10, now()))>
<cfquery datasource="#dsn#" name="pOnline">
    select count(*) as cnt from player where lastLoad >= #needLastLoad#
</cfquery>

<table border=0 cellspacing=0 cellpadding=0 width="100%"> 
<tr>
<td width="15"></td>
<td valign="top">
<font face="verdana" size=2>
<cfoutput>
There are <b>#p.recordcount#</b> players in the #gameName#.<br>
#pOnline.cnt# <cfif pOnline.cnt is 1>is<cfelse>are</cfif> online now.<br>
<br>
<font face="verdana" size=2>
<a href="viewAllPlayers.cfm" target="_blank">View All Players</a>
| <a href="viewDeadPlayers.cfm" target="_blank">View Dead Empires</a>
<br>
<cfif not deathMatchMode><a href="index.cfm?page=alliance_scores">Alliance Scores</a></cfif>
|
<a href="index.cfm?page=battle_scores">Battle Scores</a>
<br>
<a href="index.cfm?page=scores_research">Most Research</a>
|
<a href="index.cfm?page=civ_stats">Civ. Statistics</a>

</font><br>
</cfoutput>
</td>
<td width="25"></td>
<td valign="top" align="right">
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
	<tr><td class="HEADER" align="center"><font size=1>Legend:</td></tr>
	<tr><td>
	<font face=verdana size=1 color="Aqua">Your Empire</font><br>
	<cfif not deathMatchMode>
	<font face=verdana size=1 color="Yellow">Under Protection <br>or vacation mode</font><br>
	<font face=verdana size=1 color="Fuchsia">Your Alliance Member</font><br>
	<font face=verdana size=1 color="PeachPuff">Ally</font><br>
	<font face=verdana size=1 color="Crimson">Enemy</font><br>
	<font face=verdana size=1>[Alliance] - alliance leader</font><br>
	</cfif>
	<font face=verdana size=1>R/L - total research levels</font><br>
	<font face=verdana size=1>* - is online</font><br>	
	</td></tr>
	</table>
</td>
<td width="15"></td>
</tr>
</table>
<br>
<table border=1 cellspacing=0 cellpadding=2 bordercolor="darkslategray" width="100%">
<tr>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">&nbsp;</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Player</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Civilization</td>
	<cfif not deathMatchMode and allianceMaxMembers gt 0><td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Alliance</td></cfif>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">R/L</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Land</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Score</td>
	<!---<td bgcolor="darkslategray" colspan="3"><font face=verdana size=1 color="White">Score<br>Breakdown</td>--->
</tr>

<cfif player.isAdmin>
	<cfset startMax = p.recordcount>
	<cfset iAmAdmin = true>
<cfelse>
	<Cfset startMax = 15>
	<cfset iAmAdmin = false>
</cfif>

<cfoutput query="p" startrow="1" maxrows="#startMax#">
	<cfinclude template="scores_show.cfm">
</cfoutput>   

<cfif not iAmAdmin>
<tr><td colspan="9" height="20">&nbsp;</td></tr>
<tr><td colspan="9" bgcolor="darkslategray" height="10"></td></tr>
<!--- now find the player in the players --->
<cfset rank = 0>
<cfloop query="p"><cfif p.id is playerID><cfset rank = p.currentrow></cfif></cfloop>
<cfif rank lte 15><cfset start = 16><cfset max = rank + 30 - 15>
<cfelseif rank lte 45><cfset start = 16><cfset max = rank - 16 + 30>
<cfelse><cfset start = rank - 30><cfset max = 60>
	<cfif start lte 10><cfset start = 11></cfif>
</cfif>
<cfoutput query="p" startrow="#start#" maxrows="#max#">
	<cfinclude template="scores_show.cfm">
</cfoutput>
</cfif>
</table>
<br>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
	var curPID;

	function showMenu(pid, pname)
	{
		var menu = document.all.pMenu;
		
		if (menu.style.display == '') menuClose();
		
		curPID = pid;
		player = pname + ' (' + pid + ')';
		document.all.menuName.innerText = 'Action for ' + player;
		document.all.menuMessage.innerText = 'Send Message';
		document.all.menuAid.innerText = 'Send Aid';
		document.all.menuAttackArmy.innerText = 'Conquer Attack';
		document.all.menuAttackCatapults.innerText = 'Catapult Attack';
		document.all.menuAttackThieves1.innerText = 'Steal Information';
		document.all.menuAttackThieves2.innerText = 'Steal Goods';
		document.all.menuAttackThieves3.innerText = 'Poison Water';
		document.all.menuClose.innerText = 'Close Menu';
		menu.style.left=document.body.scrollLeft+event.clientX-event.offsetX-5;
		menu.style.top=document.body.scrollTop+event.clientY-event.offsetY+15;
		menu.style.display = '';
	}
	function menuClose()
	{
		curPID = 0;
		document.all.pMenu.style.display = 'none';
	}
	function menuOut(td) {
		td.style.backgroundColor = '';
		td.style.color = '';
	}
	function menuOver(td) {
		td.style.backgroundColor = 'blue';
		td.style.color = 'white';
	}
	function menuEflag(v)
	{
		var u = 'index.cfm?page=' + v + '&menuPlayerID=' + curPID + '&r=' + Math.random();
		window.open(u, '_self');
	}
	//if (document.all)
		//document.body.onclick=menuClose;
	
//-->
</SCRIPT>
<style type="text/css">
    .menuItem {
		font-family: verdana;
		color: black;
		font-size:10px;
		cursor: hand;
	}
</style>
<div style="display:none;position:absolute;border:2px outset" id="pMenu">
<table border=0 cellpadding=1 cellspacing=1 bgcolor="Silver">
<tr><td style="font-family:verdana;font-size:11px;font-weight:bold;color:black" id="menuName"></td></tr>
<tr><td class="menuItem" id="menuMessage" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('player_Messages')"></td></tr>
<tr><td class="menuItem" id="menuAid" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('aid')"></td></tr>
<tr><td class="menuItem" id="menuAttackArmy" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('attack&attack_type=0')"></td></tr>
<tr><td class="menuItem" id="menuAttackCatapults" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('attack&attack_type=10')"></td></tr>
<tr><td class="menuItem" id="menuAttackThieves1" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('attack&attack_type=20')"></td></tr>
<tr><td class="menuItem" id="menuAttackThieves2" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('attack&attack_type=23')"></td></tr>
<tr><td class="menuItem" id="menuAttackThieves3" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuEflag('attack&attack_type=24')"></td></tr>
<tr><td><hr noshade size="1"></td></tr>
<tr><td class="menuItem" id="menuClose" onmouseover="menuOver(this)" onmouseout="menuOut(this)" onclick="menuClose()"></td></tr>
</table>
</div>


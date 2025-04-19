<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="100%"><font face="verdana" size="3"><b>Most Research Scores</td>

</tr>
</table>




<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select player.id, player.name, player.civ, player.score, (mLand+fLand+pLand) as totalLand, 
	(research1+research2+research3+research4+research5+research6+research7+research8+research9+research10+research11+research12) as researchLevels
	from player left outer join alliance on player.allianceID = alliance.id 
	order by researchLevels desc
</cfquery>

<br>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="100%">
<tr>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">#</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Player</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">Civilization</td>
	<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">R/L</td>
</tr>

<cfoutput query="p" startrow="1" maxrows="100">
<tr>
	<td align="right">#p.currentRow#</td>
	<td>#p.name# (#p.id#)</td>
	<td>#empireNames[p.civ]#</td>
	<td align="right">#NumberFormat(p.researchLevels)#</td>	
</tr>
<cfif p.currentrow mod 5 is 0><tr><td colspan="9" bgcolor="darkslategray" height="10"></td></tr></cfif>

</cfoutput>
</table>

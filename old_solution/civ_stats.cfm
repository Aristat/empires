<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="100%"><font face="verdana" size="3"><b>Civilization Statistics</td>

</tr>
</table>

<cfquery datasource="#dsn#" name="civ">
	select player.civ, count(*) as cnt, avg(score) as avg_score from player
	group by civ
</cfquery>
<br>
<table border=1 cellpadding=1 cellspacing=1 bordercolor="darkslategray">
<tr>
	<td colspan="3" align="center"><b>All Players</b></td>
</tr>
<tr>
	<td class="HEADER">Civilization</td>
	<td class="HEADER">Num. Players</td>
	<td class="HEADER">Avg. Score</td>
</tr>
<cfoutput query="civ">
<tr>
	<td>#empirenames[civ.civ]#</td>
	<td>#numberFormat(civ.cnt)#</td>
	<td align="right">#numberFormat(civ.avg_score)#</td>
</tr>	
</cfoutput>
</table>

<cfquery datasource="#dsn#" name="tempP">
	select top 100 score from player order by score desc
</cfquery>
<cfif tempP.recordcount gte 100>

<cfquery datasource="#dsn#" name="civ">
	select player.civ, count(*) as cnt, avg(score) as avg_score from player
	where player.score >= #tempP.score[100]#
	group by civ
</cfquery>
<br>
<table border=1 cellpadding=1 cellspacing=1 bordercolor="darkslategray">
<tr>
	<td colspan="3" align="center"><b>Top 100 Players</b></td>
</tr>
<tr>
	<td class="HEADER">Civilization</td>
	<td class="HEADER">Num. Players</td>
	<td class="HEADER">Avg. Score</td>
</tr>
<cfoutput query="civ">
<tr>
	<td>#empirenames[civ.civ]#</td>
	<td>#numberFormat(civ.cnt)#</td>
	<td align="right">#numberFormat(civ.avg_score)#</td>
</tr>	
</cfoutput>
</table>
</cfif>
<br>
<br>

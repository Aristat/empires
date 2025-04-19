<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<style type="text/css">
    TD {
		font-size:x-small;
		font-family: verdana;
	}
</style>
	<title>All 1000 AD Players</title>
</head>

<body>

<cfquery datasource="#dsn#" name="p">
    select player.id, player.name, alliance.tag, player.killedBy, player.killedByName, player.score
	from player left outer join alliance on player.allianceID = alliance.id
	where killedBy > 0
	order by player.id
</cfquery>
<cfif p.recordcount is 0>
	<font face="verdana" size="2">Everyone is still alive!!!!</font>
<cfelse>
<table border=1 cellspacing=0 cellpadding=0>
<tr>
<td bgcolor="Silver">#</td>
<td bgcolor="silver">Empire</td>
<td bgcolor="silver">Last Score</td>
<td bgcolor="Silver">Alliance</td>
<td bgcolor="Silver">Killed By</td>
</tr>
<cfoutput query="p">
<tr><td><font face="verdana" size=2>#p.id#</font></td>
	<td nowrap><font face="verdana" size=2>#p.name#</font></td>
	<td nowrap><font face="verdana" size=2>#NumberFormat(p.score)#</font></td>	
	<td nowrap><font face="verdana" size=2>#p.tag#</font>&nbsp;</td>
	<td nowrap><font face="verdana" size="2">#p.killedByName# (#p.killedBy#)</font>
</tr>
</cfoutput>
</table>
</cfif>
</body>
</html>

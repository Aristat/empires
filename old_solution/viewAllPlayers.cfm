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
    select player.id, player.name, alliance.tag
	from player left outer join alliance on player.allianceID = alliance.id
	order by player.id
</cfquery>

<table border=1 cellspacing=0 cellpadding=0>
<tr>
<td bgcolor="Silver">#</td>
<td bgcolor="silver">Empire</td>
<td bgcolor="Silver">Alliance</td>
</tr>
<cfoutput query="p">
<tr><td><font face="verdana" size=2>#p.id#</font></td>
	<td nowrap><font face="verdana" size=2>#p.name#</font></td>
	<td nowrap><font face="verdana" size=2>#p.tag#</font>&nbsp;</td>
</tr>
</cfoutput>
</table>

</body>
</html>

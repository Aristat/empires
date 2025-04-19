<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfquery datasource="#dsn#" name="p">
    select id from player
</cfquery>
<cfloop query="p">
	<cf_calc_score datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" playerid="#p.id#">
</cfloop>

</body>
</html>

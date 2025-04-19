<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfset needLastLoad = createODBCDateTime(dateAdd("n", -10, now()))>
<cfquery datasource="#dsn#" name="pOnline">
    select count(*) as cnt from player where lastLoad >= #needLastLoad#
</cfquery>
<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    insert into gameLog (createdon, numOn)
	values (#now()#, #pOnline.cnt#)
</cfquery>

</body>
</html>

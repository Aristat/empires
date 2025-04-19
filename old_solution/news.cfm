<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<table border=0 cellspacing=0 cellpadding=0><tr><td><font face="verdana" size="2">
<b><font color=yellow><center>Game News / Announcements:</center></font></b><br>
<font face="verdana" size=2>
<cfquery name="news" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from  gameNews order by createdON desc
</cfquery>
<cfoutput query="news">
<font color="Yellow">#DateFormat(news.createdOn, "mm/dd/yyyy")#:</font><cf_getFormatedText text="#news.message#" showOutput="true"><br>
</cfoutput>

<br>
</td></tr>
</table>

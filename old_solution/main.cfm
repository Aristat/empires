<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfif player.hasMainNews gt 0>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update player set hasMainNews = 0 where id = #playerID#
	</cfquery>
</cfif>

<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="88%"><font face="verdana" size="3"><b>Main</td>
	<td class="HEADER" align="center" width="12%"><b><a href="javascript:openHelp('home')">Game Help</a></td>
</tr>
</table>


<font face=verdana size=2>
<cfoutput>#player.message#</cfoutput>
</font>
<!--- show attack news --->
<cfquery name="news" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from playerMessage where messageType = 1 and toPlayerID = #playeriD# order by createdOn desc
</cfquery>
<cfoutput query="news">
<hr noshade size="1">
#news.message#<br>
<font size="1"><a href="index.cfm?page=main&eflag=delete_news&newsID=#news.id#">Delete Message</a></font>
</cfoutput>
<br>
<br>
<cfif news.recordcount gt 1>
<font size="1"><a href="index.cfm?page=main&eflag=delete_allnews">Delete All News</a></font>
</cfif>
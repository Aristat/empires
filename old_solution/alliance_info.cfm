<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Alliance Info</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('alliance')">Help</a></td>
</tr>
</table>

<cfparam name="viewallianceID" default="0">
<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
   	select * from alliance where id = #viewAllianceID#
</cfquery>
<cfif alliance.recordCount gt 0>
	<cfoutput>
	<table border=0 cellpadding=0 cellspacing=0 width="80%">
    <tr>
		<td>
			<br>
			<font face="verdana" size=4><b>#alliance.tag#</b></font>
			<br><br>
			<cf_getFormatedText text="#alliance.description#" showOutput="true">
			<br><br>
			<cfquery name="m" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            	select id, name, score from player where allianceID = #alliance.id#
				order by score desc
            </cfquery>
			<b>Alliance members (#m.recordcount#):</b><br>
			<table border=1 cellpadding=1 cellspacing=1 bordercolor="darkslategray">
			<tr>
				<td class="HEADER">&nbsp;</td>
				<td class="HEADER">Player</td>
				<td class="HEADER">Score</td>
			</tr>
			<cfloop query="m">
            <tr>
				<td><cfif m.id is alliance.leaderID>leader<cfelse>&nbsp;</cfif></td>
				<td>#m.name# (#m.id#)</td>
				<td>#numberFormat(m.score)#</td>
			</tr>
			</cfloop>
            </table>
			<br>
		</td>
	</tr>
    </table>

	</cfoutput>
</cfif>
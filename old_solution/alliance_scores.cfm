<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<font face="verdana" size=3><B>Alliance Scores</b></font>
<br>
<font face="verdana" size=2>(with at least 3 members)</font>
<br>
<br>

<cfparam name="orderString" default="total_score">
<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * 
	from allianceScores 
	where members >= 3
	order by #orderString# <cfif orderString is not "tag">desc</cfif>
</cfquery>

<cfif alliance.recordcount gt 0>
<font face="verdana" size=2>Click on Column Heading to sort by that column</font>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr>
	<td class="HEADER">#</td>
	<td class="HEADER"><a href="index.cfm?page=alliance_scores&orderString=tag">Alliance</a></td>
	<td class="HEADER"><a href="index.cfm?page=alliance_scores&orderString=members">Members</a></td>	
	<td class="HEADER"><a href="index.cfm?page=alliance_scores&orderString=avg_score">Avg. Score</a></td>	
	<td class="HEADER"><a href="index.cfm?page=alliance_scores&orderString=total_score">Total Score</a></td>	
</tr>
<cfoutput query="alliance">
<tr>
	<td nowrap align="right">#alliance.currentrow#&nbsp;</td>
	<td nowrap><a href="index.cfm?page=alliance_info&viewAllianceID=#alliance.id#">#alliance.tag#</a></td>
	<td nowrap align="right">#alliance.members#</td>
	<td nowrap align="right">#NumberFormat(alliance.avg_score)#</td>
	<td nowrap align="right">#numberFormat(alliance.total_score)#</td>
</tr>
</cfoutput>
</table>
<cfelse>
	<font face="verdana" size=2>There are no alliaces with at lease 3 members.</font>
</cfif>

<cfquery datasource="#dsn#" name="ta">
    select count(*) as cnt from alliance 
</cfquery>
<font face="verdana" size=2>
There are total <cfoutput>#ta.cnt#</cfoutput> alliances. <br>
<cfoutput>#val(ta.cnt-alliance.recordcount)#</cfoutput> alliances didn't make it to the scores list 
<br>because they don't have 3 members.<br>
<br>
<cfquery datasource="#dsn#" name="ua">
    select count(*) as cnt from player where allianceID > 0
</cfquery>
<cfquery datasource="#dsn#" name="uw">
    select count(*) as cnt from player
</cfquery>
<cfoutput>#ua.cnt# out of #uw.cnt#</cfoutput> empires belong to an alliance.
</font>
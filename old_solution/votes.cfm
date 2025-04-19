<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center"><font face="verdana" size="3"><b>Votes</td>
</tr>
</table>

<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select id, question from vote where status = 1
	and (select count(*) from voteAnswer where voteAnswer.voteID = vote.id
	and voteAnswer.playerID = #playerid#) = 0
</cfquery>

<cfoutput query="vote">
<br>
<table border=1 cellpadding=1 cellspacing=1 width="80%" bordercolor="darkslategray">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="votes">
<input type="hidden" name="eflag" value="castVote">
<input type="hidden" name="voteID" value="#vote.id#">
<tr>
	<td class="HEADER">#vote.question#</td>
</tr>
	<cfquery name="vChoice" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, choice from voteChoice where voteID = #vote.id# order by pos
    </cfquery>
<tr>
	<td>
		<input type="Radio" name="choice" value="0" checked>Don't bother me with this question<br>
		<cfloop query="vChoice">
		<input type="Radio" name="choice" value="#vChoice.id#">#vChoice.choice#<br>
		</cfloop>
		<center>
		<input type="Submit" value="Mark Your Vote" style="font-size:10px">
	</td>	
</tr>
</form>
</table>
</cfoutput>

<cfif vote.recordcount is 0>
	<font face="verdana" size=2 color=red>There are no votes for you to be cast.<br></font>
</cfif>

<!--- show results from other votes --->
<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from vote where status = 1 order by id desc
</cfquery>
<cfif vote.recordCount gt 0>
	<br><br>
	<table border=1 cellpadding=1 cellspacing=1 width="80%" bordercolor="darkslategray">
	<tr>
		<td class="HEADER"><b>View results of other votes:</b></td>
	</tr>
	<tr><Td>
	<cfoutput query="vote">
	<li><a href="index.cfm?page=voteResults&voteID=#vote.id#">#vote.question#</a>
	</cfoutput>
	</td></tr></table>
</cfif>
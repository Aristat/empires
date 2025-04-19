<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center"><font face="verdana" size="3"><b>Vote Results</td>
</tr>
</table>


<cfparam name="voteID" default="0">
<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from vote where id = #voteID#
</cfquery>
<cfif vote.recordCount is 0>
	<font face="verdana" size=2 color=red>No vote selected.</font>
<cfelse>
	<cfquery name="vChoice" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select voteChoice.choice, 
			(select count(*) from voteAnswer where choiceID = voteChoice.id) as votes
		from voteChoice
		where voteChoice.voteID = #voteID#
		order by votes desc
    </cfquery>
	<br>
	<table border=1 cellpadding=1 cellspacing=1 width="80%" bordercolor="darkslategray">
	<tr>
		<td class="HEADER"><cfoutput>#vote.question#</cfoutput></td>
	</tr>
	<!--- calc total --->
	<cfset total = 0>
	<cfloop query="vChoice">
		<cfset total = total + val(vChoice.votes)>
	</cfloop>
	<tr>
		<td>
			<cfoutput query="vChoice">
			<li>#vChoice.choice# - #vChoice.votes# votes
				<cfif total gt 0>
				(<b>#DecimalFormat((vChoice.votes / total)*100)# %</b>)
				</cfif>
			<br><br>
			</cfoutput>
			<br>
		</td>	
	</tr>
	</table>	
</cfif>
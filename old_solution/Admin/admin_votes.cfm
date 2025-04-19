<cfinclude template="checkUser.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfinclude template="style.cfm">
	<title>1000 AD Admin</title>
</head>

<body>

<cfif eflag is "add_vote">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        insert into vote (question, status, createdOn)
		values ('#question#', 0, #now()#)
    </cfquery>
</cfif>

<font face="verdana" size=2>
<b>Current Votes:</b>
<br>
<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from vote order by createdOn
</cfquery>
<table border=0 cellpadding=0 cellspacing=1>
<tr>
	<td class="HEADER">Start Date</td>
	<td class="HEADER">Question</td>
	<td class="HEADER">Status</td>
</tr>
<cfoutput query="vote">
<tr>
	<td><a href="vote_edit.cfm?voteID=#vote.id#">#DateFormat(vote.createdOn, "mm/dd/yyyy")#</a></td>
	<td>#vote.question#</td>
	<td><cfif vote.status is 0>Inactive<cfelseif vote.status is 1>Active</cfif></td>
</tr>
<tr><td colspan="3" class="HEADER"></td></tr>
</cfoutput>
<cfif vote.recordcount is 0>
<tr><td colspan="3">No votes setup</td></tr>
</cfif>
<tr>
	<td colspan="3" class="HEADER">Add New Question</td>
</tr>
<form action="admin_votes.cfm" method="post">
<input type="hidden" name="eflag" value="add_vote">
<tr>
	<td colspan="3">
		<input type="text" name="question" value="" maxlength="200" size="80">
		<input type="Submit" value="   Add   ">
	</td>
</tr>
</form>
</table>

</font>

</body>
</html>

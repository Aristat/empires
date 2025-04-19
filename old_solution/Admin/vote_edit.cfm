<cfinclude template="checkUser.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfinclude template="style.cfm">
	<title>1000 AD Admin</title>
</head>

<body>

<cfif eflag is "update_vote">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update vote set
			status = #status#,
			question = '#question#'
		where id = #voteID#
    </cfquery>
<cfelseif eflag is "save_choices">
	<cfquery name="c" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id from voteChoice where voteID = #voteID#
    </cfquery>
	<cfloop query="c">
		<cfif isDefined("choice#c.id#")>
			<cfset pos = val(evaluate("pos#c.id#"))>
			<cfset choice = evaluate("choice#c.id#")>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update voteChoice set
					pos = #pos#,
					choice = '#choice#'
				where id = #c.id#
            </cfquery>
		</cfif>
	</cfloop>
<Cfelseif eflag is "add_choice">
	<cfset pos = val(form.pos)>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        insert into voteChoice (voteID, choice, pos)
		values (#voteID#, '#choice#', #pos#)
    </cfquery>
<cfelseif eflag is "remove_choice">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        delete from voteChoice where id = #choiceID#
    </cfquery>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        delete from voteAnswer where choiceID = #choiceID#
    </cfquery>
</cfif>

<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from vote where id = #voteID#
</cfquery>
<cfif vote.recordcount is 0>
	<font face="verdana" size=2 color=red>No Vote found.</font>
	<cfabort>
</cfif>

<cfoutput>
<font face="verdana" size=2>
<a href="admin_votes.cfm">Vote Menu</a>
|
<a href="admin.cfm">Admin Main Menu</a>
</font>
<table border=0 cellpadding=0 cellspacing=1>
<form action="vote_edit.cfm" method="post">
<input type="hidden" name="eflag" value="update_vote">
<input type="hidden" name="voteID" value="#voteID#">
<tr>
	<td class="HEADER">Question:</td>
	<td><input type="Text" name="question" value="#vote.question#" size="60" maxlength="200"></td>
</tr>
<tr>
	<td class="HEADER">Status:</td>
	<td><select name="status">
		<option value="0" <cfif vote.status is 0>selected</cfif>>Inactive
		<option value="1" <cfif vote.status is 1>selected</cfif>>Active
		</select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;		
		<input type="Submit" value="Update">
	</td>
</tr>
</form>
</table>
</cfoutput>
<br>
<font face="verdana" size=2>
<b>Answer Options:</b><br>
<cfquery name="voteChoice" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from voteChoice where voteID = #voteID# order by pos
</cfquery>
<table border=0 cellpadding=0 cellspacing=1>
<tr>
	<td class="HEADER">Pos</td>
	<td class="HEADER">Choice</td>
	<td class="HEADER">&nbsp;</td>
</tr>
<cfif voteChoice.recordCount gt 0>
<form action="vote_edit.cfm" method="post">
<input type="hidden" name="eflag" value="save_choices">
<input type="hidden" name="voteID" value="<cfoutput>#voteID#</cfoutput>">
<cfoutput query="voteChoice">
<tr>
	<td><input type="text" name="pos#voteChoice.id#" value="#voteChoice.pos#" size="3"></td>
	<td><input type="text" name="choice#voteChoice.id#" value="#voteChoice.choice#" size="50" maxlength="200"></td>
	<td><a href="vote_edit.cfm?voteID=#voteID#&choiceID=#voteChoice.id#&eflag=remove_choice">remove</a></td>
</tr>
<tr><td colspan="3" class="HEADER" height="1"></td></tr>
</cfoutput>
<tr>
	<td colspan="3" class="HEADER"><input type="Submit" value="Save"></td>
</tr>
</form>
<cfelse>
<tr><td colspan="3"><font face="verdana" size=2 color=red>No choices setup.</font></td></tr>
</cfif>
<form action="vote_edit.cfm" method="post">
<input type="hidden" name="eflag" value="add_choice">
<input type="hidden" name="voteID" value="<cfoutput>#voteID#</cfoutput>">
<tr>
	<td><input type="text" name="pos" value="" size="3"></td>
	<td><input type="text" name="choice" value="" size="50" maxlength="200"></td>
	<td><input type="Submit" value="   Add   "></td>
</tr>
</form>
</table>


</body>
</html>

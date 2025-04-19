<cfinclude template="checkUser.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfinclude template="style.cfm">
	<title>1000 AD Admin</title>
</head>

<body>


<font face="verdana" size=2>
<b>Find Players:</b>
<br>
<table border=0 cellpadding=0 cellspacing=0>
<form action="admin_players.cfm" method="post">
<tr>
	<td>Find players where:</td>
	<cfparam name="lookupfield" default="">
	<td><select name="lookupfield">
	<cfoutput>
	<cfloop list="id,name,loginName,passwd,email" index="i">
		<option value="#i#" <cfif i is lookupfield>selected</cfif>>#i#
	</cfloop>
	</select>
	</cfoutput>
	</td>
	<td>
		<cfparam name="lookuptext" default="">
		is close to:
		<input type="text" name="lookuptext" value="<cfoutput>#lookuptext#</cfoutput>" size=30>
		<input type="Submit" value="Search">
	</td>
</tr>
<tr>
	<td colspan="20"><hr noshade size="1"></td>
</tr>
</form>
</table>

<cfif lookupfield is not "">
	<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from player where 
			<cfif lookupfield is "id">
				id = #val(lookuptext)#
			<cfelse>
				#lookupfield# like '%#lookuptext#%'
			</cfif>
		order by score desc
    </cfquery>

	
	<cfif p.recordCount is 0>
		no results!
	<cfelse>
		<table border=1 cellpadding=1 cellspacing=0>
        <tr>
			<td class="HEADER">#</td>
			<td class="HEADER">Name (ID)</td>
			<td class="HEADER">Score</td>
			<Td class="HEADER">Login Name</td>
			<td class="HEADER">Password</td>
			<td class="HEADER">Email</td>
			<td class="HEADER">Validated?</td>
			<td class="HEADER">Validation Code</td>
			<td class="HEADER">Lost Load</td>
		</tr>
		<cfoutput query="p">
		<tr>
			<td>#p.currentRow#</td>
			<td>#p.name# (#p.id#)</td>
			<td>#p.score#</td>
			<td>#p.loginName#</td>
			<td>#p.passwd#</td>
			<td>#p.email#</td>
			<td>#yesNoFormat(p.validated)#</td>
			<td>#p.validationCode#</td>
			<td>#DateFormat(p.lastLoad, "mm/dd/yyyy")# #TimeFormat(p.lastLoad, "hh:mm tt")#</td>
		</tr>
		</cfoutput>
        </table>
	</cfif>
</cfif>
</font>

</body>
</html>

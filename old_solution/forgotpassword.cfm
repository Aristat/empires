<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<style type="text/css">
    td {
		font-size:x-small;
		font-family:verdana;
		color:white;
	}
</style>
	<title>1000 A.D. password lookup</title>
</head>

<body bgcolor="Black" alink="Aqua" link="Aqua" text="White" vlink="Aqua">

<cfparam name="eflag" default="">

<cfif eflag is "byemail">
	<cfset email = trim(form.youremail)>
	<cfif email is "">
		<font size=2 face=verdana color=red>Please enter your email.<br>
		</font>
	<cfelse>
		<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id, name, passwd, loginname from player where email = '#email#'
        </cfquery>
		<cfif player.recordcount is 0>
			<font size=2 face=verdana color=red>No empire found with e-mail '<cfoutput>#email#</cfoutput>'</font><br>
			
		<cfelse>
			<cfmail to="#email#" from="#adminEmail#" server="#mailserver#" subject="1000 A.D. info">
				Here is the information you requested about your 1000 A.D. account(s)
				To play the game go to #webpath#login.cfm
				
				Your empire(s):
				<cfloop query="player">
					Login Name: #player.loginname#
					Password: #player.passwd#
					Empire Name: #player.name# 
					Empire ##: #player.id#
					
				</cfloop>
			</cfmail>
			<font size=2 face=verdana color=red>
			Information about your account(s) has been emailed to you.
			<br>
			<font face="verdana" size=2><a href="login.cfm">Go Back to 1000 A.D. Home page</a>
			</font>
			<cfabort>
		</cfif>
	</cfif>
<cfelseif eflag is "byempire">
	<cfset empire = trim(form.empirename)>
	<cfif empire is "">
		<font size=2 face=verdana color=red>Please enter empire name.<br>
		</font>
	<cfelse>
		<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id, name, passwd, email, loginname from player where name = '#empire#'
        </cfquery>
		<cfif player.recordcount is 0>
			<font size=2 face=verdana color=red>No empire found with name '<cfoutput>#empire#</cfoutput>'</font><br>
			
		<cfelse>
			<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000 A.D. info">
				Here is the information you requested about your 1000 A.D. account(s)
				To play the game go to #webpath#login.cfm
				
				Your empire(s):
				<cfloop query="player">
					Login Name: #player.loginname#
					Password: #player.passwd#
					Empire Name: #player.name# 
					Empire ##: #player.id#
					
				</cfloop>
			</cfmail>
			<font size=2 face=verdana color=red>
			Information about your account(s) has been emailed to you.
			<br>
			<font face="verdana" size=2><a href="login.cfm">Go Back to 1000 A.D. Home page</a>
			</font>
			<cfabort>			
		</cfif>
	</cfif>

</cfif>

<font face="verdana" size=4>Password Lookup</font>
<table border=1 cellpadding=0 cellspacing=0  bordercolor="darkslategray" width="400">
<tr>
	<td bgcolor="darkslategray"><font face="verdana" size=2 color="White">Lookup by e-mail</td>
</tr>
<tr>
	<td>
	<form action="forgotpassword.cfm" method="post">
	<input type="hidden" name="eflag" value="byemail">
	<font face="verdana" size=2>
	Enter your e-mail below that you <br>
	used to create your account:<br>
	<input type="Text" name="youremail" size="40">
	<br>
	<input type="Submit" value="     Lookup     " style="font-size:xx-small">
	</form>
	<br>
	
	</td>
</tr>
<tr>
	<td bgcolor="darkslategray"><font face="verdana" size=2 color="White">Lookup by Empire Name</td>
</tr>
<tr>
	<td>
	<form action="forgotpassword.cfm" method="post">
	<input type="hidden" name="eflag" value="byempire">
	<font face="verdana" size=2>
	Enter your empire name:<br>
	<input type="Text" name="empirename" size="40">
	<br>
	<input type="Submit" value="     Lookup     " style="font-size:xx-small">
	</form>
	</td>
</tr>
</table>
<font face="verdana" size=2><a href="login.cfm">Go Back to 1000 A.D. Home page</a>


</body>
</html>

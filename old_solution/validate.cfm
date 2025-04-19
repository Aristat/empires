<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Validate Account</title>
</head>

<body background="images/bg.gif" bgcolor="Black" alink="Aqua" link="Aqua" text="White" vlink="Aqua" topmargin="0" marginheight="0" leftmargin="0" marginwidth="0">

<cfparam name="vcode" default="">
<cfparam name="eflag" default="">
<cfparam name="eflag_message" default="">

<cfif eflag is "validate">
	<cfset vcode = trim(vcode)>
	<cfif vcode is not "">
		<cfquery datasource="#dsn#" name="p">
        	select id, name from player where validationcode = '#vcode#'
        </cfquery>
		<cfif p.recordcount is 0>
			<cfset eflag = "">
			<cfset eflag_message = "Invalid validation code.<br>">
		<cfelse>
			<cfquery datasource="#dsn#">
                update player set validated = 1 where id = #p.id#
            </cfquery>
			<cfset eflag_message = 'Empire #p.name# (#p.id#) validated.<br><a href="login.cfm">Login To Game</a>'>
		</cfif>
	<cfelse>
		<cfset eflag = "">
		<cfset eflag_message = "Please provide validation code.">
	</cfif>
<cfelseif eflag is "email">
	<cfset eflag = "">
	<cfset loginemail = trim(loginemail)>
	<cfquery datasource="#dsn#" name="p">
    	select id, loginname, name, email, validationCode from player where email = '#loginEmail#'
    </cfquery>
	<cfif p.recordcount is 0>
		<cfset eflag_message = "Empire with email '#loginemail#' does not exist.<br>">
	<cfelse>
		<cfloop query="p">
			<cfmail to="#p.email#" from="#adminEmail#" server="#mailserver#" subject="1000 A.D. Validation Code" type="HTML">
				Empire: #p.name# (#p.id#)<br>
				Your validation code is: #p.validationCode#<br>				
				You can validate your account at #webpath#validate.cfm<br>
				or just use this link to validate your account:<br>				
				#webpath#validate.cfm?vcode=#p.validationCode#&eflag=validate<br>				
				<br>				
				Thank You for playing 1000AD.<br>				
				If you have any question you can contact me at: andrew@c3chicago.com<br>		
			</cfmail>
		</cfloop>
		<cfset eflag_message = "E-mail has been sent with your validation code to #loginEmail#.<br>">
	</cfif>
</cfif>

<table border=0 cellspacing=0 cellpadding=0>
<tr><td colspan="3" align="center" background="images/header.jpg">
		<font face=verdana size=10 color="White"><b>1000   A. D.</b></font><br>
		<br>
		<font face=verdana size=2>
		<b>1000 A.D. is a free turn based strategy game. <br>
		All you need to play is a web browser. 		
		<br>
		<a href="http://www.adersoftware.com/thegame/">1000AD Home Page</a>
		</font>
	</td>
</tr>   
<tr>
	<td width="200" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="200" bordercolor="darkslategray">
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">
				<b>Instructions</b>
			</font>
			</td>
		</tr>
		<tr>
			<td><font face=verdana size=2 color="White">
				Each player has to validate his/her account before playing. This step is required.<br>
				If you are having problems validating your account please email <a href="mailto:andrew@c3chicago.com">andrew@c3chicago.com</a>
				<br><br>
				<b><a href="login.cfm">Back to Home</a></b>
			</td>
		</tr>
        </table>
	</td>
	<td width="10">&nbsp;</td>
	<td width="400" align="right" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="400" bordercolor="darkslategray">
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2>
				<b>Validate Account:</b>
			</td>
		</tr>
		<tr><td align="center"><font face="verdana" size="2">
		<cfif eflag_message is not "">
			<cfoutput><font face="verdana" size="2" color="Yellow"><b>#eflag_message#</b></font></cfoutput><br>
		</cfif>
		
		
		<cfif eflag is "">
			<cfparam name="eflag_message" default="">
			<form action="validate.cfm" method="post">
			<input type="hidden" name="eflag" value="validate">
			You should have received your validation code in the email you specified when creating your empire.<br>			
			Validation Code: <input type="Text" name="vcode" value="<cfoutput>#vcode#</cfoutput>" size=20 maxlength=50>
			<input type="Submit" value="Validate">
			</form><br>
			<br>
			<b>E-mail validation code to me:</b><br>
			You can use the form below to resend the validation code to your email account. Please enter your email below.<br>
			<form action="validate.cfm" method="post">
			<input type="hidden" name="eflag" value="email">
			<cfparam name="loginEmail" default="">
			Email: <input type="Text" name="loginEmail" value="<cfoutput>#loginemail#</cfoutput>" size=20 maxlength=50>
			<input type="Submit" value="E-mail Validation Code">
			</form><br>
			<br>
		</cfif>
		</td></tr>
		</table>
	</td>
</tr>
<tr><td colspan="3" align="center"><font face=verdana size=2 color="White">
	<hr noshade size="1" color="darkslategray">
	&copy; Copyright Ader Software 2000, 2001<br>
	<a href="mailto:andrew@c3chicago.com">Contact Us</a>
</td></tr>
</table>


</body>
</html>



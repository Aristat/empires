<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="100%"><font face="verdana" size="3"><b>Account Options</td>
</tr>
</table>
<br />

<!--- account options --->
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function confirmVacation(form)
{
	if (confirm("Are you sure you want to go to vacation mode?")) {
		form.eflag.value = 'vacation_empire';
		form.submit();
	}
	return false;
}
//-->
</SCRIPT>
<table border=0 cellspacing=0 cellpadding=2 style="border:thin outset" width="400">
<form action="index.cfm" method="post" onsubmit="return confirmVacation(this)">
<input type="hidden" name="page" value="account">
<input type="hidden" name="eflag" value="">
<tr>
	<td colspan="2" bgcolor="darkslategray">Vacation Mode</td>
</tr>  
<tr>
	<td colspan="2">
		<font color="Yellow">
		By going into vacation mode you will not be able to access your account for 3 days and noone will be
		able to attack you during that time. While in vacation mode, your turns will not accumulate.<br>
		You cannot go into vacation mode if you attacked someone in past one hour or shorter than 3 days before the game ends.
	</td>
</tr>
<tr>
	<td><font face="verdana" size=2>Login Name:</font></td>
	<td><input type="text" name="lName" size="20" maxlength="30"></td>
</tr>  
<tr>
	<td><font face="verdana" size=2>Current Password:</font></td>
	<td><input type="Password" name="curPassword" size="20" maxlength="30"></td>
</tr>  
<tr><td colspan="2" align="center"><input type="Submit" value="Activate Vacation Mode"></td></tr>
</form>
</table>
<br>
<br>



<table border=0 cellspacing=0 cellpadding=2 style="border:thin outset" width="400">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="account">
<input type="hidden" name="eflag" value="change_login">
<tr>
	<td colspan="2" bgcolor="darkslategray">Change Login Name</td>
</tr>  
<tr><td colspan="2"><font face="verdana" size=2 color="Yellow">Changing your login name does not change your Empire name</font></td></tr>
<tr>
	<td><font face="verdana" size=2>Login Name:</font></td>
	<td><input type="text" name="newLogin" size="30" maxlength="30" value="<cfoutput>#player.loginname#</cfoutput>"></td>
</tr>  
<tr><td colspan="2" align="center"><input type="Submit" value="Change Login"></td></tr>
</form>
</table>
<br>
<br>
<table border=0 cellspacing=0 cellpadding=2 style="border:thin outset" width="400">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="account">
<input type="hidden" name="eflag" value="change_pw">
<tr>
	<td colspan="2" bgcolor="darkslategray">Change Password</td>
</tr>  
<tr>
	<td><font face="verdana" size=2>Current Password:</font></td>
	<td><input type="Password" name="curPassword" size="20" maxlength="30"></td>
</tr>  
<tr>
	<td><font face="verdana" size=2>New Password:</font></td>
	<td><input type="Password" name="newPassword" size="20" maxlength="30"></td>
</tr>  
<tr>
	<td><font face="verdana" size=2>New Password (verify):</font></td>
	<td><input type="Password" name="newPassword2" size="20" maxlength="30"></td>
</tr>  
<tr><td colspan="2" align="center"><input type="Submit" value="Change Password"></td></tr>
</form>
</table>
<br>
<br>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function confirmDelete(form)
{
	if (confirm("Are you sure you want to delete your empire?")) {
		if (confirm("Are you 100% sure you want to do this?")) {
			if (confirm("Last warning. You are about to delete your empire. Are you sure?")) {
				form.eflag.value = 'delete_empire';
				form.submit();
			}
		}	
	}
	return false;
}
//-->
</SCRIPT>
<table border=0 cellspacing=0 cellpadding=2 style="border:thin outset" width="400">
<form action="index.cfm" method="post" onsubmit="return confirmDelete(this)">
<input type="hidden" name="page" value="account">
<input type="hidden" name="eflag" value="">
<tr>
	<td colspan="2" bgcolor="darkslategray">Delete My Empire</td>
</tr>  
<tr><td colspan="2"><font face="verdana" size=2 color="Yellow">You can delete your empire only if you haven't attacked someone in the past 24 hours.</font></td></tr>
<tr>
	<td><font face="verdana" size=2>Login Name:</font></td>
	<td><input type="text" name="lName" size="20" maxlength="30"></td>
</tr>  
<tr>
	<td><font face="verdana" size=2>Current Password:</font></td>
	<td><input type="Password" name="curPassword" size="20" maxlength="30"></td>
</tr>  
<tr><td colspan="2" align="center"><input type="Submit" value="Delete Empire"></td></tr>
</form>
</table>


<table border=0 cellpadding=0 cellspacing=0>
<tr><td height="5" colspan="20"></td></tr>
<tr><td width="15"></td>
<td>
<cfoutput>
<table border=0 cellpadding=2 cellspacing=0 style="border:1px solid #borderColor#">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="search">
<tr>
	<td>SEARCH DOCUMENTATION: </td>
	<cfparam name="searchstring" default="">
	<td><input type="Text" name="searchstring" value="#searchstring#" size="44" style="background-color:black;color:#linkColor#;font-size:10px;font-family:verdana;border:1px solid #bordercolor#"></td>
	<td><input type="Submit" value="Search" style="background-color:#bgcolor#;color:#linkColor#;font-size:11px;font-family:verdana;border:1px solid #bordercolor#"></td>	
</tr>
</form>
</table>
</cfoutput>
<tr><td width="15"></td>
</td></tr>
<tr><td height="5" colspan="20"></td></tr>
</table>
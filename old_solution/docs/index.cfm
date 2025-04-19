<cfset bgColor="##2E2F27">
<cfset borderColor = "##79786C">
<cfset midColor = "##393B31">
<cfset textColor = "##9C9683">
<cfset linkColor = "##C7BB9F">
<cfoutput>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<cfparam name="page" default="home">

<html>
<head>
<style type="text/css">
    TD {
        font-family: verdana;
        font-size: 12px;
		color: #textColor#;
		line-height:16px;
    }
	A {
		color: #linkColor#;
		decoration: none;
	}
	A:hover {
		color: yellow;
		decoration: underline;
	}
	BODY {
		scrollbar-base-color: #textColor#;
	}
</style>
	<title>1000 A.D. Documentation</title>
</head>
<body bgcolor="Black" text="#textColor#" link="#linkColor#" topmargin="0" leftmargin="0">
<table border=1 rules="none" cellpadding=0 cellspacing=0 width="780" bgcolor="#bgColor#" bordercolor="#borderColor#"> 
<tr>
	<td width="600" height="40" style="border-right:1px solid #borderColor#">
		<cfinclude template="topMenu.cfm">
	</td>
	<td width="180" valign="top" align="right" bgcolor="#midColor#">
		<span style="font-size:16px"><b>1000 A.D. Documentation</b></span>
		<br>
		<font face="verdana" size="1">Version #gameVersion#
		
	</td>
</tr>
<tr>
	<td valign="top" style="border-right:1px solid #borderColor#">
		<table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr>
			<td width="15"></td>
			<td bgcolor="Black" style="padding-left:10px;padding-right:10px;border-right:1px solid #borderColor#; border-bottom:1px solid #borderColor#; border-left:1px solid #borderColor#; border-top:1px solid #borderColor#"><cfinclude template="#page#.cfm"><br></td>
			<td width="15"></td>			
		</tr>
        </table>
	</td>
	<td valign="top" bgcolor="#midColor#" style="border-top:1px solid #borderColor#;border-bottom:1px solid #borderColor#;">
		<cfinclude template="leftmenu.cfm">
	</td>
</tr>
<tr>
	<td style="border-right:1px solid #borderColor#;">
		<cfinclude template="bottomMenu.cfm">
	</td>
	<td bgcolor="#midcolor#" align="right" style="font-size:10px" valign="bottom">
		<a href="http://www.1000ad.net/thegame/">1000 A.D. Home Page</a><br>
		<a href="mailto:andrew@c3chicago.com">Contact Us</a><br>
		&copy; AderSoftware 2001
	</td>
</tr>
</table>
</cfoutput>

</body>
</html>

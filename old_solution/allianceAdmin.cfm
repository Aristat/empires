<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Alliance Admin</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('alliance')">Help</a></td>
</tr>
</table>
<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from alliance where id = #player.allianceID#
</cfquery>

<cfif alliance.leaderID is playerID>
	<br>
	<table border=1 cellpadding=1 cellspacing=1 width="400" bordercolor="darkslategray">
	<form action="index.cfm" method="post">
	<input type="hidden" name="eflag" value="change_name">
	<input type="hidden" name="page" value="allianceAdmin">
	<tr>
		<td class="HEADER"><b>Change Alliance Name:</td>
	</tr>
	<tr>
		<td>Alliance name:
			<input type="Text" name="alliance_name" value="<cfoutput>#alliance.tag#</cfoutput>" size=20 maxlength="20">
			<input type="Submit" value="Change Name">
	</tr>
	</form>
	</table>


		<br>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
		<form action="index.cfm" method="post" name="allianceForm">
		<input type="hidden" name="page" value="allianceAdmin">
		<input type="hidden" name="eflag" value="change_description">
        <tr>
			<td class="HEADER" align="center"><b>Alliance Public Information:</td>
		</tr>
		<tr>
			<td nowrap>
				<table border=0 cellpadding=0 cellspacing=0>
				<tr>
				<td><a href="javascript:insertCode('[b][/b]', document.allianceForm.description)"><img src="images/icon_bold.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[i][/i]', document.allianceForm.description)"><img src="images/icon_italic.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[u][/u]', document.allianceForm.description)"><img src="images/icon_underline.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[center][/center]', document.allianceForm.description)"><img src="images/icon_center.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[url][/url]', document.allianceForm.description)"><img src="images/icon_url.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[email][/email]', document.allianceForm.description)"><img src="images/icon_email.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[img][/img]', document.allianceForm.description)"><img src="images/icon_picture.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[quote][/quote]', document.allianceForm.description)"><img src="images/icon_quote.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[list][*] [/*][*] [/*][/list]', document.allianceForm.description)"><img src="images/icon_list.gif" border="0"></a></td>
				<td><a href="javascript:insertSmile('allianceForm.description')"><img src="images/icon_editor_smile.gif" border="0"></a></td>
				<td><select name="fontColor" onchange="insertFontColor(this, document.allianceForm.description)">
				<cfloop list="White,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen" index="color">
				<option value="<cfoutput>#color#</cfoutput>"><cfoutput>#color#</cfoutput>
				</cfloop>
				</select></td>
				<td><select name="fontSize" onchange="insertFontSize(this, document.allianceForm.description)">
				<cfloop list="1,2,3,4,5" index="i">
				<option value="<cfoutput>#i#</cfoutput>"><cfoutput>#i#</cfoutput>				
				</cfloop>
				</select></td>
				</tr>       
                </table>
				
			</td>
		</tr>
		<tr>
			<td><textarea name="description" rows=10 cols=45><cfoutput>#alliance.description#</cfoutput></textarea></td>
		</tr>
		<tr><td align="center"><input type="Submit" value="Update Public Info"></td></tr>		
		<tr>
			<td><font face="verdana" size=2><cf_getFormatedText text="#alliance.description#" showOutput="true"></td>
		</tr>
		
		</form>
		</table>		
</cfif>


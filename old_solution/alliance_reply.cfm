<cfif player.allianceID gt 0>
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
    <!--
    function checkTForm(form)
	{
		if (form.forum_message.value == "") {
			alert("Please enter the message.");
			form.forum_message.focus();
			return false;
		}
		return true;
	}
    //-->
    </SCRIPT>
	<table border=1 cellpadding=1 cellspacing=1 width="590" bordercolor="darkslategray">
	<form action="index.cfm" method="post" name="allianceForm" onsubmit="return checkTForm(this)">
	<input type="hidden" name="page" value="alliance_newtopic">
	<input type="hidden" name="eflag" value="reply_topic">
	<input type="hidden" name="topicid" value="<cfoutput>#topicid#</cfoutput>">
    <tr>
		<td></td>
		<td>
			<table border=0 cellpadding=0 cellspacing=0>
			<tr>
			<td><a href="javascript:insertCode('[b][/b]', document.allianceForm.forum_message)"><img src="images/icon_bold.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[i][/i]', document.allianceForm.forum_message)"><img src="images/icon_italic.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[u][/u]', document.allianceForm.forum_message)"><img src="images/icon_underline.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[center][/center]', document.allianceForm.forum_message)"><img src="images/icon_center.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[url][/url]', document.allianceForm.forum_message)"><img src="images/icon_url.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[email][/email]', document.allianceForm.forum_message)"><img src="images/icon_email.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[img][/img]', document.allianceForm.forum_message)"><img src="images/icon_picture.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[quote][/quote]', document.allianceForm.forum_message)"><img src="images/icon_quote.gif" border="0"></a></td>
			<td><a href="javascript:insertCode('[list][*] [/*][*] [/*][/list]', document.allianceForm.forum_message)"><img src="images/icon_list.gif" border="0"></a></td>
			<td><a href="javascript:insertSmile('allianceForm.forum_message')"><img src="images/icon_editor_smile.gif" border="0"></a></td>
			<td><select name="fontColor" onchange="insertFontColor(this, document.allianceForm.forum_message)">
			<cfloop list="White,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen" index="color">
			<option value="<cfoutput>#color#</cfoutput>"><cfoutput>#color#</cfoutput>
			</cfloop>
			</select></td>
			<td><select name="fontSize" onchange="insertFontSize(this, document.allianceForm.forum_message)">
			<cfloop list="1,2,3,4,5" index="i">
			<option value="<cfoutput>#i#</cfoutput>"><cfoutput>#i#</cfoutput>				
			</cfloop>
			</select></td>
			</tr>       
            </table>		
		</td>
	</tr>
	<tr>
		<td valign="top">Message:</td>
		<td><textarea name="forum_message" rows="10" cols="50"></textarea>
			<br>
			<input type="Submit" value="Reply to Topic">
		</td>
	</tr>
	
	</form>
    </table>

</cfif>
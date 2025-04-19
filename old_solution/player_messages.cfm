<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfparam name="messageFolder" default="inbox">
<cfparam name="menuPlayerID" default="0">
	
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Messages</td>
	<td class="HEADER" align="center" width="8%"><b><!---a href="javascript:openHelp('trade')">Help</a---></td>
</tr>
</table>
	
	
<cfoutput>
<table border=1 cellspacing=1 cellpadding=1 width="100%" bordercolor="darkslategray">
<tr>
	<cfloop list="Inbox,Saved,Sent,Deleted,Options" index="m">
		<cfif messageFolder is m>
			<td bgcolor="silver" align="center"><font face="verdana" size="2" color="Black"><b>#m#</b></font></td>
		<cfelse>
			<td bgcolor="darkslategray" align="center"><a href="index.cfm?page=player_messages&messageFolder=#m#"><font face="verdana" size="2">#m#</font></a></td>		
		</cfif>		
	</cfloop>
</tr>
</table>
</cfoutput>

<cfif messageFolder is "inbox">
<br>
<table border=1 cellpadding=1 cellspacing=1 bordercolor="darkslategray">
<tr>
	<td bgcolor="darkslategray"><a name="NEWMESSAGE"><font face="verdana" size=2 color=white>Send New Message</font></a></td>
</tr>
<cfset allianceList = "">
<cfif player.allianceID gt 0>
	<cfquery name="member" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, name from player where allianceID = #player.allianceID# order by name
    </cfquery>
	<cfset allianceList = valueList(member.id)>
</cfif>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function quickLookup(s)
{
	document.rForm.toPlayerID.value = s.options[s.selectedIndex].value;
}
//-->
</SCRIPT>
<form action="index.cfm" method="post" name="rForm" onsubmit="return checkForm(this)">
<input type="hidden" name="eflag" value="add_message">
<input type="hidden" name="page" value="player_messages">
<tr>
	<td><font face="verdana" size=2>Message To (Empire #):</font>

	<input type="Text" size="15" name="toPlayerID" value="<cfoutput>#menuPlayerID#</cfoutput>">
	<cfif player.allianceID gt 0>	
	<select name="ql" onchange="quickLookup(this)">
	<option value="">--- Quick Lookup ---
		<option value="<cfoutput>#alliancelist#</cfoutput>">All Alliance Members
		<cfoutput query="member">
		<option value="#member.id#">#member.name# (###member.id#)
		</cfoutput>
		<option value="">--------------------------------		
	</select>
	</cfif>	
	<br>
	<font face="verdana" size="1">(You can seperate multiple numbers with commas)</font>
	</td>
</tr>
<tr>
	<td>
		<table border=0 cellpadding=0 cellspacing=0>
		<tr>
		<td><a href="javascript:insertCode('[b][/b]', document.rForm.pmessage)"><img src="images/icon_bold.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[i][/i]', document.rForm.pmessage)"><img src="images/icon_italic.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[u][/u]', document.rForm.pmessage)"><img src="images/icon_underline.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[center][/center]', document.rForm.pmessage)"><img src="images/icon_center.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[url][/url]', document.rForm.pmessage)"><img src="images/icon_url.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[email][/email]', document.rForm.pmessage)"><img src="images/icon_email.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[img][/img]', document.rForm.pmessage)"><img src="images/icon_picture.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[quote][/quote]', document.rForm.pmessage)"><img src="images/icon_quote.gif" border="0"></a></td>
		<td><a href="javascript:insertCode('[list][*] [/*][*] [/*][/list]', document.rForm.pmessage)"><img src="images/icon_list.gif" border="0"></a></td>
		<td><a href="javascript:insertSmile('rForm.pmessage')"><img src="images/icon_editor_smile.gif" border="0"></a></td>
		<td><select name="fontColor" onchange="insertFontColor(this, document.rForm.pmessage)">
		<cfloop list="White,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen" index="color">
		<option value="<cfoutput>#color#</cfoutput>"><cfoutput>#color#</cfoutput>
		</cfloop>
		</select></td>
		<td><select name="fontSize" onchange="insertFontSize(this, document.rForm.pmessage)">
		<cfloop list="1,2,3,4,5" index="i">
		<option value="<cfoutput>#i#</cfoutput>"><cfoutput>#i#</cfoutput>				
		</cfloop>
		</select></td>
		</tr>       
        </table>
	
	</td>
</tr>
<tr>
	<td><textarea name="pmessage" rows="6" cols="70" style="font-size:10px;font-family:verdana;width:590"></textarea></td>
</tr>
<tr>
	<td align="center"><input type="Submit" value="Send" style="font-size:xx-small;width:100"></td>
</tr>
</form>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
document.rForm.pmessage.focus();
//-->
</SCRIPT>
</table>
<br>
<br>

<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from playerMessage where toplayerID = #playerID# and messageType = 0 order by createdOn desc
</cfquery>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function replay(pid, mid)
{
	var messages = new Array(<cfoutput>#msg.recordcount#</cfoutput>);
	<cfloop query="msg">
		<cfset rmsg = replaceList(msg.message, "#chr(10)#,#chr(13)#,""", "\n, ,&quot;")>
		messages[<cfoutput>#msg.currentrow#</cfoutput>] = "[quote]<cfoutput>#rmsg#</cfoutput>[/quote]";
	</cfloop>
	var form = document.rForm;
	form.toPlayerID.value = pid;
	form.pmessage.value = messages[mid];
}
function checkForm(form)
{
	var temp = form.pmessage.value;
	if (temp.length > 5000) {
		alert("Your message exceeds allowable 5000 characters!");
		return false;
	}
	return true;
}
//-->
</SCRIPT>

<cfif msg.recordcount is 0>
	<font size=2 face=verdana color=red>You do not have any messages.</font>
<cfelse>
<table border=1 cellpadding=1 cellspacing=1 width="100%" bordercolor="darkslategray">
<cfset maxMessageID = 0>
<cfoutput query="msg">
	<cfif msg.id gt maxMessageID><cfset maxMessageID = msg.id></cfif>
<tr>
	<td bgcolor="darkslategray"><font face="verdana" size=2 color="Aqua"><cfif msg.viewed is 0><b>NEW!</cfif>&nbsp;&nbsp;</font>
		<font face="verdana" size=2 color="White">Message from #msg.fromPlayerName# (#msg.fromPlayerID#)
		sent on #DateFormat(msg.createdon, "mm/dd/yyyy")# at #timeFormat(msg.createdOn, "hh:mm tt")#
	</td>
</tr>
<tr>
	<td><font face="verdana" size=2 color="White">
		<cf_getFormatedText text="#msg.message#" showOutput="true">
		<br>
		<font size="1">
		<a href="##NEWMESSAGE" onclick="replay(#msg.fromPlayerID#, #msg.currentrow#)">Reply</a> |
		<a href="index.cfm?page=player_messages&eflag=delete_message&messageID=#msg.id#">Delete This Message</a> |
		<a href="index.cfm?page=player_messages&eflag=save_message&messageID=#msg.id#">Save This Message</a> |
		<a href="index.cfm?page=player_messages&eflag=addblock&blockID=#msg.fromPlayerID#&messageFolder=options">Block Messages from #msg.fromPlayerID#</a>
	</td>
</tr>
<tr><td height="5" bgcolor="darkslategray"></td></tr>
</cfoutput>
</table>
<a href="index.cfm?page=player_messages&eflag=delete_all_messages&maxmessageID=<cfoutput>#maxMessageID#</cfoutput>">Delete All Messages</a>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update playerMessage set viewed = 1 where viewed = 0 and toplayerID = #playerID# and messageType = 0
    </cfquery>
	<cfquery datasource="#dsn#">
        update player set hasNewMessages = 0 where id = #playerID#
    </cfquery>
</cfif>

<cfelseif messageFolder is "saved">

<br>
<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from playerMessage where toplayerID = #playerID# and messageType = 4 order by createdOn desc
</cfquery>
<cfif msg.recordcount is 0>
	<font size=2 face=verdana color=red>You do not have any saved messages.</font>
<cfelse>
<table border=1 cellpadding=1 cellspacing=1 width="100%" bordercolor="darkslategray">
<cfoutput query="msg">
<tr>
	<td bgcolor="darkslategray">
		<font face="verdana" size=2 color="White">Message from #msg.fromPlayerName# (#msg.fromPlayerID#)
		sent on #DateFormat(msg.createdon, "mm/dd/yyyy")# at #timeFormat(msg.createdOn, "hh:mm tt")#
	</td>
</tr>
<tr>
	<td><font face="verdana" size=2 color="White">
		#replace(msg.message, "#chr(10)#", "<BR>", "ALL")#
		<br>
		<font size="1">
		<a href="index.cfm?page=player_messages&eflag=delete_message&messageID=#msg.id#&messageFolder=saved">Delete This Message</a>
	</td>
</tr>
<tr><td height="5" bgcolor="darkslategray"></td></tr>
</cfoutput>
</table>
<a href="index.cfm?page=player_messages&eflag=delete_all_saved&messageFolder=saved">Delete All Saved Messages</a>

</cfif>
<br>
<br>
<cfelseif messageFolder is "sent">
	<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select top 250 id,toPlayerName,toPlayerID,viewed,createdOn from playerMessage where fromPlayerID = #playerID# and messageType in (0, 2, 4) order by createdOn desc
	</cfquery>
	<cfif msg.recordcount is 0>
		<font size=2 face=verdana color=red>You do not have any sent messages.</font>
	<cfelse>
		<br>
		
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
        <tr>
			<td class="HEADER">Sent To</td>
			<td class="HEADER">Date/Time</td>
			<td class="HEADER">Received?</td>
		</tr>
		<cfoutput query="msg">
		<tr>
			<td><a href="index.cfm?page=player_messages&messageFolder=viewMessage&messageID=#msg.id#">#msg.toPlayerName# (#msg.toPlayerID#)</a></td>
			<td>#DateFormat(msg.createdon, "mm/dd/yyyy")# at #timeFormat(msg.createdOn, "hh:mm tt")#</td>
			<td>#YesNoFormat(msg.viewed)#</td>
		</tr>
		</cfoutput>
        </table>	
		<cfif msg.recordcount gte 250>
			Showing latest 250 sent messages...
		</cfif>
	</cfif>
<cfelseif messageFolder is "deleted">
	<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select top 250 id,fromPlayerName,fromPlayerID,viewed,createdOn from playerMessage where toPlayerID = #playerID# and messageType = 2 order by createdOn desc
	</cfquery>
	<cfif msg.recordcount is 0>
		<font size=2 face=verdana color=red>You do not have any deleted messages.</font>
	<cfelse>
		<br>
		
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
        <tr>
			<td class="HEADER">Received From</td>
			<td class="HEADER">Date/Time</td>
		</tr>
		<cfoutput query="msg">
		<tr>
			<td><a href="index.cfm?page=player_messages&messageFolder=viewMessage&messageID=#msg.id#">#msg.fromPlayerName# (#msg.fromPlayerID#)</a></td>
			<td>#DateFormat(msg.createdon, "mm/dd/yyyy")# at #timeFormat(msg.createdOn, "hh:mm tt")#</td>
		</tr>
		</cfoutput>
        </table>	
		<cfif msg.recordcount gte 250>
			Showing latest 250 sent messages...
		</cfif>
	</cfif>
	
<cfelseif messageFolder is "viewMessage">

	<br>
	<cfset messageID = val(messageID)>
	<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select * from playerMessage where (fromPlayerID = #playerID# or toPlayerID = #playerID#) and id = #messageID#
	</cfquery>
	<cfif msg.recordcount is 0>
		<font size=2 face=verdana color=red>Invalid Message.</font>
	<cfelse>
	<table border=1 cellpadding=1 cellspacing=1 width="100%" bordercolor="darkslategray">
	<cfoutput query="msg">
	<tr>
		<td bgcolor="darkslategray">
			<font face="verdana" size=2 color="White">Message to #msg.toPlayerName# (#msg.toPlayerID#)
			sent on #DateFormat(msg.createdon, "mm/dd/yyyy")# at #timeFormat(msg.createdOn, "hh:mm tt")#
		</td>
	</tr>
	<tr>
		<td><font face="verdana" size=2 color="White">
			<cf_getFormatedText text="#msg.message#" showoutput="true">
			<br>
		</td>
	</tr>
	<tr><td height="5" bgcolor="darkslategray"></td></tr>
	</cfoutput>
	</table>
	<font face="verdana" size="2"><a href="index.cfm?page=player_messages&messageFolder=sent">Back...</a></font>
	</cfif>
<cfelseif messageFolder is "options">
	<font face="verdana" size="2"><b>You do not wish to receive messages from the following empires:</b></font>
	<br>
	<cfquery datasource="#dsn#" name="block">
    	select blockMessages.id, player.id as pid, player.name from 
		player inner join blockMessages on player.id = blockMessages.blockPlayerID
		where blockMessages.playerID = #playerID#
		order by player.name		
    </cfquery>
	<cfoutput query="block">
	<li>#block.name# (#block.pid#) - <a href="index.cfm?page=player_messages&messageFolder=options&blockid=#block.id#&eflag=unblock">Unblock</a>
	</cfoutput>
	<cfif block.recordcount is 0>None<br></cfif>
	<br>
	<br>
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="player_messages">
	<input type="hidden" name="messageFolder" value="options">
	<input type="hidden" name="eflag" value="addblock">
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="150">
       <tr>
		<td nowrap colspan="2" bgcolor="darkslategray" align="center"><font face=verdana size=2 color=white><b>Block Messages From Player</b></font></td>
	</tr>
	<tr>
		<td><font face=verdana size=2>Player #:
			<input type="text" name="blockID" value=0 size=3 style="font-size:10px">
			<input type="Submit" value="Block" style="font-size:10px">			
		</td>
	</tr>	
	</table>
	</form>
</cfif>

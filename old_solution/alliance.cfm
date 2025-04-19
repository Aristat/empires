<!--- 
	Project: 1000 AD
	Author: Andrew Deren - Ader Software 2000 http://www.adersoftware.com
	File: alliance.cfm
	Date: 12/07/2000
 --->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Alliance</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('alliance')">Help</a></td>
</tr>
</table>
 
 
<cfif deathMatchMode or allianceMaxMembers is 0>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<cfif player.hasAllianceNews is 1>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	update player set hasAllianceNews = 0 where id = #playerID#
	</cfquery>
</cfif>

<cfif player.allianceID is 0><!--- doesn't belongs to any alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, tag from alliance order by tag
    </cfquery>

	<br>
	<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray" width="250">
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="alliance">
	<input type="hidden" name="eflag" value="join_alliance">
	<tr>
		<td class="HEADER">Join Alliance</td>
	</tr>
	<tr>
		<td nowrap>Alliance Tag:
		<select name="joinAllianceID">
		<option value="0">--- Select One ---
		<cfoutput query="alliance">
		<option value="#alliance.id#">#alliance.tag#
		</cfoutput>
		</select>
		<br>
		Password: &nbsp;&nbsp; <input type="Text" name="aPassword" size="20" maxlength="20">
		<center>
		<input type="Submit" value="Join" style="width:100">
		</td>
	</tr>
	</form>
	</table>
<br>
<br>
	<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray" width="250">
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="alliance">
	<input type="hidden" name="eflag" value="create_alliance">
	<tr>
		<td class="HEADER">Create New Alliance</td>
	</tr>
	<tr>
		<td nowrap>Alliance Tag:
		<input type="Text" name="newTag" size="20" maxlength="15">
		<br>
		Password: &nbsp;&nbsp; <input type="Text" name="aPassword" size="20" maxlength="20">
		<center>
		<input type="Submit" value="Create Alliance" style="width:100">
		</td>
	</tr>
	</form>
	</table>	
	<br>
	
<cfelse>
	<cfquery name="all" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, tag from alliance where id <> #player.allianceID# order by tag
    </cfquery>
	
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from alliance where id = #player.allianceID#
    </cfquery>
	<cfquery datasource="#dsn#" name="allaly">
        select tag from alliance where ally1 = #player.allianceID# or ally2 = #player.allianceID# or ally3 = #player.allianceID# or ally4 = #player.allianceID# or ally5 = #player.allianceiD# order by tag
    </cfquery>
	<cfquery datasource="#dsn#" name="allwar">
        select tag from alliance where war1 = #player.allianceID# or war2 = #player.allianceID# or war3 = #player.allianceID# or war4 = #player.allianceID# or war5 = #player.allianceid# order by tag
    </cfquery>
	
	<center><font face="verdana" size=4><b>Alliance: <cfoutput>#alliance.tag#</cfoutput></font>
		<br><font size=3><a href="index.cfm?page=alliance_forums">Alliance Forums</a>
		<cfif alliance.leaderID is playerID>
		| <a href="index.cfm?page=allianceAdmin">Alliance Admin</a>
		</cfif>
		</font>
	</center>
	<br>
		<cfquery name="member" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id, name, lastLoad, (pland+mland+fland) as totalland, score, (swordsman+horseman+archers+trainedPeasants+thieves+catapults+macemen) as totalarmy,
			alliancememberType as isTrusted
			from player where allianceID = #alliance.id#
			order by score desc
        </cfquery>

	
	<!--- show aid log --->
	<cfif alliance.leaderID is playerID or player.allianceMemberType is 1>
	<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="alliance">
	<cfparam name="aidLogHours" default="0">
    <tr><td class="HEADER">View members aid log for the past <input  style="font-size:10px" type="Text" name="aidLogHours" value="<cfoutput>#aidLogHours#</cfoutput>" size="3" maxlength="3"> hours <input type="Submit" value="View" style="font-size:10px"></td></tr>
	<cfif aidLogHours gt 0>
		<cfset dbHours = 0 - abs(val(aidLogHours))>
		<cfset startDate = dateAdd("h", dbHours, now())> 
		<cfquery datasource="#dsn#" name="aidLog">
			<!---
        	select aidLog.*, player.id as pid, player.name from aidLog inner join player on aidLog.fromPlayerID = player.id
			where player.allianceID = #alliance.id# and aidLog.createdOn > #startDate#
			order by aidLog.createdon 
			--->
		select distinct aidLog.*, fromPlayer.name as fromPlayerName, toPlayer.Name as toPlayerName
		from (aidLog inner join player fromPlayer on aidLog.fromPlayerID = fromPlayer.id) 
			inner join player toPlayer on aidLog.toPlayerID = toPlayer.id
		where (toPlayer.allianceID = #alliance.id# or fromPlayer.allianceID = #alliance.id#)
			and aidLog.createdOn > #startDate#
			order by aidLog.createdon 			
		</cfquery>
		
		<tr>
		<td><font face="verdana" size=1>
		<cfif aidLog.recordcount is 0>
		No Aid Transfers.
		<cfelse>
		<cfoutput query="aidLog">

			<b>From #aidLog.fromplayername# (#aidlog.fromPlayerID#) to #aidLog.toplayername# (#aidlog.toPlayerID#)<br>
			on #DateFormat(aidLog.createdOn, "mm/dd/yyyy")#
			at #TimeFormat(aidLog.createdOn, "hh:mm tt")#</b>:<br>
			<cfloop list="wood,food,iron,gold,swords,bows,horses,tools,maces" index="good">
				<cfset qty = evaluate("aidLog.#good#")>
				<cfif qty gt 0>#numberFormat(qty)# #good#, </cfif>
			</cfloop>
			<hr noshade size="1">
		</cfoutput>
			<cfoutput>#aidLog.recordCount# aid(s)</cfoutput>
		</cfif>
		</td>
		</tr>
	</cfif>	
	</form>
    </table>
	<br />
	
	</cfif>
		
	
	<cfif alliance.leaderID is playerID>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
        <tr>
			<td colspan="2" class="HEADER" align="center">Alliance Relations</td>
		</tr>
		<form action="index.cfm" method="post">
		<input type="hidden" name="page" value="alliance">
		<input type="hidden" name="eflag" value="change_relations">
		<tr>
			<td valign="top" width="50%" align="center"><b>Allies:</b><br>
				<cfloop from="1" to="5" index="i">
					<cfset aID = evaluate("alliance.ally#i#")>
					<select name="<cfoutput>n_ally#i#</cfoutput>">
					<option value="0">--- None ---					
					<cfoutput query="all">
						<option value="#all.id#" <cfif all.id is aID>selected</cfif>>#all.tag#
					</cfoutput>
					</select>		
					<br>
								
				</cfloop>
			</td>
			<td valign="top" width="50%" align="center"><b>War:</b><br>
				<cfloop from="1" to="5" index="i">
					<cfset aID = evaluate("alliance.war#i#")>
					<select name="<cfoutput>n_war#i#</cfoutput>">
					<option value="0">--- None ---					
					<cfoutput query="all">
						<option value="#all.id#" <cfif all.id is aID>selected</cfif>>#all.tag#
					</cfoutput>
					</select>					
					<br>
					
				</cfloop>
			</td>
		</tr>
		<tr>
			<td valign="top">
				<font face="verdana" size=2>
				<b>Alliances that have your alliance on the ally list:</b><br>
					<cfloop query="allaly">
						<cfoutput>#allaly.tag#<br></cfoutput>
					</cfloop>
					<cfif allaly.recordcount is 0>None</cfif>
			</td>
			<td valign="top">
				<font face="verdana" size=2>
				<b>Alliances that have your alliance on the war list:</b><br>
				<cfloop query="allwar">
					<cfoutput>#allwar.tag#<br></cfoutput>
				</cfloop>
				<cfif allwar.recordcount is 0>None</cfif>
				
			</td>
			
		</tr>
		<tr><td colspan="2" align="center"><input type="Submit" value="Change Relations"></td></tr>
		</form>
        </table>
		<br>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
		<form action="index.cfm" method="post" name="allianceForm">
		<input type="hidden" name="page" value="alliance">
		<input type="hidden" name="eflag" value="change_news">
        <tr>
			<td class="HEADER" align="center">Alliance News:</td>
		</tr>
		<tr>
			<td nowrap>
				<table border=0 cellpadding=0 cellspacing=0>
				<tr>
				<td><a href="javascript:insertCode('[b][/b]', document.allianceForm.news)"><img src="images/icon_bold.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[i][/i]', document.allianceForm.news)"><img src="images/icon_italic.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[u][/u]', document.allianceForm.news)"><img src="images/icon_underline.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[center][/center]', document.allianceForm.news)"><img src="images/icon_center.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[url][/url]', document.allianceForm.news)"><img src="images/icon_url.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[email][/email]', document.allianceForm.news)"><img src="images/icon_email.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[img][/img]', document.allianceForm.news)"><img src="images/icon_picture.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[quote][/quote]', document.allianceForm.news)"><img src="images/icon_quote.gif" border="0"></a></td>
				<td><a href="javascript:insertCode('[list][*] [/*][*] [/*][/list]', document.allianceForm.news)"><img src="images/icon_list.gif" border="0"></a></td>
				<td><a href="javascript:insertSmile('allianceForm.news')"><img src="images/icon_editor_smile.gif" border="0"></a></td>
				<td><select name="fontColor" onchange="insertFontColor(this, document.allianceForm.news)">
				<cfloop list="White,Red,Yellow,Pink,Green,Orange,Purple,Blue,Beige,Brown,Teal,Navy,Maroon,LimeGreen" index="color">
				<option value="<cfoutput>#color#</cfoutput>"><cfoutput>#color#</cfoutput>
				</cfloop>
				</select></td>
				<td><select name="fontSize" onchange="insertFontSize(this, document.allianceForm.news)">
				<cfloop list="1,2,3,4,5" index="i">
				<option value="<cfoutput>#i#</cfoutput>"><cfoutput>#i#</cfoutput>				
				</cfloop>
				</select></td>
				</tr>       
                </table>
				
			</td>
		</tr>
		<tr>
			<td><textarea name="news" rows=10 cols=45><cfoutput>#alliance.news#</cfoutput></textarea></td>
		</tr>
		<tr><td align="center"><input type="Submit" value="Update News"></td></tr>		
		<tr>
			<td><font face="verdana" size=2><cf_getFormatedText text="#alliance.news#" showOutput="true"></td>
		</tr>
		
		</form>
		</table>
		
		<br>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
		<form action="index.cfm" method="post">
		<input type="hidden" name="page" value="alliance">
		<input type="hidden" name="eflag" value="change_password">
        <tr>
			<td class="HEADER" align="center">Leader Options:</td>
		</tr>
		<tr>
			<td>
			Change alliance password to <input type="Text" value="<cfoutput>#alliance.passwd#</cfoutput>" name="aPassword" size="10" maxlength="20">
			<input type="Submit" value="Change">
			</td>
		</tr>
		</form>
		</table>
		<br>
		<form action="index.cfm" method="post" onsubmit="return confirm('Are you sure you want to disband this alliance?')">
		<input type="hidden" name="page" value="alliance">
		<input type="hidden" name="eflag" value="finish_alliance">
		<input type="hidden" name="allianceTag" value="<cfoutput>#alliance.tag#</cfoutput>">
		<input type="Submit" value="Disband Alliance">
		</form>
				
	<cfelse><!--- not a leader --->
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
        <tr>
			<td colspan="2" class="HEADER" align="center">Alliance Relations</td>
		</tr>
		<tr>
			<td valign="top" width="50%"><b>Allies:</b><br>
				<cfset hasAllies = false>
				<cfloop from="1" to="5" index="i">
					<cfset aID = evaluate("alliance.ally#i#")>
					<cfquery name="ally" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    	select tag from alliance where id = #aID#
                    </cfquery>
					<cfif ally.recordcount gt 0>
						<cfoutput>#ally.tag#<br></cfoutput>
						<cfset hasAllies = true>
					</cfif>					
				</cfloop>
				<cfif not hasAllies>No Allies</cfif>
			</td>
			<td valign="top" width="50%"><b>War:</b><br>
				<cfset hasWar = false>
				<cfloop from="1" to="5" index="i">
					<cfset aID = evaluate("alliance.war#i#")>
					<cfquery name="ally" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    	select tag from alliance where id = #aID#
                    </cfquery>
					<cfif ally.recordcount gt 0>
						<cfoutput>#ally.tag#<br></cfoutput>
						<cfset hasWar = true>
					</cfif>
				</cfloop>
				<cfif not hasWar>No War</cfif>
			</td>
		</tr>
		<tr>
			<td valign="top">
				<font face="verdana" size=2>
				<b>Alliances that have your alliance on the ally list:</b><br>
					<cfloop query="allaly">
						<cfoutput>#allaly.tag#<br></cfoutput>
					</cfloop>
					<cfif allaly.recordcount is 0>None</cfif>
			</td>
			<td valign="top">
				<font face="verdana" size=2>
				<b>Alliances that have your alliance on the war list:</b><br>
				<cfloop query="allwar">
					<cfoutput>#allwar.tag#<br></cfoutput>
				</cfloop>
				<cfif allwar.recordcount is 0>None</cfif>
				
			</td>
			
		</tr>
		
        </table>
		<br>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
        <tr>
			<td colspan="2" class="HEADER" align="center">Alliance News:</td>
		</tr>
		<tr>
			<td><font face="verdana" size=2><cf_getFormatedText text="#alliance.news#" showOutput="true"></td>
		</tr>
		</table>
		<br>
		<br>
		<form action="index.cfm" method="post" onsubmit="return confirm('Are you sure you want to leave this alliance?')">
		<input type="hidden" name="page" value="alliance">
		<input type="hidden" name="eflag" value="leave_alliance">
		<input type="hidden" name="allianceTag" value="<cfoutput>#alliance.tag#</cfoutput>">
		<input type="Submit" value="Leave This Alliance">
		</form>
	</cfif>
	
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
        <tr>
			<td colspan="2" class="HEADER" align="center">Alliance Members:</td>
		</tr>
		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
        <!--
        function giveLeadership(pID, pName) {
			if (confirm("Are you sure you want to change the leadership of this alliance to " + pName))		
				window.open('index.cfm?page=alliance&eflag=give_leadership&newLeader=' + pID + '&r=' + Math.random(), '_self');
		}
        function removeFromAlliance(pID, pName) {
			if (confirm("Are you sure you want to remove " + pName + " from your alliance?")) 
				window.open('index.cfm?page=alliance&eflag=remove_from_alliance&removeID=' + pID + '&r=' + Math.random(), '_self');
		}
        //-->
        </SCRIPT>
		<tr><td align="center">
		<cfoutput query="member">
			<cfif member.isTrusted is 1><b><u></cfif>#member.name# (###member.id#) <cfif member.isTrusted is 1></u></b></cfif><cfif member.id is alliance.leaderID><font color="Red"><b>&nbsp;&nbsp;&nbsp;Alliance Leader</b></font></cfif><br>
			<cfquery name="memberRank" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
            	select count(*)+1 as cnt from player where score > #member.score#
            </cfquery>
			Rank: #memberRank.cnt#<br>			
			Score: #NumberFormat(member.score)#<br>
			Land: #NumberFormat(member.totalland)#<br>
			
			<cfif player.allianceMemberType is 1 or playerID is alliance.leaderID>
				Army: #NumberFormat(member.totalarmy)#<br>
				<font color=yellow size="1">
				<cfif not isDate(member.lastLoad)><font coor=red>Never Played</font>
				<cfelse>
					<cfset h = dateDiff("h", member.lastLoad, now())>
					<cfset m = dateDiff("n", member.lastLoad, Now())>
					<cfset m = m - (h*60)>
					<cfif h is 0 and m lte 10>
						<font color=red>* Online Now</font>
					<cfelse>
						Last played: <cfif h gt 0>#h# hours and </cfif> #m# minutes ago.
					</cfif>
					<br>
				</cfif>
				</font>
				<cfif member.id is not playerID and playerID is alliance.leaderID>
				<font face="verdana" size=1>
				<a href="index.cfm?page=alliance&eflag=viewArmy&memberID=#member.id#">View Army</a>
				<br>
				<a href="index.cfm?page=alliance&eflag=changeStatus&memberID=#member.id#">
				<cfif member.isTrusted is 1>Change to Starting Member<cfelse>Change to Trusted Member</cfif></a>
				<br>
				<a href="javascript:removeFromAlliance('#member.id#', '#member.name#')">Remove From Alliance</a>
				<br>
				<a href="javascript:giveLeadership('#member.id#', '#member.name#')">Give Leadership</a><br>

				</font>
				</cfif>
			</cfif>
			<cfif member.currentrow is not member.recordcount><hr noshade size="2" color="darkslategray"></cfif>
		</cfoutput>
			</td>
		</tr>
		</table>
		<br>
	
</cfif>
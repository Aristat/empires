<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
	<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
    <!--
    function openChatWindow()
	{
		window.open("chat.cfm?", "_blank", "width=610,height=410");
	}
	var turnsEnded = false;
	function endXTurns()
	{
		if (turnsEnded) {
			alert("Your turns are being processed. Please be patient.");
		}
		else {
			turnsEnded = true;
			document.endTurnForm.submit();
		}
	}
    //-->
    </SCRIPT>

	<form action="index.cfm" method="post" name="endTurnForm">
	<input type="hidden" name="eflag" value="end_x_turns">
	<input type="hidden" name="page" value="<cfoutput>#page#</cfoutput>">
	<font face=verdana size=2 color="White">
	End	<input style="font-size:xx-small" type="Text" size="3" value="1" maxlength="3" name="xTurns">Turn(s)
	<input type="Button" value="   Go   " style="font-size:xx-small" onclick="endXTurns()">
	<br>
	</form>
<cfset totalLand = player.mland + player.fland + player.pland>
<cfset totalWall = round(totalLand*0.05)>
<cfset protection = 0>
<cfif totalWall gt 0 and totalLand gt 0>
	<cfset protection = round((player.wall / totalWall)*100)>
</cfif>
	
<font face=verdana size=3 color="White">	
	<cfif player.isAdmin is 1><li><a href="admin/admin.cfm">Admin</a></cfif>
	<li><a href="index.cfm?page=main"><cfif player.hasMainNews is 1><font color="red">MAIN</font><cfelse>Main</cfif></a> </li>
	<li><a href="index.cfm?page=player_messages"><cfif player.hasNewMessages is 1><font color="Red">NEW MESSAGE</font><cfelse>Messages</cfif></a> | <a href="javascript:openChatWindow()">Chat</a></li>
	<li><a href="index.cfm?page=build">Buildings</a> </li>
	<li><a href="index.cfm?page=wall">Great Wall (<cfoutput>#numberFormat(protection)#</cfoutput>%)</a> </li>
	<li><a href="index.cfm?page=explore">Explore</a> </li>
	<li><a href="index.cfm?page=research">Research</a> </li>
	<cfif deathmatchMode is false and allianceMaxMembers gt 0><li><a href="index.cfm?page=aid">Aid</a> </li></cfif>
	<li><a href="index.cfm?page=army">Army</a> </li>
	<li><a href="index.cfm?page=attack">Attack</a> </li>
	<cfif deathMatchMode is false and allianceMaxMembers gt 0>
		<li><a href="index.cfm?page=alliance"><cfif player.hasAllianceNews><font color=red>ALLIANCE</font><cfelse>Alliance</cfif></a>
		<cfif player.allianceID gt 0>| <a href="index.cfm?page=alliance_forums"><cfif player.hasAllianceMessages><font color=red>FORUMS</font><cfelse>Forums</cfif></a></cfif>
		</li>
	</cfif>
		
	<li><a href="index.cfm?page=recent_battles">Recent Battles</a> </li>
	<li><a href="index.cfm?page=manage">Management</a> </li>
	<li><a href="index.cfm?page=status">Status</a> </li>
	<li><a href="index.cfm?page=scores">Scores</a> </li>
	<li><a href="index.cfm?page=localtrade">Local Trade</a> </li>
	<cfif deathmatchMode is false>
	<li>Public Market<br>&nbsp;&nbsp;&nbsp;&nbsp;
		<a href="index.cfm?page=globalMarket&mType=sell">Sell</a> | 
		<a href="index.cfm?page=globalMarket&mType=buy">Buy</a>
	
	<br>	<br>	
	</cfif>
	<li><a href="index.cfm?page=search">Find Players</a></li>
	<li><a href="index.cfm?page=account">Account Options</a></li>
	<li><a href="login.cfm?eflag=logout">Logout</a> </li>

</font>

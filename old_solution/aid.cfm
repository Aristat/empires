<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfif deathMatchMode or allianceMaxMembers is 0>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Aid</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('aid')">Help</a></td>
</tr>
</table>


<!--- sending aid --->
<font face="verdana" size=2>
You can send aid to your friends. You need market places to send goods.
There is 5% fee for sending goods.
<br>
<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
<cfset maxTrades = round(maxTrades + maxTrades * (player.research9 / 100))>
<cfif maxTrades is 0><cfset maxTrades = townCenterB.maxLocalTrades></cfif>
<cfset tradesRemaining = maxTrades - player.tradesThisTurn>

Your markets allow you to send <cfoutput>#NumberFormat(maxTrades)#</cfoutput> goods each month, 
<cfif tradesRemaining is 0><font color=red></cfif>out of which <cfoutput>#NumberFormat(tradesRemaining)#</cfoutput> are still available.
</font>
<br>
<br>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="startAid">
<input type="hidden" name="page" value="aid">
<tr>
	<td class="HEADER">&nbsp;</td>
	<td class="HEADER">You Have</td>
	<td class="HEADER">Send</td>
</tr>
<cfoutput>
<tr>
	<td>Wood</td>
	<td align="right">#NumberFormat(player.wood)#</td>
	<td><input type="Text" name="sendWood" size="8"></td>
</tr>
<tr>
	<td>Food</td>
	<td align="right">#NumberFormat(player.food)#</td>
	<td><input type="Text" name="sendFood" size="8"></td>
</tr>
<tr>
	<td>Iron</td>
	<td align="right">#NumberFormat(player.iron)#</td>
	<td><input type="Text" name="sendIron" size="8"></td>
</tr>
<tr>
	<td>Gold</td>
	<td align="right">#NumberFormat(player.gold)#</td>
	<td><input type="Text" name="sendGold" size="8"></td>
</tr>
<tr>
	<td>Tools</td>
	<td align="right">#NumberFormat(player.tools)#</td>
	<td><input type="Text" name="sendTools" size="8"></td>
</tr>
<tr>
	<td>Maces</td>
	<td align="right">#NumberFormat(player.maces)#</td>
	<td><input type="Text" name="sendMaces" size="8"></td>
</tr>
<tr>
	<td>Swords</td>
	<td align="right">#NumberFormat(player.swords)#</td>
	<td><input type="Text" name="sendSwords" size="8"></td>
</tr>
<tr>
	<td>Bows</td>
	<td align="right">#NumberFormat(player.bows)#</td>
	<td><input type="Text" name="sendBows" size="8"></td>
</tr>
<tr>
	<td>Horses</td>
	<td align="right">#NumberFormat(player.horses)#</td>
	<td><input type="Text" name="sendHorses" size="8"></td>
</tr>
<cfparam name="menuPlayerID" default="0">
<tr><td colspan="2" class="HEADER"> Send to empire ##<input type="Text" name="sendEmpireNo" size="3" value="#menuPlayerID#"></td>
	<td class="HEADER"><input type="Submit" value="Send"></td>
</tr>
</form>
</cfoutput>
</table>
<br>
<br>
<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select transferQueue.*, player.name 
	from transferQueue inner join player on transferQueue.toPlayerID = player.ID
	where fromPlayerID = #playerID# and transferType = 1
	order by transferQueue.id
</cfquery>
<cfif tq.recordcount gt 0>
<table border="1" cellpadding="1" cellspacing="0">
<tr>
	<td class="HEADER">Dispatched Caravans:</td>
</tr>
<cfset cancelTime = dateAdd("n", -15, now())>
<cfoutput query="tq">
<tr>
	<td>Sent to #tq.name# (#tq.toPlayerID#) with
	#tq.wood# wood, #tq.food# food, #tq.iron# iron, #tq.gold# gold, #tq.tools# tools,
	#tq.maces# maces, #tq.swords# swords, #tq.bows# bows, #tq.maces# maces and #tq.horses# horses and will reach their
	destination in #tq.turnsRemaining# turns.<br />
	<cfif tq.turnsRemaining is 3 and tq.createdOn gt cancelTime>
		<a href="index.cfm?page=aid&eflag=cancelAid&aidID=#tq.id#">Cancel this aid</a>
	</cfif>
	
	<cfif tq.currentrow is not tq.recordcount><hr noshade size="1"></cfif>
	</td>
</tr>
</cfoutput>
</table>
</cfif>



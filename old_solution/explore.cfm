<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Explore</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('explore')">Help</a></td>
</tr>
</table>

<cfquery name="e" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from exploreQueue where playerID = #playerID# order by id
</cfquery>
<br>
<br>
<cfset totalExplorers = 0>
<cfif e.recordcount gt 0>
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
	<tr>
		<td class="HEADER">No. explorers</td>
		<td class="HEADER">Land Sought</td>
		<td class="HEADER">Months remaining</td>
		<td class="HEADER">Land discovered</td>
	</tr>       
	<cfset cancelTime = dateAdd("n", -15, now())>
	<cfoutput query="e">
	<tr>
		<td valign="top"><cfif e.turn is 0><font color=red>DONE</font><cfelse>#numberFormat(e.people)#</cfif></td>
		<td valign="top"><cfif e.seekLand is 0>All<cfelseif e.seekLand is 1>Mountains<cfelseif e.seekLand is 2>Forest<cfelseif e.seekLand is 3>Plains</cfif></td>		
		<td valign="top">#e.turn#
		
			<cfif e.turnsUsed is 0 and e.createdOn gt cancelTime>
				<br><a href="index.cfm?page=explore&eflag=cancelExplore&eID=#e.id#">Cancel Explorers</a>
			</cfif>
		</td>
		<td valign="top">
		<cfif e.seekLand is 0 or e.seekLand is 1>#numberFormat(e.mLand)# Mountains<br></cfif>
		<cfif e.seekLand is 0 or e.seekLand is 2>#numberFormat(e.fLand)# Forest<br></cfif>
		<cfif e.seekLand is 0 or e.seekLand is 3>#numberFormat(e.pLand)# Plains<br></cfif>
		</td>
		<cfif e.turn gt 0>
			<cfset totalExplorers = totalExplorers + e.people>
		</cfif>
	</tr>
	</cfoutput>
    </table>
<cfelse>	
	<font face=verdana size=2>You do not have any explorers sent.<br>
	</font>
</cfif>
<br>
<cfset totalLand = player.mLand + player.fLand + player.pLand>
<cfset extraFood = ceiling(totalLand / session.extraFoodPerLand)>

<cfset foodPerExplorer = townCenterB.foodPerExplorer + extraFood>

<cfset maxExplorers = player.townCenter * towncenterB.maxExplorers>
You have <cfoutput>#totalExplorers#</cfoutput> explorers looking for land.<br>
You can have a maximum of <cfoutput>#maxExplorers#</cfoutput> explorers.<br>
<cfset sendExplorers = fix(player.food / foodPerExplorer)>
Your food reserves allow you to send <cfoutput>#sendExplorers#</cfoutput> explorers.<br>
<cfset canSend = maxExplorers - totalExplorers>
<cfif canSend gt sendExplorers><cfset canSend = sendExplorers></cfif>
You can send <cfoutput>#canSend#</cfoutput> more explorers.<br>
You need <cfoutput>#foodperexplorer#</cfoutput> food for each explorer.<br>
You have <cfoutput>#NumberFormat(player.horses)#</cfoutput> horses.<br>
<br>
<cfif totalLand gt 500000>
	<cfset mult = TotalLand / 500000>
	<cfif mult gte 100>
		<cfset mult = 99>
	</cfif>
	<cfset mult = (100 - mult)>
	Due to your empire's large size your explorers are <cfoutput>#DecimalFormat(mult)#%</cfoutput> efficient.<br>
</cfif>

<br>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr><td class="HEADER">
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="send_explorers">
<input type="hidden" name="page" value="explore">
<font face=verdana size=2>
Send <input type="text" size="5" value="<cfoutput>#canSend#</cfoutput>" name="qty" style="font-size:xx-small"> explorers 
with 
<cfparam name="session.lastHorseSetting" default="0">
<select name="withHorses" style="font-size:xx-small">
<option value="0" <cfif session.lastHorseSetting is 0>selected</cfif>>No Horses
<option value="1" <cfif session.lastHorseSetting is 1>selected</cfif>>1X Horses
<option value="2" <cfif session.lastHorseSetting is 2>selected</cfif>>2X Horses
<option value="3" <cfif session.lastHorseSetting is 3>selected</cfif>>3X Horses
</select>
to look for 
<select name="seekLand" style="font-size:xx-small">
<option value="0" selected>All Land
<option value="1">Mountain Land
<option value="2">Forest Land
<option value="3">Plains Land
</select>
<input type="Submit" value="Send" style="font-size:xx-small">
</font>
</td></tr>
</form>
</table>
<br>

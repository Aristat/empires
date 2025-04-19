<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!--- 
	Attack 
 --->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Attack</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('attack')">Help</a></td>
</tr>
</table>

 
<cfif player.turn lte 72>
	<font face=verdana size=2>
	Cannot attack under protection.
	<br>
	(You are under protection for the first 6 years of game)
	</font>
<cfelse>
<cfset pID = playerID> 

<cfquery name="attack" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select attackQueue.*, player.name as empire_attacked, player.score as dscore
	from attackQueue inner join player on attackQueue.attackPlayerID = player.id
	where playerID = #playerID# order by attackQueue.id
</cfquery>

<cfif attack.recordcount is 0>
	<font face=verdana size=2>Your armies are not attacking anyone.</font><br>
	
<cfelse>
	<font face=verdana size=2>
	The following armies are active:<br>
	</font>
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
	<tr>
		<td nowrap class="HEADER">Empire Attacked</td>
		<td class="HEADER">Attack Type</td>
		<td class="HEADER">Your Armay</td>
		<td class="HEADER">Status</td>
		<td class="HEADER">&nbsp;</td>
	</tr>
	<cfset statusArray = structNew()>
	<cfset statusArray["0"] = "Preparing">
	<cfset statusArray["1"] = "On thier way">
	<cfset statusArray["2"] = "Almost there">
	<cfset statusArray["3"] = "Done Fighting">
	<cfset statusArray["4"] = "Returning">
	<cfset statusArray["5"] = "Almost Home">

	<cfset sDate = dateAdd("h", -24, now())>
	<cfoutput query="attack">
		<cfif attack.attackType gte 20><cfset aType = 3>
		<cfelseif attack.attackType gte 10><cfset aType = 2>
		<cfelse><Cfset aType = 1></cfif>
		
		<cfquery name="nqMyWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
	    	select count(*) as total from attackNews where attackID = #pID# and defenseID = #attack.attackPlayerID#
				and createdOn >= #sDate# and attackType = #aType# and attackerWins = 1
	    </cfquery>
		<cfquery name="nqMyLost" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
	    	select count(*) as total from attackNews where attackID = #pID# and defenseID = #attack.attackPlayerID#
				and createdOn >= #sDate# and attackType = #aType# and attackerWins = 0
	    </cfquery>
		<cfquery name="nqOtherWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
	    	select count(*) as total from attackNews where attackID <> #pID# and defenseID = #attack.attackPlayerID#
				and createdOn >= #sDate# and attackType = #aType# and attackerWins = 1
	    </cfquery>		
		<cfset hasAttacks = round(val(nqMyWon.total) + val(nqMyLost.total)/3 + val(nqOtherWon.total)/5)>
		<cfscript>
			attackPower = 100;
			if (deathMatchMode) attackPower = 100;
			else if (hasAttacks gte 15) attackPower = 25;
			else if (hasAttacks gte 12) attackPower = 60;
			else if (hasAttacks gte 10) attackPower = 68;
			else if (hasAttacks gte 8) attackPower = 76;
			else if (hasAttacks gte 5) attackPower = 84;
			else if (hasAttacks gte 3) attackPower = 92;
		</cfscript>
		<cfif attackType lt 10 and attack.status lt 3>
			<cfset totalArmy = attack.uunit + attack.trainedPeasants + attack.macemen + attack.swordsman + attack.archers + attack.horseman>
			<cfif totalArmy gt 0>
				<cfset percentWine = round((attack.costWine / totalArmy)*100)>		
			<cfelse>
				<cfset percentWine = 0>
			</cfif>
			<Cfset attackPower = attackPower + percentWine>
		</cfif>
	<tr>
		<td valign="top">#attack.empire_attacked# (#attack.attackPlayerID#)
			<cfif attack.dscore lt player.score / 2 and not deathmatchMode>
				<br><font face="verdana" size=1 color="Red">Warning!!! attacking<br>empires smaller<br>than 1/2 of your<br>size will result <br>in revolt.</font>
			</cfif>
		</td>
		<td valign="top">
		<cfswitch expression="#attack.attackType#">
		<cfcase value="0">Conquer</cfcase>
		<cfcase value="1">Raid</cfcase>
		<cfcase value="2">Rob</cfcase>
		<cfcase value="3">Slaughter</cfcase>
		<cfcase value="10">Catapult Army and Towers</cfcase>
		<cfcase value="11">Catapult Population</cfcase>
		<cfcase value="12">Catapult Buildings</cfcase>
		<cfcase value="20">Steal Army Information</cfcase>
		<cfcase value="24">Steal Building Information</cfcase>
		<cfcase value="25">Steal Research Information</cfcase>		
		<cfcase value="21">Steal Goods</cfcase>
		<cfcase value="22">Poision Water</cfcase>
		<cfcase value="23">Set Fire</cfcase>
		</cfswitch>
		</td>
		<td valign="top"><font face="verdana" size=1>
		<cfif attack.attackType gte 0 and attack.attackType lt 10>
			<cfif attack.uunit gt 0>#NumberFormat(attack.uunit)# #uunitA.name#<br></cfif>
			<cfif attack.trainedPeasants gt 0>#NumberFormat(attack.trainedPeasants)# Trained Peasants<br></cfif>
			<cfif attack.macemen gt 0>#NumberFormat(attack.macemen)# Macemen<br></cfif>
			<cfif attack.swordsman gt 0>#NumberFormat(attack.swordsman)# Swordsman<br></cfif>
			<cfif attack.archers gt 0>#NumberFormat(attack.archers)# Archers<br></cfif>
			<cfif attack.horseman gt 0>#NumberFormat(attack.horseman)# Horseman<br></cfif>
			<cfif attack.costWine gt 0>#numberFormat(attack.costWine)# units of wine<br></cfif>
		<cfelseif attack.attackType gte 10 and attack.attackType lt 20>
			#NumberFormat(attack.catapults)# catapults
		<cfelseif attack.attackType gte 20 and attack.attackType lt 30>
			#NumberFormat(attack.thieves)# thieves
		</cfif>
		
		<cfif not deathmatchMode>
			<br><b>Attack Strength: #NumberFormat(Round(attackPower))#%</b>
		</cfif>
		</td>
		
		<td valign="top"><cfif structKeyExists(statusArray, attack.status)>#statusArray["#attack.status#"]#<cfelse>?</cfif></td>
		<td valign="top"><cfif attack.status is 0 or attack.status is 1 or attack.status is 2><a href="index.cfm?page=attack&eflag=cancel_attack&armyID=#attack.id#">Cancel</a></cfif>&nbsp;</td>
	</tr>
	<tr><td colspan="10" bgcolor="darkslategray" height="5"></td></tr>
	</cfoutput>
       
    </table>
</cfif>
<br>
<br>
<cfparam name="attack_type" default="0">
<cfparam name="menuPlayerID" default="0">

<table border=1 cellspacing=1 cellpadding=1 align="center" bordercolor="darkslategray" width="350">
<tr><td class="HEADER">Army Attack</td></tr>
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="attack_empire">
<input type="hidden" name="page" value="attack">
<tr><td>
	<select name="attack_type">
	<option value="0" <cfif attack_type is 0>selected</cfif>>Conquer (take land)
	<option value="1" <cfif attack_type is 1>selected</cfif>>Raid (destroy)
	<option value="2" <cfif attack_type is 2>selected</cfif>>Rob (steal resources)
	<option value="3" <cfif attack_type is 3>selected</cfif>>Slaughter (kill population)
	</select>
	empire # <input type="Text" name="attackPlayerID" value="<cfoutput>#menuPlayerID#</cfoutput>" maxlength="5" size="3"> with<br>
	<input type="Text" name="send_uunit" value="0" maxlength="10" size="8"><cfoutput>#uunitA.name#</cfoutput> (You have <cfoutput>#player.uunit#</cfoutput>)<br>
	<input type="Text" name="send_swordsman" value="0" maxlength="10" size="8">Swordsman (You have <cfoutput>#player.swordsman#</cfoutput>)<br>
	<input type="Text" name="send_archers" value="0" maxlength="10" size="8">Archers (You have <cfoutput>#player.archers#</cfoutput>)<br>
	<input type="Text" name="send_horseman" value="0" maxlength="10" size="8">Horseman (You have <cfoutput>#player.horseman#</cfoutput>)<br>
	<input type="Text" name="send_macemen" value="0" maxlength="10" size="8">Macemen (You have <cfoutput>#player.macemen#</cfoutput>)<br>
	<input type="Text" name="send_trainedPeasants" value="0" maxlength="10" size="8">Trained Peasants (You have <cfoutput>#player.trainedPeasants#</cfoutput>)<br>
	also send:<br />
	
	<input type="Text" name="sendwine" value="0" maxlength="10" size="8"> wine (you have <cfoutput>#numberFormat(player.wine)#)</cfoutput>
	<br><input type="Checkbox" name="sendmaxwine" value="1">Send max wine?
</td>
</tr>
<tr><td class="HEADER"><input type="Checkbox" name="sendAll" value="1">Send All Army</td></tr>
<tr><td align="center"><input type="Submit" value="     Attack     "></td></tr>
</form>
</table>
<br>
<br>
<table border=1 cellspacing=1 cellpadding=1 align="center" bordercolor="darkslategray" width="350">
<tr><td class="HEADER">Catapult Attack</td></tr>
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="catapult_attack">
<input type="hidden" name="page" value="attack">
<tr><td>
	<select name="attack_type">
	<option value="10" <cfif attack_type is 10>selected</cfif>>Catapult Army and Towers
	<option value="11" <cfif attack_type is 11>selected</cfif>>Catapult Population
	<option value="12" <cfif attack_type is 12>selected</cfif>>Catapult Buildings
	</select>
	empire # <input type="Text" name="attackPlayerID" value="<cfoutput>#menuPlayerID#</cfoutput>" maxlength="5" size="3"> with<br>
	<input type="Text" name="send_catapults" value="0" maxlength="10" size="8">Catapults (You have <cfoutput>#player.catapults#</cfoutput>)<br>
</td>
</tr>
<tr><td class="HEADER"><input type="Checkbox" name="sendAll" value="1">Send All Army</td></tr>
<tr><td align="center"><input type="Submit" value="     Attack     "></td></tr>
</form>
</table>
<br>
<br>
<table border=1 cellspacing=1 cellpadding=1 align="center" bordercolor="darkslategray" width="350">
<tr><td class="HEADER">Thief Attack</td></tr>
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="thief_attack">
<input type="hidden" name="page" value="attack">
<tr><td>
	<select name="attack_type">
	<option value="20" <cfif attack_type is 20>selected</cfif>>Steal Army Information
	<option value="24" <cfif attack_type is 21>selected</cfif>>Steal Building Information
	<option value="25" <cfif attack_type is 22>selected</cfif>>Steal Research Information
	<option value="21" <cfif attack_type is 23>selected</cfif>>Steal Goods
	<option value="22" <cfif attack_type is 24>selected</cfif>>Poison Water
	<option value="23" <cfif attack_type is 25>selected</cfif>>Set Fire
	</select>
	empire # <input type="Text" name="attackPlayerID" value="<cfoutput>#menuPlayerID#</cfoutput>" maxlength="5" size="3"> with<br>
	<input type="Text" name="send_thieves" value="0" maxlength="10" size="8">Thieves (You have <cfoutput>#player.thieves#</cfoutput>)<br>
</td>
</tr>
<tr><td class="HEADER"><input type="Checkbox" name="sendAll" value="1">Send All Army</td></tr>
<tr><td align="center"><input type="Submit" value="     Attack     "></td></tr>
</form>
</table>
</cfif><!--- end of under protection --->
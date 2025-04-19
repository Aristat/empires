<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Army</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('army')">Help</a></td>
</tr>
</table>


<cfset maxTrain = player.fort * fortB.maxTrain + player.townCenter * fortB.maxTrain>
<cfset maxSoldiers = player.townCenter * townCenterB.maxUnits + player.fort * fortB.maxUnits>

<!--- compute attacking quantities --->
<cfquery name="aq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select
		sum(swordsman) as sQty, 
		sum(archers) as aQty,
		sum(horseman) as hQty,
		sum(catapults) as cQty,
		sum(macemen) as mQty,
		sum(trainedPeasants) as pQty,
		sum(thieves) as tQty,
		sum(uunit) as uQty
	from attackQueue where playerID = #playerID#	
</cfquery>
<cfset aQty = arrayNew(1)>
<cfset aQty[1] = val(aq.aQty)>
<cfset aQty[2] = val(aq.sQty)>
<cfset aQty[3] = val(aq.hQty)>
<cfset aQty[4] = 0>
<cfset aQty[5] = val(aq.cQty)>
<cfset aQty[6] = val(aq.mQty)>
<cfset aQty[7] = val(aq.pQty)>
<cfset aQty[8] = val(aq.tQty)>
<cfset aQty[9] = val(aq.uQty)>

<cfset totalUnits = player.swordsman + player.archers + player.horseman + player.macemen + player.trainedPeasants 
	+ player.thieves + player.catapults + player.uunit
	+ aQty[1] + aQty[2] + aQty[3] + aQty[5] + aQty[6] + aQty[7] + aQty[8] + aQty[9]>

<cfoutput>
<font face=verdana size=2>
Your Forts and Town Centers can hold up to
#maxSoldiers# units <br>
and you can train #maxTrain# units at a time.
<br>
You are using
<cfif maxSoldiers gt 0>
	<cfset percent = (totalUnits / maxSoldiers) * 100.0>
<cfelse>
	<cfset percent = 0>
</cfif>
#DecimalFormat(percent)#% of your maximum capacity.<br>
You also have #numberFormat(player.swords)# swords, #numberFormat(player.bows)# bows, #numberFormat(player.horses)# horses 
and #numberFormat(player.maces)# maces.
<br>
<cfset attackPower = 	(player.archers + aQty[1]) * archerA.attackPt +
						(player.swordsman + aQty[2]) * swordsmanA.attackPt +
						(player.horseman + aQty[3]) * horsemanA.attackPt +
						(player.macemen + aQty[6]) * macemanA.attackPt +
						(player.trainedPeasants + aQty[7]) * trainedPeasantA.attackPt +
						(player.uunit + aQty[9]) * uunitA.attackPt>
<cfset defensePower = 	(player.archers + aQty[1]) * archerA.defensePt +
						(player.swordsman + aQty[2]) * swordsmanA.defensePt +
						(player.horseman + aQty[3]) * horsemanA.defensePt +
						(player.tower) * towerA.defensePt +
						(player.macemen + aQty[6]) * macemanA.defensePt +
						(player.trainedPeasants + aQty[7]) * trainedPeasantA.defensePt +
						(player.uunit + aQty[9]) * uunitA.defensePt>
						
<cfset attackPower = round(attackPower + attackPower * (player.research1 / 100))>
<cfset defensePower = round(defensePower + defensePower * (player.research2 / 100))>
<hr noshade size="1" color="darkslategray">
<b>Military Strength:</b>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr>
	<td class="HEADER">&nbsp;</td>
	<td class="HEADER">Attacking Power</td>
	<td class="HEADER">Defense Power</td>
</tr>
<tr>
	<td>Army</td>
	<td>#numberFormat(attackPower)#</td>
	<td>#numberFormat(defensePower)#</td>
</tr>
<cfset cAttackPower = player.catapults*catapultA.attackPt>
<cfset cAttackpower = round(cAttackPower + cAttackPower * (player.research11 / 100))>
<cfset cDefensePower = player.catapults*catapultA.defensept>
<cfset cDefensePower = round(cDefensePower + cDefensePower * (player.research11 / 100))>
<tr>
	<td>Catapults</td>
	<td>#numberformat(cAttackPower)#</td>
	<td>#numberFormat(cDefensePower)#</td>
</tr>
<cfset tAttackPower = player.thieves*thievesA.attackPt>
<cfset tAttackpower = round(tAttackPower + tAttackPower * (player.research3 / 100))>
<cfset tDefensePower = player.thieves*thievesA.defensept>
<cfset tDefensePower = round(tDefensePower + tDefensePower * (player.research3 / 100))>

<tr>
	<td>Thieves</td>
	<td>#numberFormat(tAttackPower)#</td>
	<td>#numberFormat(tDefensePower)#</td>
</tr>
</table>						
<hr noshade size="1" color="darkslategray">
</cfoutput>

<cfquery name="q" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from trainQueue where playerID = #playerID# order by id
</cfquery>
<cfset numTrain = 0>
<cfset sQty = arrayNew(1)>
<cfloop from="1" to="#arrayLen(soldiers)#" index="i"><cfset sQty[i] = 0></cfloop>

<cfif q.recordcount gt 0>
	<b>Training Queue:</b>
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
    <tr>
		<td class="HEADER">Type</td>
		<td class="HEADER">Number</td>
		<td class="HEADER">Turns Remaining</td>
		<td class="HEADER">&nbsp;</td>
	</tr>
	<cfoutput query="q">
	<tr>
		<td>#soldiers[q.soldierType].name#</td>
		<td>#q.qty#</td>
		<td>#q.turnsRemaining#</td>
		<td><a href="index.cfm?page=army&q_id=#q.id#&eflag=dequeue">Cancel</a></td>
		<cfset numTrain = numTrain + q.qty>
		<cfset sQty[q.soldierType] = sQty[q.soldierType] + q.qty>
	</tr>
	</cfoutput>
    </table>
</cfif>
<br>

<cfset canTrain = maxTrain - numTrain><!--- can train due to train limit --->
<cfset canHold = maxSoldiers - totalUnits - numTrain>

<b>Your Army:</b>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function disbandArmy()
{
	var form = document.aForm;
	if (confirm("Are you sure you want to disband some of your army?")) {
		form.eflag.value = 'disbandArmy';
		form.submit();
	}	
}

// just in case someone clicks back, and eflag is 'disbandArmy'
function checkForm(form)
{
	form.eflag.value = "train";
	return true;
}

//-->
</SCRIPT>
<form action="index.cfm" method="post" name="aForm" onsubmit="return checkForm(this)">
<input type="hidden" name="page" value="army">
<input type="hidden" name="eflag" value="train">
<tr>
	<td class="HEADER" valign="bottom">&nbsp;</td>
	<td class="HEADER" valign="bottom">Unit Type</td>
	<td class="HEADER" valign="bottom">You Have</td>
	<td class="HEADER" valign="bottom">Upkeep<br>Cost</td>
	<td class="HEADER" valign="bottom">Attacking</td>
	<td class="HEADER" valign="bottom">Training</td>
	<td class="HEADER" valign="bottom">Needed<br>To Train</td>
	<td class="HEADER" valign="bottom">Max.<br>Train</td>	
	<td class="HEADER" valign="bottom">Num.<br>Units</td>
</tr>
<cfoutput>
<cfset totalHave = 0>
<cfset totalCost = 0>
<cfset totalFood = 0>
<cfset helpIndex = arrayNew(1)>
<cfset helpIndex[1] = 1><!--- swordsman --->
<cfset helpIndex[2] = 2><!--- archer --->
<cfset helpIndex[3] = 3><!--- horseman --->
<cfset helpIndex[4] = 8><!--- tower --->
<cfset helpIndex[5] = 6><!--- catapult --->
<cfset helpIndex[6] = 4><!--- maceman --->
<cfset helpIndex[7] = 5><!--- trained peasant --->
<cfset helpIndex[8] = 7><!--- catapult --->
<cfset helpIndex[9] = 1><!--- uunit --->
<cfif player.civ is 1>
	<cfset helpIndex[9] = 9><!--- viking --->
<cfelseif player.civ is 2>
	<cfset helpIndex[9] = 11><!--- franks --->
<cfelseif player.civ is 3>
	<cfset helpIndex[9] = 10><!--- japanese --->
<cfelseif player.civ is 4>
	<cfset helpIndex[9] = 12><!--- byzantines --->
<cfelseif player.civ is 5>
	<cfset helpIndex[9] = 13><!--- mongols --->
<cfelseif player.civ is 6>
	<cfset helpIndex[9] = 14><!--- incas --->
<cfelseif player.civ is 7>
	<cfset helpIndex[9] = 15><!--- chinese --->
<cfelseif player.civ is 8>
	<cfset helpIndex[9] = 16><!--- barbarians --->	
</cfif>	

<cfloop list="1,2,3,5,6,7,8,9" index="i">
<tr>
	<td><a href="javascript:openHelp('army##UNIT#helpIndex[i]#')"><b>?</b></a></td>
	<td>#soldiers[i].name#</td>
	<cfset have = val(evaluate("player.#soldiers[i].dbName#")) + aQty[i]>
	<td>#NumberFormat(have)#</td>
	<cfset foodUsed = have>
	<cfif i is 3><!--- horseman --->
		<cfset foodUsed = have * 2>
	<cfelseif i is 7><!--- trained peasants --->
		<cfset foodUsed = round(have * 0.1)>
	<cfelseif i is 8><!--- thieves --->
		<cfset foodUsed = have * 3>
	<cfelseif i is 9><!--- uunit --->
		<cfset foodUsed = have * 2>
	<cfelseif i is 5>
		<cfset foodUsed = 0>
	</cfif>
	<cfset totalFood = totalFood + foodUsed>
	<td valign="top"><font size="1">
	<cfif i is 5>
	W:#numberFormat(have)#<br>I:#numberFormat(round(have*0.2))#
	<cfelse>
	G:#NumberFormat(have*session.soldiers[i].goldPerTurn)#<br>F:#numberFormat(foodUsed)#
	</cfif>
	</td>
	<cfset totalCost = totalCost + have * session.soldiers[i].goldPerTurn>	
	<td>#NumberFormat(aQty[i])#</td>
	<cfset totalHave = totalHave + have>
	<cfif i is 4><td colspan="4" align="center">N/A</td>
	<cfelse><td>#sQty[i]#</td>
	<cfset cTrain = canTrain>
	<cfif cTrain gt canHold><cfset cTrain = canHold></cfif>	
	<cfif cTrain lt 0><cfset cTrain = 0></cfif>
	
	<cfswitch expression="#i#">
	<cfcase value="1"><!--- bowman --->
		<td>1 Bow</td>
		<cfif player.bows lt cTrain><cfset cTrain = player.bows></cfif>
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="2">
		<td>1 Sword</td>
		<cfif player.swords lt cTrain><cfset cTrain = player.swords></cfif>
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="3">
		<td><font face="verdana" size=1>1 Horse <br>1 Sword</td>
		<cfif player.horses lt cTrain><cfset cTrain = player.horses></cfif>
		<cfif player.swords lt cTrain><cfset cTrain = player.swords></cfif>
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="5">
		<cfset cost = catapultA.trainCost>
		<td><font face="verdana" size=1>#cost# Wood <br>#cost# Iron</td>
		<cfset mcost = cost * cTrain>
		<cfif player.wood lt mcost><cfset cTrain = fix(player.wood / cost)></cfif>
		<cfset mCost = cTrain * cost>
		<cfif player.iron lt mcost><cfset cTrain = fix(player.iron / cost)></cfif>
		
		<cfif have + cTrain + sQty[i] gt player.townCenter><cfset cTrain = player.towncenter - have - sQty[i]></cfif>		
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="6">
		<td>1 Mace</td>
		<cfif player.maces lt cTrain><cfset cTrain = player.maces></cfif>
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="7">
		<td>None</td>
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="8">
		<td>1000 Gold</td>
		<cfif player.gold lt cTrain * 1000><cfset cTrain = fix(player.gold / 1000)></cfif>
		<cfif have + cTrain + sQty[i] gt player.townCenter><cfset cTrain = player.towncenter - have - sQty[i]></cfif>		
		<td>#cTrain#</td>
	</cfcase>
	<cfcase value="9">
		<td><font face="verdana" size="1">
			#uunitA.trainGold# gold<br>
			<cfif uunitA.trainSwords gt 0>#uunitA.trainSwords# swords<br></cfif>
			<cfif uunitA.trainBows gt 0>#uunitA.trainBows# bows<br></cfif>
			<cfif uunitA.trainHorses gt 0>#uunitA.trainHorses# horses</cfif>
		</td>
		<cfif player.gold lt cTrain * uunitA.trainGold><cfset cTrain = fix(player.gold / uunitA.trainGold)></cfif>
		<cfif have + cTrain + sQty[i] gt player.townCenter><cfset cTrain = player.towncenter - have - sQty[i]></cfif>
		<cfif player.swords lt cTrain * uunitA.trainSwords><cfset cTrain = fix(player.swords / uunitA.trainSwords)></cfif>
		<cfif player.horses lt cTrain * uunitA.trainHorses><cfset cTrain = fix(player.horses / uunitA.trainHorses)></cfif>
		<cfif player.bows lt cTrain * uunitA.trainBows><cfset cTrain = fix(player.bows / uunitA.trainBows)></cfif>
		<td>#cTrain#</td>
	</cfcase>
	</cfswitch>
	</td>
	<td align="left" nowrap><input type="Text" name="qty#i#" value="" size="5">
		<cfif cTrain gt 0><input type="Button" onclick="document.aForm.qty#i#.value = #cTrain#" value="M" style="font-size:10px"></cfif>
	</td>
	</cfif>
</tr>
</cfloop>
<tr>
	<td bgcolor="darkslategray" colspan="2"><a href="javascript:openHelp('army')">Units Help</a></td>
	<td bgcolor="darkslategray">#NumberFormat(totalHave)#</td>
	<td valign="top" bgcolor="darkslategray"><font face="verdana" size=1>#NumberFormat(totalCost)# gold<br>#numberFormat(totalFood)# food</td>
	<td bgcolor="darkslategray">#NumberFormat(ArraySum(aQty))#</td>
	<td bgcolor="darkslategray">#NumberFormat(ArraySum(sQty))#</td>
	<td bgcolor="darkslategray">&nbsp;</td>
	<td bgcolor="darkslategray">#NumberFormat(CanTrain)#</td>				
	<td align="center" bgcolor="darkslategray"><input type="Submit" value="Train" style="width:55;font-size:xx-small"></td>
</tr>
</cfoutput>
<tr>
	<td colspan="10"><br>
	<cfif canHold is 0>
		Your forts and town center are full.<br>
	<cfelseif canHold gt 0>
		<cfoutput>You have room for #numberFormat(val(canHold))# more soldiers.<br></cfoutput>
	<cfelse>
		<cfoutput><font color=red>#numberFormat(abs(val(canHold)))# of your soldiers don't have any place to live.</font><br></cfoutput>
	</cfif>
		<br>
		<br>
		
		If you want to disband some of your soldiers, <br>
		fill up the quantities above and press the button below
		<br>
		<input type="Button" value="Disband Army" style="font-size:xx-small" onclick="disbandArmy()">
	</td>
</tr>
</form>
</table>
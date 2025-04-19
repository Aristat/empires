<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Status</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('resources')">Help</a></td>
</tr>
</table>


<cfoutput>
<br>

<table border=0 cellspacing=0 cellpadding=0 align="left">
<tr>
	<td width="10">&nbsp;</td>
	<td valign="top">
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="150">
        <tr>
			<td colspan="3" bgcolor="darkslategray" align="center"><font face=verdana size=2 color=white><b>Goods</b></font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##WOOD')">?</a></td>
			<td><font face=verdana size=2>Wood</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.wood)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##FOOD')">?</a></td>		
			<td><font face=verdana size=2>Food</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.food)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##WINE')">?</a></td>		
			<td><font face=verdana size=2>Wine</font></td>			
			<td align="right"><font face=verdana size=2>#NumberFormat(player.wine)#</font></td>
		</tr>		
		<tr>
			<td><a href="javascript:openHelp('resources##IRON')">?</a></td>		
			<td><font face=verdana size=2>Iron</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.iron)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##TOOLS')">?</a></td>		
			<td><font face=verdana size=2>Tools</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.tools)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##SWORD')">?</a></td>		
			<td><font face=verdana size=2>Swords</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.swords)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##BOW')">?</a></td>		
			<td><font face=verdana size=2>Bows</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.bows)#</font></td>
		</tr>
		<tr>
			<td><a href="javascript:openHelp('resources##MACE')">?</a></td>		
			<td><font face=verdana size=2>Maces</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.maces)#</font></td>
		</tr>		
		<tr>
			<td><a href="javascript:openHelp('resources##HORSE')">?</a></td>		
			<td><font face=verdana size=2>Horses</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.horses)#</font></td>
		</tr>		
		<cfset totalGoods = player.wood + player.iron + player.food + player.tools + player.swords + player.bows + player.horses + player.maces + player.wine>
		<tr>	
			<td colspan="2" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Total:</font></td>
			<td align="right" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>#NumberFormat(totalGoods)#</font></td>
		</tr>
		<cfset warehouseSpace = player.townCenter * townCenterB.supplies + player.warehouse * wareHouseB.supplies>
		<cfset warehouseSpace = round(warehouseSpace + warehouseSpace * (player.research8 / 100))>
		<tr>
			<td colspan="2"><font face=verdana size=1>Warehouse<br>space</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(warehouseSpace)#</font></td>
		</tr>
		<cfset extraSpace = warehouseSpace - totalGoods>
		<tr>
			<td colspan="2"><font face=verdana size=1><cfif extraSpace lt 0>Needed<br>space:<cfelse>Extra<br>Space:</cfif></font></td>
			<cfset extraSpace = abs(extraSpace)>
			<td align="right"><font face=verdana size=2>#NumberFormat(extraSpace)#</font></td>
		</tr>
        </table>
	<br>

	</td>
	<td width="10">&nbsp;</td>
	<td valign="top">
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="150">
        <tr>
			<td colspan="2" bgcolor="darkslategray" align="center"><font face=verdana size=2 color=white><b>Army</b></font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>Trained Peasants</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.trainedPeasants)#</font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>Macemen</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.macemen)#</font></td>
		</tr>		
		<tr>
			<td><font face=verdana size=2>Swordsman</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.swordsman)#</font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>Archers</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.archers)#</font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>Horseman</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.horseman)#</font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>#uunitA.name#</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.uunit)#</font></td>
		</tr>				
		<tr>
			<td><font face=verdana size=2>Catapults</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.catapults)#</font></td>
		</tr>		
		<tr>
			<td><font face=verdana size=2>Thieves</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.thieves)#</font></td>
		</tr>		
		<cfset totalArmy = player.swordsman + player.archers + player.horseman + player.trainedPeasants + player.macemen + player.thieves + player.catapults + player.uunit>
		<tr>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Total:</font></td>
			<td align="right" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>#NumberFormat(totalArmy)#</font></td>
		</tr>
		<cfset maxArmy = player.townCenter * townCenterB.maxUnits + player.fort * fortB.maxUnits>
		<tr>
			<td><font face=verdana size=1>Fort Space</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(maxArmy)#</font></td>
		</tr>		
		<cfset freeSpace = maxArmy - totalArmy>
		<tr>
			<td><font face=verdana size=1>Free Space</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(freespace)#</font></td>			
		</tr>
        </table>
	
	</td>
	<td width="10">&nbsp;</td>
	<td valign="top">
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="150">
        <tr>
			<td colspan="2" bgcolor="darkslategray" align="center"><font face=verdana size=2 color=white><b>People</b></font></td>
		</tr>
		<tr>
			<td><font face=verdana size=2>Population</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(player.people)#</font></td>
		</tr>		
		<cfset houseSpace = player.house * houseB.people + player.townCenter * townCenterB.people>
		<cfset houseSpace = round(houseSpace + houseSpace * (player.research8 / 100))>
		<tr>
			<td nowrap><font face=verdana size=2>House Space:</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(houseSpace)#</font></td>
		</tr>		
		<cfset freeSpace =  houseSpace - player.people>
		<tr>
			<td><font face=verdana size=2>Free Space:</font></td>
			<td align="right"><font face=verdana size=2>#NumberFormat(freeSpace)#</font></td>
		</tr>		
        </table>	
	</td>
</tr>
</table>
<br clear="all">
<br>
<font face="verdana" size="2">Monthly Summary (approximately):</font>
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
<tr>
	<td class="HEADER">Goods</td>
	<td class="HEADER">Total Gain/Loss</td>
	<td class="HEADER">Production</td>
	<td class="HEADER">Consumption</td>
	<td class="HEADER">Military</td>
	<td class="HEADER">Import/Export</td>
	<td class="HEADER">Other</td>
</tr>
<!--- precalculate extra cost used by markets --->
<cfscript>
	extra = 1;
	s = player.score;
	while (s gt 100000) {
		extra = extra + localTradeMulti;
		s = s / 2;
	}
	buyWood = 0;
	buyIron = 0;
	buyFood = 0;
	buyTools = 0;
	buyGold = 0;
	if (player.autoBuyWood gt 0) {
		woodBuyPrice = round(session.localWoodBuyPrice * extra);
		useGold = woodBuyPrice * player.autoBuyWood;
		buyWood = buyWood + player.autoBuyWood;
		buyGold = buyGold - useGold;
	}
	if (player.autoBuyFood gt 0) {
		FoodBuyPrice = round(session.localFoodBuyPrice * extra);
		useGold = FoodBuyPrice * player.autoBuyFood;
		buyFood = buyFood + player.autoBuyFood;
		buygold = buygold - useGold;
	}
	if (player.autoBuyIron gt 0) {
		IronBuyPrice = round(session.localIronBuyPrice * extra);
		useGold = IronBuyPrice * player.autoBuyIron;
		buyIron = buyIron + player.autoBuyIron;
		buygold = buygold - useGold;
	}
	if (player.autoBuyTools gt 0) {
		ToolsBuyPrice = round(session.localToolsBuyPrice * extra);
		useGold = ToolsBuyPrice * player.autoBuyTools;
		buyTools = buyTools + player.autoBuyTools;
		buygold = buygold - useGold;
	}
	
	if (player.autoSellWood gt 0) {
		woodSellPrice = round(session.localWoodSellPrice * (1.0/extra));
		getGold = woodSellPrice * player.autoSellWood;
		buywood = buywood - player.autoSellWood;
		buygold = buygold + getGold;
	}		
	if (player.autoSellFood gt 0) {
		FoodSellPrice = round(session.localFoodSellPrice * (1.0/extra));
		getGold = FoodSellPrice * player.autoSellFood;
		buyFood = buyFood - player.autoSellFood;
		buygold = buygold + getGold;
	}		
	if (player.autoSellIron gt 0) {
		IronSellPrice = round(session.localIronSellPrice * (1.0/extra));
		getGold = IronSellPrice * player.autoSellIron;
		buyIron = buyIron - player.autoSellIron;
		buygold = buygold + getGold;
	}		
	if (player.autoSellTools gt 0) {
		ToolsSellPrice = round(session.localToolsSellPrice * (1.0/extra));
		getGold = ToolsSellPrice * player.autoSellTools;
		buyTools = buyTools - player.autoSellTools;
		buygold = buygold + getGold;
	}		

	
</cfscript>

	<cfset builders = toolMakerB.numBuilders * player.toolMaker + 3>
	<cfset bPercent = player.wallBuildPerTurn / 100>
	<cfset wallBuilders = round(builders * bPercent)>
	<cfset wallBuild = int(wallBuilders/10)>

<tr>
	<td class="SMALL">Gold</td>
	<cfset getGold = round(player.goldMine * (player.goldMineStatus / 100)) * goldMineB.production>	
	<cfset goldProduction = getGold + round(getGold * (player.research6/100))>
	
	<!--- consumption by mage towers --->
	<cfset wallGoldUsage = wallBuild * session.walluseGold>
	<cfset goldConsumption = 0 - (round((player.mageTower * (player.mageTowerStatus / 100)) * mageTowerB.goldNeed) + wallGoldUsage)>

	<!--- military upkeep --->
	<cfset payGold = 0 - round(player.swordsman * swordsmanA.goldPerTurn + player.archers * archerA.goldPerTurn + player.horseman * horsemanA.goldPerTurn + player.macemen * macemanA.goldPerTurn + player.trainedPeasants * trainedPeasantA.goldPerTurn + player.thieves * thievesA.goldPerTurn + player.uunit * uunitA.goldPerTurn)>
	
	<!--- import export --->
	<cfset totalGold = goldProduction + goldConsumption + payGold + buyGold>
	<td align="right" class="SMALL"><b>#NumberFormat(totalGold, "+_,___,___,___,___")#</b></td>
	<td align="right" class="SMALL">#NumberFormat(goldProduction, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(goldConsumption, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(payGold, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(buyGold, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">---</td>
</tr>
<tr>
	<td valign="top" class="SMALL">Food <br>(Summer)<br>(Winter)</td>
	<!--- hunters --->
	<cfset canProduce = round(player.hunter * (player.hunterstatus / 100))>
	<cfset getFood = canProduce * hunterB.production>
	<cfset hunterProduction = getFood + round(getFood * (player.research5/100))>
	
	<!--- farms --->
	<cfset canProduce = round(player.farmer * (player.farmerstatus / 100))>
	<cfset getFood = canProduce * farmerB.production>
	<cfset farmerProduction = getFood + round(getFood * (player.research5/100))>
	
	<!--- stable cosumption --->
	<cfset stableConsumption = 0 - round(player.stable * (player.stableStatus / 100)) * stableB.foodNeed>

	<!--- army --->
	<cfset foodEaten = round(player.swordsman * swordsmanA.foodEaten + player.archers * archerA.foodEaten +
		 player.horseman * horsemanA.foodEaten + player.macemen * macemanA.foodEaten + 
		 player.trainedPeasants * trainedPeasantA.foodEaten + player.thieves * thievesA.foodEaten + player.uunit * uunitA.foodEaten)>
	<cfset eatSoldiersFood = 0 - foodEaten>
	
	<!--- people eat food --->
	<cfset foodEaten = round(player.people/session.peopleEatOneFood)>
	<!--- eat more or less depending on food ratios --->
	<cfif player.foodRatio is 1><cfset foodEaten = round(foodEaten * 1.5)>
	<cfelseif player.foodRatio is 2><cfset foodEaten = round(foodEaten * 2.5)>
	<cfelseif player.foodRatio is 3><cfset foodEaten = round(foodEaten * 4)>
	<cfelseif player.foodRatio is 4><cfset foodEaten = round(foodEaten * 8)>
	<cfelseif player.foodRatio is -1><Cfset foodEaten = round(foodEaten * 0.75)>
	<cfelseif player.foodRatio is -2><cfset foodEaten = round(foodEaten * 0.45)>
	</cfif>
	
	
	<cfset foodEaten = 0 - foodEaten>
	
	<cfset totalFoodSummer = hunterProduction + farmerProduction + stableConsumption + eatSoldiersFood + foodEaten + buyFood>
	<cfset totalFoodWinter = hunterProduction + stableConsumption + eatSoldiersFood + foodEaten + buyFood>
	<td align="right" class="SMALL"><br><b>#NumberFormat(totalFoodSummer, "+_,___,___,___,___")#</b><br>
						<b>#NumberFormat(totalFoodWinter, "+_,___,___,___,___")#</b></td>
						
	<td align="right" class="SMALL"><br>#NumberFormat(farmerProduction+hunterProduction, "+_,___,___,___,___")#
	<br>#NumberFormat(hunterProduction, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(stableConsumption, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(eatSoldiersFood, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(buyFood, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">(people eat)<br>#NumberFormat(foodEaten, "+_,___,___,___,___")#</td>
</tr>
<tr>
	<td valign="top" class="SMALL">Wood <br>(Summer)<br>(Winter)</td>
	<!--- wood cutter --->
	<cfset canProduce = round(player.woodCutter * (player.woodCutterStatus / 100))>
	<cfset woodproduction = canProduce * woodCutterB.production>

	<!--- toolmaker cosumption --->
	<cfset toolConsumption = 0 - round(player.toolMaker * (player.toolMakerStatus / 100)) * toolMakerB.woodNeed>
	<!--- bow consumption --->
	<cfset canProduce = round(player.bowWeaponSmith * (player.weaponSmithStatus / 100))>
	<cfset bowConsumption = 0 - canProduce * weaponSmithB.woodNeed>
	<!--- mace consumption --->
	<cfset canProduce = round(player.maceWeaponSmith * (player.weaponSmithStatus / 100))>
	<cfset maceConsumption = 0 - canProduce * weaponSmithB.maceWood>
	<!--- wall construction --->
	<cfset wallConsumption = 0 - wallBuild * session.walluseWood>

	<!--- army --->
	<cfset catapultWood  = 0 - player.catapults>
	
	<cfset burnWood = 0 - round(player.people / session.peopleBurnOneWood)>
	
	<cfset totalWoodSummer = woodProduction + toolConsumption + bowConsumption + maceConsumption + buyWood + catapultWood + wallConsumption>
	<cfset totalWoodWinter = totalWoodSummer + burnWood>
	
	<td align="right" class="SMALL"><br><b>#NumberFormat(totalWoodSummer, "+_,___,___,___,___")#</b><br>
						<b>#NumberFormat(totalWoodWinter, "+_,___,___,___,___")#</b></td>
						
	<td align="right" class="SMALL"><br>#NumberFormat(woodProduction, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(toolConsumption+bowConsumption+maceConsumption, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(catapultWood, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>#NumberFormat(buyWood, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL"><br>(heating)<br>#NumberFormat(burnWood, "+_,___,___,___,___")#</td>
</tr>
<tr>
	<td valign="top" class="SMALL">Iron</td>
	<!--- wood cutter --->
	<cfset canProduce = round(player.ironMine * (player.ironMineStatus / 100))>
	<cfset ironProduction = canProduce * ironMineB.production>
	<cfset ironProduction = ironProduction + round(ironProduction * (player.research6/100))>
	
	<!--- toolmaker cosumption --->
	<cfset toolConsumption = 0 - round(player.toolMaker * (player.toolMakerStatus / 100)) * toolMakerB.ironNeed>

	<!--- sword consumption --->
	<cfset canProduce = round(player.swordWeaponSmith * (player.weaponSmithStatus / 100))>
	<cfset swordConsumption = 0 - canProduce * weaponSmithB.ironNeed>
	<!--- mace consumption --->
	<cfset canProduce = round(player.maceWeaponSmith * (player.weaponSmithStatus / 100))>
	<cfset maceConsumption = 0 - canProduce * weaponSmithB.maceIron>
	<!--- wall construction --->
	<cfset wallConsumption = 0 - wallBuild * session.walluseIron>

	<!--- army --->
	<cfset catapultIron  = 0 - round(player.catapults/5)>
	
	<cfset totalIron = ironProduction + toolConsumption + swordConsumption + maceConsumption + buyIron + catapultIron + wallConsumption>
	
	<td align="right" class="SMALL"><b>#NumberFormat(totalIron, "+_,___,___,___,___")#</b></td>
	<td align="right" class="SMALL">#NumberFormat(ironProduction, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(toolConsumption+swordConsumption+maceConsumption+wallConsumption, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(catapultIron, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">#NumberFormat(buyIron, "+_,___,___,___,___")#</td>
	<td align="right" class="SMALL">---</td>
</tr>

</table>

</cfoutput>
<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfset research = arrayNew(1)>
<cfset research[1] = "Attack Points">
<cfset research[2] = "Defense Points">
<cfset research[3] = "Theifs Strength">
<cfset research[4] = "Military Losses">
<cfset research[5] = "Food Production">
<cfset research[6] = "Mine Production">
<cfset research[7] = "Weapons/Tools Production">
<cfset research[8] = "Space Effectivness">
<cfset research[9] = "Markets Output">
<cfset research[10] = "Explorers">
<cfset research[11] = "Catapults Strength">
<cfset research[12] = "Wood Production">



<!--- and inside the attack query loop --->
<cfquery name="defense" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #attack.attackPlayerID#
</cfquery>

<cfif defense.recordcount is 0><!--- player does not exist anymore --->
	<cfset message = message & "The empire #attack.attackPlayerID# does not exist anymore<br>">
<cfelseif newP.score gt defense.score * 2 and not deathMatchMode>
	<font face="verdana" color=red size=2>Cannot attack empires that are half as small as you.<br></font>
<cfelseif newP.score * 2 lt defense.score and not deathMatchMode>
	<font face="verdana" color=red size=2>Cannot attack empires that are twice as big as you.<br></font>
<cfelse>
	<cfset dColumns = "uunit,thieves,swordsman,archers,horseman,catapults,trainedPeasants,macemen,woodCutter,hunter,farmer,house,ironMine,goldMine,toolMaker,weaponSmith,tower,fort,townCenter,market,warehouse,stable,wood,iron,gold,food,people,swords,bows,horses,maces,tools,mageTower,research3,winery">
	<cfset dPlayer = structNew()>
	<cfloop list="#dColumns#" index="i">
		<cfset t = setVariable("dPlayer.#i#", evaluate("defense.#i#"))>
	</cfloop>

	<cfset attackMessage = "">
	
	<!--- see how many times attacked already that person --->
	<cfset sDate = dateAdd("h", -24, now())>
	<cfquery name="nqMyWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 3 and attackerWins = 1
    </cfquery>
	<cfquery name="nqMyLost" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 3 and attackerWins = 0
    </cfquery>
	<cfquery name="nqOtherWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID <> #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 3 and attackerWins = 1
    </cfquery>
	
	<cfset hasAttacks = round(val(nqMyWon.total) + val(nqMyLost.total)/3 + val(nqOtherWon.total)/5)>

	
	<cfscript>
	attackThieves = attack.thieves;
	defenseThieves = defense.thieves;
	
	attackmessage = attackmessage & "<font color=yellow face=verdana size=2>--------- Thieves Battle #player.name# (#player.id#) vs. #defense.name# (#defense.id#) #theDate# ---------<br></font>";

	attackPoints =  attackThieves * thievesA.attackPt;
	attackPoints = round(attackPoints + attackPoints * (newP.research3 / 100));	

	victoryPoints = 1;
	if (deathMatchMode) something = true; // just do nothing					
	else if (hasAttacks gte 15) {
		victoryPoints = victoryPoints * 0.01;
		attackPoints = round(attackPoints * 0.25);
		attackmessage = attackmessage & "<font color=red>#defense.name# was attacked too many times in the past 24 hours. <br>#player.name# army is weakened!!!!</font><br>";
	}					
	else if (hasAttacks gte 12) {
		victoryPoints = victoryPoints * 0.20;
		attackPoints = round(attackPoints * 0.60);
	}
	else if (hasAttacks gte 10) {
		victoryPoints = victoryPoints * 0.35;
		attackPoints = round(attackPoints * 0.68);	
	}
	else if (hasAttacks gte 8) {
		victoryPoints = victoryPoints * 0.50;
		attackPoints = round(attackPoints * 0.76);	
	}
	else if (hasAttacks gte 5) {
		victoryPoints = victoryPoints * 0.65;
		attackPoints = round(attackPoints * 0.84);	
	}
	else if (hasAttacks gte 3) {
		victoryPoints = victoryPoints * 0.80;
		attackPoints = round(attackPoints * 0.92);	
	}

	
	thiefDPt = 55;
	if (defense.civ is 1) { // vikings
		nothing = true;
	}
	else if (defense.civ is 2) { // franks
		nothing = true;
	}
	else if (defense.civ is 3) { // japanese
		nothing = true;
	}
	else if (defense.civ is 4) { // byzantines
		nothing = true;
	}
	else if (defense.civ is 5) { // mongols
		thiefDPt = 50;
	}
	else if (defense.civ is 6) { // incas
		thiefDpt = 80;
	}
	else if (defense.civ is 7) { // chinese
		thiefDpt = 65;
	}		
	else if (defense.civ is 8) { // barbarians
		nothing = true;
	}
	
	defensePoints =  defenseThieves * thiefDpt;
	defensePoints = round(defensePoints + defensePoints * (dPlayer.research3 / 100));					
	
	// now randomize the points with +/- 10%
	aStart = attackPoints - round(attackPoints*0.1);
	aEnd = attackPoints + round(attackPoints*0.1);
	dStart = defensePoints - round(defensePoints*0.1);
	dEnd = defensePoints + round(defensePoints*0.1);
	attackPoints = randRange(aStart, aEnd);
	defensePoints = randRange(dStart, dEnd);
	
	// calculate casaulties
	if (defense.score lt newP.score) // defense is weaker
		dDieThieves = round((attackPoints / 800) * victoryPoints);
	else	// defense is stronger
		dDieThieves = round((attackPoints / 500) * victoryPoints);
	if (dDieThieves gt defenseThieves) dDieThieves = defenseThieves;
	defenseThieves = defenseThieves - dDieThieves;
	

	if (defense.score gt newP.score) // attacking someone bigger, lose less army
		aDieThieves = round(defensePoints / 800);
	else 
		aDieThieves = round(defensePoints / 500);		
	if (aDieThieves gt attackThieves) aDieThieves = attackThieves;
	attackThieves = attackThieves - aDieThieves; 

	attackmessage = attackmessage & "#player.name# thieves kill #dDieThieves# thieves<br>";
	attackMessage = attackMessage & "#defense.name# thieves kill #aDieThieves# thieves.<br>";		

	if (attackPoints gt defensePoints) attackerWins = 1;
	else attackerWins = 0;
	
	newsMessage = "";
	if (attackerWins is 1) {
		attackmessage = attackmessage & "<br>#player.name# won the war!<br>";
		// look at attack type
		if (attack.attackType is 20) { // learn information
			attackmessage = attackmessage & "#player.name# learns the following information: <br>";
			attackmessage = attackmessage & "People: #NumberFormat(dPlayer.people)#<br>#uunitNames[defense.civ]#: #numberFormat(dPlayer.uunit)#<br>Swordsman: #NumberFormat(dPlayer.swordsman)#<br>Archers: #NumberFormat(dPlayer.archers)#<br>Horseman: #NumberFormat(dPlayer.horseman)#<br>Macemen: #NumberFormat(dPlayer.macemen)#<br>Trained Peasants: #NumberFormat(dPlayer.trainedPeasants)#<br>Catapults: #NumberFormat(dPlayer.catapults)#<br>Thieves: #NumberFormat(dPlayer.thieves)#<br>Towers: #NumberFormat(dPlayer.tower)#<br><br>";
			attackmessage = attackmessage & "Gold: #NumberFormat(dPlayer.gold)#<br>Food: #NumberFormat(dPlayer.food)#<br>Wood: #NumberFormat(dPlayer.wood)#<br>Iron: #NumberFormat(dplayer.iron)#<br>Tools: #NumberFormat(dPlayer.tools)#<br>";
			newsMessage = "Stole Army Information";
		}
		else if (attack.attackType is 24) { // building info
			attackmessage = attackmessage & "#player.name# learns the following information: <br>";
			for (i=1; i lt arraylen(buildings); i=i+1) {
				v = evaluate("dPlayer.#buildings[i].dbColumn#");
				attackmessage = attackmessage & "#buildings[i].name#: #NumberFormat(v)#<br>";
				newsMessage = "Stole Buildings Information";				
			}
		}				
		else if (attack.attackType is 25) { // research info
			attackmessage = attackmessage & "#player.name# learns the following information: <br>";
			for (i=1; i lte 12; i=i+1) {
				v = evaluate("dPlayer.#buildings[i].dbColumn#");
				attackmessage = attackmessage & "#research[i]#: #evaluate("defense.research#i#")#<br>";
				newsMessage = "Stole Research Information";				
			}
		}				
		
		else if (attack.attackType is 21) {	// steal goods
			p = RandRange(250, 500) / 10000; // get between 2.5 and 5 percent of what other player has
			if (p gt 0.2) p = 0.2; // no more than 20%
						
			p = p * victoryPoints;
			getGold = round(dPlayer.gold * p);
			getIron = round(dPlayer.iron * p);
			getWood = round(dPlayer.wood * p);
			getFood = round(dPlayer.food * p);
			getTools = round(dPlayer.tools * p);
			getMaces = round(dPlayer.maces * p);
			getSwords = round(dPlayer.swords * p);
			getBows = round(dPlayer.bows * p);
			getHorses = round(dPlayer.horses * p);
			attackmessage = attackmessage & "#player.name# steals #getGold# gold, #getFood# food, #getIron# iron, #getWood# wood, #getTools# tools, #getMaces# maces, #getSwords# swords, #getBows# bows and #getHorses# horses<br>";
			newsMessage = "Stole Goods";
			
			rgold = rgold + getGold;
			riron = riron + getIron;
			rfood = rfood + getFood;
			rwood = rwood + getWood;
			rtools = rtools + getTools;
			rmaces = rmaces + getMaces;
			rswords = rswords + getSwords;
			rbows = rbows + getBows;
			rhorses = rhorses + getHorses;
			
			dPlayer.gold = dPlayer.gold - getGold;
			dPlayer.iron = dPlayer.iron - getIron;
			dPlayer.food = dPlayer.food - getFood;
			dPlayer.wood = dPlayer.wood - getWood;
			dPlayer.tools = dPlayer.tools - getTools;
			dPlayer.swords = dPlayer.swords - getSwords;
			dPlayer.bows = dPlayer.bows - getBows;
			dPlayer.horses = dPlayer.horses - getHorses;
		}
		else if (attack.attackType is 22) { // poison water
			p = RandRange(200, 400) / 10000; // kill between 3 and 6 percent of army and people
			if (p gt 0.2) p = 0.2; // no more than 20%
			
			p = p * victoryPoints;
			dSwordsman = round(dPlayer.swordsman * p);
			dArchers = round(dPlayer.archers * p);
			dHorseman = round(dPlayer.horseman * p);
			dMacemen = round(dPlayer.macemen * p);
			dTrainedPeasants = round(dPlayer.trainedPeasants * p);
			dPeople = round(dPlayer.people * p);
			dUunit = round(dPlayer.uunit * p);
				
			newsMessage = "#val(dSwordsman + dArchers + dHorseman + dMacemen + dTrainedPeasants + duunit)# army<br>and #dPeople# people";
			attackmessage = attackmessage & "#player.name# poisoned #dSwordsman# swordsman, #dArchers# archers, #dHorseman# horseman, #dMacemen# macemen, #dTrainedPeasants# trained peasants, #dUunit# #uunitNames[defense.civ]#s and #dPeople# people.<br>";
				
			dPlayer.swordsman = dPlayer.swordsman - dSwordsman;
			dPlayer.archers = dPlayer.archers - dArchers;
			dPlayer.horseman = dPlayer.horseman - dHorseman;
			dPlayer.macemen = dPlayer.macemen - dMacemen;
			dPlayer.TrainedPeasants = dPlayer.trainedPeasants - dTrainedPeasants;
			dPlayer.people = dPlayer.people - dPeople;				
		}
		else if (attack.attackType is 23) { // burn buildings
			p = RandRange(200, 400) / 10000; // destory between 2 and 4 percent of buildings
			if (p gt 0.2) p = 0.2; // no more than 20%
			
			p = p * victoryPoints;
			dWoodCutter = round(dPlayer.woodCutter * p);
			dHunter = round(dPlayer.hunter * p);
			dFarmer = round(dPlayer.farmer * p);
			dHouse = round(dPlayer.house * p);
			dIronMine = round(dPlayer.ironMine * p);
			dGoldMine = round(dPlayer.goldMine * p);
			dToolMaker = round(dPlayer.toolmaker * p);
			dWeaponSmith = round(dPlayer.weaponSmith * p);
			dTower = round(dPlayer.tower * p);
			dTownCenter = round(dPlayer.townCenter * p);
			dFort = round(dPlayer.fort * p);
			dStable = round(dPlayer.stable * p);
			dWarehouse = round(dPlayer.warehouse * p);
			dMarket = round(dPlayer.market * p);
			dMageTower = round(dPlayer.mageTower * p);
			dWinery = round(dPlayer.winery * p);					

			dPlayer.woodCutter = dPlayer.woodCutter - dWoodCutter;
			dPlayer.hunter = dPlayer.hunter - dHunter;
			dPlayer.farmer = dPlayer.farmer - dFarmer;
			dPlayer.house = dPlayer.house - dHouse;
			dPlayer.ironMine = dPlayer.ironMine - dIronMine;
			dPlayer.goldMine = dPlayer.goldMine - dGoldMine;
			dPlayer.toolMaker = dPlayer.toolMaker - dToolMaker;
			dPlayer.weaponSmith = dPlayer.weaponSmith - dWeaponSmith;
			dPlayer.tower = dPlayer.tower - dTower;
			dPlayer.townCenter = dPlayer.townCenter - dTownCenter;
			dPlayer.fort = dPlayer.fort - dFort;
			dPlayer.stable = dPlayer.stable - dStable;
			dPlayer.warehouse = dPlayer.warehouse - dWarehouse;
			dPlayer.market = dPlayer.market - dMarket;
			dPlayer.mageTower = dPlayer.mageTower - dMageTower;
			dPlayer.winery = dPlayer.winery - dWinery;
					
			newsMessage = "#val(dWoodCutter+dHunter+dfarmer+dHouse+dIronMine+dGoldMine+dToolMaker+dWeaponSmith+dTower+dTownCenter+dFort+dStable+dWarehouse+dmarket+dMageTower+dWinery)# Buildings";
			attackmessage = attackmessage & "Fire destoryed #dWoodCutter# woodcutters, #dHunter# hunters, #dfarmer# farmers, #dhouse# houses, #dironmine# iron mines, #dGoldMine# gold mines, #dToolMaker# tool makers, #dweaponsmith# weaponsmiths, #dtower# towers, #dtowncenter# towncenters, #dfort# forts, #dstable# stables, #dmarket# markets, #dMageTower# mage towers, #dWinery# winery and #dwarehouse# warehouses<br>";
		}
	}
	else {
		attackmessage = attackmessage & "<br>#defense.name# won the war!<br>";
	}
	</cfscript>
	<cfset attackmessage = attackmessage & "<br>--------------------------------------------------------</font><br>">
	
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update attackQueue set 
		thieves = #attackThieves#
		where id = #attack.id#
	</cfquery>
	
	<cfset dPlayer.thieves = defenseThieves>
	<cfif dPlayer.people lt 100><cfset dPlayer.people = 100></cfif>	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update player set 
			<cfloop list="#dColumns#" index="i">
			#i# = #evaluate("dPlayer.#i#")#,
			</cfloop>
			lastAttack = #now()#,
			hasMainNews = 1
		where id = #attack.attackPlayerid#
	</cfquery>
	
	<cfset attackAlliance = "">
	<cfset defenseAlliance = "">
	<cfif player.allianceID gt 0>
		<cfquery datasource="#dsn#" name="alliance">
			select tag from alliance where id = #player.allianceiD#
		</cfquery>
		<cfif alliance.recordcount gt 0>
			<cfset attackAlliance = alliance.tag>
		</cfif>
	</cfif>
	
	<cfif defense.allianceID gt 0>
		<cfquery datasource="#dsn#" name="alliance">
	    	select tag from alliance where id = #defense.allianceID#
		</cfquery>
		<cfif alliance.recordcount gt 0>
			<cfset defenseAlliance = alliance.tag>
		</cfif>
	</cfif>
			
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		insert into attackNews (attackID, defenseID, attackThieves, defenseThieves,
			createdOn, attackerWins, message, attackAlliance, defenseAlliance, battleDetails,
			attackAllianceID, defenseAllianceID, attackType)
			values (#playerID#, #attack.attackPlayerID#, 
			#aDieThieves#, #dDieThieves#, 
			#now()#, #attackerWins#, '#newsMessage#',
			'#attackAlliance#', '#defenseAlliance#', '#attackmessage#',
			#player.allianceID#, #defense.allianceID#, 3)
	</cfquery>
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		insert into playerMessage (fromPlayerID, toPlayerID, fromPlayerName, toPlayerName, message, viewed, createdOn, messageType)
		values (#playerID#, #attack.attackPlayerID#, '#player.name#', '#defense.name#', '#attackMessage#', 0, #CreateODBCDateTime(Now())#, 1)
	</cfquery>
		
	<cfset message = message & attackMessage>
	
	<cf_calc_score datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" playerID="#attack.attackPlayerID#">

</cfif>
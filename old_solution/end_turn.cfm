<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<cfset start = getTickCount()>
<cfif page is "forum"><cfset page = "main"></cfif>

<cfset newP = structNew()>
<cfset p = player>
<cfloop list="#player.columnList#" index="col">
	<cfset t = setVariable("newP.#col#", evaluate("p.#col#"))>
</cfloop>

<cfset tempTurn = newP.turn + 1>
<cfset month = tempTurn mod 12 + 1>
<cfset year = fix(tempTurn / 12) + 1000>

<cfset message = message & "<font color=yellow><b>------------------------------ #MonthAsString(month)# #year# ------------------------------</b></font><br>">

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


<!--- process pub market --->
<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update transferQueue set turnsRemaining = turnsRemaining - 1 
	where 
		(fromPlayerID = #playerID# and transferType = 0 and turnsRemaining > 0) <!--- sending aid --->
		OR
		(toPlayerID = #playerID# and transferType = 2 and turnsRemaining > 0) <!--- buying from pub. market --->
</cfquery>

<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from transferQueue where toPlayerID = #playerID# and transferType = 2 and turnsRemaining = 0
</cfquery>
<cfloop query="tq">
	<cfset message = message & "<font color=yellow>A transport with #tq.wood# wood, #tq.food# food, #tq.iron# iron, #tq.tools# tools, #tq.maces# maces, #tq.swords# swords, #tq.bows# bows and #tq.horses# horses arrived from public market.</font><br>">
	<cfset newP.wood = newP.wood + tq.wood>
	<cfset newP.food = newp.food + tq.food>
	<cfset newP.iron = newP.iron + tq.iron>
	<cfset newP.tools = newP.tools + tq.tools>
	<cfset newP.maces = newP.maces + tq.maces>
	<cfset newP.swords = newP.swords + tq.swords>
	<cfset newP.bows = newP.bows + tq.bows>
	<cfset newP.horses = newP.horses + tq.horses>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        delete from transferQueue where id = #tq.id#
    </cfquery>
</cfloop>

<cfscript>
	numBuilders = toolMakerB.numBuilders * newP.toolMaker + 3;
	if (numBuilders gt newP.people)
		numBuilders = round(newP.people/2);
	if (numBuilders gt newP.tools) {
		message = message & "<font color=red>You do not have enough tools for all of your builders</font><br>";
		numBuilders = newP.tools;
	}
		
	// remaining
	rPeople = newP.people;	// people available for work
	rFood = newP.food;
	rWood = newP.wood;
	rIron = newP.iron;
	rGold = newP.gold;
	rTools = newP.tools;
	rSwords = newP.swords;
	rBows = newP.bows;
	rHorses = newP.horses;
	rMaces = newP.maces;
	rWine = newP.wine;
	
	// produced
	pFood = 0;
	pWood = 0;
	pIron = 0;
	pGold = 0;
	pTools = 0;
	pSwords = 0;
	pBows = 0;
	pHorses = 0;
	pMaces = 0;
	pWine = 0;
	
	// consumed
	cFood = 0;
	cWood = 0;
	cIron = 0;
	cGold = 0;
	cTools = 0;
	cSwords = 0;
	cBows = 0;
	cHorses = 0;
	cMaces = 0;
	cWine = 0;
	
	// food from hunters
	if (newP.hunterstatus gt 0) { // hunters operational
		canProduce = round(newP.hunter * (newP.hunterstatus / 100));
		peopleNeed = canProduce * hunterB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / hunterB.workers);	// if not enough people produce only what can
			message = message & "<font color=Red>Not enough people to work at hunters.<br></font>";
		}
		rPeople = rPeople - canProduce * hunterB.workers;	// working people
		getFood = canProduce * hunterB.production;
		getFood = getFood + round(getFood * (newP.research5/100));
		pFood = pFood + getFood;
	}

	// food from farms 
	if (newP.farmerStatus gt 0) {
		if (month gte 4 and month lte 10) { // only produces in certain months
			canProduce = round(newP.farmer * (newP.farmerStatus / 100));
			peopleNeed = canProduce * farmerB.workers;
			if (rPeople lt peopleNeed) {
				canProduce = int(rPeople / farmerB.workers); // produce only with available people
				message = message & "<font color=Red>Not enough people to work on farms.<br></font>";				
			}
			rPeople = rPeople - canProduce * farmerB.workers;	// working people
			
			getFood = canProduce * farmerB.production;
			getFood = getFood + round(getFood * (newP.research5/100));
			pFood = pFood + getFood;
		}		
	}
	rFood = rFood + pFood;	// new remaining food
	
	// produce wood
	if (newP.woodcutterStatus gt 0) {
		canProduce = round(newP.woodCutter * (newP.woodCutterStatus / 100));
		peopleNeed = canProduce * woodCutterB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / woodCutterB.workers);	// if not enough people produce only what can
			message = message & "<font color=Red>Not enough people to work at woodcutters.<br></font>";
		}
		rPeople = rPeople - canProduce * woodCutterB.workers;	// working people
		getWood = canProduce * 	woodCutterB.production;
		getWood = getWood + round(getWood * (newP.research12/100));
		pWood = getWood;
		rWood = rWood + pWood;		
	}
	
	// people eat food
	peopleDied = 0;
	// duing winter each house burns 1 wood
	burnWood = round(newP.people / session.peopleBurnOneWood);
	if (month gte 11 or month lte 2) {
		rWood = rWood - burnWood;
		cWood = cWood + burnWood;
		message = message & "#burnWood# wood was used for heat<br>";
		if (rWood lt 0) {
			peopleWithNoHeat = ceiling((abs(rWood) * session.peopleBurnOneWood)/8);
			if (peopleWithNoHeat gt newP.people) peopleWithNoHeat = newP.people - 1;
			peopleFreeze = randRange(val(peopleWithNoHeat/2), peopleWithNoHeat);
			newP.people = newP.people - peopleFreeze;
			message = message & "<font color=red>#peopleFreeze# people froze to death due to the lack of wood for heat</font><br>";
			rWood = 0;
		}
	}

	// soldiers eat food
	eatFood = round(newP.swordsman * swordsmanA.foodEaten + newP.archers * archerA.foodEaten + newP.horseman * horsemanA.foodEaten + 
		newP.macemen * macemanA.foodEaten + newP.trainedPeasants * trainedPeasantA.foodEaten + newP.thieves * thievesA.foodEaten + 
		newP.uunit * uunitA.foodEaten);
	if (eatFood gt 0) {

		cFood = cFood + eatFood;
		rFood = rFood - eatFood;
		message = message & "Your soldiers ate #numberFormat(eatFood)# food<br>";
		if (rFood lt 0) { // not enough food, calculate how many forts did not get food
			// 5% of army dies
			pt = 0.95;
			message = message & "<font color=red>some soldiers died due to the lack of food</font><br>";
			newP.swordsman = round(newP.swordsman * pt);
			newP.archers = round(newP.archers * pt);
			newP.horseman = round(newP.horseman * pt);
			newP.macemen = round(newP.macemen * pt);
			newP.trainedPeasants = round(newP.trainedPeasants * pt);
			newp.thieves = round(newP.thieves * pt);
			newP.uunit = round(newP.uunit * pt);
			rFood = 0;
		}
	}
	
	// produce gold
	if (newP.goldMineStatus gt 0) {
		canProduce = round(newP.goldMine * (newP.goldMineStatus / 100));
		peopleNeed = canProduce * goldMineB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / goldMineB.workers);	// if not enought people produce only what can
			message = message & "<font color=Red>Not enough people to work at gold mines.<br></font>";			
		}		
		rPeople = rPeople - canProduce * goldMineB.workers;
	
		getGold = goldMineB.production * canProduce;
		getGold = getGold + round(getGold * (newP.research6/100));
		pGold = getGold;
		rGold = rGold + pGold;
	}
		
	// produce iron
	if (newP.ironMineStatus gt 0) {
		canProduce = round(newP.ironMine * (newP.ironMineStatus / 100));

		peopleNeed = canProduce * ironMineB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / ironMineB.workers);	// if not enought people produce only what can
			message = message & "<font color=Red>Not enough people to work at iron mines.<br></font>";
		}
			
		rPeople = rPeople - canProduce * ironMineB.workers;		
		getIron = ironMineB.production * canProduce;
		getIron = getIron + round(getIron * (newP.research6/100));
		pIron = getIron;	
		rIron = rIron + pIron;
	}

 	// produce tools
	if (newP.toolMakerStatus gt 0) {
		canProduce = round(newP.toolMaker * (newP.toolMakerStatus / 100));

		peopleNeed = canProduce * toolMakerB.workers;

		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / toolMakerB.workers);	// if not enough people produce only what can
			message = message & "<font color=Red>Not enough people to work at tool makers.<br></font>";			
		}
		
		woodNeed = canProduce * toolMakerB.woodNeed;
		if (rWood lt woodNeed) {
			canProduce = int(rWood / toolMakerB.woodNeed);	// if not engout wood, produce only for the food that is available
			message = message & "<font color=Red>Not enough wood to produce all tools.<br></font>";
		}
		
		ironNeed = canProduce * toolMakerB.ironNeed;
		if (rIron lt ironNeed) {
			canProduce = int(rIron / toolMakerB.ironNeed);	// if not engout iron, produce only for the food that is available
			message = message & "<font color=Red>Not enough iron to produce all tools.<br></font>";
		}
		if (canProduce lt 0)
			canProduce = 0;
		
		rPeople = rPeople - canProduce * toolMakerB.workers;

		cWood = cWood + canProduce * toolMakerB.woodNeed;
		rWood = rWood - canProduce * toolMakerB.woodNeed;		
		
		cIron = cIron + canProduce * toolMakerB.ironNeed;
		rIron = rIron - canProduce * toolMakerB.ironNeed;
		
		pTools = canProduce * toolMakerB.production;
		pTools = pTools + round(pTools * (newP.research7/100));
		rTools = rTools + pTools;
	}
	
	// produce weapons
	if (newP.weaponSmithStatus gt 0) {
		if (newP.swordWeaponSmith + newP.bowWeaponSmith + newP.maceWeaponSmith gt newP.weaponSmith) {
			bowRatio = 0;
			maceRatio = 0;
			swordRatio = 0;
			hadBuildings = newP.swordWeaponSmith + newP.bowWeaponsmith + newP.maceweaponSmith;
			hasBuildings = newP.weaponsmith;
			
			if (hadBuildings gt 0) {
				bowRatio = newP.bowWeaponSmith / hadBuildings;
				swordRatio = newP.swordWeaponSmith / hadBuildings;
				maceRatio = newP.maceWeaponSmith / hadBuildings;
			
			}
			newP.bowWeaponsmith = int(hasBuildings * bowRatio);
			newP.swordWeaponSmith = int(hasBuildings * swordRatio);
			newP.maceWeaponsmith = int(hasBuildings * maceRatio);				

		}
	
		// swords
		canProduce = round(newP.swordWeaponSmith * (newP.weaponSmithStatus / 100));
		peopleNeed = canProduce * weaponSmithB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / weaponSmithB.workers);
			message = message & "<font color=Red>Not enough people to produce swords.<br></font>";			
		}
		
		ironNeed = canProduce * weaponSmithB.ironNeed;
		if (rIron lt ironNeed) {
			canProduce = int(rIron / weaponSmithB.ironNeed);
			message = message & "<font color=Red>Not enough iron to produce all swords.<br></font>";			
		}
		if (canProduce lt 0)
			canProduce = 0;
		
		rPeople = rPeople - canProduce * weaponSmithB.workers;
		
		cIron = cIron + canProduce * weaponSmithB.ironNeed;
		rIron = rIron - canProduce * weaponSmithB.ironNeed;
		
		pSwords = canProduce * weaponSmithB.production;
		pSwords = pSwords + round(pSwords * (newP.research7/100));
		rSwords = rSwords + pSwords;

		// bows
		canProduce = round(newP.bowWeaponSmith * (newP.weaponSmithStatus / 100));
		peopleNeed = canProduce * weaponSmithB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / weaponSmithB.workers);
			message = message & "<font color=Red>Not enough people to produce bows.<br></font>";					
		}
		
		woodNeed = canProduce * weaponSmithB.woodNeed;
		if (rWood lt woodNeed) {
			canProduce = int(rWood / weaponSmithB.woodNeed);
			message = message & "<font color=Red>Not enough wood to produce all bows.<br></font>";			
		}
		if (canProduce lt 0)
			canProduce = 0;
		
		rPeople = rPeople - canProduce * weaponSmithB.workers;
		
		cWood = cWood + canProduce * weaponSmithB.woodNeed;
		rWood = rWood - canProduce * weaponSmithB.woodNeed;
		
		pBows = canProduce * weaponSmithB.production;
		pBows = pBows + round(pBows * (newP.research7/100));
		rBows = rBows + pBows;
		
		// maces
		canProduce = round(newP.maceWeaponSmith * (newP.weaponSmithStatus / 100));
		peopleNeed = canProduce * weaponSmithB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / weaponSmithB.workers);
			message = message & "<font color=Red>Not enough people to produce maces.<br></font>";					
		}
		
		woodNeed = canProduce * weaponSmithB.maceWood;
		if (rWood lt woodNeed) {
			canProduce = int(rWood / weaponSmithB.maceWood);
			message = message & "<font color=Red>Not enough wood to produce all maces.<br></font>";			
		}
				
		ironNeed = canProduce * weaponSmithB.maceIron;
		if (rIron lt ironNeed) {
			canProduce = int(rIron / weaponSmithB.maceIron);
			message = message & "<font color=Red>Not enough iron to produce all maces.<br></font>";					
		}
		if (canProduce lt 0)
			canProduce = 0;
		
		rPeople = rPeople - canProduce * weaponSmithB.workers;
		
		cWood = cWood + canProduce * weaponSmithB.maceWood;
		rWood = rWood - canProduce * weaponSmithB.maceWood;
		
		cIron = cIron + canProduce * weaponSmithB.maceIron;
		rIron = rIron - canProduce * weaponSmithB.maceIron;
		
		pMaces = canProduce * weaponSmithB.production;
		pMaces = pMaces + round(pMaces * (newP.research7/100));
		rMaces = rMaces + pMaces;
		
	
	}
	
	// produce horses
	if (newP.stableStatus gt 0) {
		canProduce = round(newP.stable * (newP.stableStatus / 100));
		peopleNeed = canProduce * stableB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / stableB.workers);	// if not enought people produce only what can
			message = message & "<font color=Red>Not enough people to work at stables.<br></font>";			
		}
				
		foodNeed = canProduce * stableB.foodNeed;
		if (rFood lt foodNeed) {
			canProduce = int(rFood / stableB.foodNeed);	// if not engout food, produce only for the food that is available
			message = message & "<font color=Red>Not enough food to produce all horses.<br></font>";			
		}
		if (canProduce lt 0)
			canProduce = 0;
				
		rPeople = rPeople - canProduce * stableB.workers;
		
		cFood = cFood + canProduce * stableB.foodNeed;
		rFood = rFood - canProduce * stableB.foodNeed;
		
		pHorses = stableB.production * canProduce;		
		rHorses = rHorses + stableB.production * canProduce;
	}
	
	// produce wine
	if (newP.wineryStatus gt 0) {
		canProduce = round(newP.winery * (newP.wineryStatus / 100));
		peopleNeed = canProduce * wineryB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / wineryB.workers);	// if not enought people produce only what can
			message = message & "<font color=Red>Not enough people to work at winery.<br></font>";			
		}		

		goldNeed = canProduce * wineryB.goldNeed;
		if (rGold lt goldNeed) {
			canProduce = int(rGold / wineryB.goldNeed);	
			message = message & "<font color=Red>Not enough gold to produce wine.<br></font>";			
		}
		if (canProduce lt 0)
			canProduce = 0;
		
		
		rPeople = rPeople - canProduce * mageTowerB.workers;
		
		cGold = cGold + canProduce * wineryB.goldNeed;
		rGold = rGold - canProduce * wineryB.goldNeed;

	
		getWine = wineryB.production * canProduce;
		//getWine = getWine + round(getWine * (newP.research6/100));
		pWine = getWine;
		rWine = rWine + pWine;
	}
	
	
	// process mage towers
	if (newP.mageTowerStatus gt 0 and newP.currentResearch gt 0) {
		canProduce = round(newP.mageTower * (newP.mageTowerStatus / 100));

		peopleNeed = canProduce * mageTowerB.workers;
		if (rPeople lt peopleNeed) {
			canProduce = int(rPeople / mageTowerB.workers);	// if not enought people produce only what can
			message = message & "<font color=Red>Not enough people to work at magetowers.<br></font>";			
		}
		goldNeed = canProduce * mageTowerB.goldNeed;
		if (rGold lt goldNeed) {
			canProduce = int(rGold / mageTowerB.goldNeed);	
			message = message & "<font color=Red>Not enough gold to do all research.<br></font>";			
		}
		if (canProduce lt 0)
			canProduce = 0;

		
		rPeople = rPeople - canProduce * mageTowerB.workers;
		
		cGold = cGold + canProduce * mageTowerB.goldNeed;
		rGold = rGold - canProduce * mageTowerB.goldNeed;
				
		newP.researchPoints = newP.researchPoints + round(canProduce * mageTowerB.production);
	}

	// see if finished research
	if (newP.currentResearch gt 0 and newP.researchPoints gt 0) {
		totalResearches = newP.research1 + newP.research2 + newP.research3 + newP.research4 + newP.research5 + newP.research6 + newP.research7 + newP.research8 + newP.research9 + newP.research10 + newP.research11 + newP.research12;
		needResearchPoints = round(totalResearches * totalResearches * sqr(totalResearches) + 10);
		while (newP.researchPoints gte needResearchPoints) {
			newP.researchPoints = newP.researchPoints - needResearchPoints;
			totalResearches = totalResearches + 1;
			if (newP.currentResearch is 4 and newP.research4 gte 50) { // max 50 levels for military loss
				message = message & "<font color=red>You can only have up 50 research levels for military loss<br></font>";
				newP.researchPoints = needResearchPoints;
				break;
			}
			else {
				nr = evaluate("newP.research#newP.currentResearch#") + 1;
				test = setVariable("newP.research#newP.currentResearch#", nr);
				message = message & "<font color=yellow>Finished research of #research[newP.currentResearch]#<br></font>";			
				needResearchPoints = round(totalResearches * totalResearches * sqr(totalResearches) + 10);			
			}
		}			
	}
	
	// construct wall
	totalLand = player.mland + player.fland + player.pland;
	totalWall = round(totalLand * 0.05);
	
	// 25% chance that the wall will decay
	dRange = randRange(1, 100);
	if (dRange lte 25 and newP.wall gt 10) {
		decay = round(newP.wall * (dRange / 750));
		if (decay gt 0) {
			message = message & "<font color=red>#numberFormat(decay)# units of wall detoriated</font><br>";
			newP.wall = newP.wall - decay;
		}
	}	
	
	if (newP.wallBuildPerTurn gt 0 and newP.wall lt totalwall) {
		bPercent = newP.wallBuildPerTurn / 100;
		wallBuilders = round(numbuilders * bPercent);

		canProduce = int(wallBuilders / 25);
		if (canProduce + newP.wall gt totalWall)
			canProduce = totalWall - newp.wall;
		
		goldNeed = canProduce * session.wallUseGold;
		if (rGold lt goldNeed) {
			canProduce = int(rGold / session.wallUseGold);	
			message = message & "<font color=Red>Not enough gold for constuction of the great wall.<br></font>";			
		}
		woodNeed = canProduce * session.wallUseWood;
		if (rWood lt woodNeed) {
			canProduce = int(rWood / session.walluseWood);	
			message = message & "<font color=Red>Not enough wood for constuction of the great wall.<br></font>";			
		}
		ironNeed = canProduce * session.walluseIron;
		if (rIron lt ironNeed) {
			canProduce = int(rIron / session.walluseIron);	
			message = message & "<font color=Red>Not enough iron for constuction of the great wall.<br></font>";			
		}
		wineNeed = canProduce * session.walluseWine;
		if (rWine lt wineNeed) {
			canProduce = int(rWine / session.walluseWine);	
			message = message & "<font color=Red>Not enough wine for constuction of the great wall.<br></font>";			
		}
		
		if (canproduce gt 0) {
			cGold = cGold + canProduce * session.walluseGold;
			rGold = rGold - canProduce * session.walluseGold;
			
			cWood = cWood + canProduce * session.wallUseWood;
			rWood = rWood - canProduce * session.walluseWood;
			
			cIron = cIron + canProduce * session.walluseIron;
			rIron = rIron - canProduce * session.walluseIron;
					
			cWine = cWine + canProduce * session.walluseWine;
			rWine = rWine - canProduce * session.walluseWine;					
					
			newP.wall = newP.wall + canProduce;
			message = message & "<font color=yellow>Constructed #canProduce# units of wall.<br></font>";			
			
			numBuilders = numBuilders - (canProduce * 10);
		}
	}
	
</cfscript>

<cfset foodEaten = round(newp.people/session.peopleEatOneFood)>
<!--- eat more or less depending on food ratios --->
<cfif newP.foodRatio is 1><cfset foodEaten = round(foodEaten * 1.5)>
<cfelseif newP.foodRatio is 2><cfset foodEaten = round(foodEaten * 2.5)>
<cfelseif newp.foodRatio is 3><cfset foodEaten = round(foodEaten * 4)>
<cfelseif newp.foodRatio is 4><cfset foodEaten = round(foodEaten * 8)>
<cfelseif newp.foodRatio is -1><Cfset foodEaten = round(foodEaten * 0.75)>
<cfelseif newp.foodRatio is -2><cfset foodEaten = round(foodEaten * 0.45)>
</cfif>

<cfset message = message & "Your people ate #numberFormat(foodEaten)# food<br>">
<cfset rfood = rfood - foodEaten>
<cfset cFood = cFood + foodEaten>

<cfset growth = 0>
<cfswitch expression="#p.foodRatio#">
<cfcase value="-2"><cfset growth = randRange(-200, -100)></cfcase>
<cfcase value="-1"><cfset growth = randRange(-100, -50)></cfcase>
<cfcase value="0"><cfset growth = randRange(-30, 50)></cfcase>
<cfcase value="1"><cfset growth = randRange(50, 100)></cfcase>
<cfcase value="2"><Cfset growth = randRange(100, 200)></cfcase>
<cfcase value="3"><cfset growth = randRange(200, 400)></cfcase>
<cfcase value="4"><cfset growth = randRange(400, 800)></cfcase>
</cfswitch>

<cfif rfood lt 0><!--- some people did not get food --->
	<cfset peopleDie = round(newP.people * 0.07)><!--- 5% people die --->
	<cfset message = message & "<font color=red>#numberFormat(peopleDie)# people died due to lack of food</font><br>">
	<cfset newp.people = newp.people - peopleDie>
	<cfif newP.people lt newP.towncenter + newP.house>
		<cfset newP.people = newP.townCenter + newp.house>
	</cfif>	
	<cfset rfood = 0>
	<cfset growth = 0>
	<cfset processTurn = false><!--- to stop turn processing --->
</cfif>

<cfset houseSpace = newp.house * houseB.people + newP.towncenter * townCenterB.people>
<cfset houseSpace = round(houseSpace + houseSpace * (newP.research8 / 100))>

<cfif growth gt 0 and houseSpace gt newP.people><!--- people can only grow if they get enough food --->
	<cfset peopleCome = round((growth/10000) * p.people * session.popIncreaseModifier)>
	<cfset message = message & "Your population increased by #numberFormat(peopleCome)#<br>">
	<cfset rPeople = rPeople + peopleCome>
	<cfset newP.people = newp.people + peopleCome>
	<cfif newP.people gt houseSpace><cfset newP.people = houseSpace></cfif>
<cfelseif growth lt 0><!--- negative food ratio --->
	<cfset peopleLeave = abs(round((growth/10000) * p.people))>
	<cfset message = message & "Due to poor food rationing your population decreased by #numberFormat(peopleLeave)# people<br>">
	<cfset newp.people = newp.people - peopleLeave>
<cfelseif growth gt 0 and houseSpace is newP.people>
	<cfset message = message & "Lack of housing prevents further growth of population.<br>">
</cfif>	

<!--- see if enough housing --->
<cfif newP.people gt houseSpace>
	<cfset peopleLeave = ceiling((newP.people - houseSpace) / 2)>
	<cfset newP.people = newP.people - peopleLeave>
	<cfset message = message & "<font color=red>Due to lack of housing #numberFormat(peopleLeave)# people emigrated from your empire</font><br>">
</cfif>

<!--- process building queue --->
<cfquery name="b" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from buildQueue where playerID = #playerID# and onHold = 0 order by pos
</cfquery>

<cfscript>
	// calculate used land and total buildings had
	mUsed = 0;
	fUsed = 0;
	pUsed = 0;
	totalBuildings = 0;
	for (i=1; i lte arrayLen(buildings); i=i+1) {		
		thisB = buildings[i];
		has = evaluate("p.#thisb.dbColumn#");
		totalBuildings = totalBuildings + has;
		if (thisb.land is "M")
			mUsed = mUsed + has * thisb.sq;
		else if (thisb.land is "F")
			fUsed = fUsed + has * thisb.sq;
		else
			pUsed = pUsed + has * thisb.sq;
	}

	buildMoves = numBuilders;
	
</cfscript>

<cfloop query="b">
	<cfscript>
	// see if have enough land for this building 
	building = buildings[b.buildingNo];	
	needLand = building.sq;

	if (building.land is "M") hasLand = newp.mLand - mUsed;
	else if  (building.land is "F") hasLand = newp.fLand - fUsed;
	else if (building.land is "P") hasLand = newp.pLand - pUsed;
		
	if (hasLand lte 0 and b.mission is 0) {
		message = message & "<font color=red>You do not have any free #building.land# land to build #building.name#</font><br>";
		timeRemaining = -1;
	}
	else {
		buildMovesSave = buildMoves;
		bNeedTime = building.costWood + building.costIron;	// time needed for one building
			
		timeRemaining = b.timeNeeded;
		if (buildMoves gt timeRemaining) {	// we can finish all buildings
			buildMoves = buildMoves - timeRemaining;
			timeRemaining = 0;		
		}
		else {
			timeRemaining = timeRemaining - buildMoves;
			buildMoves = 0;
		}		
			
		// see how many buildings where build or demolished
		qtyRemaining = ceiling(timeRemaining / bNeedTime);
		qtyBuild = b.qty - qtyRemaining;
			
		landTaken = qtyBuild * building.sq;
		if (landTaken gt hasLand and b.mission is 0) { // cannot build, not enough land
			// see how many can be build
			qtyBuild = fix(hasLand / building.sq);
			qtyRemaining = b.qty - qtyBuild;
			buildMoves = buildMoves + qtyRemaining * bNeedTime;
			timeRemaining = qtyRemaining * bNeedTime;
			landTaken = qtyBuild * building.sq;
			
			message = message & "<font color=red>Not enough land (#val(qtyRemaining*building.sq)# #building.land#) to process construction of #building.name#</font><br>";
		}
	
		dbCol = building.dbColumn;		
		constructed = false;
		if (qtyBuild gt 0 and b.mission is 0) { // built some buildings
			message = message & "<font color=yellow>Finished construction of #qtyBuild# #building.name#s</font><br>";
			if (building.land is "M") mUsed = mUsed + landTaken;
			else if  (building.land is "F") fUsed = fused + landTaken;
			else if (building.land is "P") pUsed = pUsed + landTaken;

			hadBuildings = evaluate("newP.#dbCol#");			
			hasBuildings = hadBuildings + qtyBuild;
			constructed = true;
		}
		else if (qtyBuild gt 0 and b.mission is 1) { // demolished some buildings
			message = message & "<font color=yellow>Demolished #qtyBuild# #building.name#s</font><br>";
			if (building.land is "M") mUsed = mUsed - landTaken;
			else if  (building.land is "F") fUsed = fused - landTaken;
			else if (building.land is "P") pUsed = pUsed - landTaken;	
			
			hadBuildings = evaluate("newP.#dbCol#");
			hasBuildings = hadBuildings - qtyBuild;
			constructed = true;
		}
		
		if (constructed) {
			if (dbCol is "weaponSmith") { // demolished weapon smith 
				// try to preserve ratio
				bowRatio = 0;
				maceRatio = 0;
				swordRatio = 0;
				if (hadBuildings gt 0) {
					bowRatio = newP.bowWeaponSmith / hadBuildings;
					swordRatio = newP.swordWeaponSmith / hadBuildings;
					maceRatio = newP.maceWeaponSmith / hadBuildings;
				
				}
				newP.bowWeaponsmith = int(hasBuildings * bowRatio);
				newP.swordWeaponSmith = int(hasBuildings * swordRatio);
				newP.maceWeaponsmith = int(hasBuildings * maceRatio);				
			}		
			t = setVariable("newP.#dbCol#", hasBuildings);				
		}		
	}
	</cfscript>
		
	<cfif timeRemaining is 0>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	    	delete from buildQueue where id = #b.id#
		</cfquery>
	<cfelseif timeRemaining gt 0>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	        update buildQueue set
			timeNeeded = #timeRemaining#,
			qty = #qtyRemaining#
			where id = #b.id#
		</cfquery>
	</cfif>	
</cfloop>

<!--- process train queue --->
<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update trainQueue set turnsRemaining = turnsRemaining - 1 where playerID = #playerID#
</cfquery>
<cfquery name="t" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from trainQueue where playerID = #playeriD# and turnsRemaining <= 0
</cfquery>

<cfset pSwordsman = 0>
<cfset pArchers = 0>
<cfset pHorseman = 0>
<cfset pMacemen = 0>
<cfset pCatapults = 0>
<cfset pTrainedPeasants = 0>
<cfset pThieves = 0>
<cfset pUunit = 0>
<cfset maxSoldiers = newP.townCenter * townCenterB.maxUnits + newP.fort * fortB.maxUnits>
<cfloop query="t"><!--- process trained units --->
	<cfscript>
	totalArmy = newP.archers + newP.swordsman + newP.horseman + newP.catapults + newP.macemen + newP.thieves + newP.trainedPeasants;
	done = true;
	trainQty = t.qty;
	if (t.turnsRemaining lt 0) {
		message = message & "<font color=red>#trainQty# training army units were disbanded because of lack of forts</font><br>";
		newP.people = newP.people + trainQty;		
	}
	else {
		if (totalArmy + t.qty gt maxSoldiers) {
			done = false;
			trainQty = maxSoldiers - totalArmy;
			if (trainQty lt 0) trainQty = 0;
			message = message & "<font color=red>Not enough forts to finish training army</font><br>";
		}
		
		if (t.soldierType is 1) {
			pArchers = pArchers + trainQty;
			newP.archers = newP.archers + trainQty;
		}
		else if (t.soldierType is 2) {
			pSwordsman = pSwordsman + trainQty;
			newP.swordsman = newP.swordsman + trainQty;
		}
		else if (t.soldierType is 3) {
			pHorseman = pHorseman + trainQty;
			newP.horseman = newP.horseman + trainQty;
		}
		else if (t.soldierType is 5) {
			pCatapults = pCatapults + trainQty;
			newP.catapults = newP.catapults + trainQty;
		}
		else if (t.soldierType is 6) {
			pMacemen = pMacemen + trainQty;
			newP.macemen = newP.macemen + trainQty;
		}
		else if (t.soldierType is 7) {
			pTrainedPeasants = pTrainedPeasants + trainQty;
			newP.trainedPeasants = newP.trainedPeasants + trainQty;
		}
		else if (t.soldierType is 8) {
			pThieves = pThieves + trainQty;
			newP.thieves = newP.thieves + trainQty;
		}
		else if (t.soldierType is 9) {
			pUunit = pUunit + trainQty;
			newP.uunit = newP.uunit + trainQty;
		}
	} // end if turnsRemaining lt 0
	</cfscript>
	<cfif done>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	    delete from trainQueue where id = #t.id#
	    </cfquery>
	<cfelse>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update trainQueue set qty = qty - #trainQty# where id = #t.id#
        </cfquery>
	</cfif>
</cfloop>

<cfscript>
	// message for trained soldiers
	if (pSwordsman gt 0) 
		message = message & "<font color=yellow>#pSwordsman# swordsman have finished their training and are ready to serve you</font><br>";
	if (pArchers gt 0)
		message = message & "<font color=yellow>#pArchers# archers have finished their training and are ready to serve you</font><br>";	
	if (pHorseman gt 0)
		message = message & "<font color=yellow>#pHorseman# horsemen have finished their training and are ready to serve you</font><br>";
	if (pMacemen gt 0)
		message = message & "<font color=yellow>#pMacemen# macemen have finished their training and are ready to serve you</font><br>";
	if (pCatapults gt 0)
		message = message & "<font color=yellow>#pCatapults# catapults have finished their training and are ready to serve you</font><br>";	
	if (pTrainedPeasants gt 0)
		message = message & "<font color=yellow>#pTrainedPeasants# trained peasants have finished their training and are ready to serve you</font><br>";	
	if (pThieves gt 0)
		message = message & "<font color=yellow>#pThieves# thieves have finished their training and are ready to serve you</font><br>";	
	if (pUunit gt 0)
		message = message & "<font color=yellow>#pUunit# #uunitA.name# have finished their training and are ready to serve you</font><br>";	
	// every year 5 to 10 percent of tools used by builders use up 
	if (month is 5 or month is 10) {
		toolsUsed = int(randRange(10, 20));
		toolsUsed = round(numBuilders * toolsUsed / 100);	
		if (toolsUsed gt 0) {
			message = message & "#toolsUsed# tools wore out<br>";
			if (rTools gte toolsUsed) // if has enough tools supply builders with them
				rTools = rTools - toolsUsed;
			else rTools = 0;
		}
	}
	
	if (pWood is not 0 or cWood is not 0) {
		if (pWood - cWood lt 0) c = "red"; else c = "yellow";
		message = message & "Produced #numberFormat(pWood)# wood and used #numberFormat(cWood)# wood (<font color=#c#>#NumberFormat(val(pWood-cWood), "+_,___,___,___")#</font>)<br>";
	}	
	if (pFood is not 0 or cFood is not 0) {
		if (pFood - cFood lt 0) c = "red"; else c = "yellow";
		message = message & "Produced #numberFormat(pFood)# food and used #numberFormat(cFood)# food (<font color=#c#>#NumberFormat(val(pFood-cFood), "+_,___,___,___")#</font>)<br>";
	}		
	if (pIron is not 0 or cIron is not 0) {
		if (pIron - cIron lt 0) c = "red"; else c = "yellow";
		message = message & "Produced #numberFormat(pIron)# iron and used #numberFormat(cIron)# iron (<font color=#c#>#NumberFormat(val(pIron-cIron), "+_,___,___,___")#</font>)<br>";
	}
	if (pGold is not 0 or cGold is not 0) {
		if (pGold - cGold lt 0) c = "red"; else c = "yellow";
		message = message & "Produced #numberFormat(pGold)# gold and used #numberFormat(cGold)# gold (<font color=#c#>#NumberFormat(val(pGold-cGold), "+_,___,___,___")#</font>)<br>";
	}		
	if (pWine is not 0 or cWine is not 0) {
		if (pWine - cWine lt 0) c = "red"; else c = "yellow";
		message = message & "Produced #numberFormat(pWine)# wine and used #numberFormat(cWine)# wine (<font color=#c#>#NumberFormat(val(pWine-cWine), "+_,___,___,___")#</font>)<br>";
	}		
	
	message = message & "Produced #pTools# tools, #pSwords# swords, #pBows# bows, #pMaces# maces and #pHorses# horses<br>";
</cfscript>

<!--- process explorers --->
<cfquery name="e" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from exploreQueue where playerID = #playerID# order by id
</cfquery>
<cfloop query="e">
	<cfif e.turn is 0>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			delete from exploreQueue where id = #e.id#            
        </cfquery>
	<cfelse>
		<cfscript>
		// discovered land 

		m = ceiling(e.people * 0.13);
		f = ceiling(e.people * 0.26);
		p = ceiling(e.people * 0.58);
		//m = e.people * 4;
		//f = e.people * 6;
		//p = e.people * 12;
		m_half = round(m/3);
		f_half = round(f/3);
		p_half = round(p/3);

		if (e.seekLand is 1) {
			m = m * 3; m_half = m_half * 3;
			f = 0; f_half = 0; 
			p = 0; p_half = 0;
		}
		else if (e.seekLand is 2) {
			m = 0; m_half = 0;
			f = round(f * 2.5); f_half = round(f_half * 2.5);
			p = 0; p_half = 0;
		}
		else if (e.seekLand is 3) {
			m = 0; m_half = 0;
			f = 0; f_half = 0;
			p = p * 2;	p_half = p_half * 2;
		}

		
		m = randRange(m_half, m);  // chance to find mountains
		f = randRange(f_half, f);  // chance to find forest
		p = randRange(p_half, p);  // chance to find plains

		if (newP.research10 gt 0) { // exploring research
			m = round(m + m * (newP.research10 / 100));
			f = round(f + f * (newP.research10 / 100));
			p = round(p + p * (newP.research10 / 100));
		}
		
		playerTotalLand = newp.mLand + newp.fland + newp.pland;
		
		// for each 500K land player has, they discover less land
		mult = 1;
		if (playerTotalLand gt 500000) {
			mult = playerTotalLand / 500000; // that many percent less land
			if (mult gte 100) mult = 99;	// has at least 1% efficiecny
			mult = (100 - mult) / 100;		// 100 - percent is the actual efficiency
			
		}	

		m = round(m * mult);
		f = round(f * mult);
		p = round(p * mult);			

		newP.mLand = newP.mLand + m;
		newP.fLand = newP.fLand + f;
		newP.pLand = newP.pLand + p;
		if (m is not 0 or f is not 0 or p is not 0)
			message = message & "<font color=yellow>Your explorers have discovered #m# mountain land, #f# forest land and #p# plain land</font><br>";
		else message = message & "Your explorers did not discover any land this turn<br>";
		
		
		newTurn = e.turn - 1;		
		if (newTurn is 0)
	 		message = message & "<font color=yellow>Your explorers ended their mission discovering total #val(e.mLand+m)# mountain land, #val(e.fland+f)# forest land and #val(e.pland+p)# plain land</font><br>";
		
		</cfscript>
		
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	           update exploreQueue set
					turn = #newTurn#,
					turnsUsed = turnsUsed + 1,
					mLand = mLand + #m#,
					fLand = fLand + #f#,
					pLand = pLand + #p#
				where id = #e.id#
	     </cfquery>
	</cfif>
</cfloop>

<!--- process army --->
<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update attackQueue set status = status + 1 where playerID = #playerID#
</cfquery>
<cfquery name="attack" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from attackQueue where playerID = #playerID# and (status = 3 or status >= 6) <!--- get only attacking ones or the ones that returned home --->
</cfquery>

<cfloop query="attack">
	<cfif attack.status is 3><!--- attacking --->
		<cfif attack.attackType gte 0 and attack.attackType lt 10>
			<cfinclude template="doAttack.cfm">
		<cfelseif attack.attackType gte 10 and attack.attackType lt 20>
			<cfinclude template="doAttack2.cfm">
		<cfelseif attack.attackType gte 20 and attack.attackType lt 30>
			<cfinclude template="doAttack3.cfm">
		</cfif>
	<cfelseif attack.status gte 6><!--- got home --->
		<cfset newP.swordsman = newP.swordsman + attack.swordsman>
		<cfset newP.archers = newP.archers + attack.archers>
		<Cfset newP.horseman = newP.horseman + attack.horseman>
		<cfset newP.macemen = newP.macemen + attack.macemen>
		<cfset newP.trainedPeasants = newP.trainedPeasants + attack.trainedPeasants>
		<cfset newP.thieves = newP.thieves + attack.thieves>
		<cfset newP.catapults = newP.catapults + attack.catapults>
		<cfset newP.uunit = newP.uunit + attack.uunit>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            delete from attackQueue where id = #attack.id#
        </cfquery>
		<cfset message = message & "<font color=yellow>Your army has returned to the empire</font><br>">
	</cfif>
</cfloop>

<cfscript>
	// if there is not enough room for soldiers, some of them run away
	canHaveSoldiers = newP.fort * fortB.maxUnits + newP.towncenter * townCenterB.maxunits;
	numsoldiers = newP.swordsman + newP.archers + newP.horseman + newP.macemen + newP.trainedPeasants + newP.thieves + newP.catapults + newP.uunit;

	if (numsoldiers gt canHaveSoldiers)	// forts cannot support such huge army
	{
		tooMuch = (numsoldiers - canHaveSoldiers) * 0.25;
		runS = Round((newP.swordsman / numsoldiers) * tooMuch);
		runA = Round((newP.archers / numsoldiers) * tooMuch);
		runH = Round((newP.horseman / numsoldiers) * tooMuch);
		runM = Round((newP.macemen / numsoldiers) * tooMuch);
		runP = Round((newP.trainedPeasants / numsoldiers) * tooMuch);
		runT = Round((newP.thieves / numsoldiers) * tooMuch);
		runC = Round((newP.catapults / numsoldiers) * tooMuch);
		runU = Round((newP.uunit / numsoldiers) * tooMuch);
		
		newP.swordsman = newP.swordsman - runS;
		newP.archers = newP.archers - runA;
		newP.horseman = newP.horseman - runH;
		newP.macemen = newP.macemen - runM;
		newP.trainedPeasants = newP.trainedPeasants - runP;
		newP.thieves = newP.thieves - runT;
		newP.catapults = newP.catapults - runC;
		newP.uunit = newP.uunit - runU;
		numsoldiers = numsoldiers - runS - runA - runH - runM - runP - runT - runC - runU;;
		message = message & "<font color=red>Due to the lack of place to live some of your soldiers run away (#runU# #uunitA.name#, #runS# swordsman, #runA# archers, #runH# horseman, #runM# macemen, #runP# trained peasants, #runC# catapults and #runT# thieves)</font><br>";
	}

	// every year soldiers are paid gold
	payGold = round(newP.swordsman * swordsmanA.goldPerTurn + newP.archers * archerA.goldPerTurn + newP.horseman * horsemanA.goldPerTurn + newP.macemen * macemanA.goldPerTurn + newP.trainedPeasants * trainedPeasantA.goldPerTurn + newP.thieves * thievesA.goldPerTurn + newP.uunit * uunitA.goldPerTurn);
	if (payGold gt rGold)	// not enough gold
	{
		tempSoldiers = newP.swordsman + newP.archers + newP.horseman + newP.macemen + newP.trainedPeasants + newP.thieves + newP.uunit;
		notPaid = (payGold - rGold) * 0.1;
		runS = Round((newP.swordsman / tempSoldiers) * notPaid);
		runA = Round((newP.archers / tempSoldiers) * notPaid);
		runH = Round((newP.horseman / tempSoldiers) * notPaid);
		runM = Round((newP.macemen / tempSoldiers) * notPaid);
		runP = Round((newP.trainedPeasants / tempSoldiers) * notPaid);
		runT = Round((newP.thieves / tempSoldiers) * notPaid);
		runU = Round((newP.uunit / tempSoldiers) * notPaid);
		
		newP.swordsman = newP.swordsman - runS;
		newP.archers = newP.archers - runA;
		newP.horseman = newP.horseman - runH;
		newP.macemen = newP.macemen - runM;
		newP.trainedPeasants = newP.trainedPeasants - runP;
		newP.thieves = newP.thieves - runT;
		newP.uunit = newp.uunit - runU;
		message = message & "<font color=red>Because you did not have enough gold to pay your soldiers some of them run away (#runU# #uunitA.name#, #runS# swordsman, #runA# archers, #runH# horseman, #runM# macemen, #runP# trained peasants and #runT# thieves)</font><br>";
		processTurn = false;
		
		payGold = rGold;
		rGold = 0;
		cGold = cGold + payGold;
	}
	else {
		rGold = rGold - payGold;
		cGold = cGold + payGold;
		message = message & "Your soldiers have been paid #NumberFormat(payGold)# gold<br>";
	}

	if (newP.thieves gt newP.townCenter)	// not enough town centers for thieves
	{
		tooMuch = (newP.thieves - newP.townCenter);
		runT = tooMuch;
		
		newP.thieves = newP.thieves - runT;
		numsoldiers = numsoldiers - runT;
		message = message & "<font color=red>You do not have enough town centers for your thieves. #runT# thieves run away</font><br>";
	}

	if (newP.uunit gt newP.townCenter)	// not enough town centers for uunit
	{
		tooMuch = (newP.uunit - newP.townCenter);
		runU = tooMuch;
		
		newP.uunit = newP.uunit - runU;
		numsoldiers = numsoldiers - runU;
		message = message & "<font color=red>You do not have enough town centers for your #uunitA.name#s. #runU# #uunitA.name#s run away</font><br>";
	}


	if (newP.catapults gt newP.townCenter)	// not enough town centers for catapults
	{
		tooMuch = (newP.catapults - newP.townCenter);
		runC = tooMuch;
		
		newP.catapults = newP.catapults - runC;
		numsoldiers = numsoldiers - runC;
		message = message & "<font color=red>You do not have enough town centers for your catapults. #runC# catapults run away</font><br>";
	}
	
	// use wood and iron to upkeep catapults
	needWood = newP.catapults;
	if (newP.wood lt needWood and newP.catapults gt 0) {
		runC = round((needWood - newP.wood) * 0.25);
		if (runC gt newP.catapults)
			runC = newP.catapults;
		message = message & "<font color=red>You did not have enough wood to upkeep your catapults. #runC# of them were destroyed<br></font>";
		newP.catapults = newP.catapults - runC;
	}
	else {
		rWood = rWood - needWood;
	}
	
	needIron = round(newP.catapults/5);
	if (newP.iron lt needIron and newP.catapults gt 0) {
		runC = round((needIron - newP.iron) * 0.25);
		if (runC gt newP.catapults)
			runC = newP.catapults;		
		message = message & "<font color=red>You did not have enough iron to upkeep your catapults. #runC# of them were destroyed<br></font>";
		newP.catapults = newP.catapults - runC;
	}
	else rIron = rIron - needIron;
	
	if (needWood gt 0 and needIron gt 0)
		message = message & "#needWood# wood and #needIron# iron was used to upkeep catapults<br>";
	
	// supplies that can be hold
	canHold = newp.towncenter*townCenterB.supplies + newp.warehouse*warehouseB.supplies; // how much supplies can we hold 
	canHold = round(canHold + canHold * (newP.research8 / 100));

	newP.wood = rWood;
	newP.iron = rIron;
	newP.food = rFood;
	newP.gold = rGold;
	newP.tools = rTools;
	newP.swords = rSwords;
	newP.bows = rBows;
	newP.maces = rMaces;
	newP.horses = rHorses;
	newP.wine = rWine;

	// process auto trade
	maxTrades = newP.market * townCenterB.maxLocalTrades + 3;
	extra = 1;
	s = newP.score;
	while (s gt 100000) {
		extra = extra + localTradeMulti;
		s = s / 2;
	}

	if (newP.autoBuyWood gt 0) {
		woodBuyPrice = round(session.localWoodBuyPrice * extra);
		useGold = woodBuyPrice * newP.autoBuyWood;
		if (newP.gold gte useGold) {
			newP.wood = newP.wood + newP.autoBuyWood;
			newP.gold = newP.gold - useGold;
			message = message & "Bought #numberFormat(newP.autoBuyWood)# wood for #numberFormat(useGold)#<br>";
		}
	}
	if (newP.autoBuyFood gt 0) {
		FoodBuyPrice = round(session.localFoodBuyPrice * extra);
		useGold = FoodBuyPrice * newP.autoBuyFood;
		if (newP.gold gte useGold) {
			newP.Food = newP.Food + newP.autoBuyFood;
			newP.gold = newP.gold - useGold;
			message = message & "Bought #numberFormat(newP.autoBuyFood)# food for #numberFormat(useGold)#<br>";			
		}
	}
	if (newP.autoBuyIron gt 0) {
		IronBuyPrice = round(session.localIronBuyPrice * extra);
		useGold = IronBuyPrice * newP.autoBuyIron;
		if (newP.gold gte useGold) {
			newP.Iron = newP.Iron + newP.autoBuyIron;
			newP.gold = newP.gold - useGold;
			message = message & "Bought #numberFormat(newP.autoBuyIron)# iron for #numberFormat(useGold)#<br>";			
		}
	}
	if (newP.autoBuyTools gt 0) {
		ToolsBuyPrice = round(session.localToolsBuyPrice * extra);
		useGold = ToolsBuyPrice * newP.autoBuyTools;
		if (newP.gold gte useGold) {
			newP.Tools = newP.Tools + newP.autoBuyTools;
			newP.gold = newP.gold - useGold;
		}
		message = message & "Bought #numberFormat(newP.autoBuyTools)# tools for #numberFormat(useGold)#<br>";		
	}
	
	if (newP.autoSellWood gt 0) {
		if (newP.wood gte newP.autoSellWood) {
			woodSellPrice = round(session.localWoodSellPrice * (1.0/extra));
			getGold = woodSellPrice * newP.autoSellWood;
			newP.wood = newP.wood - newP.autoSellWood;
			newP.gold = newP.gold + getGold;
			message = message & "Sold #numberFormat(newP.autoSellWood)# wood for #numberFormat(getGold)#<br>";			
		}
	}		
	if (newP.autoSellFood gt 0) {
		if (newP.Food gte newP.autoSellFood) {
			FoodSellPrice = round(session.localFoodSellPrice * (1.0/extra));
			getGold = FoodSellPrice * newP.autoSellFood;
			newP.Food = newP.Food - newP.autoSellFood;
			newP.gold = newP.gold + getGold;
			message = message & "Sold #numberFormat(newP.autoSellFood)# food for #numberFormat(getGold)#<br>";						
		}
	}		
	if (newP.autoSellIron gt 0) {
		if (newP.Iron gte newP.autoSellIron) {
			IronSellPrice = round(session.localIronSellPrice * (1.0/extra));
			getGold = IronSellPrice * newP.autoSellIron;
			newP.Iron = newP.Iron - newP.autoSellIron;
			newP.gold = newP.gold + getGold;
			message = message & "Sold #numberFormat(newP.autoSellIron)# iron for #numberFormat(getGold)#<br>";						
		}
	}		
	if (newP.autoSellTools gt 0) {
		if (newP.Tools gte newP.autoSellTools) {
			ToolsSellPrice = round(session.localToolsSellPrice * (1.0/extra));
			getGold = ToolsSellPrice * newP.autoSellTools;
			newP.Tools = newP.Tools - newP.autoSellTools;
			newP.gold = newP.gold + getGold;
			message = message & "Sold #numberFormat(newP.autoSellTools)# tools for #numberFormat(getGold)#<br>";						
		}
	}		

	
	totalSupplies = newP.wood + newP.iron + newP.food + newP.tools + newP.swords + newP.bows + newP.horses + newP.maces + newP.wine;
	if (canHold lt totalSupplies) {
		tooMuch = totalSupplies - canHold;
		stealW = Round((newP.wood / totalSupplies) * tooMuch);
		stealF = Round((newP.food / totalSupplies) * tooMuch);
		stealI = Round((newP.iron / totalSupplies) * tooMuch);
		stealT = Round((newP.tools / totalSupplies) * tooMuch);
		stealS = Round((newP.swords / totalSupplies) * tooMuch);
		stealB = Round((newP.bows / totalSupplies) * tooMuch);
		stealH = Round((newP.horses / totalSupplies) * tooMuch);
		stealM = Round((newP.maces / totalSupplies) * tooMuch);
		stealWine = Round((newP.wine / totalSupplies) * tooMuch);
		comma = "";
		stolen = "";
		if (stealW gt 0) { stolen = stolen & "#comma# #numberFormat(stealW)# wood"; comma = ","; }
		if (stealF gt 0) { stolen = stolen & "#comma# #numberFormat(stealF)# food"; comma = ","; }
		if (stealI gt 0) { stolen = stolen & "#comma# #numberFormat(stealI)# iron"; comma = ","; }
		if (stealT gt 0) { stolen = stolen & "#comma# #numberFormat(stealT)# tools"; comma = ","; }
		if (stealS gt 0) { stolen = stolen & "#comma# #numberFormat(stealS)# swords"; comma = ","; }
		if (stealB gt 0) { stolen = stolen & "#comma# #numberFormat(stealB)# bows"; comma = ","; }
		if (stealH gt 0) { stolen = stolen & "#comma# #numberFormat(stealH)# horses"; comma = ","; }
		if (stealM gt 0) { stolen = stolen & "#comma# #numberFormat(stealM)# maces"; comma = ","; }
		if (stealWine gt 0) { stolen = stolen & "#comma# #numberFormat(stealWine)# wine"; comma = ","; }
		if (stolen is not "") {
			message = message & "<font color=red>Because your warehouses could not fit all your good some of them were stolen (#stolen#)</font><br>";
			processTurn = false;
		}
		
						
		newP.wood = newP.wood - stealW;
		newP.food = newP.food - stealF;
		newP.iron = newP.iron - stealI;	
		newP.tools = newP.tools - stealT;	
		newP.swords = newP.swords - stealS;	
		newP.bows = newP.bows - stealB;	
		newP.horses = newP.horses - stealH;	
		newP.maces = newP.maces - stealM;
		newP.wine = newP.wine - stealWine;
	}
</cfscript>

<!--- save player --->
<cfif newP.people lt 100><cfset newP.people = 100></cfif>

<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update player set
		<cfloop list="archers,swordsman,horseman,woodCutter,hunter,farmer,house,ironMine,goldmine,toolmaker,weaponsmith,swordWeaponSmith,bowWeaponSmith,maceWeaponsmith,fort,tower,towncenter,market,warehouse,stable,fland,mland,pland,food,iron,gold,wood,bows,swords,horses,people,tools,maces,catapults,trainedPeasants,macemen,thieves,mageTower,research1,research2,research3,research4,research5,research6,research7,research8,research9,research10,research11,research12,researchPoints,uunit,wine,winery,wall" index="col">
			<cfset temp = evaluate("newp.#col#")>
			<cfif temp lt 0><cfset temp = 0></cfif>
			#col# = #temp#,		
		</cfloop>
		turn = turn + 1,
		message = '#message#',
		tradesThisTurn = 0,
		turnsFree = turnsFree - 1,
		<cfif newp.numattacks gt 0>numattacks = #newp.numattacks# - 1
		<cfelse>numattacks = 0
		</cfif>
		where id = #playerID#
</cfquery>

<cf_calc_score datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" playerID="#playerID#">	

<!--- process aid --->
<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update transferQueue set turnsRemaining = turnsRemaining - 1 where fromPlayerID = #playerID# and transferType = 1
</cfquery>
<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from transferQueue where fromPlayerID = #playerID# and turnsRemaining = 0 and transferType = 1
</cfquery>
<cfloop query="tq">
	<!--- give those goods to the other player --->
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update player set
			wood = wood + #tq.wood#,
			iron = iron + #tq.iron#,
			food = food + #tq.food#,
			gold = gold + #tq.gold#,
			tools = tools + #tq.tools#,
			maces = maces + #tq.maces#,
			swords = swords + #tq.swords#,
			bows = bows + #tq.bows#,
			horses = horses + #tq.horses#,
			hasMainNews = 1
		where id = #tq.toPlayerID#
    </cfquery>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        insert into playerMessage (fromPlayerID, toPlayerID, fromPlayerName, toPlayerName, message, viewed, createdOn, messageType)
		values (#playerID#, #tq.toPlayerID#, '#newP.name#', '', 'On #theDate# you have received aid from #newP.name# (#playerID#)<br>#tq.wood# wood, #tq.food# food, #tq.iron# iron, #tq.gold# gold, #tq.tools# tools, #tq.maces# maces, #tq.swords# swords, #tq.bows# bows, #tq.horses# horses', 0, #CreateODBCDateTime(Now())#, 1)
    </cfquery>
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        delete from transferQueue where id = #tq.id#
    </cfquery>
</cfloop>	

<cfset end = getTickCount()>
<cfset time = end - start>

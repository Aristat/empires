<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->


<!--- file must be included in end_turn_new.cfm --->
<!--- and inside the attack query loop --->
<cfquery name="defense" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #attack.attackPlayerID#
</cfquery>

<cfif defense.recordcount is 0><!--- player does not exist anymore --->
	<cfset message = message & "The empire #attack.attackPlayerID# does not exist anymore<br>">
<cfelse>
	<cfset dColumns = "mLand,fLand,pLand,woodCutter,hunter,farmer,house,ironMine,goldMine,toolMaker,weaponSmith,tower,fort,townCenter,market,warehouse,stable,wood,iron,gold,food,people,research2,research4,mageTower,winery,wall">
	<cfset dPlayer = structNew()>
	<cfloop list="#dColumns#" index="i">
		<cfset t = setVariable("dPlayer.#i#", evaluate("defense.#i#"))>
	</cfloop>
	<cfset attackMessage = "">

	<!--- see how many times attacked already that person --->
	<cfset sDate = dateAdd("h", -24, now())>
	<cfquery name="nqMyWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 1 and attackerWins = 1
    </cfquery>
	<cfquery name="nqMyLost" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 1 and attackerWins = 0
    </cfquery>
	<cfquery name="nqOtherWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID <> #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 1 and attackerWins = 1
    </cfquery>
	
	<cfset hasAttacks = round(val(nqMyWon.total) + val(nqMyLost.total)/3 + val(nqOtherWon.total)/5)>
	
	<cfscript>
	debugInfo = "";
	
	attackUunit = attack.uunit;
	attackPeasants = attack.trainedPeasants;
	attackArchers = attack.archers;
	attackSwordsman = attack.swordsman;
	attackHorseman = attack.horseman;
	attackMacemen = attack.macemen;
	attackWine = attack.costwine;
	
	defenseUunit = defense.uunit;
	defensePeasants = defense.trainedPeasants;
	defenseArchers = defense.archers;
	defenseHorseman = defense.horseman;
	defenseSwordsman = defense.swordsman;
	defenseMacemen = defense.macemen;
	defenseTowers = defense.tower;
	
	// see if not attacking someone weak
	runPercent = 0;
	victoryPoints = 1;

	attackmessage = attackmessage & "<font color=yellow face=verdana size=2>--------- Battle #player.name# (#player.id#) vs. #defense.name# (#defense.id#) #theDate# ---------</font><br>";	
	
	if (not deathMatchMode) {
		if (player.score gt defense.score * 10) { runPercent = 0.80; victoryPoints = 0.01; }
		else if (player.score gt defense.score * 8) { runPercent = 0.70; victoryPoints = 0.05; }
		else if (player.score gt defense.score * 6)  { runPercent = 0.60; victoryPoints = 0.10; } // attacking really weak opponent
		else if (player.score gt defense.score * 5) { runPercent = 0.50; victoryPoints = 0.20; }	
		else if (player.score gt defense.score * 4) {runPercent = 0.40; victoryPoints = 0.30; }
		else if (player.score gt defense.score * 3) { runPercent = 0.30; victoryPoints = 0.40; }
		else if (player.score gt defense.score * 2) { runPercent = 0.20; victoryPoints = 0.50; } // attacking less than half the size
			
		if (runPercent gt 0)
		{
			runUunit = round(attackuunit*runpercent);
			runSwordsman = round(attackswordsman*runpercent);
			runArchers = round(attackarchers*runpercent);
			runHorseman = round(attackhorseman*runpercent);
			runMacemen = round(attackmacemen*runpercent);
			runPeasants = round(attackPeasants*runpercent);
			
			attackmessage = attackmessage & "<font color=red>#player.name# attacked much weaker enemy. <br>#runuunit# #uunitA.name#s, #runPeasants# peasants, #runMacemen# macemen, #runSwordsman# swordsman, #runArchers# archers and #runHorseman# horseman<br>revolt and go away.<br></font>";
			attackuunit = attackuunit - runuunit;
			attackswordsman = attackswordsman - runSwordsman;
			attackarchers = attackarchers - runArchers;
			attackhorseman = attackhorseman - runHorseman;
			attackPeasants = attackPeasants - runPeasants;
			attackMacemen = attackMacemen - runMacemen;
			
			debugInfo = debugInfo & "run percent: #runPercent#<br>";
		}
	}

	debugInfo = debugInfo & "Attack army: #attackSwordsman# swordsman, #attackArchers# archers, #attackHorseman# horseman, #attackPeasants# peasants, #attackMacemen# macemen, #attackUunit# uunit, #attackWine# wine<br>";

	totalAttackArmy = attackSwordsman + attackArchers + attackHorseman + attackPeasants + attackMacemen + attackUunit;
	attackPoints =  attackSwordsman * swordsmanA.attackPt + 
					attackArchers * archerA.attackPt + 
					attackHorseman * horsemanA.attackPt +
					attackPeasants * trainedPeasantA.attackPt +
					attackMacemen * macemanA.attackPt +
					attackuunit * uunitA.attackPt;
					
	attackPoints = round(attackPoints + attackPoints * (newP.research1 / 100));
	debugInfo = debugInfo & "attack points: #attackPoints# with #newP.research1# attack research<br>";

	if (attackWine gt 0 and totalAttackArmy gt 0) {
		percentWine = attackWine / totalAttackArmy;
		attackpoints = round(attackPoints + attackPoints * percentWine);
		debugInfo = debugInfo & "attack points with wine: #attackPoints# (wine percent: #percentWine#)<br>";
	}	
	
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
		
	debugInfo = debugInfo & "has attacks: #hasAttacks#, attack points reduced to: #attackPoints#<br>";
		
	swordsmanDPt = 6;
	archerDPt = 12;
	horsemanDPt = 10;
	trainedPeasantDPt = 2;
	macemanDPt = 3;
	uunitDPt = 0;
	towerDPt = 50;
	
	if (defense.civ is 1) { // vikings
		uunitDPt = 5;
	}
	else if (defense.civ is 2) { // franks
		uunitDPt = 30;
		towerDPt = 65;
		archerDPt = 15;
	}
	else if (defense.civ is 3) { // japanese
		uunitDpt = 10;
	}
	else if (defense.civ is 4) { // byzantines
		uunitDpt = 15;
		archerDPt = 15;
	}
	else if (defense.civ is 5) { // mongols
		uunitDPt = 5;
	}
	else if (defense.civ is 6) { // incas
		uunitDPt = 1;
		horsemanDpt = 1;
	}
	else if (defense.civ is 7) { // chinese
		uunitDPt = 15;
		trainedPeasantDPt = 3;
	}
	else if (defense.civ is 8) { // barbarians
		uunitDPt = 1;
		macemanDPt = 5;
	}
	
				
	defensePoints =  defenseSwordsman * swordsmanDpt + 
					defenseArchers * archerDPt + 
					defenseHorseman * horsemanDPt +
					defensePeasants * trainedPeasantDPt +
					defenseMacemen * macemanDPt +
					defenseTowers * towerDPt +
					defenseUunit * uunitDPt;
					
	debugInfo = debugInfo & "Defense army: #defenseSwordsman# swordsman, #defenseArchers# archers, #defenseHorseman# horseman, #defensePeasants# peasants, #defenseMacemen# macemen, #defenseUunit# uunit, #defenseTowers# towers<br>";					
					
	defensePoints = round(defensePoints + defensePoints * (dPlayer.research2 / 100));					

	debugInfo = debugInfo & "defense points: #defensePoints# with #dPlayer.research2# defense research<br>";	
	
	// add wall defense
	totalLand = dPlayer.mland + dPlayer.fland + dPlayer.pland;
	totalWall = round(totalLand * 0.05);
	if (totalWall gt 0) {
		protection = dplayer.wall / totalWall;
		defensePoints = round(defensePoints + defensePoints * protection);
		attackmessage = attackmessage & "Great Wall provides #numberFormat(protection*100)#% extra defense!!!<br>";
	}
	debugInfo = debugInfo & "defense points: #defensePoints# with #dPlayer.wall# wall for #totalLand# land.<br>";		
	
	// now randomize the points with +/- 10%
	aStart = attackPoints - round(attackPoints*0.1);
	aEnd = attackPoints + round(attackPoints*0.1);
	dStart = defensePoints - round(defensePoints*0.1);
	dEnd = defensePoints + round(defensePoints*0.1);
	if (aStart gt 2000000000 or aEnd gt 2000000000) { // might cause overflow
		aStart = round(aStart / 100);
		aEnd = round(aEnd / 100);
		attackPoints = round(randRange(aStart, aEnd) * 100);
	}
	else
		attackPoints = randRange(aStart, aEnd);
		
	if (dStart gt 2000000000 or dEnd gt 2000000000) {
		dStart = round(dStart / 100);
		dEnd = round(dEnd / 100);	
		defensePoints = round(randRange(dStart, dEnd) * 100);
	}
	else
		defensePoints = randRange(dStart, dEnd);
	
	debugInfo = debugInfo & "Randomized attack points: #attackPoints#<br>";
	debugInfo = debugInfo & "Randomize defense points: #defensePoints#<br>";
	
	// calculate casaulties
	dTotalArmy = defenseSwordsman + defenseArchers + defenseHorseman + defensePeasants + defenseMacemen + defenseUunit;
	if (defense.score lt newP.score) { // defense is weaker
		dKilled = round((attackPoints / 300) * victoryPoints);
		tKilled = round((attackPoints / 3000) * victoryPoints);
	}
	else {	// defense is stronger
		dKilled = round((attackPoints / 150) * victoryPoints);
		tKilled = round((attackPoints / 1500) * victoryPoints);
	}
		
	if (dplayer.research4 lte 50) {
		heal = (dPlayer.research4 / 100) * dKilled;
		dKilled = dKilled - round(heal);
	}
	
	if (dKilled gte dTotalArmy or dTotalArmy is 0) { // killed all
		dKilledPercent = 1.00;
	}
	else {
		dKilledPercent = dKilled / dTotalArmy;
	}
	dDieArchers = round(defenseArchers * dKilledPercent);
	dDieSwordsman = round(defenseSwordsman * dKilledPercent);
	dDieHorseman = round(defenseHorseman * dKilledPercent);
	dDiePeasants = round(defensePeasants * dKilledPercent);
	dDieMacemen = round(defenseMacemen * dKilledPercent);
	dDieUunit = round(defenseUunit * dKilledPercent);
	dDieTowers = tKilled;
	
	if (defenseArchers lt dDieArchers) dDieArchers = defenseArchers;
	if (defenseSwordsman lt dDieSwordsman) dDieSwordsman = defenseSwordsman;
	if (defenseHorseman lt dDieHorseman) dDieHorseman = defenseHorseman;
	if (defensePeasants lt dDiePeasants) dDiePeasants = defensePeasants;
	if (defenseMacemen lt dDieMacemen) dDieMacemen = defenseMacemen;
	if (defenseUunit lt dDieUunit) dDieUunit = defenseUunit;
	if (defenseTowers lt dDieTowers) dDieTowers = defenseTowers;
	
	defenseArchers = defenseArchers - dDieArchers; 
	defenseSwordsman = defenseSwordsman - dDieSwordsman;
	defenseHorseman = defenseHorseman - dDieHorseman;
	defensePeasants = defensePeasants - dDiePeasants;
	defenseMacemen = defenseMacemen - dDieMacemen;
	defenseUunit = defenseUunit - dDieUunit;
	defenseTowers = defenseTowers - dDieTowers;
	dPlayer.tower = defenseTowers;
	
	aTotalArmy = attackSwordsman + attackArchers + attackHorseman + attackPeasants + attackMacemen + attackuunit;
	if (defense.score gt newP.score) // attacking someone bigger, lose less army
		aKilled = round(defensePoints / 300);
	else 
		aKilled = round(defensePoints / 150);		
		
	if (newP.research4 lte 50) {
		heal = (newP.research4 / 100) * aKilled;
		aKilled = aKilled - round(heal);
	}
	
	if (aKilled gt aTotalArmy or aTotalArmy is 0) { // killed all
		aKilledPercent = 1.00;
	}
	else {
		aKilledPercent = aKilled / aTotalArmy;
	}
	aDieArchers = round(attackArchers * aKilledPercent);
	aDieSwordsman = round(attackSwordsman * aKilledPercent);
	aDieHorseman = round(attackHorseman * aKilledPercent);
	aDiePeasants = round(attackPeasants * aKilledPercent);
	aDieMacemen = round(attackMacemen * aKilledPercent);
	aDieUunit = round(attackUunit * aKilledPercent);

	if (attackArchers lt aDieArchers) aDieArchers = attackArchers;
	if (attackSwordsman lt aDieSwordsman) aDieSwordsman = attackSwordsman;
	if (attackHorseman lt aDieHorseman) aDieHorseman = attackHorseman;
	if (attackPeasants lt aDiePeasants) aDiePeasants = attackPeasants;
	if (attackMacemen lt aDieMacemen) aDieMacemen = attackMacemen;
	if (attackUunit lt aDieUunit) aDieUunit = attackUunit;
	
	attackArchers = attackArchers - aDieArchers; 
	attackSwordsman = attackSwordsman - aDieSwordsman;
	attackHorseman = attackHorseman - aDieHorseman;
	attackPeasants = attackPeasants - aDiePeasants;
	attackMacemen = attackMacemen - aDieMacemen;
	attackUunit = attackUunit - aDieUunit;

	// display casualties
	attackMessage = attackMessage & "<b>#player.name# killed:</b><br>";
	killedTotal = dDieUunit + dDieHorseman + dDieSwordsman + dDieArchers + dDieMacemen + dDiePeasants;
	if (dDieUunit gt 0)
		attackMessage = attackMessage & "#uunitNames[defense.civ]#: #NumberFormat(dDieUunit)#<br>";
	if (dDieHorseman gt 0)
		attackmessage = attackMessage & "Horseman: #numberFormat(dDieHorseman)#<br>";
	if (dDieSwordsman gt 0)
		attackMessage = attackmessage & "Swordsman: #numberFormat(dDieSwordsman)#<br>";
	if (dDieArchers gt 0)
		attackMessage = attackMessage & "Archers: #numberFormat(dDieArchers)#<br>";
	if (dDieMacemen gt 0)
		attackMessage = attackMessage & "Macemen: #numberFormat(dDieMacemen)#<br>";
	if (dDiePeasants gt 0)
		attackMessage = attackMessage & "Trained Peasants: #numberFormat(dDiePeasants)#<br>";
	if (killedTotal is 0)
		attackMessage = attackMessage & "No Kills<br>";
	if (dDieTowers gt 0)
		attackMessage = attackMessage & "Towers Razed: #numberFormat(dDieTowers)#<br>";
	
	attackMessage = attackMessage & "<br><b>#defense.name# killed:</b><br>";
	killedTotal = aDieUunit + aDieHorseman + aDieSwordsman + aDieArchers + aDieMacemen + aDiePeasants;
	if (aDieUunit gt 0)
		attackMessage = attackMessage & "#uunitA.name#: #NumberFormat(aDieUunit)#<br>";
	if (aDieHorseman gt 0)
		attackmessage = attackMessage & "Horseman: #numberFormat(aDieHorseman)#<br>";
	if (aDieSwordsman gt 0)
		attackMessage = attackmessage & "Swordsman: #numberFormat(aDieSwordsman)#<br>";
	if (aDieArchers gt 0)
		attackMessage = attackMessage & "Archers: #numberFormat(aDieArchers)#<br>";
	if (aDieMacemen gt 0)
		attackMessage = attackMessage & "Macemen: #numberFormat(aDieMacemen)#<br>";
	if (aDiePeasants gt 0)
		attackMessage = attackMessage & "Trained Peasants: #numberFormat(aDiePeasants)#<br>";
	if (killedTotal is 0)
		attackMessage = attackMessage & "No Kills<br>";
	
	/* attackmessage = attackmessage & "#player.name# killed #dDieUunit# #uunitNames[defense.civ]#s, 
		#dDiePeasants# trained peasants, 
		#dDieMacemen# macemen, 
		#dDieSwordsman# swordsman, 
		#dDieArchers# archers and 
		#dDieHorseman# horseman.<br>";		
		
	if (dDieTowers gt 0)
		attackmessage = attackmessage & "#player.name# also razed #dDieTowers# towers.<br>";
	attackmessage = attackmessage & "#defense.name# killed #aDieUunit# #uunitA.name#s, #aDiePeasants# trained peasants, #aDieMacemen# macemen, #aDieSwordsman# swordsman, #aDieArchers# archers and #aDieHorseman# horseman.<br>";		
	*/
	
	if (attackPoints gt defensePoints) attackerWins = 1;
	else attackerWins = 0;
	
	dPlayer.towers = defenseTowers;
	
	debugInfo = debugInfo & "Attacker wins: #attackerWins# with #attackPoints# attack points and #defensePoints# defense points<br>";
	
	newsMessage = "";
	if (attackerWins is 1) {
		attackmessage = attackmessage & "<br>#player.name# won the war!<br>";
		// look at attack type
		if (attack.attackType is 0) { // conquer
			attackPoints = (attackSwordsman*swordsmanA.takeLand + attackArchers*archerA.takeLand + attackHorseman*horsemanA.takeLand + attackMacemen*macemanA.takeLand + attackPeasants*trainedPeasantA.takeLand + attackUunit*uunitA.takeLand) * victoryPoints; // take that much land (possibly)
			if (attackPoints gt 0) {
				takeLand = RandRange(attackPoints/2, attackPoints)+1;
				
				dTotalLand = dPlayer.mland + dPlayer.pland + dPlayer.fland;
				if (dPlayer.mland lte 0) mPercent = 0;
				else mPercent = dPlayer.mLand / dTotalLand;
				
				if (dPlayer.fland lte 0) fPercent = 0;
				else fPercent = dPlayer.fLand / dTotalLand;
				
				if (dPlayer.pland lte 0) pPercent = 0;
				else pPercent = dPlayer.pland / dTotalLand;
				
			
				takeM = round(takeLand * mPercent);
				takeF = round(takeLand * fPercent);
				takeP = round(takeLand * pPercent);
				
				if (dPlayer.mLand lt takeM) takeM = dPlayer.mLand;
				if (dPlayer.fLand lt takeF) takeF = dPlayer.fLand;
				if (dPlayer.pLand lt takeP) takeP = dPlayer.pLand;
					
				dPlayer.mLand = dPlayer.mLand - takeM;
				dPlayer.fLand = dPlayer.fLand - takeF;
				dPlayer.pLand = dPlayer.pLand - takeP;
					
				newP.mland = newP.mLand + takeM;
				newP.fLand = newP.fLand + takeF;
				newP.pLand = newP.pLand + takeP;
					
				newsMessage = "#val(takeM+takeF+takeP)# land";
				attackmessage = attackmessage & "#player.name# conquered #numberformat(takeM)# mountains, #numberformat(takeF)# forest and #numberFormat(takeP)# plain land<br>";
					
				// need to update the buildings for defense civ
				ironMineB_sq = 2;
				goldMineB_sq = 6;
				woodCutterB_sq = 4;
				hunterB_sq = 2;
				farmerB_sq = 4;
				houseB_sq = 2;
				toolMakerB_sq = 2;
				weaponSmithB_sq = 4;
				fortB_sq = 12;
				towerB_sq = 4;
				townCenterB_sq = 25;
				marketB_sq = 4;
				warehouseB_Sq = 2; 
				stableB_sq = 4;
				mageTowerB_sq = 10; 
				wineryB_sq = 6;
				
				if (defense.civ is 1) { // viking
					stableB_sq = 6;
					woodCutterB_sq = 3;
				}
				else if (defense.civ is 2) { // franks
					townCenterB_sq = 35;
					mageTowerB_sq = 12;
					farmerB_sq = 2;
					towerB_sq = 3;
				}
				else if (defense.civ is 3) { // japanese
					woodCutterB_sq = 5;
					stableB_sq = 8;
					townCenterB_sq = 20;
				
				}
				else if (defense.civ is 4) { // byzantines
					ironMineB_sq = 3;
					goldMineB_sq = 2;
					townCenterB_sq = 22;
					mageTowerB_sq = 8;
				
				}
				else if (defense.civ is 5) { // mongols
					fortB_sq = 8;
				}
				else if (defense.civ is 6) { // icans
					ironMineB_sq = 3;
					townCenterB_sq = 30;
				}					
				else if (defense.civ is 7) { // chinese
					towerB_sq = 3;
					wineryB_sq = 8;
					houseB_sq = 4;
					farmerB_sq = 5;
				}					
				else if (defense.civ is 8) { // barbarians
					doNothing = true;
				}					
				
					
				// see if the other play has enough land for buildings, if not destroy some buildings
				// forumla to calculate land taken
				// calculate percentage of land that building is occupying: percentage = (no. buildings * number of squares) / total land taken
				// calculate percentage of land that is remaining: useLand = floor(percentage * land remaining)
				// calculate number of buildings that can be placed on that land: no. buildings = floor(useLand / number of squares)
					
				needMLand = dPlayer.ironMine*ironMineB_sq + dPlayer.goldMine*goldMineB_sq;
				if (dPlayer.mLand is 0) {
					dPlayer.ironMine = 0;
					dPlayer.goldMine = 0;
				}
				else if (needMLand gt dPlayer.mLand) {
					dPlayer.ironMine = fix(fix(((dPlayer.ironMine * ironMineB_sq) / needMLand) * dPlayer.mLand) / ironMineB_sq);
					dPlayer.goldMine = fix(fix(((dPlayer.goldMine * goldMineB_sq) / needMLand) * dPlayer.mLand) / goldMineB_sq);
					//writeOutput("destroyed #val(player.ironMine-dPlayer.ironMine)# iron mines and #val(player.goldMine-dPlayer.goldMine)# gold mines<br>");
				}

				needFLand = dPlayer.woodCutter * woodCutterB_sq + dPlayer.hunter * hunterB_sq;
				if (dPlayer.fLand is 0) {
					dPlayer.woodcutter = 0;
					dPlayer.hunter = 0;
				}
				else if (needFLand gt dPlayer.fLand) {
					dPlayer.woodcutter = fix(fix(((dPlayer.woodCutter * woodCutterB_sq) / needFLand) * dPlayer.fLand) / woodCutterB_sq);
					dPlayer.hunter = fix(fix(((dPlayer.hunter * hunterB_sq) / needFLand) * dPlayer.fLand) / hunterB_sq);
				}
				
				hadWeaponsmith = dPlayer.weaponsmith;
				
				needPLand = dPlayer.farmer * farmerB_sq + dPlayer.house * houseB_sq + dPlayer.toolmaker * toolMakerB_sq + 
					dPlayer.weaponSmith * weaponSmithB_sq + dPlayer.fort * fortB_sq + dPlayer.tower * towerB_sq + 
					dPlayer.townCenter * townCenterB_sq + dPlayer.market * marketB_sq + dPlayer.warehouse * wareHouseB_sq + 
					dPlayer.stable * stableB_sq + dPlayer.mageTower * mageTowerB_sq + dPlayer.winery * wineryB_sq;
				if (dPlayer.pLand is 0) {
					dPlayer.farmer = 0;
					dPlayer.house = 0;
					dPlayer.toolmaker = 0;
					dPlayer.weaponSmith = 0;
					dPlayer.fort = 0;
					dPlayer.tower = 0;
					dPlayer.townCenter = 0;
					dPlayer.market = 0;
					dPlayer.warehouse = 0;
					dPlayer.stable = 0;
					dPlayer.mageTower = 0;
					dPlayer.winery = 0;
				}
				else if (needPLand gt dPlayer.pLand) {
					// forumla to calculate land taken
					// calculate percentage of land that building is occupying: percentage = (no. buildings * number of squares) / total land taken
					// calculate percentage of land that is remaining: useLand = floor(percentage * land remaining)
					// calculate number of buildings that can be placed on that land: no. buildings = floor(useLand / number of squares)

					//writeOutput("Before:<br>farm: #dPlayer.farmer#<br>house: #dPlayer.house#<br>tool: #dPlayer.toolMaker#<br>weapon: #dPlayer.weaponSmith#<br>");
					//writeOutput("fort: #dPlayer.fort#<br>tower: #dPlayer.tower#<br>tc: #dPlayer.townCenter#<br>market: #dPlayer.market#<br>");
					//writeOutput("warehouse: #dplayer.warehouse#<br>stable: #dPlayer.stable#<br>mage: #dPlayer.mageTower#<br>");
					
					dPlayer.farmer = fix(fix(((dPlayer.farmer * farmerB_sq) / needPLand) * dPlayer.pLand) / farmerB_sq);
					dPlayer.house = fix(fix(((dPlayer.house * houseB_sq) / needPLand) * dPlayer.pLand) / houseB_sq);
					dPlayer.toolmaker = fix(fix(((dPlayer.toolmaker * toolmakerB_sq) / needPLand) * dPlayer.pLand) / toolmakerB_sq);
					dPlayer.weaponsmith = fix(fix(((dPlayer.weaponsmith * weaponsmithB_sq) / needPLand) * dPlayer.pLand) / weaponsmithB_sq);
					dPlayer.fort = fix(fix(((dPlayer.fort * fortB_sq) / needPLand) * dPlayer.pLand) / fortB_sq);
					dPlayer.tower = fix(fix(((dPlayer.tower * towerB_sq) / needPLand) * dPlayer.pLand) / towerB_sq);
					dPlayer.townCenter = fix(fix(((dPlayer.townCenter * townCenterB_sq) / needPLand) * dPlayer.pLand) / townCenterB_sq);
					dPlayer.market = fix(fix(((dPlayer.market * marketB_sq) / needPLand) * dPlayer.pLand) / marketB_sq);
					dPlayer.warehouse = fix(fix(((dPlayer.warehouse * warehouseB_sq) / needPLand) * dPlayer.pLand) / warehouseB_sq);
					dPlayer.stable = fix(fix(((dPlayer.stable * stableB_sq) / needPLand) * dPlayer.pLand) / stableB_sq);
					dPlayer.mageTower = fix(fix(((dPlayer.mageTower * mageTowerB_sq) / needPLand) * dPlayer.pLand) / mageTowerB_sq);
					dPlayer.winery = fix(fix(((dPlayer.winery * wineryB_sq) / needPLand) * dPlayer.pLand) / wineryB_sq);
					
					//writeOutput("After:<br>farm: #dPlayer.farmer#<br>house: #dPlayer.house#<br>tool: #dPlayer.toolMaker#<br>weapon: #dPlayer.weaponSmith#<br>");
					//writeOutput("fort: #dPlayer.fort#<br>tower: #dPlayer.tower#<br>tc: #dPlayer.townCenter#<br>market: #dPlayer.market#<br>");
					//writeOutput("warehouse: #dplayer.warehouse#<br>stable: #dPlayer.stable#<br>mage: #dPlayer.mageTower#<br>");
					
				}
				
				totalLand = dPlayer.mland + dPlayer.fland + dPlayer.pland;
				totalWall = round(totalLand * 0.05);
				if (dPlayer.wall gt totalWall)
					dPlayer.wall = totalWall;
			}
			else {
				newsMessage = "0 Land";
				attackmessage = attackmessage & "But failed to take any land<br>";
			}
		}
		else if (attack.attackType is 1) { // raid
			attackPoints = round((attackSwordsman*0.05 + attackArchers*0.04 + attackHorseman*0.1 + attackMacemen * 0.03 + attackPeasants * 0.01) * victoryPoints * 0.1); // that many buildings are destroyed
			dTotalBuildings = dPlayer.woodCutter + dPlayer.hunter + dPlayer.farmer + dPlayer.house + dPlayer.ironMine +
				dPlayer.goldMine + dPlayer.toolMaker + dPlayer.weaponSmith + dPlayer.tower + dPlayer.winery +
				dPlayer.towncenter + dPlayer.fort + dPlayer.stable + dPlayer.warehouse + dPlayer.market + dPlayer.mageTower;
			if (attackPoints gt 0 and dTotalBuildings gt 0) {
				dWoodCutter = round((dPlayer.woodCutter / dTotalBuildings) * attackPoints);
				dHunter = round((dPlayer.hunter / dTotalBuildings) * attackPoints);
				dFarmer = round((dPlayer.farmer / dTotalBuildings) * attackPoints);
				dHouse = round((dPlayer.house / dTotalBuildings) * attackPoints);
				dIronMine = round((dPlayer.ironMine / dTotalBuildings) * attackPoints);
				dGoldMine = round((dPlayer.goldMine / dTotalBuildings) * attackPoints);
				dToolMaker = round((dPlayer.toolmaker / dTotalBuildings) * attackPoints);
				dWeaponSmith = round((dPlayer.weaponSmith / dTotalBuildings) * attackPoints);
				dTower = round((dPlayer.tower / dTotalBuildings) * attackPoints);
				dTownCenter = round((dPlayer.townCenter / dTotalBuildings) * attackPoints);
				dFort = round((dPlayer.fort / dTotalBuildings) * attackPoints);
				dStable = round((dPlayer.stable / dTotalBuildings) * attackPoints);
				dWarehouse = round((dPlayer.warehouse / dTotalBuildings) * attackPoints);
				dMarket = round((dPlayer.market / dTotalBuildings) * attackPoints);
				dMageTower = round((dPlayer.mageTower / dTotalBuildings) * attackPoints);
				dWinery = 	round((dPlayer.winery / dTotalBuildings) * attackPoints);
					
				if (dPlayer.woodCutter lt dWoodCutter) dWoodCutter = dPlayer.woodCutter;
				if (dPlayer.hunter lt dhunter) dhunter = dPlayer.hunter;
				if (dPlayer.farmer lt dfarmer) dfarmer = dPlayer.farmer;
				if (dPlayer.house lt dhouse) dhouse = dPlayer.house;
				if (dPlayer.ironMine lt dironMine) dironMine = dPlayer.ironMine;
				if (dPlayer.goldMine lt dgoldMine) dgoldMine = dPlayer.goldMine;
				if (dPlayer.toolMaker lt dtoolMaker) dtoolMaker = dPlayer.toolMaker;
				if (dPlayer.weaponSmith lt dweaponSmith) dweaponSmith = dPlayer.weaponSmith;
				if (dPlayer.tower lt dtower) dtower = dPlayer.tower;
				if (dPlayer.townCenter lt dtownCenter) dtownCenter = dPlayer.townCenter;
				if (dPlayer.fort lt dfort) dfort = dPlayer.fort;
				if (dPlayer.stable lt dstable) dstable = dPlayer.stable;
				if (dPlayer.warehouse lt dwarehouse) dwarehouse = dPlayer.warehouse;
				if (dPlayer.market lt dmarket) dmarket = dPlayer.market;
				if (dPlayer.mageTower lt dmagetower) dmagetower = dPlayer.mageTower;
				if (dPlayer.winery lt dwinery) dwinery = dPlayer.winery;
				
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

				attackmessage = attackmessage & "#player.name# destroyed #dWoodCutter# woodcutters, #dHunter# hunters, #dfarmer# farmers, #dhouse# houses, #dironmine# iron mines, #dGoldMine# gold mines, #dToolMaker# tool makers, #dweaponsmith# weaponsmiths, #dtower# towers, #dtowncenter# towncenters, #dfort# forts, #dstable# stables, #dmarket# markets, #dMageTower# mage towers, #dWinery# winery and #dwarehouse# warehouses<br>";
			}
			else {
				newsMessage = "0 Buildings";
				attackmessage = attackmessage & "But failed to destroy any building.<br>";
			}				
		}
		else if (attack.attackType is 2) { // rob
			attackPoints = fix((attackSwordsman*1.0 + attackArchers*0.9 + attackHorseman*1.5 + attackMacemen*0.5 + attackPeasants*0.1) * victoryPoints * 0.5); // take that many goods (possibly)
			dTotalGoods = dPlayer.wood + dPlayer.food + dPlayer.iron + fix(dPlayer.gold/100);				
			// goods that can be taken, food, iron, wood, gold
			if (attackPoints gt 0 and dTotalGoods gt 0)
			{
				pWood = dPlayer.wood / dTotalGoods;
				pIron = dPlayer.iron / dTotalGoods;
				pFood = dPlayer.food / dTotalGoods;
				pGold = (dPlayer.gold/100) / dTotalGoods;
					
				takeWood = round(attackPoints * pWood);
				takeIron = round(attackPoints * pIron);
				takeFood = round(attackPoints * pFood);
				takeGold = round(attackPoints * pGold) * 25;
					
				
				if (dPlayer.wood lt takeWood) takeWood = dPlayer.wood;
				if (dPlayer.iron lt takeIron) takeIron = dPlayer.iron;
				if (dPlayer.food lt takeFood) takeFood = dPlayer.food;
				if (dPlayer.gold lt takeGold) takeGold = dPlayer.gold;
					
				dPlayer.wood = dPlayer.wood - takeWood;
				dPlayer.iron = dPlayer.iron - takeIron;
				dPlayer.food = dPlayer.food - takeFood;
				dPlayer.gold = dPlayer.gold - takeGold;
					
				newP.wood = newP.wood + takeWood;
				newP.food = newP.food + takeFood;
				newP.iron = newP.iron + takeIron;
				newP.gold = newP.gold + takeGold;

				newsMessage = "#val(takeWood+takeFood+takeIron)# goods <br>and #takeGold# gold";
				attackmessage = attackmessage & "#player.name# robbed #takeWood# wood, #takeIron# iron, #takeFood# food and #takeGold# gold<br>";					
			}
			else {
				newsMessage = "0 Goods";
				attackmessage = attackmessage & "But failed to take any goods<br>";
			}				
		}
		else if (attack.attackType is 3) { // slaughter
			attackPoints = round((attackSwordsman*1.0 + attackArchers*0.9 + attackHorseman*1.5 + attackMacemen*0.5 + attackPeasants*0.1) * victoryPoints * 0.5); // kill that many possibly
			
			// goods that can be taken, food, iron, wood, gold
			if (attackPoints gt 0 and dPlayer.people gt 0)
			{
				killPeople = attackPoints;
				if (dPlayer.people lt killPeople) killPeople = dPlayer.people;
				dPlayer.people = dPlayer.people - killPeople;
					
				newsMessage = "#killPeople# people";
				attackmessage = attackmessage & "#player.name# slaughtered #killPeople# people<br>";					
			}
			else {
				newsMessage = "No kills";
				attackmessage = attackmessage & "But failed to kill any people<br>";
			}				
		}
		
	}
	else {
		attackmessage = attackmessage & "<br>#defense.name# won the war!<br>";
	}
	</cfscript>

	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update attackQueue set 
		swordsman = #attackSwordsman#,
		archers = #attackArchers#,
		horseman = #attackHorseman#,
		macemen = #attackMacemen#,
		trainedPeasants = #attackPeasants#,
		uunit = #attackuunit#
		where id = #attack.id# 
	</cfquery>
	
	<cfset remLand = dPlayer.mland + dPlayer.fland + dPlayer.pLand>
	<cfif remLand lte 0>
		<cfset attackMessage = attackMessage & "<br><b>#newP.name# killed #defense.name#</b>">
	</cfif>
	<cfset attackmessage = attackmessage & "<br>--------------------------------------------------------</font><br>">
	
	<cfif dPlayer.people lt 100><cfset dPlayer.people = 100></cfif>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update player set 
			<cfif remLand lte 0>
			killedBy = #playerID#,
			killedByName = '#newP.name#',
			</cfif>
			<cfloop list="#dColumns#" index="i">
				<cfset temp = evaluate("dPlayer.#i#")>
				<cfif temp lt 0><cfset temp = 0></cfif>
				#i# = #temp#,
			</cfloop>
			lastAttack = #now()#,
			swordsman = #defenseSwordsman#,
			archers = #defenseArchers#,
			horseman = #defenseHorseman#,
			macemen = #defenseMacemen#,
			trainedPeasants = #defensePeasants#,
			uunit = #defenseUunit#,
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
		insert into attackNews (attackID, defenseID, 
			attackSwordsman, attackHorseman, attackArchers, attackMacemen, attackPeasants,
			defenseSwordsman, defenseHorseman, defenseArchers, defenseMacemen, defensePeasants,
			createdOn, attackerWins, message, attackAlliance, defenseAlliance, battleDetails,
			attackAllianceID, defenseAllianceID, attackType, debugInfo)
			values (#playerID#, #attack.attackPlayerID#, 
			#aDieSwordsman#, #aDieHorseman#, #aDieArchers#, #aDieMacemen#, #aDiePeasants#,
			#dDieSwordsman#, #dDieHorseman#, #dDieArchers#, #dDieMacemen#, #dDiePeasants#,
			#now()#, #attackerWins#, '#newsMessage#',
			'#attackAlliance#', '#defenseAlliance#', '#attackmessage#',
			#player.allianceID#, #defense.allianceID#, 1, '#debugInfo#')
	</cfquery>
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		insert into playerMessage (fromPlayerID, toPlayerID, fromPlayerName, toPlayerName, message, viewed, createdOn, messageType)
		values (#playerID#, #attack.attackPlayerID#, '#player.name#', '#defense.name#', '#attackmessage#', 0, #CreateODBCDateTime(Now())#, 1)
	</cfquery>

	<cfset message = message & attackMessage>
		
	<cf_calc_score datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" playerID="#attack.attackPlayerID#">

</cfif>
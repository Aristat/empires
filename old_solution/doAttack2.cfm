<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!--- and inside the attack query loop --->
<cfquery name="defense" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #attack.attackPlayerID#
</cfquery>

<cfif defense.recordcount is 0><!--- player does not exist anymore --->
	<cfset message = message & "The empire #attack.attackPlayerID# does not exist anymore<br>">
<cfelse>
	<cfset dColumns = "uunit,swordsman,archers,horseman,trainedPeasants,thieves,macemen,woodCutter,hunter,farmer,house,ironMine,goldMine,toolMaker,weaponSmith,tower,fort,townCenter,market,warehouse,stable,wood,iron,gold,food,people,mageTower,research11,winery">
	<cfset dPlayer = structNew()>
	<cfloop list="#dColumns#" index="i">
		<cfset t = setVariable("dPlayer.#i#", evaluate("defense.#i#"))>
	</cfloop>
	<cfset attackMessage = "">

	<!--- see how many times attacked already that person --->
	<cfset sDate = dateAdd("h", -24, now())>
	<cfquery name="nqMyWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 2 and attackerWins = 1
    </cfquery>
	<cfquery name="nqMyLost" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID = #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 2 and attackerWins = 0
    </cfquery>
	<cfquery name="nqOtherWon" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select count(*) as total from attackNews where attackID <> #playerID# and defenseID = #defense.id#
			and createdOn >= #sDate# and attackType = 2 and attackerWins = 1
    </cfquery>
	
	<cfset hasAttacks = round(val(nqMyWon.total) + val(nqMyLost.total)/3 + val(nqOtherWon.total)/5)>

	
	<cfscript>
	attackCatapults = attack.catapults;
	defenseCatapults = defense.catapults;
	
	// see if not attacking someone weak
	runPercent = 0;
	victoryPoints = 1;

	if (not deathMatchMode) {		
		if (player.score gt defense.score * 16)  { runPercent = 0.4; victoryPoints = 0.1; } // attacking really weak opponent
		else if (player.score gt defense.score * 8) {runPercent = 0.2; victoryPoints = 0.25; }
		else if (player.score gt defense.score * 4) { runPercent = 0.1; victoryPoints = 0.5; }
		else if (player.score gt defense.score * 2) { runPercent = 0.05; victoryPoints = 0.75; } // attacking less than half the size
	}
			
	attackmessage = attackmessage & "<font color=yellow face=verdana size=2>--------- Catapult Battle #player.name# (#player.id#) vs. #defense.name# (#defense.id#) #theDate# ---------<br></font>";

	if (runPercent gt 0)
	{
		runCatapults = round(attackCatapults*runpercent);
		attackmessage = attackmessage & "<font color=red>#player.name# attacked much weaker enemy. <br>#runCatapults# catapults revolt and go away.<br></font>";
		attackCatapults = attackCatapults - runCatapults;
	}
	
	attackPoints =  attackCatapults * catapultA.attackPt;
	attackPoints = round(attackPoints + attackPoints * (newP.research11 / 100));	
	
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

	
	catapultDpt = 25;
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
		catapultDPt = 30;
	}
	else if (defense.civ is 5) { // mongols
		nothing = true;
	}
	else if (defense.civ is 6) { // incas
		catapultDpt = 20;
	}	
	else if (defense.civ is 7) { // chinese
		nothing = true;
	}
	else if (defense.civ is 8) { // barbarians
		nothing = true;
	}
	
	defensePoints =  defenseCatapults * catapultDpt;
	defensePoints = round(defensePoints + defensePoints * (dPlayer.research11 / 100));					
	
	// now randomize the points with +/- 10%
	aStart = attackPoints - round(attackPoints*0.1);
	aEnd = attackPoints + round(attackPoints*0.1);
	dStart = defensePoints - round(defensePoints*0.1);
	dEnd = defensePoints + round(defensePoints*0.1);
	attackPoints = randRange(aStart, aEnd);
	defensePoints = randRange(dStart, dEnd);
	
	// calculate casaulties
	if (defense.score lt newP.score) // defense is weaker
		dDieCatapults = round((attackPoints / 650) * victoryPoints);
	else	// defense is stronger
		dDieCatapults = round((attackPoints / 400) * victoryPoints);
		
	if (defenseCatapults lt dDieCatapults) {
		dDieCatapults = defenseCatapults;
		defenseCatapults = 0;
	}
	else {
		defenseCatapults = defenseCatapults - dDieCatapults;		
	}

	if (defense.score gt newP.score) // attacking someone bigger, lose less army
		aDieCatapults = round(defensePoints / 650);
	else 
		aDieCatapults = round(defensePoints / 400);		
		
	if (attackCatapults lt aDieCatapults) {
		aDieCatapults = attackCatapults;
		attackCatapults = 0;
	}
	else
		attackCatapults = attackCatapults - aDieCatapults; 
	
	attackmessage = attackmessage & "#player.name# destroyed #dDieCatapults# catapults<br>";
	attackmessage = attackmessage & "#defense.name# destroyed #aDieCatapults# catapults.<br>";		

	if (attackPoints gt defensePoints) attackerWins = 1;
	else attackerWins = 0;
	
	newsMessage = "";
	if (attackerWins is 1) {
		attackmessage = attackmessage & "<br>#player.name# won the war!<br>";
		// look at attack type
		if (attack.attackType is 10) { // army and towers

			attackPoints = round(attackCatapults * victoryPoints);			
			if (dPlayer.tower gt 0) {
				// 10 cats destroy 1 tower
				catsKilled = round(dPlayer.tower / 10);
				if (catsKilled gt attackCatapults)
					catsKilled = attackCatapults;
					
				attackCatapults = attackCatapults - catsKilled;	
				attackMessage = attackMessage & "#catsKilled# attacking catapults were annihilated by defending towers<br>";
				
				dTower = round(attackPoints / 10);
				if (dTower gt dPlayer.tower)
					dTower = dPlayer.tower;
				
				dPlayer.tower = dPlayer.tower - dTower;
				attackMessage = attackMessage & "and #dTower# towers were razed by attacking catapults.<br><br>";
			}
			
			attackPoints = round(attackCatapults * victoryPoints);						
			dTotalArmy = dPlayer.swordsman + dPlayer.archers + dPlayer.horseman + dPlayer.macemen + dPlayer.trainedPeasants + dPlayer.uunit;			
			
			if (attackPoints gt 0 and dTotalArmy gt 0) {
				dSwordsman = round((dPlayer.swordsman / dTotalArmy) * attackPoints);
				dArchers = round((dPlayer.archers / dTotalArmy) * attackPoints);
				dHorseman = round((dPlayer.horseman / dTotalArmy) * attackPoints);
				dMacemen = round((dPlayer.macemen / dTotalArmy) * attackPoints);
				dTrainedPeasants = round((dPlayer.trainedPeasants / dTotalArmy) * attackPoints);
				dUunit = round((dPlayer.uunit / dTotalArmy) * attackPoints);
								
				if (dSwordsman gt dPlayer.swordsman) dSwordsman = dPlayer.swordsman;								
				if (dArchers gt dPlayer.archers) dArchers = dPlayer.archers;
				if (dHorseman gt dPlayer.horseman) dHorseman = dPlayer.horseman;
				if (dMacemen gt dPlayer.macemen) dMacemen = dPlayer.macemen;
				if (dTrainedPeasants gt dPlayer.trainedPeasants) dTrainedPeasants = dPlayer.trainedPeasants;
				if (dUUnit gt dPlayer.uunit) dUunit = dPlayer.uunit;								
								
				newsMessage = "#val(dSwordsman + dArchers + dHorseman + dMacemen + dTrainedPeasants + dUunit)# army<br>";
				attackmessage = attackmessage & "#player.name# catapulted #dSwordsman# swordsman, #dArchers# archers, #dHorseman# horseman, #dMacemen# macemen, #dTrainedPeasants# trained peasants and #dUunit# #uunitNames[defense.civ]#s";
				
				dPlayer.swordsman = dPlayer.swordsman - dSwordsman;
				dPlayer.archers = dPlayer.archers - dArchers;
				dPlayer.horseman = dPlayer.horseman - dHorseman;
				dPlayer.macemen = dPlayer.macemen - dMacemen;
				dPlayer.TrainedPeasants = dPlayer.trainedPeasants - dTrainedPeasants;
				dPlayer.uunit = dPlayer.uunit - dUunit;
				
			}
			else {
				attackmessage = attackmessage & "No army killed.";
				newsMessage = "0 army";
			}
			
		}
		else if (attack.attackType is 11) { // catapult population
			attackPoints = round(attackCatapults * 12 * victoryPoints);
			
			if (attackPoints gt 0 and dPlayer.people gt 0)
			{
				killPeople = attackPoints;
				if (dPlayer.people lt killPeople) killPeople = dPlayer.people;
				dPlayer.people = dPlayer.people - killPeople;
									
				newsMessage = "#killPeople# people";
				attackMessage = attackMessage & "#NumberFormat(killPeople)# people were killed by #player.name# catapults.<br>";
			}
			else {
				newsMessage = "No kills";
				attackmessage = attackmessage & "But failed to kill any people<br>";
			}				
		}				
		else if (attack.attackType is 12) { // catapult buildings
			attackPoints = round(attackCatapults * victoryPoints) * 0.5; // that many buildings are destroyed
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
				dWinery = round((dPlayer.winery / dTotalBuildings) * attackPoints);
					
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
				if (dPlayer.mageTower lt dMageTower) dMageTower = dPlayer.mageTower;
				if (dPlayer.winery lt dWinery) dWinery = dPlayer.winery;

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
				attackmessage = attackmessage & "#player.name# have destroyed #dWoodCutter# woodcutters, #dHunter# hunters, #dfarmer# farmers, #dhouse# houses, #dironmine# iron mines, #dGoldMine# gold mines, #dToolMaker# tool makers, #dweaponsmith# weaponsmiths, #dtower# towers, #dtowncenter# towncenters, #dfort# forts, #dstable# stables, #dmarket# markets, #dmagetower# mage towers, #dwinery# winery and #dwarehouse# warehouses<br>";
			}
			else {
				newsMessage = "0 Buildings";
				attackmessage = attackmessage & "But failed to destroy any building.<br>";
			}				
		}
	}
	else {
		attackmessage = attackmessage & "<br>#defense.name# won the war!<br>";
	}
	</cfscript>
	<cfset attackmessage = attackmessage & "<br>--------------------------------------------------------</font><br>">
	
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update attackQueue set 
		catapults = #attackCatapults#
		where id = #attack.id#
	</cfquery>
	
	<cfif dPlayer.people lt 100><cfset dPlayer.people = 100></cfif>	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update player set 
			<cfloop list="#dColumns#" index="i">
			#i# = #evaluate("dPlayer.#i#")#,
			</cfloop>
			catapults = #defenseCatapults#,
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
		insert into attackNews (attackID, defenseID, attackCatapults, defenseCatapults,
			createdOn, attackerWins, message, attackAlliance, defenseAlliance, battleDetails,
			attackAllianceID, defenseAllianceID, attackType)
			values (#playerID#, #attack.attackPlayerID#, 
			#aDieCatapults#, #dDieCatapults#, 
			#now()#, #attackerWins#, '#newsMessage#',
			'#attackAlliance#', '#defenseAlliance#', '#attackmessage#',
			#player.allianceID#, #defense.allianceID#, 2)
	</cfquery>
	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		insert into playerMessage (fromPlayerID, toPlayerID, fromPlayerName, toPlayerName, message, viewed, createdOn, messageType)
		values (#playerID#, #attack.attackPlayerID#, '#player.name#', '#defense.name#', '#attackmessage#', 0, #CreateODBCDateTime(Now())#, 1)
	</cfquery>

	<cfset message = message & attackMessage>
		
	<cf_calc_score datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" playerID="#attack.attackPlayerID#">

</cfif>
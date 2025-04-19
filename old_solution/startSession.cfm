<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<cfscript>
session.buildings = arrayNew(1);

// wood cutter 
session.buildings[1] = structNew();
session.buildings[1].name = "Wood Cutter";
session.buildings[1].dbColumn = "woodCutter";
session.buildings[1].land = "F";
session.buildings[1].workers = 6;
session.buildings[1].sq = 4;
session.buildings[1].foodEaten = 0;
session.buildings[1].costWood = 2;
session.buildings[1].costIron = 0;
session.buildings[1].costGold = 25;
session.buildings[1].allowOff = true;
session.buildings[1].production = 4;// 2 wood per turn 
session.buildings[1].productionName = "wood";

// hunter 
session.buildings[2] = structNew();
session.buildings[2].name = "Hunter";
session.buildings[2].dbColumn = "hunter";
session.buildings[2].land = "F";
session.buildings[2].workers = 6;
session.buildings[2].sq = 2;
session.buildings[2].foodEaten = 0;
session.buildings[2].costWood = 4;
session.buildings[2].costIron = 0;
session.buildings[2].costGold = 25;
session.buildings[2].allowOff = true;
session.buildings[2].production = 3;// food per turn 
session.buildings[2].productionName = "food";

// farmer 
session.buildings[3] = structNew();
session.buildings[3].name = "Farm";
session.buildings[3].dbColumn = "farmer";
session.buildings[3].land = "P";
session.buildings[3].workers = 12;
session.buildings[3].sq = 4;
session.buildings[3].foodEaten = 0;
session.buildings[3].costWood = 8;
session.buildings[3].costIron = 1;
session.buildings[3].costGold = 25;
session.buildings[3].allowOff = true;
session.buildings[3].production = 8;// food per turn 
session.buildings[3].productionName = "food";

// house 
session.buildings[4] = structNew();
session.buildings[4].name = "House";
session.buildings[4].dbColumn = "house";
session.buildings[4].land = "P";
session.buildings[4].workers = 0;
session.buildings[4].sq = 2;
session.buildings[4].foodEaten = 1;
session.buildings[4].costWood = 4;
session.buildings[4].costIron = 0;
session.buildings[4].costGold = 100;
session.buildings[4].allowOff = false;
session.buildings[4].people = 100;// can hold 25 people 
session.buildings[4].productionName = "";

// iron 
session.buildings[5] = structNew();
session.buildings[5].name = "Iron Mine";
session.buildings[5].dbColumn = "ironMine";
session.buildings[5].land = "M";
session.buildings[5].workers = 8;
session.buildings[5].sq = 2;
session.buildings[5].costWood = 6;
session.buildings[5].costIron = 0;
session.buildings[5].costGold = 100;
session.buildings[5].allowOff = true;
session.buildings[5].production = 1;// 1 iron per turn 
session.buildings[5].productionName = "iron";

// gold 
session.buildings[6] = structNew();
session.buildings[6].name = "Gold Mine";
session.buildings[6].dbColumn = "goldMine";
session.buildings[6].land = "M";
session.buildings[6].workers = 12;
session.buildings[6].sq = 6;
session.buildings[6].costWood = 10;
session.buildings[6].costIron = 10;
session.buildings[6].costGold = 1000;
session.buildings[6].allowOff = true;
session.buildings[6].production = 100;// gold per turn 
session.buildings[6].productionName = "gold";

// tool maker 
session.buildings[7] = structNew();
session.buildings[7].name = "Tool Maker";
session.buildings[7].dbColumn = "toolMaker";
session.buildings[7].land = "P";
session.buildings[7].workers = 10;
session.buildings[7].sq = 2;
session.buildings[7].foodEaten = 0;
session.buildings[7].costWood = 6;
session.buildings[7].costIron = 2;
session.buildings[7].costGold = 200;
session.buildings[7].allowOff = true;
session.buildings[7].production = 1;// 1 tool 
session.buildings[7].woodNeed = 2;// 1 wood for 1 tool 
session.buildings[7].ironNeed = 2;// and 1 iron 
session.buildings[7].productionName = "tools";
session.buildings[7].numBuilders = 6;	// number of builders per tool maker

// weapon smith 
session.buildings[8] = structNew();
session.buildings[8].name = "Weaponsmith";
session.buildings[8].dbColumn = "weaponsmith";
session.buildings[8].land = "P";
session.buildings[8].workers = 10;
session.buildings[8].sq = 4;
session.buildings[8].foodEaten = 0;
session.buildings[8].costWood = 10;
session.buildings[8].costIron = 4;
session.buildings[8].costGold = 600;
session.buildings[8].allowOff = true;
session.buildings[8].production = 1;
session.buildings[8].woodNeed = 25;// need 1 wood when doing bows 
session.buildings[8].ironNeed = 25;// need 1 iron when doing swords 
session.buildings[8].maceWood = 6; // need 4 wood
session.buildings[8].maceIron = 6; // and 4 iron to produce 1 mace
session.buildings[8].productionName = "weapons";

// fort 
session.buildings[9] = structNew();
session.buildings[9].name = "Fort";
session.buildings[9].dbColumn = "fort";
session.buildings[9].land = "P";
session.buildings[9].workers = 0;
session.buildings[9].sq = 12;
session.buildings[9].foodEaten = 2;
session.buildings[9].costWood = 20;
session.buildings[9].costIron = 8;
session.buildings[9].costGold = 1000;
session.buildings[9].allowOff = false;
session.buildings[9].maxTrain = 2;
session.buildings[9].maxUnits = 15;// maximum of 10 units 
session.buildings[9].needGold = 25;// need gold per each turn
session.buildings[9].productionName = "";

// tower 
session.buildings[10] = structNew();
session.buildings[10].name = "Tower";
session.buildings[10].dbColumn = "tower";
session.buildings[10].land = "P";
session.buildings[10].workers = 0;
session.buildings[10].sq = 4;
session.buildings[10].foodEaten = 0;
session.buildings[10].costWood = 20;
session.buildings[10].costIron = 20;
session.buildings[10].costGold = 400;
session.buildings[10].allowOff = false;
session.buildings[10].productionName = "";

// town center 
session.buildings[11] = structNew();
session.buildings[11].name = "Town Center";
session.buildings[11].dbColumn = "townCenter";
session.buildings[11].land = "P";
session.buildings[11].workers = 0;
session.buildings[11].sq = 25;
session.buildings[11].foodEaten = 0;
session.buildings[11].costWood = 100;
session.buildings[11].costIron = 40;
session.buildings[11].costGold = 2500;
session.buildings[11].allowOff = false;
session.buildings[11].maxUnits = 10;
session.buildings[11].people = 100;
session.buildings[11].supplies = 1000;
session.buildings[11].maxExplorers = 6;
session.buildings[11].foodPerExplorer = 5;
session.buildings[11].productionName = "";
session.buildings[11].maxLocalTrades = 100;

// market 
session.buildings[12] = structNew();
session.buildings[12].name = "Market";
session.buildings[12].dbColumn = "market";
session.buildings[12].land = "P";
session.buildings[12].workers = 6;
session.buildings[12].sq = 4;
session.buildings[12].foodEaten = 0;
session.buildings[12].costWood = 20;
session.buildings[12].costIron = 2;
session.buildings[12].costGold = 250;
session.buildings[12].allowOff = false;
session.buildings[12].maxTrades = 50;// can trade max. 50 supplies per turn 
session.buildings[12].productionName = "";

// warehouse 
session.buildings[13] = structNew();
session.buildings[13].name = "Warehouse";
session.buildings[13].dbColumn = "warehouse";
session.buildings[13].land = "P";
session.buildings[13].workers = 4;
session.buildings[13].sq = 2;
session.buildings[13].foodEaten = 0;
session.buildings[13].costWood = 15;
session.buildings[13].costIron = 0;
session.buildings[13].costGold = 100;
session.buildings[13].allowOff = false;
session.buildings[13].supplies = 2500;// can hold 100 supplies 
session.buildings[13].productionName = "";

// stable 
session.buildings[14] = structNew();
session.buildings[14].name = "Stable";
session.buildings[14].dbColumn = "stable";
session.buildings[14].land = "P";
session.buildings[14].workers = 12;
session.buildings[14].sq = 4;
session.buildings[14].foodEaten = 0;
session.buildings[14].costWood = 10;
session.buildings[14].costIron = 2;
session.buildings[14].costGold = 200;
session.buildings[14].allowOff = true;
session.buildings[14].production = 1;// produces 1 horse 
session.buildings[14].foodNeed = 100;// need 5 food 
session.buildings[14].productionName = "horses";

// mage tower
session.buildings[15] = structNew();
session.buildings[15].name = "Mage Tower";
session.buildings[15].dbColumn = "mageTower";
session.buildings[15].land = "P";
session.buildings[15].workers = 20;
session.buildings[15].sq = 10;
session.buildings[15].foodEaten = 0;
session.buildings[15].costWood = 50;
session.buildings[15].costIron = 50;
session.buildings[15].costGold = 2000;
session.buildings[15].allowOff = true;
session.buildings[15].production = 1;// produces 10 research points
session.buildings[15].goldNeed = 100;// needed gold to produce 1 research points
session.buildings[15].productionName = "research points";

// winery
session.buildings[16] = structNew();
session.buildings[16].name = "Winery";
session.buildings[16].dbColumn = "winery";
session.buildings[16].land = "P";
session.buildings[16].workers = 12;
session.buildings[16].sq = 6;
session.buildings[16].foodEaten = 0;
session.buildings[16].costWood = 12;
session.buildings[16].costIron = 4;
session.buildings[16].costGold = 1000;
session.buildings[16].allowOff = true;
session.buildings[16].production = 1;// produces 1 wine
session.buildings[16].goldNeed = 10; // need 10 units of gold to produce 1 wine
session.buildings[16].productionName = "wine";


session.soldiers = arrayNew(1);
session.soldiers[1] = structNew();
session.soldiers[1].name = "Archer";
session.soldiers[1].dbName = "archers";
session.soldiers[1].turns = 6;
session.soldiers[1].attackPt = 4;
session.soldiers[1].defensePt = 12;
session.soldiers[1].goldPerTurn = 3;
session.soldiers[1].takeLand = 0.05;
session.soldiers[1].foodEaten = 0.5;
	
session.soldiers[2] = structNew();
session.soldiers[2].name = "Swordsman";
session.soldiers[2].dbName = "swordsman";
session.soldiers[2].turns = 4;
session.soldiers[2].attackPt = 8;
session.soldiers[2].defensePt = 6;
session.soldiers[2].goldPerTurn = 3;
session.soldiers[2].takeland = 0.10;
session.soldiers[2].foodEaten = 0.4;

session.soldiers[3] = structNew();
session.soldiers[3].name = "Horseman";
session.soldiers[3].dbName = "horseman";
session.soldiers[3].turns = 8;
session.soldiers[3].attackPt = 10;
session.soldiers[3].defensePt = 10;
session.soldiers[3].goldPerTurn = 5;
session.soldiers[3].takeLand = 0.15;
session.soldiers[3].foodEaten = 1;
	
session.soldiers[4] = structNew();
session.soldiers[4].name = "Tower";
session.soldiers[4].dbName = "tower";
session.soldiers[4].turns = 0;
session.soldiers[4].attackPt = 0;
session.soldiers[4].defensePt = 50;
session.soldiers[4].goldPerTurn = 0;
session.soldiers[4].takeLand = 0;
session.soldiers[4].foodEaten = 0;

session.soldiers[5] = structNew();
session.soldiers[5].name = "Catapult";
session.soldiers[5].dbName = "catapults";
session.soldiers[5].turns = 8;
session.soldiers[5].attackPt = 25;
session.soldiers[5].defensePt = 25;
session.soldiers[5].goldPerTurn = 0;
session.soldiers[5].trainCost = 250;
session.soldiers[5].takeLand = 0;
session.soldiers[5].foodEaten = 0;

session.soldiers[6] = structNew();
session.soldiers[6].name = "Macemen";
session.soldiers[6].dbName = "macemen";
session.soldiers[6].turns = 3;
session.soldiers[6].attackPt = 6;
session.soldiers[6].defensePt = 3;
session.soldiers[6].goldPerTurn = 2;
session.soldiers[6].takeLand = 0.06;
session.soldiers[6].foodEaten = 0.2;

session.soldiers[7] = structNew();
session.soldiers[7].name = "Trained Peasant";
session.soldiers[7].dbName = "trainedPeasants";
session.soldiers[7].turns = 1;
session.soldiers[7].attackPt = 1;
session.soldiers[7].defensePt = 2;
session.soldiers[7].goldPerTurn = 0.1;
session.soldiers[7].takeLand = 0.01;
session.soldiers[7].foodEaten = 0.1;

session.soldiers[8] = structNew();
session.soldiers[8].name = "Thieves";
session.soldiers[8].dbName = "thieves";
session.soldiers[8].turns = 10;
session.soldiers[8].attackPt = 50;
session.soldiers[8].defensePt = 55;
session.soldiers[8].goldPerTurn = 25;
session.soldiers[8].takeLand = 0;
session.soldiers[8].foodEaten = 5;

session.soldiers[9] = structNew();
session.soldiers[9].name = "Unique Unit";
session.soldiers[9].dbName = "uunit";
session.soldiers[9].turns = 12;
session.soldiers[9].attackPt = 1;
session.soldiers[9].defensePt = 1;
session.soldiers[9].goldPerTurn = 25;
session.soldiers[9].trainGold = 1000;
session.soldiers[9].trainSwords = 0;
session.soldiers[9].trainBows = 0;
session.soldiers[9].trainHorses = 0;
session.soldiers[9].takeLand = 0;
session.soldiers[9].foodEaten = 1;

session.localWoodSellPrice = 30;
session.localWoodBuyPrice = 32;
session.localFoodSellPrice = 15;
session.localFoodBuyPrice = 18;
session.localIronSellPrice = 75;
session.localIronBuyPrice = 78;
session.localToolsSellPrice = 150;
session.localToolsBuyPrice = 180;

session.peopleEatOneFood = 50;
session.extraFoodperLand = 800;
session.peopleBurnOneWood = 250;
session.popIncreaseModifier = 1;

session.wallUseGold = 150;
session.wallUseIron = 2;
session.wallUseWood = 15;
session.wallUseWine = 5;


/* civ differences, if changing land used by buildings, it has to be changed in doAttack also */
if (civID is 1) { // viking
	session.soldiers[9].name = "Berserker";
	session.soldiers[9].attackPt = 25;
	session.soldiers[9].defensePt = 5;
	session.soldiers[9].trainSwords = 1;
	session.soldiers[9].trainHorses = 1;
	session.soldiers[9].trainBows = 1;
	session.soldiers[9].takeLand = 0.30;
	
	// minus
	session.peopleBurnOneWood = 125;
	session.buildings[14].sq = 6;			// stable
	session.buildings[14].foodNeed = 150; 
	session.buildings[13].supplies = 1250; // warehouse
	session.buildings[4].people = 75;		// house
	session.buildings[3].production = 6; // farm
	session.buildings[16].sq = 8;	// winery +2
	
	// plus
	session.buildings[1].sq = 3; // wood cutter
	session.buildings[1].production = 5; // wood cutter
	session.buildings[2].production = 5; // hunter
	session.buildings[5].production = 2; // iron mine
}
else if (civID is 2) { // franks
	session.soldiers[9].name = "Paladin";
	session.soldiers[9].attackPt = 5;
	session.soldiers[9].defensePt = 30;
	session.soldiers[9].trainSwords = 3;
	session.soldiers[9].trainHorses = 1;
	session.soldiers[9].takeLand = 0.30;
	
	// minus
	session.buildings[9].maxUnits = 12;	// fort
	session.buildings[15].sq = 12; // mage tower
	session.buildings[15].workers = 15;
	session.popIncreaseModifier = 0.80;	// 15% slower
	
	// plus
	session.buildings[3].sq = 2; // farm
	session.buildings[7].numBuilders = 10;	// tool maker
	session.buildings[10].sq = 3;	// tower
	session.soldiers[4].defensePt = 65; // tower
	session.soldiers[1].defensePt = 15; // archers
	session.buildings[10].costWood = 10;
	session.buildings[10].costIron = 10;
	session.buildings[11].maxExplorers = 7;	// town center
	session.extraFoodperLand = 840;	// 10% better
}
else if (civID is 3) { // japanese
	session.soldiers[9].name = "Samurai";
	session.soldiers[9].attackPt = 20;
	session.soldiers[9].defensePt = 10;
	session.soldiers[9].trainSwords = 2;
	session.soldiers[9].takeLand = 0.50;
	
	// minus
	session.buildings[2].production = 2; // hunter
	session.buildings[1].sq = 5;		// wood cutter
	session.buildings[12].maxTrades = 40; // market
	session.buildings[14].sq = 8;		// stable
	
	// plus
	session.buildings[3].production = 10; // farm
	session.buildings[4].people = 120; // house
	session.buildings[11].sq = 20; // town center
	session.buildings[15].production = 1.5;	// mage tower
}
else if (civID is 4) { // byzantines
	session.soldiers[9].name = "Cataphract";
	session.soldiers[9].attackPt = 15;
	session.soldiers[9].defensePt = 15;
	session.soldiers[9].trainSwords = 1;
	session.soldiers[9].trainHorses = 1;
	session.soldiers[9].trainBows = 1;
	session.soldiers[9].takeLand = 0.20;
	
	// minus
	session.buildings[5].sq = 3;			// iron mine
	session.buildings[7].numBuilders = 5;	// tool maker
	session.peopleEatOneFood = 60; 
	
	// plus
	session.buildings[6].sq = 2; // gold mine
	session.buildings[6].production = 200;
	session.buildings[12].maxTrades = 100;	// market
	session.buildings[13].supplies = 5000; // warehouse
	session.soldiers[1].defensePt = 14; // archer
	session.soldiers[5].defensePt = 30; // catapult
	session.soldiers[5].attackPt = 30; 
	session.buildings[15].sq = 8;	// mage tower
}
else if (civID is 5) { // mongols
	session.soldiers[9].name = "Horse Archer";
	session.soldiers[9].attackPt = 20;
	session.soldiers[9].defensePt = 5;
	session.soldiers[9].trainHorses = 1;
	session.soldiers[9].trainBows = 1;
	session.soldiers[9].takeLand = 0.15;
	session.soldiers[9].turns = 10;
	session.soldiers[9].trainGold = 100;
	session.soldiers[9].goldPerTurn = 5;
	
	// minus
	session.peopleEatOneFood = 50;
	session.soldiers[8].defensePt = 50; // thieves
	session.buildings[11].maxExplorers = 5; // town center
	session.buildings[15].goldNeed = 200; // mage tower
	session.buildings[3].production = 6;	// farm
	session.extraFoodperLand = 720;	// 5% worse
		
	// plus
	session.buildings[9].sq = 8; // fort
	session.buildings[2].production = 4; // hunters
	session.buildings[9].maxUnits = 20;
	session.buildings[8].production = 2; // weaponesmith
	session.buildings[7].production = 2; // tool maker
	session.buildings[7].numBuilders = 8; 
	session.popIncreaseModifier = 1.4; // 40% better
}
else if (civID is 6) { // incans
	session.soldiers[9].name = "Shaman";
	session.soldiers[9].attackPt = 1;
	session.soldiers[9].defensePt = 1;
	session.soldiers[9].trainHorses = 0;
	session.soldiers[9].trainBows = 0;
	session.soldiers[9].takeLand = 5;
	session.soldiers[9].turns = 14;
	session.soldiers[9].trainGold = 5000;
	session.soldiers[9].goldPerTurn = 50;

	// pluses
	session.buildings[15].goldNeed = 25; // mage tower
	session.buildings[11].people = 100; // town center
	session.buildings[11].supplies = 5000;
	session.soldiers[8].defensePt = 80;		// thief
	session.buildings[12].maxTrades = 100; // market
	session.soldiers[2].attackPt = 9;
	session.soldiers[6].attackPt = 8;
	
	// minuses
	session.soldiers[3].turns = 80; // no horses
	session.soldiers[3].attackPt = 1;
	session.soldiers[3].defensePt = 1;
	session.soldiers[5].attackPt = 16;
	session.soldiers[5].defensePt = 20;
	
	session.buildings[11].sq = 36; // town center
	session.buildings[5].sq = 3; // iron mine
}
else if (civID is 7) { // chinese
	session.soldiers[9].name = "Kung Fu Warrior";
	session.soldiers[9].attackPt = 15;
	session.soldiers[9].defensePt = 15;
	session.soldiers[9].trainHorses = 0;
	session.soldiers[9].trainBows = 0;
	session.soldiers[9].takeLand = 0.5;
	session.soldiers[9].turns = 10;


	// pluses
	session.buildings[10].sq = 3; // tower -1
	session.buildings[8].woodNeed = 20;// weaponsmith -5
	session.buildings[8].ironNeed = 20;// -5
	session.popIncreaseModifier	= 2; // 100% faster population increase

	session.wallUseGold = 75; 	// 50% cheaper wall
	session.wallUseIron = 1;
	session.wallUseWood = 8;
	session.wallUseWine = 3;
	
	session.soldiers[8].attackPt = 65;	// thief
	session.soldiers[7].attackPt = 2; // trained peasant
	session.soldiers[7].defensePt = 3; 
	session.soldiers[7].takeLand = 0.04;
	
	// minuses
	session.buildings[16].sq = 8; // +2 winery
	session.buildings[4].sq = 4; // +2 house

}
else if (civID is 8) { // barbarians
	session.soldiers[9].name = "Giant Warrior";
	session.soldiers[9].attackPt = 50;
	session.soldiers[9].defensePt = 1;
	session.soldiers[9].trainHorses = 1;
	session.soldiers[9].trainSwords = 3;
	session.soldiers[9].takeLand = 1;
	session.soldiers[9].turns = 4;
	session.soldiers[9].foodEaten = 4; // double
	
	session.soldiers[6].attackPt = 8; // maceman +2
	session.soldiers[6].defensePt = 4; // +1
	session.soldiers[6].takeLand = 0.09;
}

</cfscript>
<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!--- 
	Calculates the score of the player.
	Passed:
	datasource, username, password (for database)
	playerID
 --->

<cfset dsn = attributes.datasource>
<cfset dsn_login = attributes.username>
<cfset dsn_pw = attributes.password>
<cfset playerID = attributes.playerID>
 
<!--- see how many soldier enemy has queued --->
<cfquery name="q" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select 
		sum(swordsman) as attackingSwordsman, 
		sum(archers) as attackingArchers, 
		sum(horseman) as attackingHorseman,
		sum(trainedPeasants) as attackingPeasants,
		sum(macemen) as attackingMacemen,
		sum(catapults) as attackingCatapults,
		sum(thieves) as attackingThieves
	from attackQueue where playerID = #playerID#
</cfquery>
 
<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #playerID#
</cfquery>

<cfset TotalSwordsman = val(q.attackingSwordsman)+p.swordsman>
<Cfset TotalHorseman = val(q.attackingHorseman)+p.Horseman>
<Cfset TotalArchers = val(q.attackingArchers)+p.Archers>
<cfset TotalCatapults = val(q.attackingCatapults)+p.catapults>
<cfset TotalMacemen = val(q.attackingMacemen)+p.macemen>
<cfset TotalPeasants = val(q.attackingPeasants)+p.trainedPeasants>
<cfset TotalThieves = val(q.attackingThieves)+p.thieves>
	
<cfset totalBuildings = p.woodCutter + p.hunter + p.farmer + p.house + p.ironMine + 
						p.goldMine*2 + p.toolMaker + p.weaponSmith + p.fort + p.tower*5 + 
						p.townCenter*10 + p.market + p.stable + p.mageTower * 3>

<cfset militaryScore = round(TotalSwordsman*2) + round(TotalArchers*1.8) + round(TotalHorseman*3) + round(p.people*0.25)
					 + round(TotalMacemen*1) + round(TotalPeasants*0.3) + round(TotalCatapults*6) + round(TotalThieves*4)>
<cfset landScore = p.mland*5 + p.fland*4 + p.pland*3>
<cfset goodScore = round(p.wood*0.005) + round(p.food*0.0005) + round(p.iron*0.005) + round(p.gold*0.00001) + round(p.tools*0.01) + round(p.swords*0.1) + round(p.bows*0.1) + round(p.horses*0.15) + round(p.maces*0.1) + totalBuildings>

<cfset thescore = militaryScore + landScore + goodScore>
<cfset militaryScore = round((militaryScore / thescore) * 100.00)>
<cfset landScore = round((landScore / thescore) * 100.00)>
<cfset goodScore = round((goodScore / thescore) * 100.00)>

<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    update player set 
		score = #thescore#,
		militaryScore = #militaryScore#,
		landScore = #landScore#,
		goodScore = #goodScore#
	where id = #playerID#
</cfquery>


<cfif eflag is "train">	
	<cfset maxTrain = player.fort * fortB.maxTrain + player.townCenter * fortB.maxTrain>
	<cfset qty1 = abs(val(form.qty1))>
	<cfset qty2 = abs(val(form.qty2))>
	<cfset qty3 = abs(val(form.qty3))>
	<cfset qty5 = abs(val(form.qty5))>
	<cfset qty6 = abs(val(form.qty6))>
	<cfset qty7 = abs(val(form.qty7))>
	<cfset qty8 = abs(val(form.qty8))>
	<cfset qty9 = abs(val(form.qty9))>

	<cfset totalQty = qty1 + qty2 + qty3 + qty5 + qty6 + qty7 + qty8 + qty9>

	<cfset catapultCost = catapultA.trainCost * qty5>
	
	<cfset needBows = qty1 + qty9 * uunitA.trainBows>
	<cfset needSwords = qty2 + qty3 + qty9 * uunitA.trainSwords>
	<cfset needHorses = qty3 + qty9 * uunitA.trainHorses>
	<cfset needGold = qty8 * 1000 + qty9 * uunitA.trainGold>
	
	<!--- see how many are training now, can train only some per fort --->
	<cfquery name="check" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select sum(qty) as num_training from trainQueue where playerID = #playerID#
	</cfquery>
	<cfset newTrain = val(check.num_training) + totalQty>
	<cfif newTrain gt maxTrain>
		<cfset eflag_message = eflag_message & "You can only train #numberFormat(maxTrain)# soldiers.<br> (#fortB.maxTrain# soldiers per fort or towncenter.)<br>">
	<cfelseif player.people lt totalQty><!--- see if enough people --->
		<cfset eflag_message = eflag_message & "You do not have enough people.<br>">
	<cfelseif player.bows lt needBows><!--- bows --->
		<cfset eflag_message = eflag_message & "You do not have enough bows for training.<br>">
	<cfelseif player.swords lt needSwords><!--- swordsman --->
		<cfset eflag_message = eflag_message & "You do not have enough swords for training.<br>">
	<cfelseif player.horses lt needHorses><!--- horseman --->
		<cfset eflag_message = eflag_message & "You do not have enough horses for training.<br>">
	<cfelseif qty5 gt 0 and player.wood lt catapultCost><!--- catapults, wood --->
		<cfset eflag_message = eflag_message & "You do not have enough wood to train #qty5# catapults.<br>">
	<cfelseif qty5 gt 0 and player.iron lt catapultCost><!--- catapults, iron --->
		<cfset eflag_message = eflag_message & "You do not have enough iron to train #qty5# catapults.<br>">
	<cfelseif qty6 gt 0 and player.maces lt qty6><!--- macemen --->
		<cfset eflag_message = eflag_message & "You do not have enough maces to train #qty6# macemen.<br>">
	<cfelseif player.gold lt needGold><!--- thieves --->
		<cfset eflag_message = eflag_message & "You do not have enough gold for training.<br>">
	<cfelseif player.civ is 6 and qty3 gt 0>
		<cfset eflag_message = eflag_message & "Incas cannot train horseman.<br>">
	<cfelse>
		<cfloop list="1,2,3,5,6,7,8,9" index="i">
			<cfset qty = evaluate("qty#i#")>
			<cfif qty lt 0><cfset test = setVariable("qty#i#", 0)><cfset qty = 0></cfif>
			<cfif qty gt 0>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    			    insert into trainQueue (playerID, soldierType, turnsRemaining, qty)
					values (#playerID#, #i#, #soldiers[i].turns#, #qty#)
			    </cfquery>
			</cfif>
		</cfloop>
		
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				swords = swords - #needSwords#,
				bows = bows - #needBows#,
				maces = maces - #qty6#,
				horses = horses - #needHorses#,
				wood = wood - #val(qty5*catapultA.trainCost)#,
				iron = iron - #val(qty5*catapultA.trainCost)#,
				gold = gold - #needGold#,
				people = people - #totalQty#
			where id = #playerID#
        </cfquery>
	</cfif>
<cfelseif eflag is "dequeue">
	<!--- get back the weapons --->
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from trainQueue where playerID = #playerID# and id = #q_id#
    </cfquery>
	<cfoutput query="tq">
		<cfset getGold = 0>
		<cfset getSwords = 0>
		<cfset getHorses = 0>
		<cfset getBows = 0>
		<cfset getMaces = 0>
		<cfset getWood = 0>
		<cfset getIron = 0>
		<cfif tq.soldierType is 1><!--- archer --->
			<cfset getBows = tq.qty>
		<cfelseif tq.soldierType is 2><!--- swordsman --->
			<cfset getSwords = tq.qty>
		<cfelseif tq.soldierType is 3><!--- horseman --->
			<cfset getSwords = tq.qty>
			<cfset getHorses = tq.qty>
		<cfelseif tq.soldierType is 5><!--- catapults --->
			<cfset getWood = tq.qty * catapultA.trainCost>
			<cfset getIron = tq.qty * catapultA.trainCost>
		<cfelseif tq.soldierType is 6><!--- macemen --->
			<cfset getMaces = tq.qty>
		<cfelseif tq.soldierType is 8><!--- thief --->
			<cfset getGold = tq.qty * 1000>
		<cfelseif tq.soldierType is 9>
			<cfset getGold = tq.qty * uunitA.trainGold>
			<cfset getSwords = tq.qty * uunitA.trainSwords>
			<cfset getBows = tq.qty * uunitA.trainBows>
			<Cfset getHorses = tq.qty * uunitA.trainHorses>
		</cfif>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				gold = gold + #getGold#,
				swords = swords + #getSwords#,
				bows = bows + #getBows#,
				maces = maces + #getMaces#,
				horses = horses + #getHorses#,
				wood = wood + #getWood#,
				iron = iron + #getIron#,
				people = people + #tq.qty#
			where id = #playerID#
        </cfquery>		
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	    delete from trainQueue where id = #tq.id#
	    </cfquery>
	</cfoutput>
<cfelseif eflag is "disbandArmy">
	<cfset qty1 = val(form.qty1)>
	<cfset qty2 = val(form.qty2)>
	<cfset qty3 = val(form.qty3)>
	<cfset qty5 = val(form.qty5)>
	<cfset qty6 = val(form.qty6)>
	<cfset qty7 = val(form.qty7)>
	<cfset qty8 = val(form.qty8)>
	<cfset qty9 = val(form.qty9)>
	<cfset totalDisband = qty1 + qty2 + qty3 + qty5 + qty6 + qty7 + qty8 + qty9>
	
	<cfif qty1 lt 0 or qty2 lt 0 or qty3 lt 0 or qty5 lt 0 or qty6 lt 0 or qty7 lt 0 or qty8 lt 0 or qty9 lt 0>
		<cfset eflag_message = eflag_message & "Sorry, cannot disband negative army.<br>">
	<cfelseif qty1 gt player.archers>
		<cfset eflag_message = eflag_message & "Cannot disband #qty1# archers. You have only #player.archers#<br>">
	<cfelseif qty2 gt player.swordsman>
		<cfset eflag_message = eflag_message & "Cannot disband #qty2# swordsman. You have only #player.swordsman#.<br>">
	<cfelseif qty3 gt player.horseman>
		<cfset eflag_message = eflag_message & "Cannot disband #qty3# horseman. You have only #player.horseman#.<br>">
	<cfelseif qty5 gt player.catapults>
		<cfset eflag_message = eflag_message & "Cannot disband #qty5# catapults. You have only #player.catapults#.<br>">
	<cfelseif qty6 gt player.macemen>
		<cfset eflag_message = eflag_message & "Cannot disband #qty6# macemen. You have only #player.macemen#.<br>">
	<cfelseif qty7 gt player.trainedPeasants>
		<cfset eflag_message = eflag_message & "Cannot disband #qty7# trained peasants. You have only #player.trainedPeasants#.<br>">
	<cfelseif qty8 gt player.thieves>
		<cfset eflag_message = eflag_message & "Cannot disband #qty8# thieves. You have only #player.thieves#.<br>">
	<cfelseif qty9 gt player.uunit>
		<cfset eflag_message = eflag_message & "Cannot disband #qty9# #uunitA.name#. You have only #player.uunit#.<br>">
	<cfelse>
		<cfset getIron = 0>
		<cfset getWood = 0>
		<cfset getSwords = 0>
		<cfset getHorses = 0>
		<cfset getBows = 0>
		<cfset getMaces = 0>
		<cfif qty1 gt 0><cfset getBows = qty1></cfif>
		<cfif qty2 gt 0><cfset getSwords = qty2></cfif>
		<cfif qty3 gt 0><cfset getSwords = getSwords + qty3><cfset getHorses = qty3></cfif>
		<cfif qty5 gt 0><cfset getWood = round(qty5 * catapultA.trainCost)><cfset getIron = round(qty5 * catapultA.trainCost)></cfif>
		<cfif qty6 gt 0><cfset getMaces = qty6></cfif>
		<cfif qty9 gt 0>
			<cfset getSwords = getSwords + qty9 * uunitA.trainSwords>
			<cfset getBows = getBows + qty9 * uunitA.trainBows>
			<Cfset getHorses = getHorses + qty9 * uunitA.trainHorses>
		</cfif>
		
		<!--- get only 1/2 of what it was --->
		<cfset getIron = int(getIron / 2)>
		<cfset getWood = int(getWood / 2)>
		<cfset getSwords = int(getSwords / 2)>
		<cfset getBows = int(getBows / 2)>
		<cfset getMaces = int(getMaces / 2)>
		
		<cfset eflag_message = eflag_message & "You have disbanded #qty1# archers, #qty2# swordsman, #qty3# horsemen, #qty5# catapults,<br>#qty6# macemen, #qty7# trained peasants, #qty8# thieves.<br>You have received #getIron# iron, #getWood# wood, #getSwords# swords, #getBows# bows, #getHorses# horses and #getMaces# maces.<br>">
		
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				archers = archers - #qty1#,
				swordsman = swordsman - #qty2#,
				horseman = horseman - #qty3#,
				catapults = catapults - #qty5#,
				macemen = macemen - #qty6#,
				trainedPeasants = trainedPeasants - #qty7#,
				thieves = thieves - #qty8#,
				uunit = uunit - #qty9#,
				wood = wood + #getWood#,
				iron = iron + #getIron#,
				swords = swords + #getSwords#,
				bows = bows + #getBows#,
				maces = maces + #getMaces#,
				horses = horses + #getHorses#,
				people = people + #totalDisband#
			where id = #playerID#
        </cfquery>
	</cfif>
</cfif>
<cfif deathMatchMode and not deathMatchStarted>
	<font face="verdana" color=red size=2>Cannot attack before official deathmatch starts.</font>
	<cfabort>
</cfif>

<cfif eflag is "attack_empire">
	<!--- see if player has that many units --->
	<cfparam name="sendAll" default="0">
	<cfset sendWine = val(form.sendWine)>
	
	<cfif sendAll is 1>
		<cfset send_swordsman = player.swordsman>
		<cfset send_archers = player.archers>
		<cfset send_horseman = player.horseman>	
		<cfset send_macemen = player.macemen>
		<cfset send_trainedPeasants = player.trainedPeasants>
		<cfset send_uunit = player.uunit>
	<cfelse>
		<cfset send_swordsman = val(form.send_swordsman)>
		<cfset send_archers = val(form.send_archers)>
		<cfset send_horseman = val(form.send_horseman)>	
		<cfset send_macemen = val(form.send_macemen)>
		<cfset send_trainedPeasants = val(form.send_trainedPeasants)>
		<cfset send_uunit = val(form.send_uunit)>
	</cfif>
	<cfset attackPlayerID = val(form.attackPlayerID)>
	<cfset attack_type = val(attack_type)>

	<cfquery name="attackPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select killedBy,score,name,turn,numattacks,lastattack,allianceID, vacationEnd from player where id = #attackPlayerID#
    </cfquery>
	<cfquery name="attacks" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select count(id) as total from attackQueue where playerID = #playerID# and attackType between 0 and 9
    </cfquery>
	
	<cfset attackAlly = false>
	<cfif player.allianceID gt 0 and attackPlayer.allianceID gt 0>
		<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select ally1, ally2, ally3, ally4, ally5 from alliance where id = #player.allianceID#
        </cfquery>
		<cfif alliance.recordcount gt 0>
			<cfif alliance.ally1 is attackPlayer.allianceID or alliance.ally2 is attackPlayer.allianceID or alliance.ally3 is attackPlayer.allianceID or alliance.ally4 is attackPlayer.allianceID or alliance.ally5 is attackPlayer.allianceID>
				<cfset attackAlly = true>
			</cfif>
		</cfif>
	</cfif>

	<cfset totalArmy = send_swordsman + send_archers + send_horseman + send_macemen + send_trainedPeasants + send_uunit>
	<cfset eatSoldiersFood = send_swordsman * swordsmanA.foodEaten + send_archers * archerA.foodEaten + 
		send_horseman * horsemanA.foodEaten + send_macemen * macemanA.foodEaten + send_trainedPeasants * trainedPeasantA.foodEaten + 
		send_uunit * uunitA.foodEaten>
	<cfset eatSoldiersFood = round(eatSoldiersFood * 6) >
	
	<cfparam name="sendMaxWine" default="0">
	<cfif sendMaxWine is 1>
		<cfset sendWine = player.wine>
		<cfif sendWine gt totalArmy>
			<cfset sendWine = totalArmy>
		</cfif>
	</cfif>
	
	<cfset needGold = round(send_swordsman*swordsmanA.goldPerTurn + send_archers*archerA.goldPerTurn + send_horseman*horsemanA.goldPerTurn + send_macemen*macemanA.goldPerTurn + send_trainedPeasants*trainedPeasantA.goldPerTurn + send_uunit*uunitA.goldPerTurn) * 6>
	<cfif attackPlayerID is playerID>
		<cfset eflag_message = eflag_message & "Are you nuts? You can't attack yourself!!!">
	<cfelseif attackplayer.vacationEnd is not "" and attackplayer.vacationEnd gt now()>
		<cfset eflag_message = eflag_message & "Cannot attack empires while they are in vacation mode.<br>">
	<cfelseif player.food lt eatSoldiersFood>
		<cfset eflag_message = eflag_message & "You do not have enough food to send your soldiers. You need #numberFormat(eatSoldiersFood)# to send that much army.">
	<cfelseif attackAlly>
		<cfset eflag_message = eflag_message & "You cannot attack your allies.">
	<cfelseif player.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack under protection.">
	<cfelseif attackPlayer.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack players under protection.">
	<cfelseif attackPlayer.killedBy gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack dead empires.">
	<cfelseif attackPlayer.allianceID is player.allianceID and player.allianceID gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack empires in your alliance.">
	<cfelseif attack_type lt 0 or attack_type gt 3>
		<cfset eflag_message = eflag_message & "Invalid attack type!">
	<cfelseif send_swordsman lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative swordsman!">
	<cfelseif send_archers lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative archers!">
	<cfelseif send_horseman lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative horseman!">
	<cfelseif send_macemen lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative macemen!">
	<cfelseif send_uunit lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative #uunitA.name#s">
	<cfelseif send_trainedPeasants lt 0>
		<cfset eflag_message = eflag_message & "Cannot send negative trained peasants!">
	<cfelseif totalArmy is 0>
		<cfset eflag_message = eflag_message & "Cannot send 0 total army!">
	<cfelseif sendWine gt totalArmy>
		<cfset eflag_message = eflag_message & "You can only send 1 wine per soldier.">
	<cfelseif sendWine lt 0>
		<cfset eflag_message = eflag_message & "Cannot send less than 0 wine.">
	<cfelseif sendWine gt player.wine>
		<cfset eflag_message = eflag_message & "You do not have that much wine.">
	<cfelseif send_uunit gt player.uunit>
		<cfset eflag_message = eflag_message & "You do not have that many #uunitA.name#">
	<cfelseif send_swordsman gt player.swordsman>
		<cfset eflag_message = eflag_message & "You do not have that many swordman.">
	<cfelseif send_archers gt player.archers>
		<cfset eflag_message = eflag_message & "You do not have that many archers.">
	<cfelseif send_horseman gt player.horseman>
		<cfset eflag_message = eflag_message & "You do not have that many horseman.">
	<cfelseif send_macemen gt player.macemen>
		<cfset eflag_message = eflag_message & "You do not have that many macemen.">
	<cfelseif send_trainedPeasants gt player.trainedPeasants>
		<cfset eflag_message = eflag_message & "You do not have that many trained peasants.">
	<cfelseif attackPlayer.recordcount is 0>
		<cfset eflag_message = eflag_message & "Empire No. #attackPlayerID# does not exist.">
	<cfelseif attacks.total gte 1 and not deathmatchMode><!--- can have only 1 attack active--->
		<cfset eflag_message = eflag_message & "Your armies are already attacking someone. Please wait for them to come back.">
	<cfelseif needGold gt player.gold>
		<cfset eflag_message = eflag_message & "You do not have enough gold to pay your soldiers to fight<br>(You need #needGold# gold)">
	<cfelse>
		<!--- ok to send now --->
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
       	    insert into attackQueue (playerID, attackPlayerID, uunit, swordsman, archers, horseman, macemen, trainedPeasants, turn, status, attackType, costWine, costFood, costGold)
				values (#playerID#, #attackPlayerID#, #send_uunit#, #send_swordsman#, #send_archers#, #send_horseman#, #send_macemen#, #send_trainedPeasants#, #player.turn#, 0, #attack_Type#, #sendWine#, #eatSoldiersFood#, #needGold#)
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			update player set 
				uunit = uunit - #send_uunit#,
				swordsman = swordsman - #send_swordsman#,	
				archers = archers -  #send_archers#,
				horseman = horseman - #send_horseman#,
				macemen = macemen - #send_macemen#,
				trainedPeasants = trainedPeasants - #send_trainedPeasants#,
				gold = gold - #needGold#,
				food = food - #eatSoldiersFood#,
				wine = wine - #sendWine#
			where id = #playerID#
        </cfquery>
		<cfset eflag_message = eflag_message & "<b>Your army is preparing to attack #attackPlayer.name# (#attackPlayerID#).<br>They will reach their destination in 3 months.</b><br>Your soldiers have been paid #numberformat(needGold)# and given #numberFormat(eatSoldiersFood)# food for this expedition.<br>">
		<cfif sendWine gt 0>
			<cfset percentWine = round((sendWine / totalArmy)*100)>
			<cfset eflag_message = eflag_message & "#numberFormat(sendWine)# units of wine will boost army strength by #numberFormat(percentWine)#%<br>">
		</cfif>		
	</cfif>
<cfelseif eflag is "catapult_attack">
	<!--- see if player has that many units --->
	<cfparam name="sendAll" default="0">
	<cfif sendAll is 1>
		<cfset send_catapults = player.catapults>
	<cfelse>
		<cfset send_catapults = val(form.send_catapults)>
	</cfif>
	<cfset attackPlayerID = val(form.attackPlayerID)>
	<cfset attack_type = val(attack_type)>

	<cfquery name="attackPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select killedBy,name,turn,numattacks,lastattack,allianceID,vacationEnd from player where id = #attackPlayerID#
    </cfquery>
	<cfquery name="attacks" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select count(id) as total from attackQueue where playerID = #playerID# and attackType between 10 and 19
    </cfquery>
	
	<cfset attackAlly = false>
	<cfif player.allianceID gt 0 and attackPlayer.allianceID gt 0>
		<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select ally1, ally2, ally3, ally4, ally5 from alliance where id = #player.allianceID#
        </cfquery>
		<cfif alliance.recordcount gt 0>
			<cfif alliance.ally1 is attackPlayer.allianceID or alliance.ally2 is attackPlayer.allianceID or alliance.ally3 is attackPlayer.allianceID or alliance.ally4 is attackPlayer.allianceID or alliance.ally5 is attackPlayer.allianceID>
				<cfset attackAlly = true>
			</cfif>
		</cfif>
	</cfif>
	
	<cfset needWood = send_catapults * 1>
	<cfset needIron = send_catapults * 0.2>
	
	<cfif attackPlayerID is playerID>
		<cfset eflag_message = eflag_message & "Are you nuts? You can't attack yourself!!!">
	<cfelseif attackplayer.vacationEnd is not "" and attackplayer.vacationEnd gt now()>
		<cfset eflag_message = eflag_message & "Cannot attack empires while they are in vacation mode.<br>">		
	<cfelseif attackAlly>
		<cfset eflag_message = eflag_message & "You cannot attack your allies.">
	<cfelseif player.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack under protection.">
	<cfelseif attackPlayer.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack players under protection.">
	<cfelseif attackPlayer.allianceID is player.allianceID and player.allianceID gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack empires in your alliance.">
	<cfelseif attackPlayer.killedBy gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack dead empires.">
	<cfelseif attack_type lt 10 or attack_type gt 12>
		<cfset eflag_message = eflag_message & "Invalid attack type!">
	<cfelseif send_catapults lte 0>
		<cfset eflag_message = eflag_message & "Cannot send negative or 0 catapults!">
	<cfelseif send_catapults gt player.catapults>
		<cfset eflag_message = eflag_message & "You do not have that many catapults.">
	<cfelseif send_catapults gt player.towncenter>
		<cfset eflag_message = eflag_message & "You do not have that many town centers to support your catapults.">
	<cfelseif attackPlayer.recordcount is 0>
		<cfset eflag_message = eflag_message & "Empire No. #attackPlayerID# does not exist.">
	<cfelseif needWood gt player.wood>
		<cfset eflag_message = eflag_message & "You do not have enough wood to send with your catapults<br>(You need #needWood# wood)">
	<cfelseif needIron gt player.iron>
		<cfset eflag_message = eflag_message & "You do not have enough iron to send with your catapults<br>(You need #needIron# iron)">		
	<cfelseif attacks.total gte 1><!--- can have only 1 attack active--->
		<cfset eflag_message = eflag_message & "Your armies are already attacking someone. Please wait for them to come back.">
	<cfelse>
		<!--- ok to send now --->
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
       	    insert into attackQueue (playerID, attackPlayerID, catapults, turn, status, attackType, costWood, costIron)
				values (#playerID#, #attackPlayerID#, #send_catapults#, #player.turn#, 0, #attack_Type#, #needWood#, #needIron#)
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			update player set 
				catapults = catapults - #send_catapults#,
				wood = wood - #needWood#,
				iron = iron - #needIron#
			where id = #playerID#
        </cfquery>
		<cfset eflag_message = eflag_message & "<b>Your catapults are preparing to attack #attackPlayer.name# (#attackPlayerID#).<br>They will reach their destination in 3 turns.</b><br>#NumberFormat(needIron)# iron and #numberFormat(needWood)# wood has been sent for upkeep.<br>">
	</cfif>
<cfelseif eflag is "thief_attack">
	<!--- see if player has that many units --->
	<cfparam name="sendAll" default="0">
	<cfif sendAll is 1>
		<cfset send_thieves = player.thieves>
	<cfelse>
		<cfset send_thieves = val(form.send_thieves)>
	</cfif>
	<cfset attackPlayerID = val(form.attackPlayerID)>
	<cfset attack_type = val(attack_type)>

	<cfquery name="attackPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select killedBy,score,name,turn,numattacks,lastattack,allianceID,vacationEnd from player where id = #attackPlayerID#
    </cfquery>
	<cfquery name="attacks" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select count(id) as total from attackQueue where playerID = #playerID# and attackType between 20 and 29
    </cfquery>
	
	<cfset attackAlly = false>
	<cfif player.allianceID gt 0 and attackPlayer.allianceID gt 0>
		<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select ally1, ally2, ally3, ally4, ally5 from alliance where id = #player.allianceID#
        </cfquery>
		<cfif alliance.recordcount gt 0>
			<cfif alliance.ally1 is attackPlayer.allianceID or alliance.ally2 is attackPlayer.allianceID or alliance.ally3 is attackPlayer.allianceID or alliance.ally4 is attackPlayer.allianceID or alliance.ally5 is attackPlayer.allianceID>
				<cfset attackAlly = true>
			</cfif>
		</cfif>
	</cfif>
	
	
	<cfset needGold = round(send_thieves * thievesA.goldPerTurn) * 6>
	<cfset needFood = round(send_thieves * thievesA.foodEaten) * 6>
	
	<cfif attackPlayerID is playerID>
		<cfset eflag_message = eflag_message & "Are you nuts? You can't attack yourself!!!">
	<cfelseif attackplayer.vacationEnd is not "" and attackplayer.vacationEnd gt now()>
		<cfset eflag_message = eflag_message & "Cannot attack empires while they are in vacation mode.<br>">		
	<cfelseif attackAlly>
		<cfset eflag_message = eflag_message & "You cannot attack your allies.">		
	<cfelseif player.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack under protection.">
	<cfelseif attackPlayer.turn lte 72 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack players under protection.">
	<cfelseif attackPlayer.allianceID is player.allianceID and player.allianceID gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack empires in your alliance.">
	<cfelseif attackPlayer.killedBy gt 0>
		<cfset eflag_message = eflag_message & "Cannot attack dead empires.">
	<cfelseif attack_type lt 20 or attack_type gt 25>
		<cfset eflag_message = eflag_message & "Invalid attack type!">
	<cfelseif send_thieves lte 0>
		<cfset eflag_message = eflag_message & "Cannot send negative or 0 thieves!">
	<cfelseif send_thieves gt player.thieves>
		<cfset eflag_message = eflag_message & "You do not have that many thieves.">
	<cfelseif send_thieves gt player.towncenter>
		<cfset eflag_message = eflag_message & "You do not have that many town centers to support your thieves.">
	<cfelseif attackPlayer.recordcount is 0>
		<cfset eflag_message = eflag_message & "Empire No. #attackPlayerID# does not exist.">
	<cfelseif needGold gt player.gold>
		<cfset eflag_message = eflag_message & "You do not have enough gold to pay your thieves for the attack.<br>(You need #needGold# gold)">
	<cfelseif needFood gt player.food>
		<cfset eflag_message = eflag_message & "You do not have enough food to send with your thieves for the attack.<br>(You need #needFood# food)">		
	<cfelseif attacks.total gte 1><!--- can have only 1 attack active--->
		<cfset eflag_message = eflag_message & "Your armies are already attacking someone. Please wait for them to come back.">
	<cfelseif player.score gt attackPlayer.score * 2 and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack empires that are half as small as you.">
	<cfelseif player.score * 2 lt attackPlayer.score and not deathMatchMode>
		<cfset eflag_message = eflag_message & "Cannot attack empires that are twice as big as you.">
	<cfelse>
		<!--- ok to send now --->
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
       	    insert into attackQueue (playerID, attackPlayerID, thieves, turn, status, attackType, costGold, costFood)
				values (#playerID#, #attackPlayerID#, #send_thieves#, #player.turn#, 0, #attack_Type#, #needGold#, #needFood#)
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			update player set 
				thieves = thieves - #send_thieves#,
				gold = gold - #needGold#,
				food = food - #needFood#
			where id = #playerID#
        </cfquery>
		<cfset eflag_message = eflag_message & "<b>Your thieves are preparing to attack #attackPlayer.name# (#attackPlayerID#).<br>They will reach their destination in 3 months.</b><br>Your theives have been paid #numberFormat(needGold)# and #numberFormat(needFood)# food for this expedition.">
	</cfif>

<cfelseif eflag is "cancel_attack">
	<cfset queueID = val(armyID)>
	<cfquery name="attack" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select attackQueue.*, player.name as attackPlayerName 
		from attackQueue inner join player on attackQueue.attackPlayerID = player.id
		where attackQueue.id = #queueID# and playerID = #playerID#
    </cfquery>
	<cfif attack.recordcount gt 0>
		<cfif attack.status is 0><!--- did not leave the fort yet --->
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set
					uunit = uunit + #attack.uunit#,
					swordsman = swordsman + #attack.swordsman#,
					archers = archers + #attack.archers#,
					horseman = horseman + #attack.horseman#,
					macemen = macemen + #attack.macemen#,
					trainedPeasants = trainedPeasants + #attack.trainedPeasants#,
					catapults = catapults + #attack.catapults#,
					thieves = thieves + #attack.thieves#,
					food = food + #attack.costFood#,
					wine = wine + #attack.costWine#,
					gold = gold + #attack.costGold#,
					wood = wood + #attack.costWood#,
					iron = iron + #attack.costIron#
				where id = #playerID#
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                delete from attackQueue where id = #attack.id#
            </cfquery>
			<cfset eflag_message = eflag_message & "<b>Your army stopped preparing to attack #attack.attackPlayername# (#attack.attackPlayerID#).</b>">
		<cfelseif attack.status is 1 or attack.status is 2><!--- on their way, set status to 4 (returning) --->
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update attackQueue set status = 4 where id = #attack.id#
            </cfquery>
			<cfset eflag_message = eflag_message & "<b>Your army is returning to your empire as you requested and should be back soon.</b>">
		</cfif>
	</cfif>
</cfif>
<cfif deathMatchMode>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<cfif eflag is "startAid">
	<!--- get the amounts --->
	<cfset sendWood = val(Replace(form.sendWood, ",", "", "ALL"))>
	<cfset sendIron = val(Replace(form.sendIron, ",", "", "ALL"))>
	<cfset sendFood = val(Replace(form.sendFood, ",", "", "ALL"))>
	<Cfset sendTools = val(Replace(form.sendTools, ",", "", "ALL"))>
	<cfset sendGold = val(Replace(form.sendGold, ",", "", "ALL"))>
	<cfset sendMaces = val(Replace(form.sendMaces, ",", "", "ALL"))>
	<cfset sendSwords = val(Replace(form.sendSwords, ",", "", "ALL"))>
	<cfset sendBows = val(Replace(form.sendBows, ",", "", "ALL"))>
	<cfset sendHorses = val(Replace(form.sendHorses, ",", "", "ALL"))>
	<cfset toPlayerID = val(sendEmpireNo)>
	<cfset sendOK = true>
	
	<!--- see if already sent to this person in past hour --->
	<cfset sTime = dateAdd("h", -4, now())>
	<cfquery name="aidLog" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select createdOn from aidLog where fromPlayerID = #playerID# and toPlayerID = #toPlayerID# and createdOn >= #sTime#
    </cfquery>
	<cfif aidLog.recordcount gt 0>
		<cfset eflag_message = "You are only allowed to send aid to the same person once every 4 hours. <!--#dateDiff("n", aidlog.createdon, now())#-->">
		<cfset sendOK = false>
	</cfif>
	
	<cfquery name="toPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, name from player where id = #toPlayerID#
    </cfquery>
	<cfif toPlayer.recordcount is 0>
		<cfset eflag_message = "Empire #toPlayerID# not found.">
		<cfset sendOK = false>
	</cfif>
	<cfif sendWood lt 0 or sendWood gt player.wood>
		<cfset eflag_message = "You can only send #player.wood# wood.">
		<cfset sendOK = false>
	</cfif>
	<cfif sendIron lt 0 or sendIron gt player.iron>
		<cfset eflag_message = "You can only send #player.iron# iron.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendFood lt 0 or sendFood gt player.Food>
		<cfset eflag_message = "You can only send #player.Food# Food.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendGold lt 0 or sendGold gt player.Gold>
		<cfset eflag_message = "You can only send #player.Gold# Gold.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendTools lt 0 or sendTools gt player.Tools>
		<cfset eflag_message = "You can only send #player.Tools# Tools.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendMaces lt 0 or sendMaces gt player.maces>
		<cfset eflag_message = "You can only send #player.Maces# Maces.">
		<cfset sendOK = false>		
	</cfif>	
	<cfif sendSwords lt 0 or sendSwords gt player.Swords>
		<cfset eflag_message = "You can only send #player.Swords# Swords.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendBows lt 0 or sendBows gt player.Bows>
		<cfset eflag_message = "You can only send #player.Bows# Bows.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendHorses lt 0 or sendHorses gt player.Horses>
		<cfset eflag_message = "You can only send #player.Horses# Horses.">
		<cfset sendOK = false>		
	</cfif>
	<cfif sendOK>
		<cfset totalSend = sendWood + sendIron + sendFood + sendGold + sendTools + sendSwords + sendBows + sendHorses + sendMaces>
		<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
		<cfset r = player.research9*10>
		<cfset maxTrades = round(maxTrades + maxtrades * (r/100))>
		<cfif maxTrades is 0><cfset maxTrades = townCenterB.maxLocalTrades></cfif>
		<cfset tradesRemaining = maxTrades - player.tradesThisTurn>
		<cfif totalSend is 0>
			<cfset eflag_message = "Cannot send 0 goods.">
		<cfelseif totalSend gt tradesRemaining>
			<cfset eflag_message = "You can send only #tradesRemaining# more goods this month.">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set 
					wood = wood - #sendWood#,
					iron = iron - #sendIron#,
					gold = gold - #sendGold#,
					food = food - #sendFood#,
					tools = tools - #sendTools#,
					swords = swords - #sendSwords#,
					bows = bows - #sendBows#,
					horses = horses - #sendHorses#,
					maces = maces - #sendMaces#,
					tradesThisTurn = tradesThisTurn + #totalSend#
				where id = #playerID#
            </cfquery>		
			<!--- 5% fee --->
			<cfset sendWood = round(sendWood * 0.95)>
			<cfset sendIron = round(sendIron * 0.95)>
			<cfset sendFood = round(sendFood * 0.95)>
			<cfset sendGold = round(sendGold * 0.95)>
			<Cfset sendTools = round(sendTools * 0.95)>
			<cfset sendMaces = round(sendMaces * 0.95)>
			<cfset sendSwords = round(sendSwords * 0.95)>
			<cfset sendBows = round(sendBows * 0.95)>
			<cfset sendHorses = round(sendHorses * 0.95)>
			<cfset cOn = now()>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                insert into transferQueue (fromPlayerID, toPlayerID, wood, iron, food, gold, tools, maces, swords, bows, horses, transferType, turnsRemaining, createdOn)
				values (#playerID#, #toPlayerID#, #sendWood#, #sendIron#, #sendFood#, #sendGold#, #sendTools#, #sendMaces#, #sendSwords#, #sendBows#, #sendHorses#, 1, 3, #cOn#)
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                insert into aidLog (fromPlayerID, toPlayerID, wood, iron, food, gold, tools, maces, swords, bows, horses, createdOn)
				values (#playerID#, #toPlayerID#, #sendWood#, #sendIron#, #sendFood#, #sendGold#, #sendTools#, #sendMaces#, #sendSwords#, #sendBows#, #sendHorses#, #cOn#)
            </cfquery>
			
			<cfset eflag_message = "Transport to #toPlayer.name# has been dispatched. <br>
			5% fee has been assessed by merchants.<br>
			Caravans will reach their destination in 3 turns.">
		</cfif>
	</cfif>	
<cfelseif eflag is "cancelAid">
	<cfset aidID = val(aidID)>
	<cfquery name="aid" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from transferQueue where id = #aidID# and fromPlayerID = #playerID# and transferType = 1
    </cfquery>
	<cfif aid.recordcount gt 0>
		<cfset cancelTime = dateAdd("n", -15, now())>
		<cfif aid.turnsRemaining is not 3 or aid.createdOn lt cancelTime>
			<cfset eflag_message = eflag_message & "This aid cannot be cancelled anymore.<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set
					wood = wood + #aid.wood#,
					iron = iron + #aid.iron#,
					food = food + #aid.food#,
					gold = gold + #aid.gold#,
					tools = tools + #aid.tools#,
					maces = maces + #aid.maces#,
					swords = swords + #aid.swords#,
					bows = bows + #aid.bows#,
					horses = horses + #aid.horses#
				where id = #playerID#
            </cfquery>
			<cfset eflag_message = eflag_message & "Aid to empire ## #aid.toPlayerID# has been cancelled.<br>">			

			<cfquery name="aidLog" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            	delete from aidLog where fromPlayerID = #aid.fromPlayerID# and toPlayerID = #aid.toPlayerID# and
					createdOn = #createODBCDateTime(aid.createdOn)#
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                delete from transferQueue where id = #aid.id#
            </cfquery>
			
		</cfif>
	</cfif>
</cfif>
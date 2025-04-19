<cfif deathMatchMode>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<cfif eflag is "sellOnPubMarket">
	<!--- get the amounts --->
	<cfset sellWood = val(Replace(form.sellWood, ",", "", "ALL"))>
	<cfset sellIron = val(Replace(form.sellIron, ",", "", "ALL"))>
	<cfset sellFood = val(Replace(form.sellFood, ",", "", "ALL"))>
	<Cfset sellTools = val(Replace(form.sellTools, ",", "", "ALL"))>
	<cfset sellMaces = val(Replace(form.sellMaces, ",", "", "ALL"))>
	<cfset sellSwords = val(Replace(form.sellSwords, ",", "", "ALL"))>
	<cfset sellBows = val(Replace(form.sellBows, ",", "", "ALL"))>
	<cfset sellHorses = val(Replace(form.sellHorses, ",", "", "ALL"))>

	<cfset priceWood = val(Replace(form.priceWood, ",", "", "ALL"))>
	<cfset priceIron = val(Replace(form.priceIron, ",", "", "ALL"))>
	<cfset priceFood = val(Replace(form.priceFood, ",", "", "ALL"))>
	<cfset priceTools = val(Replace(form.priceTools, ",", "", "ALL"))>
	<cfset priceMaces = val(Replace(form.priceMaces, ",", "", "ALL"))>
	<cfset priceSwords = val(Replace(form.priceSwords, ",", "", "ALL"))>
	<cfset priceBows = val(Replace(form.priceBows, ",", "", "ALL"))>
	<cfset priceHorses = val(Replace(form.priceHorses, ",", "", "ALL"))>						
	
	<cfset sendOK = true>
	<cfloop list="wood,food,iron,tools,maces,swords,bows,horses" index="i">
		<cfset qty = evaluate("sell#i#")>
		<cfset qtyPlayer = evaluate("player.#i#")>
		<cfset sellPrice = evaluate("price#i#")>
		<cfset minPrice = evaluate("#i#minPrice")>
		<cfset maxPrice = evaluate("#i#maxPrice")>
		<cfif qty lt 0>
			<cfset eflag_message = eflag_message & "Cannot sell negative #i#.<br>">
			<cfset sendOK = false>
		<cfelseif qty gt 0 and qty gt qtyPlayer>		
			<cfset eflag_message = eflag_message & "You don't have that many #i#. You only have #qtyPlayer#.<br>">
			<cfset sendOK = false>
		<cfelseif qty gt 0 and sellPrice lt minPrice>
			<cfset eflag_message = eflag_message & "The minimum sell price for #i# is #minPrice# gold.<br>">
			<cfset sendOK = false>
		<cfelseif qty gt 0 and sellPrice gt maxPrice>
			<cfset eflag_message = eflag_message & "The maximum sell price for #i# is #maxPrice# gold.<br>">
			<cfset sendOK = false>
		</cfif>
	</cfloop>
	
	
	<cfif sendOK>
		<cfset totalSell = sellWood + sellIron + sellFood + sellTools + sellSwords + sellBows + sellHorses + sellMaces>
		<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
		<cfset r = player.research9*10>
		<cfset maxTrades = round(maxTrades + maxtrades * (r/100))>		
		<cfif maxTrades is 0><cfset maxTrades = townCenterB.maxLocalTrades></cfif>
		<cfset tradesRemaining = maxTrades - player.tradesThisTurn>
		<cfif totalSell is 0>
			<cfset eflag_message = eflag_message & "Cannot sell 0 goods.<br>">
		<cfelseif totalSell gt tradesRemaining>
			<cfset eflag_message = eflag_message & "You can sell only #tradesRemaining# more goods this month.<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set 
					wood = wood - #sellWood#,
					iron = iron - #sellIron#,
					food = food - #sellFood#,
					tools = tools - #sellTools#,
					swords = swords - #sellSwords#,
					bows = bows - #sellBows#,
					horses = horses - #sellHorses#,
					maces = maces - #sellMaces#,
					tradesThisTurn = tradesThisTurn + #totalsell#
				where id = #playerID#
            </cfquery>		
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                insert into transferQueue (fromPlayerID, toPlayerID, wood, iron, food, tools, maces,  swords, bows, horses, transferType, turnsRemaining, woodPrice, ironPrice, foodPrice, toolsPrice, macesPrice, swordsPrice, bowsPrice, horsesPrice)
				values (#playerID#, 0, #sellWood#, #sellIron#, #sellFood#, #sellTools#, #sellMaces#, #sellSwords#, #sellBows#, #sellHorses#, 0, 3, #priceWood#, #priceIron#, #priceFood#, #priceTools#, #priceMaces#, #priceSwords#, #priceBows#, #priceHorses#)
            </cfquery>
			<cfset eflag_message = eflag_message & "Goods have been sent to the public market. They will reach the market in 3 months.<br>">
			<cfset totalValue = sellWood * priceWood + sellIron * priceIron + sellFood * priceFood + sellTools * priceTools + sellSwords * priceSwords + sellBows * priceBows + sellHorses * priceHorses + sellMaces * priceMaces>
			<cfset eflag_message = eflag_message & "Total value of the transport is #NumberFormat(totalValue)#.<br>">
		</cfif>
	</cfif>	
<cfelseif eflag is "takeFromPubMarket">
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from transferQueue where fromPlayeriD = #playerID# and id = #val(tid)#
    </cfquery>
	<cfloop query="tq">
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set 
				wood = wood + #round(tq.wood * 0.9)#,
				iron = iron + #round(tq.iron * 0.9)#,
				food = food + #round(tq.food * 0.9)#,
				tools = tools + #round(tq.tools * 0.9)#,
				swords = swords + #round(tq.swords * 0.9)#,
				bows = bows + #round(tq.bows * 0.9)#,
				horses = horses + #round(tq.horses * 0.9)#,
				maces = maces + #round(tq.maces * 0.9)#
			where id = #playerID#
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            delete from transferQueue where id = #tq.id#
        </cfquery>
	</cfloop>
<cfelseif eflag is "buyFromPubMarket">
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select *, #good# as stuff, #good#Price as stuffPrice from transferQueue 
		where fromPlayerID <> #playerID# and transferType = 0 and turnsRemaining = 0 and #good#Price > 0 and #good# > 0
		order by #good#Price
    </cfquery>
	<cfset iHaveGold = player.gold>
	<cfloop query="tq">
		<cfparam name="qty#tq.id#" default="0">
		<cfset qty = int(val(evaluate("qty#tq.id#")))>
		<cfif qty gt 0>
			<!--- see if that many are avilable --->
			<cfif qty lt 0>
				<cfset eflag_message = eflag_message & "Cannot buy negative quantity.<br>">
			<cfelseif qty gt tq.stuff>
				<cfset eflag_message = eflag_message & "You tried to buy #qty# #good#, but there are only #tq.stuff# available.<br>">
			<cfelseif qty * tq.stuffPrice gt iHaveGold>
				<cfset eflag_message = eflag_message & "You do not enough gold to buy #qty# #good#. You need #val(qty*tq.stuffPrice)# gold.<br>">
			<cfelse><!--- buy goods --->
				<cfset useGold = qty * tq.stuffPrice>
				<cfset eflag_message = eflag_message & "#numberformat(qty)# #good# bought for #numberformat(useGold)#. The caravans with #good# will reach your empire in 3 months.<br>">
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update player set 
						gold = gold - #useGold#
					where id = #playerID#
                </cfquery>
				<cfset iHaveGold = iHaveGold - useGold>
				
				<cfset remainGoods = tq.wood + tq.iron + tq.food + tq.tools + tq.maces + tq.swords + tq.bows + tq.horses - qty>
				<cfif remainGoods gt 0>
					<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
						update transferQueue set #good# = #good# - #qty# where id = #tq.id#
					</cfquery>
				<cfelse>
					<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        delete from transferQueue where id = #tq.id#
                    </cfquery>
				</cfif>
				
				<!--- now give gold to the other player --->
				<cfset getGold = round(useGold * 0.95)>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update player set gold = gold + #getGold#, hasMainNews = 1 where id = #tq.fromPlayerID#
                </cfquery>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			        insert into playerMessage (fromPlayerID, toPlayerID, fromPlayerName, toPlayerName, message, viewed, createdOn, messageType)
					values (#playerID#, #tq.fromPlayerID#, '#player.name#', '', 'On #theDate# you sold #numberFormat(qty)# #good# for #NumberFormat(getGold)#', 0, #CreateODBCDateTime(Now())#, 1)
			    </cfquery>
				
				<!--- see if there is a caravan that is just departed --->
				<cfquery name="check" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                	select id from transferQueue where toPlayerID = #playerID# and transferType = 2 and turnsRemaining = 3
                </cfquery>
				<cfif check.recordcount gt 0>
					<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        update transferQueue set #good# = #good# + #qty# where id = #check.id#
                    </cfquery>
				<cfelse>
					<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    insert into transferQueue (toPlayerID, #good#, transferType, turnsRemaining)
						values (#playerID#, #qty#, 2, 3)
        	        </cfquery>
				</cfif>
			</cfif>
		</cfif>	
	</cfloop>	
<cfelseif eflag is "changePrices">
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from transferQueue where id = #tqID# and fromPlayerID = #playerID#
    </cfquery>
	<cfif tq.recordcount gt 0>
		<!--- loop thru the goods --->
		<cfloop list="wood,food,iron,tools,maces,swords,bows,horses" index="i">
			<cfset price = evaluate("tq.#i#price")>
			<cfparam name="price#i#" default="#price#">
			<Cfset newPrice = evaluate("price#I#")>
			<cfset newPrice = val(replace(newPrice, ",", "", "ALL"))>
			<cfset minPrice = evaluate("#i#minPrice")>
			<cfset maxPrice = evaluate("#i#maxPrice")>
			<cfif newPrice lt minPrice and newPrice is not 0>
				<cfset eflag_message = eflag_message & "Cannot change price for #i# to #newPrice#. Minimum sell price is #minPrice#.<br>">
			<cfelseif newPrice gt maxPrice and newPrice is not 0>
				<cfset eflag_message = eflag_message & "Cannot change price for #i# to #newPrice#. Maximum sell price is #maxPrice#.<br>">
			<cfelseif price is not newPrice>
				<cfset eflag_message = eflag_message & "Changed price for #i# to #newPrice#<br>">
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update transferQueue
						set #i#price = #newPrice#
					where id = #tq.id#
                </cfquery>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

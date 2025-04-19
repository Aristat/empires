<cfif eflag is "localbuy">
	<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
	<cfif maxTrades is 0><cfset maxTrades = 50></cfif>
	<cfset r = player.research9*10>
	<cfset maxTrades = round(maxTrades + maxtrades * (r/100))>	
	<cfset tradesRemaining = maxTrades - player.tradesThisTurn>

	<cfset extra = 1>
	<cfset s = player.score>
	<cfloop condition="#s# gt 100000">
		<cfset extra = extra + localTradeMulti>
		<cfset s = s / 2>
	</cfloop>
	<cfset woodPrice = round(session.localWoodBuyPrice * extra)>
	<cfset foodPrice = round(session.localFoodBuyPrice * extra)>
	<cfset ironPrice = round(session.localIronBuyPrice * extra)>
	<cfset toolPrice = round(session.localToolsBuyPrice * extra)>
	
	<cfset buyWood = val(replace(form.buyWood, ",", "", "ALL"))>
	<cfset buyIron = val(replace(form.buyIron, ",", "", "ALL"))>
	<cfset buyFood = val(replace(form.buyFood, ",", "", "ALL"))>
	<cfset buyTools = val(replace(form.buyTools, ",", "", "ALL"))>
	
	<cfset totalNewTrades = buyWood + buyIron + buyFood + buyTools>
	<cfset needGold = buyWood * woodPrice + buyFood * foodPrice + buyIron * ironPrice + buyTools * toolPrice>	
	
	<cfif buyWood lt 0 or buyIron lt 0 or buyFood lt 0 or buyTools lt 0>
		<cfset eflag_message = eflag_message & "Cannot buy negative amounts.">
	<cfelseif totalNewTrades gt tradesRemaining>
		<cfset eflag_message = eflag_message & "You can only trade #numberFormat(tradesRemaining)# more goods this month.">
	<cfelseif needGold gt player.gold>
		<cfset eflag_message = eflag_message & "You do not have enough gold to buy those good (you need #numberFormat(needGold)# gold)">
	<cfelse>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set 
				wood = wood + #buyWood#,
				food = food + #buyFood#,
				iron = iron + #buyIron#,
				gold = gold - #needGold#,
				tools = tools + #buyTools#,
				tradesThisTurn = tradesThisTurn + #totalNewTrades#
			where id = #playerID#
        </cfquery>
		<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            select * from player where id = #playerID#
        </cfquery>
		<cfif buyWood gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(buyWood)# wood bought for #NumberFormat(val(buyWood*woodPrice))# gold.<br>">
		</cfif>
		<cfif buyFood gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(buyFood)# food bought for #NumberFormat(val(buyFood*foodPrice))# gold.<br>">
		</cfif>
		<cfif buyIron gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(buyIron)# iron bought for #NumberFormat(val(buyIron*ironPrice))# gold.<br>">
		</cfif>
		<cfif buyTools gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(buyTools)# tools bought for #NumberFormat(val(buyTools*toolPrice))# gold.<br>">
		</cfif>
		<cfset eflag_message = eflag_message & "You spend a total of #numberformat(needGold)# gold.<br>">
	</cfif>
<cfelseif eflag is "localsell">
	<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
	<cfif maxTrades is 0><cfset maxTrades = 50></cfif>	
	<cfset r = player.research9*10>
	<cfset maxTrades = round(maxTrades + maxtrades * (r/100))>	

		
		
	<cfset tradesRemaining = maxTrades - player.tradesThisTurn>

	<cfset extra = 1>
	<cfset s = player.score>
	<cfloop condition="#s# gt 100000">
		<cfset extra = extra + localTradeMulti>
		<cfset s = s / 2>
	</cfloop>

	<cfset woodPrice = round(session.localWoodSellPrice * (1/extra))>
	<cfset foodPrice = round(session.localFoodSellPrice * (1/extra))>
	<cfset ironPrice = round(session.localIronSellPrice * (1/extra))>
	<cfset toolPrice = round(session.localToolsSellPrice * (1/extra))>

	<cfset sellWood = val(replace(form.sellWood, ",", "", "ALL"))>
	<cfset sellIron = val(replace(form.sellIron, ",", "", "ALL"))>
	<cfset sellFood = val(replace(form.sellFood, ",", "", "ALL"))>
	<cfset sellTools = val(replace(form.sellTools, ",", "", "ALL"))>

	<cfset totalNewTrades = sellWood + sellIron + sellFood + sellTools>
	
	<cfif sellWood lt 0 or sellIron lt 0 or sellFood lt 0 or sellTools lt 0>
		<cfset eflag_message = eflag_message & "Cannot sell negative amounts.<br>">
	<cfelseif totalNewTrades gt tradesRemaining>
		<cfset eflag_message = eflag_message & "You can only trade #numberFormat(tradesRemaining)# more goods this turn.<br>">
	<cfelseif sellWood gt player.wood>
		<cfset eflag_message = eflag_message & "You do not have that much wood to sell.<br>">
	<cfelseif sellFood gt player.food>
		<cfset eflag_message = eflag_message & "You do not have that much food to sell.<br>">
	<cfelseif sellIron gt player.iron>
		<cfset eflag_message = eflag_message & "You do not have that much iron to sell.<br>">
	<cfelseif sellTools gt player.tools>
		<cfset eflag_message = eflag_message & "You do not have that many tools to sell.<br>">
	<cfelse>
		<cfset getGold = sellWood * woodPrice + sellFood * foodPrice + sellIron * ironPrice + sellTools * toolPrice>	
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set 
				wood = wood - #sellWood#,
				food = food - #sellFood#,
				iron = iron - #sellIron#,
				tools = tools - #sellTools#,
				gold = gold + #getGold#,
				tradesThisTurn = tradesThisTurn + #totalNewTrades#
			where id = #playerID#
        </cfquery>

		<cfif sellWood gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(sellWood)# wood sold for #NumberFormat(val(sellWood*woodPrice))# gold.<br>">
		</cfif>
		<cfif sellFood gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(sellFood)# food sold for #NumberFormat(val(sellFood*foodPrice))# gold.<br>">
		</cfif>
		<cfif sellIron gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(sellIron)# iron sold for #NumberFormat(val(sellIron*ironPrice))# gold.<br>">
		</cfif>
		<cfif sellTools gt 0>
			<cfset eflag_message = eflag_message & "#numberFormat(sellTools)# tools sold for #NumberFormat(val(sellTools*toolPrice))# gold.<br>">
		</cfif>
		<cfset eflag_message = eflag_message & "You made a total of #numberFormat(getGold)# gold.<br>">
		
	</cfif>
<cfelseif eflag is "updateautotrade">

	<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
	<cfif maxTrades is 0><cfset maxTrades = 50></cfif>	
	<cfset r = player.research9*10>
	<cfset maxTrades = round(maxTrades + maxtrades * (r/100))>	
		
	<cfset bFood = val(replace(form.autoBuyFood, ",", "", "ALL"))>
	<cfset bWood = val(replace(form.autoBuyWood, ",", "", "ALL"))>
	<Cfset bIron = val(replace(form.autoBuyIron, ",", "", "ALL"))>
	<cfset bTools = val(replace(form.autoBuyTools, ",", "", "ALL"))>
	<cfset sFood = val(replace(form.autoSellFood, ",", "", "ALL"))>
	<cfset sWood = val(replace(form.autoSellWood, ",", "", "ALL"))>
	<cfset sIron = val(replace(form.autoSellIron, ",", "", "ALL"))>
	<cfset sTools = val(replace(form.autoSellTools, ",", "", "ALL"))>
	<cfif bFood lt 0 or bWood lt 0 or bIron lt 0 or bTools lt 0 or sFood lt 0 or sWood lt 0 or sIron lt 0 or sTools lt 0>
		<cfset eflag_message = eflag_message & "Cannot sell or buy negative numbers.<br>">
	<cfelseif (bFood + bIron + bWood + bTools + sFood + sWood + sIron + sTools) gt maxTrades>
		<cfset eflag_message = eflag_message & "You can only trade up to #numberFormat(maxTrades)# goods each month.<br>">
	<cfelse>

		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				autoBuyWood = #bWood#,
				autoSellWood = #sWood#,
				autoBuyIron = #bIron#,
				autoSellIron = #sIron#,
				autoBuyFood = #bFood#,
				autoSellFood = #sFood#,
				autoBuyTools = #bTools#,
				autoSellTools = #sTools#
			where id = #playerID#
        </cfquery>
	</cfif>
</cfif>
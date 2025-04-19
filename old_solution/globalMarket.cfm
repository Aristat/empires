<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfif deathMatchMode>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>


<cfparam name="mType" default="sell">

<cfif mType is "sell"><!--- selling --->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Global Market: Sell</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('trade')">Help</a></td>
</tr>
</table>

<font face="verdana" size=2>
You can send goods to the public market.<br>
You need market places to send goods.<br>
There is 5% fee after you sell the goods.
<br>
<cfset maxTrades = player.market * townCenterB.maxLocalTrades>
<cfset r = player.research9*10>
<cfset maxTrades = round(maxTrades + maxTrades * (r / 100))>
<cfif maxTrades is 0><cfset maxTrades = townCenterB.maxLocalTrades></cfif>
<cfset tradesRemaining = maxTrades - player.tradesThisTurn>

Your markets allow you to send <cfoutput>#NumberFormat(maxTrades)#</cfoutput> goods each month, <br>
<cfif tradesRemaining is 0><font color=red></cfif>out of which <cfoutput>#NumberFormat(tradesRemaining)#</cfoutput> are still available.
</font>
<br>
<br>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<form action="index.cfm" method="post">
<input type="hidden" name="eflag" value="sellOnPubMarket">
<input type="hidden" name="page" value="globalMarket">
<input type="hidden" name="mtype" value="sell">
<tr>
	<td class="HEADER">&nbsp;</td>
	<td class="HEADER">You Have</td>
	<td class="HEADER">Sell Amount</td>
	<td class="HEADER">Price <font size=1>(per unit)</td>	
	<td class="HEADER">Min Price</td>
	<td class="HEADER">Max Price</td>
</tr>
<cfoutput>
<tr>
	<td>Wood</td>
	<td align="right">#NumberFormat(player.wood)#</td>
	<td><input type="Text" name="sellWood" size="8"></td>
	<td><input type="Text" name="priceWood" size="8"></td>	
	<td align="right">#numberFormat(woodMinPrice)#</td>
	<td align="right">#numberFormat(woodMaxPrice)#</td>
</tr>
<tr>
	<td>Food</td>
	<td align="right">#NumberFormat(player.food)#</td>
	<td><input type="Text" name="sellFood" size="8"></td>
	<td><input type="Text" name="priceFood" size="8"></td>	
	<td align="right">#numberFormat(foodMinPrice)#</td>
	<td align="right">#numberFormat(foodMaxPrice)#</td>
	
</tr>
<tr>
	<td>Iron</td>
	<td align="right">#NumberFormat(player.iron)#</td>
	<td><input type="Text" name="sellIron" size="8"></td>
	<td><input type="Text" name="priceIron" size="8"></td>	
	<td align="right">#numberFormat(ironMinPrice)#</td>
	<td align="right">#numberFormat(ironMaxPrice)#</td>	
</tr>
<tr>
	<td>Tools</td>
	<td align="right">#NumberFormat(player.tools)#</td>
	<td><input type="Text" name="sellTools" size="8"></td>
	<td><input type="Text" name="priceTools" size="8"></td>	
	<td align="right">#numberFormat(toolsMinPrice)#</td>
	<td align="right">#numberFormat(toolsMaxPrice)#</td>
	
</tr>
<tr>
	<td>Maces</td>
	<td align="right">#NumberFormat(player.maces)#</td>
	<td><input type="Text" name="sellMaces" size="8"></td>
	<td><input type="Text" name="priceMaces" size="8"></td>	
	<td align="right">#numberFormat(macesMinPrice)#</td>
	<td align="right">#numberFormat(macesMaxPrice)#</td>
	
</tr>
<tr>
	<td>Swords</td>
	<td align="right">#NumberFormat(player.swords)#</td>
	<td><input type="Text" name="sellSwords" size="8"></td>
	<td><input type="Text" name="priceSwords" size="8"></td>	
	<td align="right">#numberFormat(swordsMinPrice)#</td>
	<td align="right">#numberFormat(swordsMaxPrice)#</td>
	
</tr>
<tr>
	<td>Bows</td>
	<td align="right">#NumberFormat(player.bows)#</td>
	<td><input type="Text" name="sellBows" size="8"></td>
	<td><input type="Text" name="priceBows" size="8"></td>	
	<td align="right">#numberFormat(bowsMinPrice)#</td>
	<td align="right">#numberFormat(bowsMaxPrice)#</td>

</tr>
<tr>
	<td>Horses</td>
	<td align="right">#NumberFormat(player.horses)#</td>
	<td><input type="Text" name="sellHorses" size="8"></td>
	<td><input type="Text" name="priceHorses" size="8"></td>	
	<td align="right">#numberFormat(bowsMinPrice)#</td>
	<td align="right">#numberFormat(bowsMaxPrice)#</td>
	
</tr>
<tr>
	<td class="HEADER" colspan="4" align="right"><input type="Submit" value="    Sell    "></td>
	<td class="HEADER" colspan="2">&nbsp;</td>
</tr>
</form>
</cfoutput>
</table>
<br>
<br>
<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select transferQueue.*
	from transferQueue 
	where fromPlayerID = #playerID# and transferType = 0
	order by turnsRemaining desc, transferQueue.id
</cfquery>
<cfif tq.recordcount gt 0>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr>
	<td class="HEADER">Dispatched Caravans:</td>
</tr>
<cfoutput query="tq">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="globalMarket">
<input type="hidden" name="mtype" value="sell">
<input type="hidden" name="eflag" value="changePrices">
<input type="hidden" name="tqID" value="#tq.id#">
<tr>
	<td><font face="verdana" size=2>
	<cfif tq.turnsRemaining gt 0>
	Caravans departed with:<br>
	<cfloop list="wood,food,iron,gold,tools,swords,bows,horses" index="good">
		<cfset qty = evaluate("tq.#good#")>
		<cfif qty gt 0>#numberFormat(qty)# #good#<br></cfif>
	</cfloop>
	will reach their
	destination in #tq.turnsRemaining# turns.
	<cfelse>
	You have:<br>
	<cfloop list="wood,food,iron,tools,maces,swords,bows,horses" index="i">
		<cfset qty = evaluate("tq.#i#")>
		<cfif qty gt 0>#numberFormat(qty)# #i# for <input type="Text" name="price#i#" value="#evaluate("tq.#i#price")#" size=4 style="font-size:10px"> gold each<br></cfif>		
	</cfloop>
	placed on the public market.
	<br>
	<input type="Submit" value="Change Prices" style="font-size:10px"><br>
	<font face="verdana" size=1><a href="index.cfm?page=globalMarket&mtype=sell&eflag=takeFromPubMarket&tid=#tq.id#">Withdraw from market</a>
	There is a 10% withdrawal fee.
	</font>
	</cfif>
</tr>
</form>
</cfoutput>
</table>
</cfif>
<cfelse><!--- buying --->

<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Global Market: Buy</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('trade')">Help</a></td>
</tr>
</table>

	<font face="verdana" size=2>
	Buy: 
	<a href="#BUYWOOD">Wood</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYFOOD">Food</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYIRON">Iron</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYTOOLS">Tools</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYMACES">Maces</a>	
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYSWORDS">Swords</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYBOWS">Bows</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="#BUYHORSES">Horses</a>
	
	<cfoutput>
	<cfloop list="Wood,Food,Iron,Tools,Maces,Swords,Bows,Horses" index="good">	
	<br>
	<br>
	<a name="BUY#UCase(good)#"><b>Buy #good#</b> (You have #NumberFormat(Evaluate("player.#good#"))#)</a>
	<br>
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select top 10 id, #good# as stuff, #good#Price as stuffPrice, fromPlayerID from transferQueue 
		where turnsRemaining = 0 and #good#Price > 0 and #good# > 0
		order by #good#Price, stuff desc
    </cfquery>
	<cfif tq.recordcount is 0>
		<font face="verdana" size=2 color=red>There is no #good# available to buy.</font>
	<cfelse>
		<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
		<form action="index.cfm" method="post">
		<input type="hidden" name="page" value="globalMarket">
		<input type="hidden" name="mType" value="buy">
		<input type="hidden" name="eflag" value="buyFromPubMarket">
		<input type="hidden" name="good" value="#good#">
        <tr>
			<td class="HEADER">Available</td>
			<td class="HEADER">You can buy</td>
			<td class="HEADER">Price <font size=1>(Per Unit)</td>
			<td class="HEADER">Buy Qty.</td>
		</tr>
		<cfloop query="tq">
		<tr>
			<cfset canAfford = fix(player.gold / tq.stuffPrice)>
			<cfif canAfford gt tq.stuff><cfset canAfford = tq.stuff></cfif>
			<td>#NumberFormat(tq.stuff)#</td>
			<td>#NumberFormat(canAfford)#</td>
			<td>#NumberFormat(tq.stuffPrice)#</td>
			<cfif tq.fromPlayerID is playerID>
			<td>Yours</td>
			<Cfelse>
			<td><input type="Text" size="8" name="qty#tq.id#" style="font-size:xx-small"></td>
			</cfif>
		</tr>		
		</cfloop>
		<tr>
			<td class="HEADER" colspan="4" align="right">
			<cfif tq.recordcount is 10><font size=1>Displaying 10 least expensive&nbsp;&nbsp;</cfif>
			<input type="Submit" value="Buy #good#" style="font-size:xx-small"></td>
		</tr>
		</form>
        </table>
	</cfif>
	</cfloop>
	</font>
	
	<br>
	<cfquery name="tq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		select transferQueue.*
		from transferQueue 
		where toPlayerID = #playerID# and transferType = 2
		order by turnsRemaining desc, transferQueue.id
	</cfquery>
	<cfif tq.recordcount gt 0>
	<br>
	<br>
	<table border="1" cellpadding="1" cellspacing="0">
	<tr>
		<td class="HEADER">Incoming Caravans:</td>
	</tr>
	<cfloop query="tq">
	<tr>
		<td><font face="verdana" size=2>
		Transport with
		#tq.wood# wood, #tq.food# food, #tq.iron# iron, #tq.gold# gold, #tq.tools# tools, #tq.maces# maces,
		#tq.swords# swords, #tq.bows# bows and #tq.horses# horses will reach your empire
		in #tq.turnsRemaining# turns.
		</font>
	</tr>
	</cfloop>
	</table>
	</cfif>	
	
	</cfoutput>	
</cfif>


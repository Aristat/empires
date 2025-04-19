<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Local Trade</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('trade')">Help</a></td>
</tr>
</table>

<font face=verdana size=2>
<center>
Local trade lets you trade small amount of neccessary goods between your people.<br>
Number of goods traded depends on how many markets you have.<br>
<br>
You have traded <cfoutput>#numberFormat(player.tradesThisTurn)#</cfoutput> goods this turn<br>
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

<cfset woodBuyPrice = round(session.localWoodBuyPrice * extra)>
<cfset foodBuyPrice = round(session.localFoodBuyPrice * extra)>
<cfset ironBuyPrice = round(session.localIronBuyPrice * extra)>
<cfset toolBuyPrice = round(session.localToolsBuyPrice * extra)>
<cfset woodSellPrice = round(session.localWoodSellPrice * (1.0/extra))>
<cfset foodSellPrice = round(session.localFoodSellPrice * (1.0/extra))>
<cfset ironSellPrice = round(session.localIronSellPrice * (1.0/extra))>
<cfset toolSellPrice = round(session.localToolsSellPrice * (1.0/extra))>


<cfif tradesRemaining gt 0>
	and you can still trade <cfoutput>#tradesRemaining#</cfoutput> goods this turn.

	<br>
	<table border=1 cellspacing=0 cellpadding=2>
	<tr>
		<td bgcolor="darkslategray">&nbsp;</td>
		<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Wood</b></font><font face=verdana size=1><br>(You have <cfoutput>#numberformat(player.wood)#)</cfoutput></font></td>
		<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Food</b></font><font face=verdana size=1><br>(You have <cfoutput>#numberformat(player.food)#)</cfoutput></font></td>
		<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Iron</b></font><font face=verdana size=1><br>(You have <cfoutput>#numberformat(player.iron)#)</cfoutput></font></td>
		<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Tools</b></font><font face=verdana size=1><br>(You have <cfoutput>#numberformat(player.tools)#)</cfoutput></font></td>		
		<td bgcolor="darkslategray">&nbsp;</td>
	</tr>
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="localtrade">
	<input type="hidden" name="eflag" value="localbuy">
    <tr>
		<td><font face=verdana size=2>Buy</font></td>
		<td><input type="text" size="3" maxlength="10" name="buyWood" value="0"><font face=verdana size=1><cfoutput>#woodBuyPrice#</cfoutput> gold each</font></td>
		<td><input type="text" size="3" maxlength="10" name="buyFood" value="0"><font face=verdana size=1><cfoutput>#foodBuyPrice#</cfoutput> gold each</font></td>
		<td><input type="text" size="3" maxlength="10" name="buyIron" value="0"><font face=verdana size=1><cfoutput>#ironBuyPrice#</cfoutput> gold each</font></td>				
		<td><input type="text" size="3" maxlength="10" name="buyTools" value="0"><font face=verdana size=1><cfoutput>#toolBuyPrice#</cfoutput> gold each</font></td>						
		<td><input type="Submit" value="Buy"></td>
	</tr>
	</form>
	<tr><td colspan="6" bgcolor="darkslategray" height="5"></td></tr>		
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="localtrade">
	<input type="hidden" name="eflag" value="localSell">
    <tr>
	
		<td><font face=verdana size=2>Sell</font></td>
		<td><input type="text" size="3" maxlength="10" name="SellWood" value="0"><font face=verdana size=1><cfoutput>#woodSellPrice#</cfoutput> gold each</font></td>
		<td><input type="text" size="3" maxlength="10" name="SellFood" value="0"><font face=verdana size=1><cfoutput>#foodSellPrice#</cfoutput> gold each</font></td>
		<td><input type="text" size="3" maxlength="10" name="SellIron" value="0"><font face=verdana size=1><cfoutput>#ironSellPrice#</cfoutput> gold each</font></td>				
		<td><input type="text" size="3" maxlength="10" name="SellTools" value="0"><font face=verdana size=1><cfoutput>#toolSellPrice#</cfoutput> gold each</font></td>						
		<td><input type="Submit" value="Sell"></td>
	</tr>
	</form>
	
	<tr><td colspan="6" bgcolor="darkslategray" height="5"></td></tr>	
    </table>	
<cfelse>
	and you already sold maximum amount available.
</cfif>

<br>
<br>
<font face="verdana" size=3><b>Automatic Trade</b></font>
<br>
<font face="verdana" size=2>
You might also automate your local trade and create automatic trades.<br>
Those trades will occur each time you end your turn.<br>
Maximum number of goods you can autotrade is the same <br>
as number of goods you can trade normaly (<cfoutput>#numberFormat(maxtrades)#</cfoutput>).<br>
<cfset totalAutoTrade = player.autoBuyWood + player.autoBuyFood + player.autoBuyIron + player.autoBuyTools
	+ player.autoSellWood + player.autoSellFood + player.autoSellIron + player.autoSellTools>
<cfset remAutoTrade = maxTrades - totalAutoTrade>
You are currently auto trading <cfoutput>#NumberFormat(totalAutoTrade)#</cfoutput> goods <br />
and you can auto trade
<cfoutput>#numberFormat(remAutoTrade)#</cfoutput> more goods.
</font>
<table border=1 cellpadding=2 cellspacing=0>
<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="localtrade">
	<input type="hidden" name="eflag" value="updateautotrade">

<tr>
<td bgcolor="darkslategray"><font face="verdana" size=2 color="White">Type</font></td>
<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Wood</b></font></td>
<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Food</b></font></td>
<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Iron</b></font></td>
<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Tools</b></font></td>		
<td align="center" bgcolor="darkslategray"><font face=verdana size=2 color="White"><b>Gold</b></font></td>		
</tr>
<cfoutput>
<tr>
	<td nowrap><font face="verdana" size=2>Auto Buy</font></td>
	<td><input type="Text" name="autoBuyWood" value="#NumberFormat(player.autoBuyWood)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoBuyFood" value="#NumberFormat(player.autoBuyFood)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoBuyIron" value="#NumberFormat(player.autoBuyIron)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoBuyTools" value="#NumberFormat(player.autoBuyTools)#" size="10" maxlength="12"></td>
	<cfset useGold = player.autoBuyWood * woodBuyPrice + player.autoBuyFood * foodBuyPrice +
					 player.autoBuyIron * ironBuyPrice + player.autoBuyTools * toolBuyPrice>
	<td><font face="verdana" size=2><cfif useGold gt 0>-</cfif>#numberformat(useGold)#</font></td>
</tr>
<tr><td colspan="6" bgcolor="darkslategray" height="5"></td></tr>		
<tr>
	<td nowrap><font face="verdana" size=2>Auto Sell</font></td>
	<td><input type="Text" name="autoSellWood" value="#NumberFormat(player.autoSellWood)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoSellFood" value="#NumberFormat(player.autoSellFood)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoSellIron" value="#NumberFormat(player.autoSellIron)#" size="10" maxlength="12"></td>
	<td><input type="Text" name="autoSellTools" value="#NumberFormat(player.autoSellTools)#" size="10" maxlength="12"></td>
	<cfset getGold = player.autoSellWood * woodSellPrice + player.autoSellFood * foodSellPrice +
					 player.autoSellIron * ironSellPrice + player.autoSellTools * toolSellPrice>
	<td><font face="verdana" size=2>#numberformat(getGold)#</font></td>
</tr>
<tr bgcolor="darkslategray">
	<td><input type="Submit" value="Update" style="font-size:xx-small;width:80"></td>
	<td align="right" colspan="4"><font face="verdana" size=2>Total:</font></td>
	<cfset t = getGold - useGold>
	<td><font face="verdana" size=2>#NumberFormat(t)#</font></td>
</tr>
</cfoutput>

</form>
</table>


</font>
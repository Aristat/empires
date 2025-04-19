<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfset numBuilders = toolMakerB.numBuilders * player.toolMaker + 3>
<cfset bPercent = player.wallBuildPerTurn / 100>
<cfset wallBuilders = round(numbuilders * bPercent)>

<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Buildings</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('buildings')">Help</a></td>
</tr>
</table>
<br />


<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr>
	<td class="HEADER">Build or Demolish Buildings</td>
</tr>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function showBuild()
{
	var freePLand = <cfoutput>#freeP#</cfoutput>;
	var freeMLand = <cfoutput>#freeM#</cfoutput>;
	var freeFLand = <cfoutput>#freeF#</cfoutput>;
	var gold = <cfoutput>#player.gold#</cfoutput>;
	var iron = <cfoutput>#player.iron#</cfoutput>;
	var wood = <cfoutput>#player.wood#</cfoutput>;
	
	if (document.all) {
		if (document.buildForm.buildingNo.selectedIndex == 0) return;
		
		var box = document.buildForm.buildingNo.options[document.buildForm.buildingNo.selectedIndex];

		var s = "Your resources allow you to build ";
		var canBuild = 1000000000;
		var temp = 0;
		
		if (box.gold > 0) {
			temp = Math.floor(gold / box.gold);
			if (temp < canBuild)
				canBuild = temp;
		}
		if (box.iron > 0) {
			temp = Math.floor(iron / box.iron);
			if (temp < canBuild)
				canBuild = temp;
		}
		if (box.wood > 0) {
			temp = Math.floor(wood / box.wood);
			if (temp < canBuild)
				canBuild = temp;
		}
		
		if (box.land == "P") {
			temp = Math.floor(freePLand / box.sq);
			if (temp < canBuild)
				canBuild = temp;
		}
		if (box.land == "M") {
			temp = Math.floor(freeMLand / box.sq);
			if (temp < canBuild)
				canBuild = temp;
		}
		if (box.land == "F") {
			temp = Math.floor(freeFLand / box.sq);
			if (temp < canBuild)
				canBuild = temp;
		}
		
		s = s + " " + canBuild;		
		s = s + " " + box.bname;
		
		document.all.allowBuild.innerHTML = s;
	}
}
//-->
</SCRIPT>
<form action="index.cfm" method="post" name="buildForm">
<tr><td><font face=verdana size=2>
	<input type="hidden" name="page" value="build">
	<select name="eflag">
	<option value="build">Build
	<option value="demolish">Demolish
	</select>
	<input type="Text" name="qty" value="1" maxlength="8" size="5">
	<cfoutput>
	<select name="buildingNo" onchange="showBuild()">
	<option value="0">--- Select a building to build or demolish ---
	<cfloop list="2,3,1,5,6,16,7,8,14,15,9,10,11,12,13,4" index="i">
	<option value="#i#" bname="#buildings[i].name#" wood="#buildings[i].CostWood#" iron="#buildings[i].CostIron#" gold="#buildings[i].CostGold#" sq="#buildings[i].sq#" land="#buildings[i].land#">#buildings[i].name# (#buildings[i].costWood# W, #buildings[i].costIron# I, #buildings[i].costGold# G, #buildings[i].sq# #buildings[i].land#)
	</cfloop>
	</select>
	<input type="Submit" value="Go">
	</cfoutput>
	</font>
</td></tr>
<tr>
	<td class="SMALL" align="right">W - Wood, I - Iron, G - Gold, P - Plains, F - Forest, M - Mountains</td>
</tr>
<tr>
	<td class="HEADER" id="allowBuild"></td>
</tr>
</form>
</table>

<cfquery name="bq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from buildQueue where playerID = #playerID# order by pos 
</cfquery>
<cfif bq.recordcount gt 0>
<br>
<b>Your Building Queue:</b>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
<tr>
	<td class="HEADER">Building</td>
	<td class="HEADER">No.</td>
	<td class="HEADER">Time Needed</td>
	<td class="HEADER">Cancel?</td>
	<td class="HEADER">Hold</td>
	<td class="HEADER">Move</td>
</tr>   
<cfset totalTimeNeeded = 0>
<cfif numBuilders lte 3>
	<cfset numBuilders = 3>
</cfif>
<cfset bbuilders = numBuilders - wallBuilders>

<cfoutput query="bq">
<tr <cfif bq.onHold is 1>bgcolor=gray</cfif>>
	<cfset b = buildings[bq.buildingNo]>
	<td>#b.name# <cfif bq.mission is 1>(Demolish)</cfif></td>
	<td>#bq.qty#</td>
	<td><cfif bbuilders gt 0>#ceiling(val(bq.timeneeded / bbuilders))# turns (#bq.timeneeded# builders)<cfelse>All builders are working on great wall</cfif></td>
	<td><font face="verdana" size="1"><a href="index.cfm?page=build&eflag=b_dequeue&q_id=#bq.id#">Cancel</a></td>
	<td><font face="verdana" size="1"><a href="index.cfm?page=build&eflag=hold&q_id=#bq.id#"><cfif bq.onHold is 0>Hold<cfelse>Resume</cfif></a></td>	
	<td><font face="verdana" size="1">
		<a href="index.cfm?page=build&eflag=to_top&q_id=#bq.id#">To Top</a> |
		<a href="index.cfm?page=build&eflag=to_bottom&q_id=#bq.id#">To Bottom</a>
	</td>
</tr>
</cfoutput>
<cfif bq.recordcount gt 1>
<tr>
	<td colspan="6" align="center"><a href="index.cfm?eflag=cancel_all&page=build">Cancel All</a></td>
</tr>
</cfif>
</table>

</cfif>

<br>
<br>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
<tr>
	<td class="HEADER">&nbsp;</td>
	<td class="HEADER">Building</td>
	<td class="HEADER">You Have</td>
	<td class="HEADER">Land</td>
	<td class="HEADER">Status</td>
	<td class="HEADER">Working</td>	
	<td class="HEADER">Workers</td>	
	<td class="HEADER">Production</td>
	<td class="HEADER">Consumption</td>
</tr>   
<cfoutput>
<cfset colors = arrayNew(1)>
<cfset colors[2] = "##ff6600">
<cfset colors[3] = "##ff6600">
<cfset colors[1] = "##00ff00">
<cfset colors[5] = "##ffcc00">
<cfset colors[6] = "##ffcc00">
<cfset colors[7] = "##00ccff">
<cfset colors[16] = "##00ccff">
<cfset colors[8] = "##00ccff">
<cfset colors[14] = "##00ccff">
<cfset colors[15] = "##00ccff">
<cfset colors[9] = "##ffffff">
<cfset colors[10] = "##ffffff">
<cfset colors[11] = "##ffffff">
<cfset colors[12] = "##ffffff">
<cfset colors[13] = "##ffffff">
<cfset colors[4] = "##ffffff">

<cfset totalWorkers = 0>
<cfset totalBuildings = 0>
<cfset totalLand = 0>
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="build">
<input type="hidden" name="eflag" value="changeBuildingStatus">
<cfloop list="2,3,1,5,6,16,7,8,14,15,9,10,11,12,13,4" index="i">
	<cfset b = buildings[i]>
<tr>
	<td width="8" style="color:#colors[i]#"><b><a href="javascript:openHelp('buildings###b.dbColumn#')">?</a></td>
	<td height="22" style="color:#colors[i]#">#b.name#
		<font size="1">
		<cfif i is 8><!--- weaponsmith --->
			<a href="index.cfm?page=manage">Set Production</a>
		<cfelseif i is 15><!--- mage tower --->
			<a href="index.cfm?page=research">Set Research</a>
		</cfif>
	</td>
	<cfset have = evaluate("player.#b.dbcolumn#")>
	<td align="right" style="color:#colors[i]#">#numberFormat(have)#</td>
	<cfset land = have * b.sq>
	<cfset totalLand = totalLand + land>
	<td align="right" style="color:#colors[i]#">#land# #b.land#</td>
	<cfset bWorking = have><!--- number of buildings in operation --->
	<cfset totalBuildings = totalBuildings + have>
	<cfif b.allowOff>
		<cfset status = evaluate("player.#b.dbColumn#Status")>
		<cfif status is 0>
			<cfset bWorking = 0>
		<cfelse>
			<cfset bWorking = round(have *  (status / 100))>
		</cfif>
		
		<td style="color:#colors[i]#">
		<select name="#b.dbColumn#Status" style="font-size:xx-small">
		<cfloop from="0" to="10" index="s">
			<cfset sIndex = s * 10>
			<option value="#s#" <cfif sIndex is status>selected</cfif>>#val(sIndex)# %
		</cfloop>
		</select>
	<cfelse>
		<td style="color:#colors[i]#">&nbsp;</td>
	</cfif>
	<cfset workers = bWorking * b.workers>
	<cfset totalWorkers = totalWorkers + workers>
	<td style="color:#colors[i]#" align="right">#NumberFormat(bWorking)#</td>
	<td style="color:#colors[i]#" align="right">#NumberFormat(workers)#</td>
	
	<!--- production --->
	<td style="color:#colors[i]#;font-size:xx-small">
		<cfif i is 8><!--- weapon smith --->
			<cfset bowProduction = round(player.bowWeaponSmith * (status / 100))>
			<cfset swordProduction = round(player.swordWeaponSmith * (status / 100))>
			<cfset maceProduction = round(player.maceWeaponSmith * (status / 100))>
			#swordProduction# swords, <br>
			#bowProduction# bows,
			<br>#maceProduction# maces
		<cfelseif b.productionName is not "">
			<cfset production = bWorking * b.production>
			#NumberFormat(production)# #b.productionName#
		<cfelse>
			&nbsp;
		</cfif>
	</td>

	<!--- consumption --->
	<td style="color:#colors[i]#;font-size:xx-small">
		<cfif i is 7><!--- tool maker --->
			#NumberFormat(val(bWorking*b.woodNeed))# wood,<br>
			#NumberFormat(val(bWorking*b.ironNeed))# iron
		<cfelseif i is 8><!--- weapon smith --->
			<cfset useWood = bowProduction * b.woodNeed + maceProduction * b.maceWood>
			<cfset useIron = swordProduction * b.ironNeed + maceProduction * b.maceIron>
			#NumberFormat(useWood)# wood,<br>
			#NumberFormat(useIron)# iron
		<cfelseif i is 14><!--- stable --->
			#NumberFormat(val(bWorking * b.foodNeed))# food
		<cfelseif i is 15><!--- mage tower --->
			#NumberFormat(val(bWorking * b.goldNeed))# gold
		<cfelseif i is 16><!--- winery --->
			#NumberFormat(val(bWorking * b.goldNeed))# gold		
		<cfelse>
			&nbsp;
		</cfif>
	</td>
</tr>
</cfloop>

</cfoutput>
<tr>
<cfoutput>
	<td class="HEADER" colspan="2" align="right"><b>Totals</b></td>
	<td class="HEADER" align="right">#NumberFormat(totalBuildings)#</td>
	<td class="HEADER" align="right">#NumberFormat(totalLand)#</td>
	<td class="HEADER"><input type="submit" value="Update" style="font-size:xx-small;width:60"></td>
	<td class="HEADER">&nbsp;</td>	
	<td class="HEADER" align="right">#NumberFormat(totalWorkers)#</td>
	<td class="HEADER">&nbsp;</td>
	<td class="HEADER">&nbsp;</td>
</cfoutput>
</tr>
</form>
</table>
<br>
<br>
<font face=verdana size=2>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr><td colspan="2" class="HEADER"><b>Population:</b></td></tr>
<cfoutput>
<cfset free = val(player.people - totalWorkers - numBuilders)>
<cfif free lt 0>
	<cfset totalWorkers = totalWorkers + free><!--- free is negative so subtraction --->
</cfif>
<tr><td align="right">Total:</td><td>#NumberFormat(player.people)#</td></tr>
<tr><td align="right">Working:</td><td>#NumberFormat(totalWorkers)#</td></tr>
<tr><td align="right">Construction Workers:</td><td>#NumberFormat(numBuilders)#</td></tr>
<tr><td align="right">Wall Builders:</td><td>#NumberFormat(wallBuilders)#</td></tr>
<cfif free lt 0>
<tr><td colspan="2"><cfset needed = abs(free)>
	<font face=verdana size=2 color="Red">You do not have enough people for your production.<br>
	You need additional #needed# people.<br>
	</font>
	</td>
</tr>
<cfelse>
<tr><td align="right">Not Working:</td><td>#NumberFormat(free)#</td></tr>
</cfif>

<!--- calculate house space --->
<cfset houseSpace = player.house * houseB.people + player.townCenter * townCenterB.people>
<cfset houseSpace = round(houseSpace + houseSpace * (player.research8 / 100))>
<cfset freeSpace =  houseSpace - player.people>
<tr>
	<td align="right">Extra House Space:</td>
	<td>#NumberFormat(freeSpace)#</td>
</tr>
</table>
</cfoutput>



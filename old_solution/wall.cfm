<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Great Wall</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('wall')">Help</a></td>
</tr>
</table>


<cfset totalLand = player.mland + player.fland + player.pland>
<cfset totalWall = round(totalLand*0.05)>
<cfset protection = 0>
<cfif totalWall gt 0 and totalLand gt 0>
	<cfset protection = round((player.wall / totalWall)*100)>
</cfif>
<cfset needWall = totalWall - player.wall>

<cfoutput>
Wall provides extra protection for your empire. <br>
You currently have #numberFormat(player.wall)# units of wall which provide you with
<font size="4"><b>#protection#%</b></font> extra protection.<br>

You need #totalWall# units of wall to have 100% extra defense.
<br>
<br>
<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr><td class="HEADER" colspan="2">
<b>Percentage of builders you want to dedicate to wall construction:
	</td>
</tr>
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="wall">
<input type="hidden" name="eflag" value="updateWall">
<tr>
	<cfset builders = toolMakerB.numBuilders * player.toolMaker + 3>
	<cfset bPercent = player.wallBuildPerTurn / 100>
	<cfset wallBuilders = round(builders * bPercent)>
	<cfset wallBuild = int(wallBuilders/25)>
	<td><input type="Text" name="wallBuildPerTurn" value="#NumberFormat(player.wallBuildPerTurn)#" size="6">%
	&nbsp;&nbsp;&nbsp;
	#wallBuilders# out of #builders# builders will construct #wallBuild# units of wall every month.<br>
	Wall construction monthly cost: 
	#NumberFormat(wallBuild * session.wallUseGold)# gold, 
	#NumberFormat(wallBuild * session.wallUseWood)# wood, 
	#NumberFormat(wallBuild * session.wallUseIron)# iron,
	#NumberFormat(wallBuild * session.walluseWine)# wine
	<hr noshade size="1">
	Cost to construct 1 unit of wall is: #session.wallUseGold# gold, #session.walluseWood# wood, #session.walluseIron# iron and
	#session.walluseWine# wine
	</td>
</tr>
<tr>
	<td colspan="2" class="HEADER" align="center"><input type="Submit" value="Update"></td>
</tr>	
</form>
</table>

</cfoutput>
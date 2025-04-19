<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<!--- managements --->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Empire Management</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('manage')">Help</a></td>
</tr>
</table>
<br />


<font face=verdana size=2>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="300">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="manage">
<input type="hidden" name="eflag" value="changeWeaponProduction">
<tr><td align="center" bgcolor="darkslategray"><font face=verdana size=2 color=white>Weapon Production</font></td></tr>
<tr><td>
You have <cfoutput>#player.weaponSmith# weaponsmiths and <br>
<input type="Text" name="bowProduction" size="4" maxlength="8" value="#player.bowWeaponSmith#"> of them are producing bows and<br>
<input type="Text" name="swordProduction" size="4" maxlength="8" value="#player.swordWeaponSmith#"> of them are producing swords<br>
<input type="Text" name="maceProduction" size="4" maxlength="8" value="#player.maceWeaponSmith#"> of them are producing maces<br>
and 
<cfset free = player.weaponSmith - player.bowWeaponSmith - player.swordWeaponSmith - player.maceWeaponSmith>
#free# are idle.
<hr noshade size="1" color="darkslategray">
<cfset woodUsed = player.bowWeaponSmith * weaponSmithB.woodNeed + player.maceWeaponSmith * weaponSmithB.maceWood>
<cfset ironUsed = player.swordWeaponSmith * weaponSmithB.ironNeed + player.maceWeaponSmith * weaponSmithB.maceIron>
Your weaponsmiths are using #woodUsed# wood and #ironUsed# iron for production every month.
</cfoutput>
</td></tr>
<tr><td bgcolor="darkslategray"><center><input type="Submit" value="Change" style="font-size:xx-small;width:80"></center></td></tr>
</form>
</table>
<br>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="300">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="manage">
<input type="hidden" name="eflag" value="changeFoodRatio">
<tr><td align="center" bgcolor="darkslategray"><font face=verdana size=2 color=white>Food Rationing</font></td></tr>
<tr><td>
<input type="Radio" name="foodRatio" value="4" <cfif player.foodRatio is 4>checked</cfif>>Extremly High <font face="verdana" size=1>(High population growth)</font><br>
<input type="Radio" name="foodRatio" value="3" <cfif player.foodRatio is 3>checked</cfif>>Very High <br>
<input type="Radio" name="foodRatio" value="2" <cfif player.foodRatio is 2>checked</cfif>>High<br>
<input type="Radio" name="foodRatio" value="1" <cfif player.foodRatio is 1>checked</cfif>>Above Average <br>
<input type="Radio" name="foodRatio" value="0" <cfif player.foodRatio is 0>checked</cfif>>Average <font face="verdana" size=1>(Normal Growth)</font><br>
<input type="Radio" name="foodRatio" value="-1" <cfif player.foodRatio is -1>checked</cfif>>Below Average<br>
<input type="Radio" name="foodRatio" value="-2" <cfif player.foodRatio is -2>checked</cfif>>Low <font face="verdana" size=1>(High Population Decline)</font><br>
</td></tr>
<tr><td align="center" bgcolor="darkslategray"><input type="Submit" value="Change Food Rationing" style="font-size:xx-small"></td></tr>
</form>
</table>
<br>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="300">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="manage">
<input type="hidden" name="eflag" value="changeLand">
<tr><td align="center" bgcolor="darkslategray"><font face=verdana size=2 color=white>Land</font></td></tr>
<tr><td>
	Change <input type="Text" name="mLandChange" size="5" maxlength="10" value="0"> mountain land to forest <br>(100 gold for each land)<br><br>
	
	Change <input type="Text" name="fLandChange" size="5" maxlength="10" value="0"> forest land to plains <br>(25 gold for each land)<br><br>
</td></tr>	
<tr><td bgcolor="darkslategray" align="center"><input type="Submit" value="Change" style="font-size:xx-small;width:80"></td></tr>
</form>
</table>

</font>
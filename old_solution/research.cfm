<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Research</td>
	<td class="HEADER" align="center" width="8%"><b><a href="javascript:openHelp('research')">Help</a></td>
</tr>
</table>


<cfset research = arrayNew(1)>
<cfset research[1] = "Attack Points">
<cfset research[2] = "Defense Points">
<cfset research[3] = "Theifs Strength">
<cfset research[4] = "Military Losses">
<cfset research[5] = "Food Production">
<cfset research[6] = "Mine Production">
<cfset research[7] = "Weapons/Tools Production">
<cfset research[8] = "Space Effectivness">
<cfset research[9] = "Markets Output">
<cfset research[10] = "Explorers">
<cfset research[11] = "Catapults Strength">
<cfset research[12] = "Wood Production">

<cfset totalResearchLevels = player.research1 + player.research2 + player.research3 + player.research4 + player.research5
	 + player.research6 + player.research7 + player.research8 + player.research9 + player.research10 + player.research11 
	 + player.research12>

<cfoutput>

<cfif player.mageTower is 0>
	<font face="verdana" size=2 color=red>
	<b>Build mage towers to start research.</b>
	</font>
	<br>
	<br>
<cfelse>
	<font face="verdana" size=2>
	You have a total of #totalResearchLevels# research levels.<br>
	<cfset nextLevelPoints = 10 + round(totalresearchLevels*totalresearchLevels*sqr(totalresearchlevels))>
	<br><br>
	<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray" width="100%">
	<form action="index.cfm" method="post">
	<input type="hidden" name="page" value="research">
	<input type="hidden" name="eflag" value="changeresearch">
	<tr>
		<td class="HEADER">Current Research:</td>
	</tr>
	<tr>
		<td valign="middle">
		Set current research: <select name="newCurrentResearch" style="font-size:xx-small">
		<option value="0">--- None ---
		<cfloop from="1" to="#arrayLen(research)#" index="i">
		<option value="#i#" <cfif i is player.currentResearch>selected</cfif>>#research[i]#
		</cfloop>
		</select>
		
		<cfif player.currentResearch gt 0>
		<br>
		#NumberFormat(player.researchPoints)# out of #NumberFormat(nextLevelPoints)#
		<cfset percent = (player.researchPoints / nextLevelPoints) * 100>
		(#DecimalFormat(percent)#% complete)
		<br>
		<font face="verdana" size="1">
		<cfset mt = round((player.mageTowerStatus / 100) * player.mageTower)>
		<cfset researchProduced = round(val(mt*mageTowerB.production))>
		You have #numberFormat(mt)# mage towers active producing #numberFormat(researchProduced)# research points <br>
		and using #numberFormat(val(mt*mageTowerB.goldNeed))# gold every month.
		<cfif researchProduced gt 0>
		<br>It takes your mage towers #DecimalFormat(nextLevelPoints/researchProduced)# months to advance research level.
		</cfif>
		</font>
		</cfif>
		</td>
	</tr>
	<tr><td align="center"><input type="Submit" value="Change Research"></td></tr>
	</form>
	</table>	
	<br>
	<br>
	
</cfif>

<table border="1" cellpadding="1" cellspacing="1" bordercolor="darkslategray">
<tr>
	<td class="HEADER">Research Name</td>
	<td class="HEADER">Current</td>
	<td class="HEADER">Description</td>
</tr>
<tr>
	<td colspan="10"><b>Military Research</td>
</tr>
<tr>
	<td>#research[1]#</td>
	<td align="center">#player.research1#</td>
	<td>Your army attack points are increased by #player.research1#%</td>
</tr>
<tr>
	<td>#research[2]#</td>
	<td align="center">#player.research2#</td>
	<td>Your army defense points are increased by #player.research2#%</td>
</tr>
<tr>
	<td>#research[3]#</td>
	<td align="center">#player.research3#</td>
	<td>Your thieves are #player.research3#% stronger</td>
</tr>
<tr>
	<td>#research[11]#</td>
	<td align="center">#player.research11#</td>
	<td>Your catapults are #player.research11#% stronger</td>
</tr>
<tr>
	<td>#research[4]#</td>
	<td align="center">#player.research4#</td>
	<td>You lose #player.research4#% less army in battles</td>
</tr>
<tr>
	<td colspan="10"><b>Production Research</td>
</tr>
<tr>
	<td>#research[5]#</td>
	<td align="center">#player.research5#</td>
	<td>Your food production is increased by #player.research5#%</td>
</tr>
<tr>
	<td>#research[12]#</td>
	<td align="center">#player.research12#</td>
	<td>Your wood production is increased by #player.research12#%</td>
</tr>
<tr>
	<td>#research[6]#</td>
	<td align="center">#player.research6#</td>
	<td>Your mine production is increased by #player.research6#%</td>
</tr>
<tr>
	<td>#research[7]#</td>
	<td align="center">#player.research7#</td>
	<td>Your weaponsmiths and tool makers are #player.research7#% more effective</td>
</tr>
<tr>
	<td colspan="10"><b>Other Research</td>
</tr>
<tr>
	<td>#research[8]#</td>
	<td align="center">#player.research8#</td>
	<td>Your storage and housing space is increased by #player.research8#%</td>
</tr>
<tr>
	<td>#research[9]#</td>
	<td align="center">#player.research9#</td>
	<td>You can transfer/aid #val(player.research9*10)#% more goods</td>
</tr>
<tr>
	<td>#research[10]#</td>
	<td align="center">#player.research10#</td>
	<td>Your explorers find #player.research10#% more land</td>
</tr>
</table>
</cfoutput>
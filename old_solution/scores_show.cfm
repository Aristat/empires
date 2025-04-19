<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<cfparam name="rankView" default="false">
<cfoutput>
	<cfif p.id is playerID><cfset color="Aqua">
	<cfelseif p.allianceID gt 0 and (p.allianceID is myAllianceID)><cfset color="Fuchsia">
	<cfelseif p.allianceID gt 0 and (p.allianceID is ally1 or p.allianceID is ally2 or p.allianceID is ally3 or p.allianceID is ally4 or p.allianceID is ally5)><cfset color="PeachPuff">
	<cfelseif p.allianceID gt 0 and (p.allianceID is war1 or p.allianceID is war2 or p.allianceID is war3 or p.allianceID is war4 or p.allianceID is war5)><cfset color="Crimson">
	<cfelseif p.turn lte 72><cfset color="Yellow">	
	<cfelseif p.vacationEnd is not "" and p.vacationEnd gt Now()><cfset color="Yellow">		
	<cfelse><cfset color="White"></cfif>
<tr>
	<td align="right"><font face=verdana size=1 color="#color#">
	<cfif isDate(p.lastLoad) and not rankView><cfif abs(dateDiff("n", p.lastLoad, now())) lt 10>*</cfif></cfif>
	<span onclick="showMenu('#p.id#', '#p.name#')" style="cursor:hand">#p.currentRow#</span></td>
	<td><font face=verdana size=1 color="#color#"><span onclick="showMenu('#p.id#', '#p.name#')" style="cursor:hand">#p.name# (#p.id#)</span></td>
	<td><font face=verdana size=1 color="#color#">#empireNames[p.civ]#</td>
	<cfif not deathMatchMode and allianceMaxMembers gt 0><td align="center">
		<cfif p.tag is ""><font face="verdana" size=1 color="#color#">&nbsp;</font>
		<cfelse>
			<a href="index.cfm?page=alliance_info&viewAllianceID=#p.allianceID#">
			<font face="verdana" size=1 color="#color#">
			<cfif p.id is p.leaderID>[#p.tag#]
			<cfelse>#p.tag#</cfif></a>
		</cfif></font></td>
	</cfif>
	<cfif p.totalLand lte 0>
	<td align="center" colspan="5"><font size=1 face=verdana color=red><b>DEAD by #p.killedByName# (#p.killedBy#)</b></font></td>
	<cfelse>
	<td align="right"><font face="verdana" size=1 color="#color#">#NumberFormat(p.researchLevels)#</font></td>	
	<td align="right"><font face="verdana" size=1 color="#color#">#NumberFormat(p.totalLand)#</font></td>
	<td align="right"><font face=arial size=1 color="#color#">#NumberFormat(p.score)#</td>
	</cfif>
</tr>
<cfif p.currentrow mod 5 is 0><tr><td colspan="9" bgcolor="darkslategray" height="10"></td></tr></cfif>
</cfoutput>
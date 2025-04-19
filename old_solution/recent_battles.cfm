<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="92%"><font face="verdana" size="3"><b>Recent Battles</td>
	<td class="HEADER" align="center" width="8%"><b><!---a href="javascript:openHelp('trade')">Help</a---></td>
</tr>
</table>


<cfif deathMatchMode>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<cfparam name="pageFlag" default="">

<cfif pageFlag is "view_battles">
	<cfset numHours = val(form.numHours)>
	<cfset empireNo = val(form.viewPlayer)>
	<cfif numHours is 0>
		<font face=verdana size=2 color=red>Invalid number of hours.</font>	<br>
	<cfelseif empireNo lte 0 or empireNo gt 1000000>
		<font face=verdana size=2>Invalid empire #</font><br>
	<cfelse>
		<cfset numHours = 0 - numHours>
		<cfset dateStart = DateAdd("h", numHours, Now())> 
		<cfquery name="v" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" maxrows="250">	
			SELECT attackNews.*, attacker.name as attackerName, defender.name as defenderName 
			FROM (attackNews 
				 left outer join player attacker on attackNews.attackID = attacker.id)
				 left outer join player defender on attackNews.defenseID = defender.id
			WHERE
				attackNews.createdOn > #dateStart#
			<cfif searchType is "empireNo">
				<cfif listLen(viewPlayer) is 1>
					<cfset pOption = " = #val(viewPlayer)#">
				<cfelse>
					<cfset pOption = " in (0 ">
					<cfloop list="#viewPlayer#" index="i">
						<cfset pOption = pOption & ", #val(i)#">
					</cfloop>
					<cfset pOption = pOption & ")">
				</cfif>
			
				<cfif defenderOrAttacker is 0>
					AND defenseID #preserveSingleQuotes(pOption)#
				<cfelseif defenderOrAttacker is 1>
					AND attackID #preserveSingleQuotes(pOption)#
				<cfelse>
					AND (attackID #preserveSingleQuotes(pOption)# OR defenseID #preserveSingleQuotes(pOption)#)
				</cfif>
			<cfelse>
				<cfif allianceName is "___ANY___">
				
				<cfelse>
					<cfif defenderOrAttacker is 0>
						AND defenseAlliance = '#allianceName#'
					<cfelseif defenderOrAttacker is 1>
						AND attackAlliance = '#allianceName#'
					<cfelse>
						AND (defenseAlliance = '#allianceName#' or attackAlliance = '#allianceName#')
					</cfif>			
				</cfif>
			</cfif>
			<cfif attackType gt 0>
			AND attackType = #attackType#
			</cfif>
			order by attackNews.id desc 
        </cfquery>
		
		<cfif v.recordcount is 0>
			<font face=verdana size=2 color=red>No Battles found.</font><br>
			
		<cfelse>
		<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
        <tr>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">&nbsp;</font></td>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Date/Time</font></td>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Type</font></td>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Attacker</font></td>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Defender</font></td>
			<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Result</font></td>
		</tr>
		<cfoutput query="v" maxrows="250">
		<tr>
			<cfset showDetail = false>
			<td valign="top" align="right"><font face="verdana" size=1>#v.currentrow#.</font></td>
			<td valign="top"><font face=verdana size=1>
				<cfif v.attackID is playerID or v.defenseID is playerID><cfset showDetail = true>
				<cfelseif player.allianceID gt 0 and player.allianceMemberType is 1>
					<cfif v.attackAllianceID is player.allianceID or v.defenseAllianceID is player.allianceID>
						<cfset showDetail = true>
					</cfif>
				</cfif>
				
				<cfif showDetail><a href="index.cfm?page=recent_battles&pageFlag=viewDetail&bID=#v.id#"></cfif>
				#DateFormat(v.createdOn, "mm/dd/yy")#<br>#TimeFormat(v.createdOn, "hh:mm tt")#</a></font></td>
			<td valign="top"><font face="verdana" size=2>
			<cfif v.attackType is 1>Army
			<cfelseif v.attackType is 2>Catapults
			<Cfelseif v.attackType is 3>Thieves</cfif>
			</td>
			<td valign="top"><font face=verdana size=2>#v.attackername# (#v.attackID#)
				<cfif v.attackAlliance is not ""><br><font face="verdana" size=1><b>#v.attackAlliance#</b></font></cfif>
				</font>
			</td>
			<td valign="top"><font face=verdana size=2>#v.defendername# (#v.defenseID#)
				<cfif v.defenseAlliance is not ""><br><font face="verdana" size=1><b>#v.defenseAlliance#</b></font></cfif>
			</font></td>
			<td valign="top"><font face=verdana size=2>
				<cfif v.attackerWins is 1>#v.message#<cfelse>Defense Held</cfif>
			</font>
			</td>
		</tr>
		<cfif v.currentrow mod 10 is 0><tr><td colspan="6" bgcolor="darkslategray" height="5"></td></tr></cfif>
		</cfoutput>
        </table>
		<cfif v.recordCount gte 250>
			Limiting display to 250 results.<br>
		</cfif>

		</cfif>
	</cfif>
<cfelseif pageFlag is "viewDetail">
	<cfset bID = val(bID)>
	<cfquery name="v" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		SELECT attackNews.*, attacker.name as attackerName, defender.name as defenderName 
		FROM (attackNews 
			 left outer join player attacker on attackNews.attackID = attacker.id)
			 left outer join player defender on attackNews.defenseID = defender.id
		WHERE attackNews.id = #bID#
	</cfquery>	
	<cfif v.recordcount is 0>
		<font face=verdana size=2 color=red>No Battles found.</font><br>
		
	<cfelse>
	<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray">
       <tr>
		<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Date/Time</font></td>
		<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Attacker</font></td>
		<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Defender</font></td>
		<td bgcolor="darkslategray"><font face=verdana size=2 color="White">Result</font></td>
	</tr>
	<cfoutput query="v">
	<tr>
		<cfset showDetail = false>
		<td valign="top"><font face=verdana size=1>
			<cfif v.attackID is playerID or v.defenseID is playerID><cfset showDetail = true>
			<cfelseif player.allianceID gt 0 and player.allianceMemberType is 1>
				<cfif v.attackAllianceID is player.allianceID or v.defenseAllianceID is player.allianceID>
					<cfset showDetail = true>
				</cfif>
			</cfif>
			#DateFormat(v.createdOn, "mm/dd/yy")#<br>#TimeFormat(v.createdOn, "hh:mm tt")#</a></font></td>
		<td valign="top"><font face=verdana size=2>#v.attackername# (#v.attackID#)
			<cfif v.attackAlliance is not ""><br><font face="verdana" size=1><b>#v.attackAlliance#</b></font></cfif>
			</font>
		</td>
		<td valign="top"><font face=verdana size=2>#v.defendername# (#v.defenseID#)
			<cfif v.defenseAlliance is not ""><br><font face="verdana" size=1><b>#v.defenseAlliance#</b></font></cfif>
		</font></td>
		<td valign="top"><font face=verdana size=2>
			<cfif v.attackerWins is 1>#v.message#<cfelse>Defense Held</cfif>
		</font>
		</td>
	</tr>
	<cfif showDetail>
		<tr><td colspan="10">#v.battleDetails#</td></tr>
	</cfif>
	</cfoutput>
       </table>
	</cfif>
	

</cfif>

<font face=verdana size=2>
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="recent_battles">
<input type="hidden" name="pageFlag" value="view_battles">
View battles fought within last
<input type="Text" name="numHours" value="24" size="3"> hours<br>
attack type
<select name="attackType">
<option value="0">Any
<option value="1">Army
<option value="2">Catapults
<option value="3">Thieves
</select><br>
and where 
<select name="defenderOrAttacker">
<option value="0">Defender
<option value="1">Attacker
<option value="2" selected>Defender or Attacker
</select><br>
<input type="radio" name="searchType" value="empireNo" checked>was empire # <input type="Text" name="viewPlayer" value="<cfoutput>#playerID#</cfoutput>" size="15"><br>
<cfquery datasource="#dsn#" name="a">
    select id, tag from alliance order by tag
</cfquery>
<input type="radio" name="searchType" value="alliance">alliance
<select name="allianceName">
<option value="">--- Select One ---
<option value="___ANY___">--- All Alliances ---
<cfoutput query="a">
<option value="#a.tag#" <cfif a.id is player.allianceID>selected</cfif>>#a.tag#
</cfoutput>
</select>
<br>
<input type="Submit" value="View">
</form>
</font>
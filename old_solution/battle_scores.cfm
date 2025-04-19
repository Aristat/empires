<cfparam name="ostring" default="total_battles">
<cfparam name="timeframe" default="24hours">
<font face="verdana" size=1>
Sort by:
<cfoutput>
<a href="index.cfm?page=battle_scores&ostring=total_battles&timeframe=#timeframe#"><cfif ostring is "total_battles"><b>Total Battles</b><cfelse>Total Battles</cfif></a> |
<a href="index.cfm?page=battle_scores&ostring=total_wins&timeframe=#timeframe#"><cfif ostring is "total_wins"><b>Total Wins</b><cfelse>Total Wins</cfif></a> |
<a href="index.cfm?page=battle_scores&ostring=num_attacks&timeframe=#timeframe#"><cfif ostring is "num_attacks"><b>Num. Attacks</b><cfelse>Num Attacks</cfif></a> |
<a href="index.cfm?page=battle_scores&ostring=num_attack_wins&timeframe=#timeframe#"><cfif ostring is "num_attack_wins"><b>Attacks Won</b><cfelse>Attacks Won</cfif></a> |
<a href="index.cfm?page=battle_scores&ostring=num_defenses&timeframe=#timeframe#"><cfif ostring is "num_defenses"><b>Num. Defenses</b><cfelse>Num. Defenses</cfif></a> |
<a href="index.cfm?page=battle_scores&ostring=num_defense_wins&timeframe=#timeframe#"><cfif ostring is "num_defense_wins"><b>Defenses Won</b><cfelse>Defenses Won</cfif></a> 
<br>
</cfoutput>
<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select top 25 * from battleScores 
	order by 
	<cfswitch expression="#ostring#">
	<cfcase value="total_battles">(num_attacks+num_defenses) desc</cfcase>
	<cfcase value="total_wins">(num_attack_wins+num_defense_wins) desc</cfcase>
	<cfcase value="num_attacks">num_attacks desc</cfcase>
	<cfcase value="num_attack_wins">num_attack_wins desc</cfcase>
	<cfcase value="num_defenses">num_defenses desc</cfcase>
	<cfcase value="num_defense_wins">num_defense_wins desc</cfcase>
	</cfswitch>
</cfquery>

<table border=1 cellspacing=1 cellpadding=2 bordercolor="darkslategray" width="100%">
<tr>
	<td rowspan="2" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">&nbsp;</td>
	<td rowspan="2" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Player</td>
	<td rowspan="2" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Alliance</td>		
	<td colspan="3" align="center" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Attacks</td>		
	<td colspan="3" align="center" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Defenses</td>		
	<td colspan="3" align="center" class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Total</td>			
</tr>
<tr>		
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Num.</td>
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Won</td>	
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Percent</td>	
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Num.</td>
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Won</td>
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Percent</td>	
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Num.</td>
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Won</td>	
	<td class="SMALL" bgcolor="darkslategray" align="center"><font face=verdana color="White">Percent</td>	
</tr>
<cfoutput query="p">
<tr>
	<td class="SMALL">#p.currentRow#</td>
	<td class="SMALL">#p.name# (#p.id#)</td>
	<td class="SMALL">#p.tag#&nbsp;</td>
	<td class="SMALL">#p.num_attacks#</td>
	<td class="SMALL">#p.num_attack_wins#</td>	
	<cfif p.num_attacks is 0><cfset percent = 0>
	<cfelse><cfset percent = (p.num_attack_wins / p.num_attacks) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
	
	<td class="SMALL">#p.num_defenses#</td>
	<td class="SMALL">#p.num_defense_wins#</td>	
	<cfif p.num_defenses is 0><cfset percent = 0>
	<cfelse><cfset percent = (p.num_defense_wins / p.num_defenses) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
	
	<cfset total_battles = p.num_defenses + p.num_attacks>
	<cfset total_battles_win = p.num_defense_wins + p.num_attack_wins>
	<td class="SMALL">#total_battles#</td>
	<td class="SMALL">#total_battles_win#</td>	
	<cfif total_battles is 0><cfset percent = 0>
	<cfelse><cfset percent = (total_battles_win / total_battles) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
</tr>
</cfoutput>
<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select top 25 * from battleScores where id = #playerID#
</cfquery>
<tr><td colspan="20" class="HEADER" align="center"><b>Your Battle Results:</b></td></tr>
<cfoutput query="p">
<tr>
	<td class="SMALL">&nbsp;</td>
	<td class="SMALL">#p.name# (#p.id#)</td>
	<td class="SMALL">#p.tag#&nbsp;</td>
	<td class="SMALL">#p.num_attacks#</td>
	<td class="SMALL">#p.num_attack_wins#</td>	
	<cfif p.num_attacks is 0><cfset percent = 0>
	<cfelse><cfset percent = (p.num_attack_wins / p.num_attacks) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
	
	<td class="SMALL">#p.num_defenses#</td>
	<td class="SMALL">#p.num_defense_wins#</td>	
	<cfif p.num_defenses is 0><cfset percent = 0>
	<cfelse><cfset percent = (p.num_defense_wins / p.num_defenses) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
	
	<cfset total_battles = p.num_defenses + p.num_attacks>
	<cfset total_battles_win = p.num_defense_wins + p.num_attack_wins>
	<td class="SMALL">#total_battles#</td>
	<td class="SMALL">#total_battles_win#</td>	
	<cfif total_battles is 0><cfset percent = 0>
	<cfelse><cfset percent = (total_battles_win / total_battles) * 100></cfif>
	<td class="SMALL">#Round(percent)#%</td>	
</tr>
</cfoutput>

</table>

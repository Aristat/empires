<cfset theDate = "#DateFormat(now(), "mm/dd/yyyy")# #TimeFormat(now(), "hh:mm tt")#">
<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #playerID#
</cfquery>

<cfif player.killedBy gt 0>
	<font face="verdana" color=red size=2>Sorry, but you're already dead.</font>
	<cfabort>
</cfif>

<cfif eflag is "end_turn">
	<cfif player.turnsFree gt 0>
		<cfinclude template="end_turn.cfm">
	<cfelse>
		<cfset eflag_message = eflag_message & "You do not have any months remaining (1 free month every #minutesPerTurn# minutes)<br>">
	</cfif>
<cfelseif eflag is "end_x_turns">
	<cfset xTurns = val(xTurns)>
	<cfif xTurns lte 0>
		<cfset eflag_message = eflag_message & "Cannot end less than 0 turns.<br>">
	<cfelseif xTurns gt 12>
		<cfset eflag_message = eflag_message & "Due to the processing time of ending each turn, this operation is limited to 12 turns at a time.<br>">
	<cfelse>
		<cfset processTurn = true>
		<cfset big_message = "">
		<cfloop from="1" to="#xTurns#" index="turnNoLoop">
			<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	        	select * from player where id = #playerID#
	        </cfquery>
			<cfif processTurn is false>
				<cfbreak>
			<cfelseif player.turnsFree gt 0>
				<cfset message = "">
				<cfinclude template="end_turn.cfm">
				<cfset big_message = big_message & message>
			<cfelse>
				<cfset eflag_message = eflag_message & "No more turns left...<br>">
				<cfbreak>
			</cfif>
		</cfloop>	
		<cfset message = big_message>
	</cfif>
</cfif>
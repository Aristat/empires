<cfif eflag is "updateWall">
	<cfset wallBuildPerTurn = round(val(wallBuildPerTurn))>
	<cfif wallBuildPerTurn lt 0 or wallBuildPerTurn gt 100>
		<cfset eflag_message = eflag_message & "Percentage of builders have to be between 0 and 100.">
	<cfelse>
		<cfquery datasource="#dsn#">
            update player set
				wallBuildPerTurn = #wallBuildPerTurn#
			where id = #playerID#
        </cfquery>	
	</cfif>
</cfif>
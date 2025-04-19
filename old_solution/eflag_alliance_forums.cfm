<cfif player.allianceID gt 0>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.leaderID is playerID>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            delete from forumTopic 
				where id = #topicID# and allianceID = #player.allianceID#
        </cfquery>
		<cfset eflag_message = eflag_message & "Topic deleted.<br>">
	</cfif>
</cfif>
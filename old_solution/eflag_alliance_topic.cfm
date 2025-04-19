<cfif player.allianceID gt 0>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	<cfquery name="m" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, playerID from forumMessage where id = #messageID#
    </cfquery>
	<cfif m.playerID is playerID or alliance.leaderID is playerID>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
			delete from forumMessage where id = #m.id#
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update forumTopic set messageCount = messageCount - 1 where id = #topicID# 
				and allianceID = #player.allianceID#
        </cfquery>
		<cfset eflag_message = eflag_message & "Message deleted.<br>">
	</cfif>
</cfif>
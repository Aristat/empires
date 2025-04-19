<cfif player.allianceID gt 0>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update player set hasAllianceMessages = 1 where allianceID = #player.allianceID#
    </cfquery>

	<cfif eflag is "post_topic">
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            insert into forumTopic (allianceID, topic, author, createdOn, messageCount, 
				lastPostOn, lastPostBy, playerID)
			values (#player.allianceID#, '#form.subject#', '#player.name# (#player.id#)', #now()#, 1,
				#now()#, '#player.name# (#player.id#)', #player.id#)
        </cfquery>
		<cfquery name="topic" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select max(id) as mid from forumTopic where playerID = #player.id#
        </cfquery>
		<cfset topicID = topic.mid>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            insert into forumMessage (topicID, allianceID, createdOn, createdBy, playerID, message)
			values (#topicID#, #player.allianceID#, #now()#, '#player.name# (#player.id#)', #player.id#, '#form.forum_message#')
        </cfquery>
		<cflocation url="index.cfm?page=alliance_topic&topicID=#topicID#">
	<cfelseif eflag is "reply_topic">
		<cfquery name="topic" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id from forumtopic where id = #topicid# and allianceID = #player.allianceID#
        </cfquery>
		<cfif topic.recordcount gt 0>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                insert into forumMessage (allianceID, topicID, createdOn, createdBy, playerID, message)
				values (#player.allianceID#, #topicID#, #now()#, '#player.name# (#player.id#)', #player.id#, '#form.forum_message#')
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update forumTopic 
					set messageCount = messageCount + 1,
					lastPostOn = #now()#,
					lastPostBy = '#player.name# (#player.id#)'
				where id = #topicID#
            </cfquery>
			<cflocation url="index.cfm?page=alliance_topic&topicID=#topicID#">
		</cfif>
	</cfif>
</cfif>
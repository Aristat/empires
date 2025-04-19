<cfif player.allianceID gt 0 and isDefined("topicID")>
	<cfif player.hasAllianceMessages>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	    update player set hasAllianceMessages = 0 where id = #player.id#
	    </cfquery>
	</cfif>

	<cfquery name="topic" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from forumTopic where id = #topicID# and allianceID = #player.allianceID#
    </cfquery>
	<cfif topic.recordcount is 0><cfabort></cfif>
	
	<cfif isDefined("reply")>
		<cfinclude template="alliance_reply.cfm">
	</cfif>	
	
	<a href="index.cfm?page=alliance_forums">Back to Forums</a> |	
	<a href="index.cfm?page=alliance_newtopic">Start New Topic</a> |
	<a href="index.cfm?page=alliance_topic&topicID=<cfoutput>#topicID#</cfoutput>&reply=1">Reply to Topic</a>

	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>	

	<table border=1 cellpadding=0 cellspacing=0 width="590" bordercolor="darkslategray">
    <tr>
		<td class="HEADER" align="center">Topic: <cfoutput>#topic.topic#</cfoutput></td>
	</tr>
	<cfquery name="msg" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from forumMessage
		where topicID = #topicID#
		order by createdOn
    </cfquery>
	<cfoutput query="msg">
	<tr>
		<td bgcolor="gray"><font size=2>
			Posted by #msg.createdBy# on #DateFormat(msg.createdOn, "mm/dd/yyyy")# at #TimeFormat(msg.createdOn, "hh:mm tt")#
			</font>
		</td>
	<tr>
	<tr><td>
			<cf_getFormatedText text="#msg.message#" showoutput="true">
			<br><br>
			<cfif msg.playerID is playerID or alliance.leaderID is playerID>
				<font size=1>- <a href="index.cfm?page=alliance_topic&eflag=delete_message&messageID=#msg.id#&topicID=#topicID#">delete message</a>
			</cfif>
			
		</td>
	</tr>
	</cfoutput>
    </table>
	<a href="index.cfm?page=alliance_forums">Back to Forums</a> |
	<a href="index.cfm?page=alliance_newtopic">Start New Topic</a> |
	<a href="index.cfm?page=alliance_topic&topicID=<cfoutput>#topicID#</cfoutput>&reply=1">Reply to Topic</a>

</cfif>
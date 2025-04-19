<cfif player.allianceID gt 0>
	<cfif player.hasAllianceMessages>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	    update player set hasAllianceMessages = 0 where id = #player.id#
	    </cfquery>
	</cfif>

	<style type="text/css">
		A.forum { color: yellow; }
		A.forum:visited { color: aqua; }
    </style>	
	<a href="index.cfm?page=alliance_newtopic">Start New Topic</a>
	<table border=1 cellpadding=1 cellspacing=1 width="590" bordercolor="darkslategray">
    <tr>
		<td width="350" class="HEADER" align="center">Topic</td>
		<td width="100" class="HEADER" align="center">Author</td>
		<td width="40" class="HEADER" align="center">Posts</td>
		<td width="100" class="HEADER" align="center" nowrap>Last Post</td>
	</tr>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	
	<Cfset startDate = dateAdd("d", -7, now())>
	<cfquery name="topic" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from forumTopic 
		where allianceID = #player.allianceID# and lastPostOn > #startDate#
		order by lastPostOn desc
    </cfquery>
	<cfset today = createODBCDate(now())>
	<cfset yesterday = createODBCDate(dateAdd("d", -1, today))>
	<cfoutput query="topic">
	<tr>
		<td><a class="forum" href="index.cfm?page=alliance_topic&topicID=#topic.id#&m=#topic.messageCount#">#topic.topic#</a></td>
		<td nowrap align="center">#topic.author#
			<cfif alliance.leaderID is playerID><font size=1><br><a href="index.cfm?page=alliance_forums&eflag=delete_topic&topicID=#topic.id#">delete topic</a></cfif>	
		</td>
		<td align="center">#topic.messageCount#</td>
		<td nowrap align="center"><font size=1>
		<cfset thisDate = createODBCDate(topic.lastPostOn)>
		<cfif thisDate is yesterday>
			Yesterday at
		<cfelseif thisDate is today>
			Today at
		<cfelse>
			#DateFormat(topic.lastPostOn, "mm/dd/yyyy")# 
		</cfif>
		#TimeFormat(topic.lastPostOn, "hh:mm tt")#<br>
			by: <b>#topic.lastPostBy#</b>
		</td>
	</tr>
	</cfoutput>
    </table>
	<br><a href="index.cfm?page=alliance_newtopic">Start New Topic</a>
</cfif>
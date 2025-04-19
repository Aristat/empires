<cfif eflag is "add_message">
	<!--- check if player exists --->
	<cfset pmessage = left(pmessage, 5000)>
	
	<cfloop list="#toPlayerID#" index="tpID">
		<cfset pID = val(tpID)>	
		<cfquery name="toPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	    	select id, name from player where id = #pID#
	    </cfquery>
		<cfquery datasource="#dsn#" name="block">
    		select id from blockMessages where playerID = #pID# and blockPlayerID = #playerID#
	    </cfquery>
		
		<cfif toPlayer.recordcount is 0>
			<cfset eflag_message = eflag_message & "Player ## #pID# is not valid.<br>">
		<cfelseif block.recordcount gt 0>
			<cfset eflag_message = eflag_message &  "Player ## #pid# doesn't want to receive messages from you.<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	            insert into playerMessage (toPlayerID, fromPlayerID, toPlayerName, fromPlayerName, createdon, viewed, message)
				values (#pID#, #playerID#, '#toPlayer.name#', '#player.name#', #Now()#, 0, '#pmessage#')
	        </cfquery>
			<cfquery datasource="#dsn#">
                update player set hasNewMessages = 1 where id = #pid#
            </cfquery>
			<cfset eflag_message = eflag_message & "Message sent to #toPlayer.name#<br>">
		</cfif>	
	</cfloop>
<cfelseif eflag is "delete_message">
	<cfset messageID = val(messageid)>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update playerMessage set messageType = 2 where toPlayerID = #playerID# and id = #messageid#
    </cfquery>
<cfelseif eflag is "delete_all_messages">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update playerMessage set messageType = 2 where toPlayerID = #playerID# and messageType = 0 and id <= #val(maxMessageID)#
    </cfquery>
<cfelseif eflag is "save_message">
	<cfset messageID = val(messageid)>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update playerMessage set messageType = 4 where toPlayerID = #playerID# and id = #messageid#
    </cfquery>	
<cfelseif eflag is "delete_all_saved">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		update playerMessage set messageType = 2 where toPlayerID = #playerID# and messageType = 4
    </cfquery>
<cfelseif eflag is "addblock">
	<cfset blockid = val(blockId)>
	<cfquery datasource="#dsn#" name="p">
    	select name from player where id = #blockid#
    </cfquery>
	<cfif p.recordcount is 0>
		<cfset eflag_message = "Player #blockid# not found.">
	<cfelse>
		<cfquery datasource="#dsn#" name="b">
        	select id from blockMessages where playerID = #playerID# and blockPlayerID = #blockid#
        </cfquery>
		<cfif b.recordcount gt 0>
			<cfset eflag_message = "You're already blocking messages from player ## #blockID#">
		<cfelse>
			<cfquery datasource="#dsn#">
                insert into blockMessages (playerID, blockPlayerID)
				values (#playerID#, #blockID#)
            </cfquery>
			<cfset eflag_message = "You will no longer receive messages from #p.name# (#blockID#)">
		</cfif>
	</cfif>
<cfelseif eflag is "unblock">
	<cfset blockID = val(blockID)>
	<cfquery datasource="#dsn#">
        delete from blockMessages where id = #blockID# and playerID = #playerID#
    </cfquery>
</cfif>
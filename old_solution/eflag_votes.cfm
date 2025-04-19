<cfif eflag is "castVote">
	<!--- see if player already voted for that one --->
	<cfquery name="v" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id from voteAnswer where playerID = #playerID# and voteID = #voteID#
    </cfquery>
	<Cfif v.recordCount gt 0>
		<cfset eflag_message = eflag_message & "You already cast your vote!<br>">
	<cfelse>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            insert into voteAnswer (voteID, playerID, createdOn, choiceID)
			values (#voteID#, #playerID#, #now()#, #val(choice)#)
        </cfquery>
		<cfset eflag_message = eflag_message & "Thank you for you input.<br>">
	</cfif>
</cfif>
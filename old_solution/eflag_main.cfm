<cfif eflag is "delete_news">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update playerMessage set messageType = 3 where toPlayerID = #playerID# and id = #newsID#
    </cfquery>
<cfelseif eflag is "delete_allnews">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update playerMessage set messageType = 3 where toPlayerID = #playerID# and messageType = 1
    </cfquery>
</cfif>
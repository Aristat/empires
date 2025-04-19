<cfif eflag is "changeresearch">	
	<cfparam name="newCurrentResearch" default="0">
	<cfset cr = val(newCurrentResearch)>
	<cfif cr gte 0 and cr lte 12>
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
        update player set 
			currentResearch = #cr#
		where id = #playerID#
    </cfquery>
	</cfif>
</cfif>
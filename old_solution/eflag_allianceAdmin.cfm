<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from alliance where id = #player.allianceID#
</cfquery>
<cfif playerID is alliance.leaderID>
	<cfif eflag is "change_name">
		<cfquery name="dupAlliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id from alliance where tag = '#alliance_name#'
        </cfquery>
		<cfset isValid = true>
		<cfloop from="1" to="#len(alliance_name)#" index="i">
			<cfset ch = asc(mid(alliance_name, i, 1))>
			<cfif (ch gte 65 and ch lte 90) or (ch gte 97 and ch lte 122) or ch is 32 or ch is 95 or (ch gte 48 and ch lte 57)>
			
			<cfelse>
				<cfset isValid = false>
			</cfif>
		</cfloop>
		<cfif alliance_name contains "  ">
			<cfset isValid = false>		
		</cfif>
		
		<cfif alliance_name is "">
			<cfset eflag_message = "Please provide alliance name.">
		<cfelseif not isValid>
			<cfset eflag_message = "Alliance name can only contain spaces and alpha-numeric characters and cannot contain two spaces by each other.<br>">		
		<cfelseif dupAlliance.recordcount gt 0>
			<cfset eflag_message = "Alliance with that tag already exists.">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	            update alliance set 
					tag = '#alliance_name#',
					news = '#alliance.news##chr(10)#[yellow]#theDate#:[/yellow] Your alliance is now knows as #alliance_name#'
				where id = #alliance.id#
	        </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
				update player set hasAllianceNews = 1 where allianceID = #alliance.id#
			</cfquery>
			<!--- notify other alliances that are allied or at war with this one --->
			
		</cfif>
	<Cfelseif eflag is "change_description">
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update alliance set 
				description = '#form.description#'
			where id = #alliance.id#
        </cfquery>
	</cfif>
</cfif>
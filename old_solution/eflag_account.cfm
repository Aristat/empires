<cfif eflag is "change_pw">
	<cfif curPassword is not player.passwd>
		<cfset eflag_message = "Invalid current password entered.">
	<cfelseif newPassword is not newPassword2>
		<cfset eflag_message = "Your verify password does not match your new password.">
	<cfelse>
		<cfquery datasource="#dsn#">
            update player set passwd = '#newPassword#' where id = #playerID#
        </cfquery>	
		<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000AD account changed">
			Password for empire #player.name# has been changed to #newpassword#
			
			#webpath#login.cfm			
		</cfmail>
		<cfset eflag_message = "Password change successful.">
	</cfif>

<cfelseif eflag is "change_login">
	<!--- see if other player has the same login name --->
	<cfset newlogin = trim(form.newlogin)>
	<cfquery datasource="#dsn#" name="op">
        select id from player where loginname = '#newlogin#' and id <> #playerID#
    </cfquery>
	<cfif op.recordcount gt 0>
		<cfset eflag_message = "Cannot change login name. <br>Another player is using '#newlogin#'">
	<cfelse>
		<cfquery datasource="#dsn#">
            update player set loginname = '#newlogin#' where id = #playerID#
        </cfquery>
		<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000AD account changed">
			Login name for empire #player.name# has been changed to #newLogin#		
			
			#webpath#login.cfm
		</cfmail>
		<cfset eflag_message = "Login name change successful.">
		
	</cfif>
<cfelseif eflag is "delete_empire">
	<!--- cannot delete if attacked someone in past 24 hours --->
	<cfset yesDate = dateAdd("h", -24, now())>
	<cfquery name="a" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id from attackNews where attackID = #playerID# 
			and createdOn > #yesDate#
    </cfquery>

	
	<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select id from player where loginname = '#lname#' and passwd = '#curPassword#' and id = #playerID#
    </cfquery>

	<cfif p.recordcount is 0>
		<cfset eflag_message = "Invalid login name or password. <br>Account not deleted.">
	<cfelseif deathmatchStarted>
		<cfset eflag_message = "Cannot delete empires once deathmatch started.">
	<cfelseif a.recordCount gt 0>
		<cfset eflag_message = "You cannot delete your empire because you attacked someone in the past 24 hours.<br>">
	<cfelse>
		<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000AD account deleted">
			You have deleted your account for login name: #player.loginname#
			Empire Name: #player.name#
			Empire Number: #player.id#
		</cfmail>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
            delete from player where id = #p.id#
        </cfquery>
		<font face="verdana" size=2>
		Your empire has been deleted.<br><a href="login.cfm">Back to game home page</a>
		<cfset test = setVariable("session.#gameCode#playerID", 0)>	
		<cfset test = setVariable("session.#gameCode#loginname", "")>
		<cfset test = setVariable("session.#gameCode#loginpassword", "")>
		
		<cfabort>
	</cfif>
<cfelseif eflag is "vacation_empire">
	<!--- cannot delete if attacked someone in past 24 hours --->
	<cfset yesDate = dateAdd("h", -1, now())>
	<cfquery name="a" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id from attackNews where attackID = #playerID# 
			and createdOn > #yesDate#
    </cfquery>

	<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
    	select id from player where loginname = '#lname#' and passwd = '#curPassword#' and id = #playerID#
    </cfquery>
	
	<cfset vacation_end = dateAdd("h", 72, now())>

	<cfif p.recordcount is 0>
		<cfset eflag_message = "Invalid login name or password. <br>">
	<cfelseif deathmatchStarted>
		<cfset eflag_message = "Cannot go on vacation mode once deathmatch started.">
	<cfelseif a.recordCount gt 0>
		<cfset eflag_message = "You cannot activate vacation mode because you attacked someone in the past 1 hour.<br>">
	<cfelseif vacation_end gt endGameDate>
		<cfset eflag_message = "Cannot go on vacation mode less than 3 days before the game ends.<br>">
	<cfelse>
		<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000AD account set to activation mode">
			You account has been set to vacation mode.
			You will not be able to login until: #DateFormat(vacation_end, "mm/dd/yyyy")# #TimeFormat(vacation_end, "hh:mm tt")#
			Empire Name: #player.name# (#player.id#)
		</cfmail>
		
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set vacationEnd = #vacation_end# where id = #p.id#
        </cfquery>
		<cfset test = setVariable("session.#gameCode#playerID", 0)>	
		<cfset test = setVariable("session.#gameCode#loginname", "")>
		<cfset test = setVariable("session.#gameCode#loginpassword", "")>
		
		<font face="verdana" size=2>
		Your empire has been set to vacation mode.<br><a href="login.cfm">Back to game home page</a>
		<cfabort>
	</cfif>
	
</cfif>
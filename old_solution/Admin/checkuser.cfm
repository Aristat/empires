<cfparam name="session.#gameCode#playerID" default="0">
<cfparam name="session.#gameCode#loginName" default="0">
<cfparam name="session.#gameCode#loginPassword" default="0">

<cfset playerID = val(evaluate("session.#gameCode#playerID"))>
<cfset sLoginName = evaluate("session.#gameCode#loginName")>
<cfset sLoginPassword = evaluate("session.#gameCode#loginPassword")>

<cfif playerID is 0>
	You have to login to access this page.
	<cfabort>
</cfif>

<cfquery name="variables.player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select id, name, isAdmin from player where id = #playerID#
</cfquery>
<cfif variables.player.recordCount is 0>
	Unauthorized use.
	<cfabort>
</cfif>

<cfparam name="eflag" default="">

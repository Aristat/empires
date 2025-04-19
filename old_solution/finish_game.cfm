<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2001
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>End Game</title>
</head>

<body>

<!--- uncomment abort when done. Do not want to run this script --->
<cfabort>

<!--- gameID, must be valid game from ader db --->
<cfquery datasource="#ader_dsn#" name="g">
	select max(id)+1 as mid from game
</cfquery>
<cfset gameID = g.mid>
<cfquery datasource="#ader_dsn#">
	insert into game (id, start_date, end_date, name)
	values (#gameID#, #createODBCDate(startGameDate)#, 
		#createODBCDate(endGameDate)#, '#gameName#')
</cfquery>

<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select player.id, player.name, email, (mland+fland+pland) as land, score, civ,
		(research1 + research2 + research3 + research4 + research5 + research6 + research7 + research8 + research9 + research10 + research11 + research12) as research,
		alliance.tag, player.validated
	from
		player left outer join alliance on player.allianceID = alliance.id
	where killedBy = 0 
	order by score desc
</cfquery>


<cfloop query="player">
	<cfoutput>#player.currentrow#. #player.name# (#player.id#)<br></cfoutput>
	<cfif player.validated is 1>
	<!--- calc points --->
	<cfset points = 0>
	<cfif player.currentrow gt 50>
		<cfset points = 1>
	<cfelseif player.currentrow gt 40>
		<cfset points = 2>
	<cfelseif player.currentrow gt 30>
		<cfset points = 3>
	<cfelseif player.currentrow gt 25>
		<cfset points = 4>
	<cfelseif player.currentrow gt 20>
		<cfset points = 5>
	<cfelseif player.currentrow gt 18>
		<cfset points = 6>
	<cfelseif player.currentrow gt 16>
		<cfset points = 7>
	<cfelseif player.currentrow gt 14>
		<cfset points = 8>
	<cfelseif player.currentrow gt 12>
		<cfset points = 9>
	<cfelseif player.currentrow gt 10>
		<cfset points = 10>
	<cfelseif player.currentrow is 10>
		<cfset points = 11>
	<cfelseif player.currentrow is 9>
		<cfset points = 12>
	<cfelseif player.currentrow is 8>
		<cfset points = 13>
	<cfelseif player.currentrow is 7>
		<cfset points = 14>
	<cfelseif player.currentrow is 6>
		<cfset points = 15>
	<cfelseif player.currentrow is 5>
		<cfset points = 16>
	<cfelseif player.currentrow is 4>
		<cfset points = 17>
	<cfelseif player.currentrow is 3>
		<cfset points = 18>
	<cfelseif player.currentrow is 2>
		<cfset points = 20>
	<cfelseif player.currentrow is 1>
		<cfset points = 25>
	</cfif>	
	<cfif points gt 0>
		<cfquery datasource="#ader_dsn#">	
    	    insert into player (gameID, playerID, name, email, score, civ, land, research, alliance, rank, points)
			values (#gameID#, #player.id#, '#player.name#', '#player.email#', #player.score#,  
				#player.civ#, #player.land#, #player.research#, '#player.tag#', #player.currentrow#, #points#)
	    </cfquery>
	</cfif>

	<cfmail to="#player.email#" from="#adminEmail#" server="#mailserver#" subject="1000AD: #gameName# has ended.">
		1000AD #gameName# has ended.
		Your final results for empire #player.name# (#player.id#) are:
		Score: #numberformat(player.score)#
		Ranking: #numberformat(player.currentrow)# out of #numberformat(player.recordcount)#
		Land: #numberformat(player.land)#
		<cfif points gt 0>League Points: #points#</cfif>
		
		You can come and create your new empire at
		#webpath#
		
		Thank You for playing.
	</cfmail>
	</cfif>
	
</cfloop>

<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
SELECT id, tag,
        (SELECT COUNT(*)
      FROM player
      WHERE allianceID = alliance.id) AS members,
        (SELECT SUM(score)
      FROM player
      WHERE allianceID = alliance.id) AS total_score,
        (SELECT AVG(score)
      FROM player
      WHERE allianceID = alliance.id) AS avg_score
FROM Alliance
WHERE (SELECT COUNT(*)
      FROM player
      WHERE allianceID = alliance.id) > 2
ORDER BY total_score desc
</cfquery>
<cfloop query="alliance">
	<cfquery datasource="#ader_dsn#">	
        insert into alliance (gameID, allianceID, score, avg_score, members, name, rank)
		values (#gameID#, #alliance.id#, #alliance.total_score#, #alliance.avg_score#, #alliance.members#,
			'#alliance.tag#', #alliance.currentrow#)
    </cfquery>
</cfloop>

</body>
</html>

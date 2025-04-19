<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<cfparam name="eflag" default="">

<cfif eflag is "login">
	<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select id, civ, loginname, createdon, validationCode, passwd, validated, vacationEnd from player where loginname = '#form.loginname#' and passwd = '#form.loginpassword#'
    </cfquery>
	<cfif endGameDate lt now()>
		<font face="verdana" color="red" size="2">Sorry but this game has ended.</font>
	<cfelseif p.recordcount is 0>
		<cfset message = "Invalid login name or passwod">
	<cfelseif p.validated is 0>
		<cflocation url="validate.cfm">
	<cfelseif p.vacationEnd is not "" and p.vacationEnd gt now()>
		<cfset message = "Your empire is in vacation mode. You cannot login until: #DateFormat(p.vacationEnd, "mm/dd/yyyy")# #TimeFormat(p.vacationEnd, "hh:mm tt")#.">
	<cfelse>
		<cfset test = setVariable("session.#gameCode#playerID", p.id)>
		<cfset test = setVariable("session.#gameCode#loginname", p.loginname)>
		<cfset test = setVariable("session.#gameCode#loginpassword", p.passwd)>
		<cfset civID = p.civ>
		<cfinclude template="startSession.cfm">
		<cfset session.started = true>
		<cfset session.lastGame = gameCode>
		
		<!--- check if this user has any unanswered votes --->
		<cfquery name="vote" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
           	select id from vote where status = 1
				and (select count(*) from voteAnswer where voteAnswer.voteID = vote.id
					and voteAnswer.playerID = #p.id#) = 0
       </cfquery>
		<cfset page = "main">
		<cfif vote.recordCount gt 0>
			<cfset page = "votes">
		</cfif>
		
		<!--- if coming from vacation mode, need to update last turn --->
		<cfif p.vacationEnd is not "">
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            	update player set
					vacationEnd = null,
					lastTurn = #createODBCDateTime(p.vacationEnd)#
				where id = #p.id#
    	    </cfquery>
		</cfif>
		
		<cfinclude template="index.cfm">

		<cfparam name="cgi.remote_addr" default="">
		<cfparam name="cgi.http_referer" default="">
		<cfparam name="cgi.http_user_agent" default="">
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
               insert into loginEntry (playerID, createdOn, IPAddress, http_referer, http_user_agent)
			values (#playerID#, #Now()#, '#Left(cgi.REMOTE_ADDR, 20)#', '#Left(cgi.http_referer, 50)#', '#Left(cgi.http_user_agent, 50)#')
		</cfquery>

		<cfabort>
	</cfif>
<cfelseif eflag is "logout">
	<cfparam name="session.#gameCode#playerID" default="0">
	<cfparam name="session.#gameCode#loginName" default="0">
	<cfparam name="session.#gameCode#loginPassword" default="0">
	
	<cfset newLastLoad = dateAdd("n", -10, now())>
	<cfset pID = evaluate("session.#gameCode#playerID")>
	<cfquery datasource="#dsn#">
        update player set lastLoad = #newLastLoad# where id = #pID#
    </cfquery>
	<cfset test = setVariable("session.#gameCode#playerID", 0)>	
	<cfset test = setVariable("session.#gameCode#loginname", "")>
	<cfset test = setVariable("session.#gameCode#loginpassword", "")>

	<cfset session.started = false>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<style type="text/css">
    td {
		font-size:x-small;
		font-family:verdana;
		color:white;
	}
	A:hover {
		text-decoration: underline overline;
		color: red;
	}
</style>
	<title>Login</title>
</head>

<body bgcolor="Black" alink="Aqua" link="Aqua" text="White" vlink="Aqua" topmargin="0" marginheight="0" leftmargin="0" marginwidth="0">
<table border=0 cellspacing=0 cellpadding=0 width="610">
<tr><td colspan="3" align="center" background="images/header.jpg">
		<font face=verdana size=10 color="White"><b>1000   A. D.</b></font><br>
		<br>
		<font face=verdana size=2>
		<b>1000 A.D. is a free turn based strategy game. <br>
		All you need to play is a web browser. 		
		<br>
		<a href="http://www.adersoftware.com/thegame/">1000AD Home Page</a>
		<br>
		<br>
		
		</font>
	</td>
</tr>   
<tr>
	<td width="200" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="200" bordercolor="darkslategray" background="images/bgad.gif">
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">
				<b>Info</b>
			</font>
			</td>
		</tr>
		<tr>
			<td><font face=verdana size=2 color="White">
			Come and vote for 1000AD at <a href="http://www.mpogd.com/gotm/vote.asp" target="_blank">MPOGD site</a> for best online game. 
			</td>
		</tr>
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">
				<b>Available Game:</b>
			</font>
			</td>
		</tr>
		<tr><td>
				<a href="http://www.adersoftware.com/ad1000/login.cfm"><b>Standard Game:</b></a><br>
				turns every 10 minutes. <br>
				Max stored: 300<br>			
				<font size=1>Points count towards league</font><br>
				<hr noshade size="1" color="darkslategray">				

				<a href="http://www.adersoftware.com/tour/login.cfm"><b>Tournament Game:</b></a><br>
				turns every 5 minutes. <br>
				Max stored: 300<br>				
				<font size=1>Points count towards league</font><br>	
				<hr noshade size="1" color="darkslategray">

		
				<a href="http://www.adersoftware.com/ad1000_a/login.cfm"><b>Armaggeddon Game:</b></a><br>
				turns every 5 minutes. <br>
				Max stored: 1000<br>			
				<hr noshade size="1" color="darkslategray">				
		
				<a href="http://www.adersoftware.com/deathmatch/login.cfm"><b>Deathmatch Game:</b></a><br>
				turns every 5 minutes. <br>
				Max stored: 1000<br>			
				<hr noshade size="1" color="darkslategray">
				<a href="http://www.adersoftware.com/thegame3/login.cfm"><b>Test Game:</b></a><br>
				turns every 5 minutes. <br>
				Max stored: 500<br>			
				<hr noshade size="1" color="darkslategray">
				
				
				If you have questions about the game or find any bugs let me know:
				&lt;<a href="mailto:andrew@c3chicago.com">andrew@c3chicago.com</a>&gt;<br>
				<b><a href="http://www.adersoftware.com/thegame/">1000 AD Home Page</a></b>				
				</font>					
			</td>
		</tr>
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">
				<b>Docs</b>
			</font>
			</td>
		</tr>
		<tr>
			<td><font face=verdana size=2 color="White"><br>
				<a href="docs/index.cfm" target="_blank">1000 A.D. Documentation</a><br>
				<br>
			</td>
		</tr>
        <TR>
          <TD align=middle bgColor=darkslategray><FONT face=verdana 
            color=white size=2><B><A target=_blank 
            href="http://www.adersoftware.com/forums/">Game 
            Forums </B></FONT></TD></TR>
        <TR>
          <TD><FONT face=verdana color=white size=2>
		  	Post bugs, suggestions. Find alliance members. 
			Find out what's new and coming soon.
			<center><b><A target=_blank href="http://www.adersoftware.com/forums/">Game Forums</a></center>
			<br>
            </FONT>
			
		</TD>
		</TR>
        </table>
	</td>
	<td width="10">&nbsp;</td>
	<td width="400" align="right" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="400" bordercolor="darkslategray" background="images/bgad.gif">
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2>
				<b>Welcome to 1000 A.D.</b>
			</td>
		</tr>
		<tr>
			<td align="center">
			
		<font face=verdana size=2 color="White">
		<cfif deathMatchStarted>
			This deathmatch game is already in progress. <br>
			You can join this game next time.<br>
		<cfelse>
			If you have your account created, login below.<br>
			If not, <a href="createPlayer.cfm"><b>Click here</b></a> to get your FREE account.
		</cfif>
		</font><br>
		<br>
		
		<cfparam name="message" default="">
		<font face=verdana size=2 color="Yellow"><cfoutput>#message#</cfoutput></font>
		<cfif endGameDate lt now()><!--- game has ended --->
		<br><font face="verdana" size="2" color="Red">This game has ended.</font>
		<cfelse>
		<table border=0 cellspacing=0 cellpadding=4 style="border:thin outset" bgcolor="darkslategray" background="images/map.jpg">
		<form action="login.cfm" method="post" name="gForm">
		<input type="hidden" name="eflag" value="login">
		<tr>
			<td colspan="2" align="center"><font face="verdana" size=2>
			<font face="Arial" size=5><B><cfoutput>#gamename#</cfoutput></font>
			<cfif deathMatchMode>
			<br><a href="deathmatchrules.cfm">View Rules of Deathmatch</a>
			</cfif>
			<font face="verdana" size="1"><br>Game started: <cfoutput>#DateFormat(startGameDate, "mmm. dd, yyyy")#</cfoutput>
			<br>Game Ends: 
			<cfif deathMatchMode>
				Until there is only one.
				<cfif not deathMatchStarted>
				<br>Deathmatch Starts on<br>
				<cfoutput>#DateFormat(deathmatchStart, "mmm. dd, yyyy")#
				at #TimeFormat(deathMatchStart, "hh:mm tt")#
				</cfoutput>
				</cfif>
			<cfelse>
				<cfoutput>#DateFormat(endGameDate, "mmm. dd, yyyy")#</cfoutput>
			</cfif>
			</font>
			<br>
			<br>
			<font face="verdana" size=2 color="Yellow">1 Turn every <cfoutput>#minutesPerTurn# minutes.<br>Max turns stored: #maxTurnsStored#</cfoutput></td>
		</tr>
		<tr>
			<td>Login Name:</td>
			<td><input type="Text" name="loginname" value=""></td>
		</tr>   
		<tr>
			<td>Password:</td>
			<td><input type="Password" name="loginpassword" value=""></td>
		</tr>   
		<tr>
			<td colspan="2" align="center"><input type="Submit" value="Login">
			<br><br>
			<cfif not deathMatchStarted>
			<a href="createPlayer.cfm"><b>or get your FREE account</b></a>
			</cfif>
			</td>
		</tr>
		</form>
		</table>

		<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
        <!--
        	document.gForm.loginname.focus();
        //-->
        </SCRIPT>
		
		</cfif>
		<br>
		<br>
		Forgot your password or login name? <br>
		<a href="forgotpassword.cfm">Click here.</a>
		<br>
		<br>
		</td></tr>
		<tr><td bgcolor="darkslategray" align="center"><font face="verdana" size=2 color="White"><b>Current Rankings</font></td></tr>
		<tr>
			<td align="center"><font face="verdana" size=2>
			<a href="rank.cfm?rank=top10">Top 10 Empires</a><br>
			<cfif not deathmatchMode and allianceMaxMembers gt 0>
			<a href="rank.cfm?rank=alliance_by_score">Top Alliances By Score</a><br>
			<a href="rank.cfm?rank=alliance_by_avgscore">Top Alliances By Avg. Score</a><br>
			<a href="rank.cfm?rank=alliance_by_members">Top Alliances By Num. Members</a><br>
			</cfif>
			</font><br>
			
			</td>
		</tr>
		<tr><td bgcolor="darkslategray" align="center"><font face="verdana" size=2 color="White"><b>
			Past Game Winners</font></td></tr>
		<tr>
			<td align="center" background="images/bgad.gif"><font face="verdana" size=3><b>
			<a href="http://www.1000ad.net/thegame/pastWinners.cfm" target="_blank">1000 A.D. Past Games Winners</a><br>
			<br>
			<a href="http://www.1000ad.net/thegame/league.cfm" target="_blank">1000 A.D. League</a><br>
			</font><br>
			
			</td>
		</tr>				

		</table>
		<br>
	</td>
</tr>
<tr><td colspan="3" align="center"><font face=verdana size=2 color="White">
	<hr noshade size="1" color="darkslategray">
	&copy; Copyright Ader Software 2000, 2001<br>
	<a href="mailto:andrew@c3chicago.com">Contact Us</a>
</td></tr>
</table>


</body>
</html>

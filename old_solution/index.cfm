<!---
	1000 AD
	Andrew Deren
	(C) AderSoftware 2000
--->

<cfif endGameDate lt now()>
	<font face="verdana" color="red" size="2">Sorry but this game has ended.</font><br>
	<font face="verdana" size="2"><a href="http://www.1000ad.net/thegame/">1000 AD Home Page</a></font>
	<br>
</cfif>

<cfparam name="session.#gameCode#playerID" default="0">
<cfparam name="session.#gameCode#loginName" default="0">
<cfparam name="session.#gameCode#loginPassword" default="0">
<cfparam name="session.lastGame" default="#gameCode#">

<cfset playerID = val(evaluate("session.#gameCode#playerID"))>
<cfset sLoginName = evaluate("session.#gameCode#loginName")>
<cfset sLoginPassword = evaluate("session.#gameCode#loginPassword")>

<cfif playerID is 0>
	<cfset message = "You have to login to access this page">
	<cfinclude template="login.cfm">
	<cfabort>
</cfif>

<cfif not session.started>
	<cfquery name="p" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select loginname, passwd, civ from player where id = #playerID#
    </cfquery>
	<cfif p.loginname is not sLoginName or p.passwd is not sLoginPassword>
		<cfset message = "You have to login to access this page">
		<cfinclude template="login.cfm">
		<cfabort>
	</cfif>
</cfif>

<cfif session.lastGame is not gameCode><!--- so that session vars don't get confused between two games --->
	<font face="verdana" size=2 color=red>
	If you're playing another game (deathmatch, standard or test) you have to logout from one and login again in this one 
	in order to play.<br>
	<a href="login.cfm">Please login again.</a>
	</font>
	<cfabort>
</cfif>

<cfset buildings = session.buildings>
<cfset woodCutterB = buildings[1]>
<cfset hunterB = buildings[2]>
<cfset farmerB = buildings[3]>
<cfset houseB = buildings[4]>
<cfset ironMineB = buildings[5]>
<cfset goldMineB = buildings[6]>
<cfset toolMakerB = buildings[7]>
<cfset weaponSmithB = buildings[8]>
<cfset fortB = buildings[9]>
<Cfset towerB = buildings[10]>
<cfset townCenterB = buildings[11]>
<cfset marketB = buildings[12]>
<cfset warehouseB = buildings[13]>
<cfset stableB = buildings[14]>
<cfset mageTowerB = buildings[15]>
<cfset wineryB = buildings[16]>

<cfset soldiers = session.soldiers>	
<cfset archerA = soldiers[1]>
<cfset swordsmanA = soldiers[2]>
<cfset horsemanA = soldiers[3]>
<Cfset towerA = soldiers[4]>
<cfset catapultA = soldiers[5]>
<cfset macemanA = soldiers[6]>
<cfset trainedPeasantA = soldiers[7]>
<cfset thievesA = soldiers[8]>
<cfset uunitA = soldiers[9]>

<cfset woodMinPrice = 5>
<cfset woodMaxPrice = 80>
<cfset foodMinPrice = 5>
<cfset foodMaxPrice = 40>
<cfset ironMinPrice = 20>
<Cfset ironMaxPrice = 250>
<cfset toolsMinPrice = 50>
<Cfset toolsMaxPrice = 500>
<cfset macesMinPrice = 50>
<Cfset macesMaxPrice = 1000>
<Cfset swordsMinPrice = 100>
<cfset swordsMaxPrice = 3000>
<cfset bowsMinPrice = 100>
<cfset bowsMaxPrice = 3000>
<cfset horsesMinPrice = 100>
<cfset horsesMaxPrice = 3000>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
<!---meta HTTP-EQUIV="Expires" CONTENT="Mon, 06 Jan 1990 00:00:01 GMT"---> 
<style type="text/css">
	TD {
		font-family:verdana;
		font-size: 12px;
	}  
	TD.SMALL {
		font-family:verdana;
		font-size: 10px;	
	}
	TD.HEADER {
		font-family:verdana;
		font-size: 12px;
		background-color: darkslategray;
		color: white;	
	}
	A {
		text-decoration: none;
	}
	A:hover {
		color: red;
		text-decoration: overline underline;
	}
</style>
	<title>1000 A.D.</title>
</head>
<body background="images/bgad.gif" bgcolor="Black" alink="Aqua" link="Aqua" text="White" vlink="Aqua">

<cfparam name="eflag" default="">
<cfparam name="page" default="main">

<cfset message = "">
<cfset eflag_message = "">
<cfset theDate = "#DateFormat(now(), "mm/dd/yyyy")# #TimeFormat(now(), "hh:mm tt")#">

<cfif eflag is "end_turn" or eflag is "end_x_turns">
	<cfinclude template="eflag_endturn.cfm">
<cfelseif eflag is not "">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from player where id = #playerID#
	</cfquery>
	<cfif player.recordcount is 0><font face="verdana" color=red size=2>Account does not exist.</font><cfabort></cfif>	
	<cfif player.killedBy gt 0 and page is not "player_messages"><!--- allow sending messages --->
		<font face="verdana" color=red size=2>Sorry, but you're dead.</font><br>
	<cfelse>
		<cfinclude template="eflag_#page#.cfm">
	</cfif>
</cfif>

<cfif eflag_message is not "">
<table border=1 cellpadding=0 cellspacing=0 width="780">
<tr><td bgcolor="White" align="center">
<font face="verdana" size=2 color="red"><b><cfoutput>#eflag_message#<br></cfoutput></font>
</td></tr>
</table>
</cfif>		

<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    select * from player where id = #playerID# and loginName = '#sLoginName#' and passwd = '#sLoginpassword#'
</cfquery>
<cfif player.recordcount is 0>Account does not exist.<cfabort></cfif>

<cfset playerTurns = player.turnsFree>
<cfset sDate = now()>

<cfif deathMatchMode>
	<cfif not isDate(player.lastTurn)><!--- never played --->
		<cfset playerDate = deathMatchStart>
	<cfelseif player.lastTurn lt deathMatchStart><!--- start counting turns only from deathmatch start date --->
		<cfset playerDate = deathMatchStart>
	<cfelse>
		<cfset playerDate = player.lastTurn>
	</cfif>
<cfelse>
	<cfset playerDate = player.lastTurn>
</cfif>

<cfset minutes = DateDiff("n", playerDate, sDate)>

<cfset newTurns = int(minutes / minutesPerTurn)>

<cfif newTurns gt 0>
	<cfset addMinutes = newTurns * minutesPerTurn>
	<cfset newDate = DateAdd("n", addMinutes, playerDate)>
	<cfset playerTurns = playerTurns + newTurns>
	<cfif playerTurns gt maxTurnsStored><cfset playerTurns = maxTurnsStored></cfif>	
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update player set 
			lastTurn = #newDate#, 
			turnsFree = #playerTurns#,
			lastLoad = #now()#
		where id = #playerID#
    </cfquery>
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select * from player where id = #playerID#
    </cfquery>
<cfelse>
	<cfif player.lastLoad is "" or dateDiff("n", player.lastLoad, Now()) gt 5>
		<cfquery datasource="#dsn#">
    		update player set lastLoad = #createODBCDateTime(now())# where id = #playerID#
		</cfquery>
	</cfif>
</cfif>


<cfset nextTurnSeconds = DateDiff("s", player.lastTurn, sDate)>
<cfset nextTurnSeconds = (minutesPerTurn*60) - nextTurnSeconds>

<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function openHelp(h)
{
	window.open("docs/index.cfm?page="+h, "_blank", "width=800,height=500,scrollbars=yes");
}
function insertCode(code, obj)
{
	obj.value += code;
}
function insertSmile(obj)
{
  popupWin = window.open('ubb_smile.cfm?obj='+obj, 'new_page','width=350,height=340');
}
function insertFontColor(sel, obj)
{
	var color = sel.options[sel.selectedIndex].value;
	obj.value += "[" + color + "][/" + color + "]";
}
function insertFontSize(sel, obj)
{
	var size = sel.options[sel.selectedIndex].value;
	obj.value += "[size" + size + "][/size" + size + "]";
}
//-->
</SCRIPT>
<table border=0 cellspacing=0 cellpadding=0 width="780"> 
<tr><td colspan="3" align="center">
		<font face=verdana size=10 color="White"><b>1000   A. D.</b><br></font>
		<font face=verdana size=4><cfoutput><b>#player.name# ###player.id#  - #empireNames[player.civ]# </cfoutput></font><br>
		<cfset month = (player.turn mod 12)+1>
		<cfset year = int(player.turn / 12) + 1000>
		<cfoutput><font face="verdana" size=2><b>#MonthAsString(month)# #year#</b></font></cfoutput>
		
		<cfif message is not "">
		<br>
		<table border=1 cellspacing=0 cellpadding=0 bordercolor="darkslategray">
		<tr>
			<td><cfoutput>#message#</cfoutput><br></td>
		</tr>
		</table>
		</cfif>
		
		<cfif player.killedBy gt 0>
			<br><font face="verdana" color=red size=4><b>You have been killed by <cfoutput>#player.killedByName# (#player.killedBy#)</cfoutput></font>
			<br>
			<cfif player.killedBy is 1>
				<font face="verdana" color="red" size="2">You might have been killed because of cheating (using multiple accounts).
				<br>
				If you think it was a mistake, send email to andrew@c3chicago.com.
				</font>
			</cfif>
		</cfif>
	</td>
</tr>   
<tr><td colspan="3">
<br><font face=verdana size=1>
		<cfoutput>
		<cfif deathMatchMode>
			(#playerTurns# months remaining, 
			<cfset min = dateDiff("n", now(), deathmatchStart)>
			<cfif min gt 0>
				<b>Deathmatch will start in #val(fix(min/60))# hours and #val(min mod 60)# minutes (no turns added until then).</b>
			<cfelse>
				<cfif playerTurns gte maxTurnsStored>maximum turns stored<cfelse>next free month in #int(val(nextTurnSeconds/60))# minutes and #val(nextTurnSeconds mod 60)# seconds</cfif></font>				
			</cfif>
			)
		<cfelse>
			(#playerTurns# months remaining, 
			<cfif playerTurns gte maxTurnsStored>maximum turns stored<cfelse>next free month in #int(val(nextTurnSeconds/60))# minutes and #val(nextTurnSeconds mod 60)# seconds</cfif>)</font>
		</cfif>
		</cfoutput>						
	</td>
</tr>
<tr>
	<td width="150" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="200" bordercolor="darkslategray">
        <tr>
			<td bgcolor="darkslategray" align="center"><font face=verdana size=2 color="White">
				<b>Menu</b>
			</font>
			</td>
		</tr>
		<tr>
			<td><font face=verdana size=2 color="White">
				<cfinclude template="left_menu.cfm">
				</font>					
				<br>
				<br>
				
			</td>
		</tr>
        <tr>
			<td bgcolor="darkslategray" align="center"><b><font face=verdana size=2 color="White">Documentation / Etc.</font></td>
		</tr>
		<tr><td><font face="verdana" size=2>
			<li><a href="javascript:openHelp('home')">Game Help / Docs</a>
			<li><a href="index.cfm?page=votes">Game Votes</a>
			<li><a href="index.cfm?page=news">Game News</a>
		</td></tr>
        <TR>
          <TD align=middle bgColor=darkslategray><FONT face=verdana 
            color=white size=2><B><A target=_blank 
            href="http://www.adersoftware.com/forums/">Game 
            Forums </B></FONT></TD></TR>
        <TR>
          <TD><FONT face=verdana color=white size=2>
		  	Post bugs, suggestions. Find alliance members. 
			Find out what's new and coming soon.
			<li><b><A target=_blank href="http://www.adersoftware.com/forums/">Game Forums</a>
            </TD>
		</TR>

		
        </table>
	</td>
	<td width="10">&nbsp;</td>
	<td width="600" align="right" valign="top">
		<table border=1 cellspacing=0 cellpadding=0 width="600" bordercolor="darkslategray">
        <tr>
			<cfoutput>
			<td nowrap bgcolor="darkslategray" align="center"><font face=verdana size=2>
			<b>Score: #NumberFormat(player.score)#</b>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</td>
			<td nowrap align=center bgcolor="darkslategray"><font face=verdana size=2>
				<b>Population: #NumberFormat(player.people)#</b>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<b>Gold: #NumberFormat(player.gold)#</b>				
			</td>
			<td nowrap align="right" bgcolor="darkslategray"><font face=verdana size=2>
				<a href="index.cfm?page=#page#&eflag=end_turn">END TURN</a>
			</td>
			</cfoutput>
		</tr>
		<tr>
			<td colspan="3">
			<table border=0 cellspacing=0 cellpadding=0 width="100%">
            <tr>
			<!--- calculate free land --->
			<cfset usedM = player.ironMine * ironMineB.sq + player.goldMine * goldMineB.sq>
			<cfset usedF = player.hunter * hunterB.sq + player.woodcutter * woodCutterB.sq>
			<cfset usedP = 	player.farmer * farmerB.sq + 
							player.house * houseB.sq + 
							player.toolmaker * toolmakerB.sq + 
							player.weaponsmith * weaponSmithB.sq + 
							player.fort * fortB.sq + 
							player.tower * towerB.sq +
							player.towncenter * towncenterB.sq + 
							player.market * marketB.sq + 
							player.warehouse * warehouseB.sq +
							player.stable * stableB.sq + 
							player.magetower * magetowerB.sq +
							player.winery * wineryB.sq
						>
			<cfset freeM = player.mland - usedM>
			<cfset freeF = player.fland - usedF>
			<cfset freeP = player.pland - usedP>
			<td>
				<cfoutput>
				
				<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>
				<TR>
					<TD>
						<TABLE borderColor=##333333 cellSpacing=0 cellPadding=2 border=0>
						<TR>
							<TD bgColor=##663333><B>Total:</B></TD>
							<TD noWrap bgColor=##663333><IMG alt="Total Mountain Land" src="images/mland.gif" align=absmiddle border=0><font size=1>#numberformat(player.mland)#</TD>
							<td width="10" bgColor=##663333>&nbsp;</td>
							<TD noWrap bgColor=##663333><IMG alt="Total Forest Land" src="images/fland.gif" align=absmiddle border=0><font size=1>#numberformat(player.fland)#</TD>
							<td width="10" bgColor=##663333>&nbsp;</td>						
							<TD noWrap bgColor=##663333><IMG alt="Total Plains Land" src="images/pland.gif" align=absmiddle border=0><font size=1>#numberformat(player.pland)#</TD>			
						</tr>						
						<tr>
							<TD bgColor=##336633><B>Free:</B></TD>
							<TD noWrap bgColor=##336633><IMG alt="Free Mountain Land" src="images/mland_free.gif" align=absmiddle border=0><font size=1>#numberformat(freeM)#</TD>
							<td width="10" bgColor=##336633>&nbsp;</td>						
							<TD noWrap bgColor=##336633><IMG alt="Free Forest Land" src="images/fland_free.gif" align=absmiddle border=0><font size=1>#numberformat(freeF)#</TD>
							<td width="10" bgColor=##336633>&nbsp;</td>						
							<TD noWrap bgColor=##336633><IMG alt="Free Plains Land" src="images/pland_free.gif" align=absmiddle border=0><font size=1>#numberformat(freeP)#</TD>			
						</tr>
						<!---
						<tr>
							<TD><B></B></TD>
							<TD noWrap><IMG alt="Maces" width="24" height="24" src="images/mace.gif" align=absmiddle border=0><font size=1>#numberformat(player.maces)#</TD>										
							<td width="10">&nbsp;</td>						
							<TD noWrap><IMG alt="Swords" width="24" height="24" src="images/sword.gif" align=absmiddle border=0><font size=1>#numberformat(player.swords)#</TD>							
							<td width="10">&nbsp;</td>						
							<TD noWrap><IMG alt="Bows" width="24" height="24" src="images/bow.gif" align=absmiddle border=0><font size=1>#numberformat(player.bows)#</TD>
						</tr>
						--->
						</table>
					</td>			
					<TD width=10>&nbsp;</TD>
					<TD align=right>
						<TABLE borderColor=silver cellSpacing=0 cellPadding=2 border=0>
						<TR>
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.food)# food available" ><IMG src="images/food.gif" width="24" height="24" alt="Food" align=absmiddle border=0><font size=1>#NumberFormat(player.food)#</TD>						
							<td width="10">&nbsp;</td>						
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.wood)# wood available" ><IMG src="images/wood.gif" width="24" height="24" alt="Wood" align=absmiddle border=0><font size=1>#NumberFormat(player.wood)#</TD>						
							<td width="10">&nbsp;</td>						
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.iron)# iron available" ><IMG src="images/iron.gif" width="24" height="24" alt="Iron" align=absmiddle border=0><font size=1>#NumberFormat(player.iron)#</TD>						
						</tr>			
						<TR>
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.wine)# wine available" ><IMG src="images/wine.gif" width="24" height="24" alt="Wine" align=absmiddle border=0><font size=1>#NumberFormat(player.wine)#</TD>
							<td width="10">&nbsp;</td>							
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.tools)# tools available" ><IMG src="images/tools.gif" width="24" height="24" alt="Tools" align=absmiddle border=0><font size=1>#NumberFormat(player.tools)#</TD>						
							<td width="10">&nbsp;</td>
							<TD noWrap style="cursor:default" title="You have #NumberFormat(player.horses)# horses available" ><IMG src="images/horse.gif" width="24" height="24" alt="Horses" align=absmiddle border=0><font size=1>#NumberFormat(player.horses)#</TD>
						</tr>			
						
						</table>
					</td>
				</tr>
				</table>		
				</cfoutput>
				</td>
			</tr>
            </table>
			</td>
		</tr>
		<tr>
			<td align="center" colspan="3">
				<cfinclude template="#page#.cfm">
			</td>
		</tr>			
		</table>
		<br>
		<br>
	</td>
</tr>
<tr><td colspan="3" align="center"><font face=verdana size=2 color="White">
	<hr noshade size="1" color="darkslategray">
	Game Time: <cfoutput>#DateFormat(now(), "mmm d, yyyy")# #TimeFormat(now(), "hh:mm tt")#</cfoutput><br>
	<!--- show time remaining until reset --->
	Game ends in
	<cfset mins = dateDiff("n", now(), endGameDate)>
	<cfset days = fix(mins / 1440)>
	<cfif days gt 0><cfoutput>#days# days, </cfoutput></cfif>
	<Cfset mins = mins - days * 1440>
	<cfset hours = fix(mins / 60)>
	<cfif hours gt 0><cfoutput>#hours# hours, </cfoutput></cfif>
	<cfoutput>#val(mins mod 60)# minutes.</cfoutput>
	
	<br>
	
	&copy; Copyright Ader Software 2000, 2001<br>
	<a href="mailto:andrew@c3chicago.com">Contact Us</a><br>
</td></tr>
</table>


</body>
</html>

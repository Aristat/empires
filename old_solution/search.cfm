<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr>
	<td class="HEADER" align="center" width="100%"><font face="verdana" size="3"><b>Search</td>
</tr>
</table>


<cfparam name="searchType" default="">
<cfparam name="searchString" default="">
<br>
<br>
<table border=1 cellspacing=1 cellpadding=1 bordercolor="darkslategray" width="300">
<form action="index.cfm" method="post">
<input type="hidden" name="page" value="search">
<tr><td align="center" bgcolor="darkslategray"><font face=verdana size=2 color=white>Search Players where:</font></td></tr>
<tr><td><font face="verdana" size="2">
	<input type="Radio" name="searchType" <cfif searchType is "playerNumber" or searchType is "">checked</cfif> value="playerNumber">Player Number<br>
	<input type="Radio" name="searchType" <cfif searchType is "playerName">checked</cfif> value="playerName">Player Name<br>
	<input type="Radio" name="searchType" <cfif searchType is "allianceName">checked</cfif> value="allianceName">Alliance Name<br>
	<input type="Radio" name="searchType" <cfif searchType is "online">checked</cfif> value="online">Player Online<br>
	&nbsp;&nbsp;&nbsp;&nbsp;is <input type="Text" name="searchString" value="<cfoutput>#searchString#</cfoutput>" size=20 style="font-size:xx-small">
</td></tr>
<tr><td bgcolor="darkslategray"><center><input type="Submit" value="Search" style="font-size:xx-small;width:80"></center></td></tr>
</form>
</table>

<cfif searchType is not "">
<br>
<br>

	<cfquery name="member" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#" maxrows="100">	
    	select player.id, player.name, (pland+mland+fland) as totalland, score, alliance.tag, lastLoad, alliance.leaderID, civ
		from player left outer join alliance on player.allianceID = alliance.id 
		<cfif searchType is "playerNumber">where player.id = #val(searchString)#
		<cfelseif searchType is "playerName">where player.name like '%#searchString#%'
		<cfelseif searchType is "allianceName">where alliance.tag like '%#searchString#%'
		<cfelseif searchType is "online">where lastLoad > #CreateODBCDateTime(DateAdd("n", -10, Now()))#
		</cfif>
		order by score desc
    </cfquery>
	<cfif member.recordcount is 0>
		<font face="verdana" color="red" size="2">No players found.</font>
	<cfelse>
		<table border="1" cellpadding="1" cellspacing="1" width="400" bordercolor="darkslategray">
        <tr>
			<td colspan="2" class="HEADER" align="center">Search Results (<cfoutput>#member.recordcount#</cfoutput>):</td>
		</tr>
		<tr><td align="center">
		<cfoutput query="member" maxrows="100">
			#member.name# (###member.id#) <br>
			#empireNames[member.civ]#<br>
			<cfquery name="memberRank" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
            	select count(*)+1 as cnt from player where score > #member.score# 
            </cfquery>
			<cfif isDate(member.lastLoad)><cfif abs(dateDiff("n", member.lastLoad, now())) lt 10><font color=red>Online Now</font><br></cfif></cfif>
			Rank: #memberRank.cnt#<br>		
			Alliance: <cfif member.leaderID gt 0 and member.id is member.leaderID>[#member.tag#]<cfelse>#member.tag#</cfif><br>	
			Score: #NumberFormat(member.score)#<br>
			Land: #NumberFormat(member.totalland)#<br>
			<cfif member.currentrow is not member.recordcount><hr noshade size="2" color="darkslategray"></cfif>
		</cfoutput>
			</td>
		</tr>
		<cfif member.recordcount gte 100>
		<tr><td align="center"><font face="verdana" color="red" size="2">More than 100 results found.<br> Displaying first 100 results.</font></td></tr>
		</cfif>
		</table>
		<br>
	</cfif>
	
</cfif>
<cfset nameList = "Home">
<cfset pageList = "home">

<cfswitch expression="#page#">
<cfcase value="home">
</cfcase>
<cfcase value="basics">
	<cfset nameList = nameList & ",Game Basics">
	<cfset pageList = pageList & ",basics">
</cfcase>
<cfcase value="resources">
	<cfset nameList = nameList & ",Resources">
	<cfset pageList = pageList & ",resources">
</cfcase>
<cfcase value="army">
	<cfset nameList = nameList & ",Game Units">
	<cfset pageList = pageList & ",army">
</cfcase>
<cfcase value="research">
	<cfset nameList = nameList & ",Research">
	<cfset pageList = pageList & ",research">
</cfcase>
<cfcase value="trade">
	<cfset nameList = nameList & ",Trade">
	<cfset pageList = pageList & ",trade">
</cfcase>
<cfcase value="aid">
	<cfset nameList = nameList & ",Aid">
	<cfset pageList = pageList & ",aid">
</cfcase>
<cfcase value="explore">
	<cfset nameList = nameList & ",Exploring">
	<cfset pageList = pageList & ",explore">
</cfcase>
<cfcase value="buildings">
	<cfset nameList = nameList & ",Buildings">
	<cfset pageList = pageList & ",buildings">
</cfcase>
<cfcase value="attack">
	<cfset nameList = nameList & ",Attacking">
	<cfset pageList = pageList & ",attack">
</cfcase>
<cfcase value="people">
	<cfset nameList = nameList & ",Population">
	<cfset pageList = pageList & ",people">
</cfcase>
<cfcase value="civs">
	<cfset nameList = nameList & ",Civilizations">
	<cfset pageList = pageList & ",civs">
</cfcase>
<cfcase value="search">
	<cfset nameList = nameList & ",Search Results">
	<cfset pageList = pageList & ",search">
</cfcase>
<cfcase value="wall">
	<cfset nameList = nameList & ",Great Wall">
	<cfset pageList = pageList & ",wall">
</cfcase>
<cfcase value="manage">
	<cfset nameList = nameList & ",Management">
	<cfset pageList = pageList & ",manage">
</cfcase>
<cfcase value="alliance">
	<cfset nameList = nameList & ",Alliance">
	<cfset pageList = pageList & ",alliance">
</cfcase>

</cfswitch>

<cfset names = listToArray(nameList)>
<cfset pages = listToArray(pageList)>
<cfoutput>
<table border=0 cellpadding=0 cellspacing=0 width="100%" style="border-bottom:1px solid #borderColor#">
<tr>
	<td width="15"></td>
<cfloop from="1" to="#arrayLen(names)#" index="i">
	<td align="center" nowrap width="80" style="border-top:1px solid #borderColor#;border-right:1px solid #borderColor#;border-left:1px solid #borderColor#;<cfif i is arrayLen(names)>background-color: #borderColor#;</cfif>">
		<a href="index.cfm?page=#pages[i]#">#names[i]#</a>
	</td>
	<td width="5"></td>
</cfloop>
	<td>&nbsp;</td>
</tr>
</table>
</cfoutput>
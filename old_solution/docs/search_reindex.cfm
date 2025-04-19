<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- pages to index --->
<cfset pageFiles = listToArray("home,basics,resources,buildings,army,attack,explore,people,research,trade,aid,civs,wall,alliance,manage")>
<cfset pageNames = listToArray("Home,Game Basics,Resources,Buildings,Unit,Attacking,Exploring,Population,Research,Trade,Aid,Civilizations,Wall,Alliance,Management")>

<cfindex action="PURGE" collection="#veritySearch#">
<font face="verdana" size="2">
<cfset count = arrayLen(pageFiles)>
<cfloop from="1" to="#count#" index="i">
	<cfset f = "#filepath#\docs\#pageFiles[i]#.cfm">
	<cfif not fileExists(f)>Not found</cfif>
	<cfindex collection="#veritySearch#" type="FILE" title="#pageNames[i]#" action="UPDATE" key="#f#" custom1="#pageFiles[i]#">
	<cfoutput>#i#: #pagenames[i]# - #f#<br></cfoutput>
</cfloop>


</body>
</html>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>1000 AD Chat</title>
</head>

<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">


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

<cfquery datasource="#dsn#" name="player">
	select id, name, email from player where loginName = '#sLoginname#' and id = #playerID# and passwd = '#sLoginpassword#'
</cfquery>

<!--Begin code for ConferenceRoom Applet-->
<table border=0 width=500 align=center><tr><td>
<applet archive="http://irc.webmaster.com/backpack/cr.zip" 
	codebase="http://irc.webmaster.com/backpack/" 
	name=cr 
	code="ConferenceRoom.class" 
	width=600 
	height=400> 
<param name=channel value=#AD1000> 
<param name=showbuttonpanel value=false>
<param name=bg value=FFFFFF>
<param name=fg value=000000>
<param name=roomswidth value=0>
<param name=lurk value=false>
<param name=simple value=true>
<param name=restricted value=true>
<param name=showjoins value=true>
<param name=showserverwindow value=false>
<param name=nicklock value=true>
<param name=playsounds value=false>
<param name=onlyshowchat value=true>
<param name=showcolorpanel value=false>
<param name=floatnewwindows value=false>
<param name=timestamp value=false>
<param name=listtime value=0>
<param name=guicolors1 value="youColor=000000;operColor=FF0000;voicecolor=006600;userscolor=000099">
<param name=guicolors2 value="inputcolor=FFFFFF;inputtextColor=000099;sessioncolor=FFFFFF;systemcolor=0000FF">
<param name=guicolors3 value="titleColor=FFFFFF;titletextColor=000099;sessiontextColor=000000">
<param name=guicolors4 value="joinColor=009900;partColor=009900;talkcolor=000099">
<cfset chatName = replace(player.name, " ", "_", "ALL") & "_#playerID#">
<param name=nick value="<cfoutput>#chatName#</cfoutput>"> 
<center> This application requires Java suport.<br> This server also available via IRC at:<br> <a href="irc://%hostname%:%port%/">irc://%hostname%:%port%/</a></center></applet> </td></tr></table>
<!--End code for ConferenceRoom Applet-->

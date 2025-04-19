<cfinclude template="checkUser.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfinclude template="style.cfm">
	<title>1000 AD Admin</title>
</head>

<body>

<cfif eflag is "add_news">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        insert into gameNews (createdOn, message)
		values (#now()#, '#message#')
    </cfquery>
<cfelseif eflag is "update_news">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        update gameNews set message = '#message#' where id = #newsID#
    </cfquery>
<cfelseif eflag is "delete_news">
	<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
		delete from gameNews where id = #newsID#
    </cfquery>
</cfif>

<font face="verdana" size=2>
<b>Current News:</b>
<br>
<cfquery name="news" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	select * from gameNews order by createdOn desc
</cfquery>
<table border=0 cellpadding=0 cellspacing=1>
<tr>
	<td class="HEADER">Date</td>
	<td class="HEADER">Message</td>
</tr>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
<!--
function delete_news(form)
{
	form.eflag.value = 'delete_news';
	form.submit();
}
//-->
</SCRIPT>
<cfoutput query="news">
<form action="admin_news.cfm" method="post" name="nForm#news.id#">
<input type="hidden" name="eflag" value="update_news">
<input type="hidden" name="newsID" value="#news.id#">
<tr>
	<td valign="top">#DateFormat(news.createdOn, "mm/dd/yyyy")#
		<br>
		<input type="Submit" value="Update" style="font-size:10px;width:100px"><br>
		<input type="Button" value="Delete" style="font-size:10px;width:100px" onclick="delete_news(document.nForm#news.id#)">
	</td>
	<td><textarea name="message" rows="3" cols="50">#news.message#</textarea></td>
</tr>
<tr><td colspan="3" class="HEADER"></td></tr>
</form>
</cfoutput>
<cfif news.recordcount is 0>
<tr><td colspan="3">No News</td></tr>
</cfif>
<tr>
	<td colspan="3" class="HEADER">Add News</td>
</tr>
<form action="admin_news.cfm" method="post" name="nFormA">
<input type="hidden" name="eflag" value="add_news">
<tr>
	<td valign="top"><cfoutput>#DateFormat(now(), "mm/dd/yyyy")#</cfoutput>
		<br>
		<input type="Submit" value="Add" style="font-size:10px;width:100px"><br>
	</td>
	<td><textarea name="message" rows="3" cols="50"></textarea></td>
</tr>
<tr><td colspan="3" class="HEADER"></td></tr>
</form>

</table>

</font>

</body>
</html>

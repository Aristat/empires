<cfsearch collection="#veritySearch#" criteria="#searchstring#" name="p">
<cfif p.recordcount is 0>
	<font face="verdana" size=2 color=red>0 Results</font>
<cfelse>
	<cfoutput query="p">
		<b>#p.currentrow#. <a href="index.cfm?page=#p.custom1#">#p.title#</a> (#val(val(p.score)*100)#%)<br></b>
		#p.summary#
		<hr noshade size="1" color="#bordercolor#">
	</cfoutput>
</cfif>
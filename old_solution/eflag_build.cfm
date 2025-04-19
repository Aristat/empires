<cfif eflag is "build">
	<cfset qty = val(form.qty)>
	<cfif buildingno lt 1 or buildingno gt arrayLen(buildings)>
		<cfset eflag_message = "Invalid building to build.">
	<cfelseif qty lt 0 or qty gt 10000000>
		<cfset eflag_message = "Invalid number of buildings.">
	<cfelse>
		<cfset needGold = buildings[buildingNo].costGold * qty>
		<cfset needWood = buildings[buildingNo].costWood * qty>
		<cfset needIron = buildings[buildingNo].costIron * qty>
		<cfset b = buildings[buildingNo]>
		
		<cfscript>
		mUsed = 0;
		fUsed = 0;
		pUsed = 0;
		for (i=1; i lte arrayLen(buildings); i=i+1) {		
			thisB = buildings[i];
			has = evaluate("player.#thisb.dbColumn#");
			if (thisb.land is "M")
				mUsed = mUsed + has * thisb.sq;
			else if (thisb.land is "F")
				fUsed = fUsed + has * thisb.sq;
			else
				pUsed = pUsed + has * thisb.sq;
		}
		
		if (b.land is "M") hasLand = player.mLand - mUsed;
		else if  (b.land is "F") hasLand = player.fLand - fUsed;
		else if (b.land is "P") hasLand = player.pLand - pUsed;
		
		needLand = qty * b.sq;		
		</cfscript>

		<cfif needLand gt hasLand>
			<cfset eflag_message = "You do not have that much free land. (needed #needLand#)">
		<cfelseif needGold gt player.gold>
			<cfset eflag_message = "You do not have enough gold. <br>You need #needGold#">
		<cfelseif needWood gt player.wood>
			<cfset eflag_message = "You do not have enough wood. <br>You need #needWood#">
		<cfelseif needIron gt player.iron>
			<cfset eflag_message = "You do not have enough iron. <br>You need #needIron#">
		<cfelse>
			<!--- get last position --->
			<cfquery datasource="#dsn#" name="bq">
            	select max(id)+1 as mpos from buildQueue where playerID = #playerID#
            </cfquery>
			<cfset newPos = val(bq.mpos)>
		
			<cfset timeNeeded = needWood + needIron>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	    	    insert into buildQueue (playerID, buildingNo, turnAdded, mission, timeNeeded, qty, pos)
				values (#playerID#, #buildingNo#, #player.turn#, 0, #timeNeeded#, #qty#, #newpos#)
		    </cfquery>	
			<cfset eflag_message = "#qty# #b.name# added to your queue. <br>Total Cost: #needGold# gold, #needWood# wood, #needIron# iron.">
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	        update player set 
					gold = gold - #needGold#,
					iron = iron - #needIron#,
					wood = wood - #needWood#
				where id = #playerID#
        	</cfquery>			
		</cfif>
	</cfif>
<cfelseif eflag is "b_dequeue">
	<cfquery name="bq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select * from buildQueue where id = #q_id# and playerID = #playerID#
    </cfquery>
	<cfif bq.recordcount gt 0>
		<cfset b = buildings[bq.buildingNo]>
		<cfif bq.mission is 0>		
			<cfset getIron = b.costIron * bq.qty>
			<cfset getWood = b.costWood * bq.qty>
			<cfset getGold = b.costGold * bq.qty>			
		<cfelse><!--- only get iron or wood back when building (not demolishing) --->
			<cfset getIron = 0>
			<cfset getWood = 0>
			<cfset getGold = 0>
		</cfif>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				gold = gold + #getGold#,
				wood = wood + #getWood#,
				iron = iron + #getIron#
			where id = #playerID#
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            delete from buildQueue where id = #bq.id#
        </cfquery>
	</cfif>
<cfelseif eflag is "cancel_all">
	<cfquery name="bq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select * from buildQueue where playerID = #playerID#
    </cfquery>
	<cfloop query="bq">
		<cfset b = buildings[bq.buildingNo]>
		<cfif bq.mission is 0>		
			<cfset getIron = b.costIron * bq.qty>
			<cfset getWood = b.costWood * bq.qty>
			<cfset getGold = b.costGold * bq.qty>			
		<cfelse><!--- only get iron or wood back when building (not demolishing) --->
			<cfset getIron = 0>
			<cfset getWood = 0>
			<cfset getGold = 0>
		</cfif>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				gold = gold + #getGold#,
				wood = wood + #getWood#,
				iron = iron + #getIron#
			where id = #playerID#
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            delete from buildQueue where id = #bq.id#
        </cfquery>
	</cfloop>
<cfelseif eflag is "changeBuildingStatus">
	<cfloop from="1" to="#arrayLen(buildings)#" index="i">
		<cfset b = buildings[i]>
		<cfif b.allowOff>
			<cfset status = int(val(evaluate("#b.dbColumn#status")))>
			
			<cfif status gte 0 and status lte 10>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update player set #b.dbColumn#Status = #val(status*10)# where id = #playerID#
                </cfquery>
			</cfif>
		</cfif>	
	</cfloop>	
<cfelseif eflag is "demolish">
	<cfset qty = val(form.qty)>
	<cfif buildingno lt 1 or buildingno gt arrayLen(buildings)>
		<cfset eflag_message = "Invalid building to demolish.">
	<cfelseif qty lt 1 or qty gt 10000000>
		<cfset eflag_message = "Cannot demolish 0 buildings.">
	<cfelse>
		<!--- check how many are being destroyed --->
		<cfquery name="bq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
        	select sum(qty) as total from buildQueue where playerID = #playerID# and buildingNo = #buildingNo# and mission = 1
        </cfquery>
		<cfset b = buildings[buildingNo]>
		<cfset num_builds = evaluate("player.#b.dbColumn#") - val(bq.total)>
		<cfif num_builds lt qty>
			<cfset eflag_message = "You do not have that many buildings of this type.">
		<cfelse>
			<cfset timeNeeded = (b.costWood + b.costIron) * qty>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	    	    insert into buildQueue (playerID, buildingNo, turnAdded, mission, timeNeeded, qty)
				values (#playerID#, #buildingNo#, #player.turn#, 1, #timeNeeded#, #qty#)
		    </cfquery>	
		</cfif>
	</cfif>
<cfelseif eflag is "to_top">
	<cfset q_id = val(q_id)>
	<cfquery datasource="#dsn#">
        update buildQueue set pos = pos + 1 where playerID = #playerID#
    </cfquery>
	<cfquery datasource="#dsn#">
        update buildQueue set pos = 0 where playerID = #playerID# and id = #q_id#
    </cfquery>
<cfelseif eflag is "to_bottom">
	<cfset q_id = val(q_id)>
	<!--- get last position --->
	<cfquery datasource="#dsn#" name="bq">
    	select max(id)+1 as mpos from buildQueue where playerID = #playerID#
	</cfquery>
	<cfset newPos = val(bq.mpos)>
	<cfquery datasource="#dsn#">
        update buildQueue set pos = #newPos# where playerID = #playerID# and id = #q_id#
    </cfquery>
<cfelseif eflag is "hold">
	<cfset q_id = val(q_id)>
	<cfquery name="bq" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select onHold from buildQueue where id = #q_id# and playerID = #playerID#
    </cfquery>
	<cfif bq.recordcount gt 0>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update buildQueue set 
				onHold = <cfif bq.onHold is 0>1<cfelse>0</cfif>
			where id = #q_id# and playerID = #playerID#
        </cfquery>
	</cfif>
</cfif>
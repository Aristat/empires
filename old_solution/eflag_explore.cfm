<cfif eflag is "send_explorers">
	<cfset session.lastHorseSetting = withHorses>

	<cfset qty = val(qty)>
	<cfset maxExplorers = player.townCenter * townCenterB.maxExplorers>
	
	<cfset totalLand = player.mLand + player.fLand + player.pLand>
	<cfset extraFood = ceiling(totalLand / session.extraFoodPerLand)>
	
	<cfset foodPerExplorer = townCenterB.foodPerExplorer + extraFood>
	<cfset exploreFood = foodPerExplorer * qty>
	
	<cfset seekLand = val(form.seekLand)>
	
	<cfif player.people lte qty>
		<cfset eflag_message = eflag_message & "You don't have that many people.<br>">
	<cfelseif player.Food lt exploreFood>
		<cfset eflag_message = eflag_message & "You don't have that much food.<br>">
	<cfelseif seekLand lt 0 or seekLand gt 3>
		<cfset eflag_message = eflag_message & "Invalid Option<br>">
	<cfelseif qty lt 4>
		<cfset eflag_message = eflag_message & "You have to send at least 4 explorers.<br>">
	<cfelseif withHorses is 1 and player.horses lt qty>
		<cfset eflag_message = eflag_message & "You do not have enough horses to send with your explorers (You need #qty#).<br>">
	<cfelseif withHorses is 2 and player.horses lt qty * 2>
		<cfset eflag_message = eflag_message & "You do not have enough horses to send with your explorers (You need #val(qty*2)#).<br>">
	<cfelseif withHorses is 3 and player.horses lt qty * 3>
		<cfset eflag_message = eflag_message & "You do not have enough horses to send with your explorers (You need #val(qty*3)#).<br>">
	<cfelse>
		<cfquery name="check" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            select sum(people) as num_explorers from exploreQueue where playerID = #playerID# and turn > 0
        </cfquery>
		<cfif val(check.num_explorers) + qty gt maxExplorers>
			<cfset eflag_message = eflag_message & "You can only have a total of #maxExplorers# explorers at a time.<br>">
		<cfelse>
			<cfset useHorses = 0>
			<cfset tripLength = 6>
			<cfif withHorses is 1 or withHorses is 2 or withHorses is 3>
				<cfset useHorses = qty * withHorses>
				<cfset tripLength = tripLength + withHorses * 2>
			</cfif>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	            insert into exploreQueue (playerID, turn, people, food, seekLand, horses, createdOn, turnsUsed)
					values (#playerID#, #tripLength#, #qty#, #exploreFood#, #seekLand#, #useHorses#, #now()#, 0) <!--- explore for 6 months --->
	        </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	            update player set people = people - #qty#,
					food = food - #exploreFood#,
					horses = horses - #useHorses#
					where id = #playerID#
	        </cfquery>
		</cfif>
	</cfif>
<cfelseif eflag is "cancelExplore">
	<cfset eID = val(eID)>
	<cfquery name="e" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        select * from exploreQueue where playerID = #playerID# and id = #eID#
    </cfquery>
	<cfif e.recordcount gt 0>
		<cfset cancelTime = dateAdd("n", -15, Now())>
		<cfif e.turnsUsed gt 0 or e.createdOn lt cancelTime>
			<cfset eflag_message = eflag_message & "You cannot cancel those explorers anymore.<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set
					food = food + #e.food#,
					horses = horses + #e.horses#,
					people = people + #e.people#
				where id = #playerID#
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                delete from exploreQueue where id = #e.id#
            </cfquery>
			<cfset eflag_message = eflag_message & "Your explorers have been cancelled.<br>">
		</cfif>
	</cfif>
</cfif>
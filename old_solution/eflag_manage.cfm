<cfif eflag is "changeWeaponProduction">
	<cfset bowProduction = val(form.bowProduction)>
	<cfset swordProduction = val(form.swordProduction)>
	<cfset maceProduction = val(form.maceProduction)>
	<cfif bowProduction lt 0 or swordProduction lt 0 or maceProduction lt 0>
		<cfset eflag_message = eflag_message & "Cannot set negative production<br>">
	<cfelseif bowProduction + swordProduction + maceProduction gt player.weaponSmith>
		<cfset eflag_message = eflag_message & "You can have a maximum of #player.weaponsmith# units produced.<br>">
	<cfelse>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set
				bowWeaponSmith = #bowProduction#,
				swordWeaponSmith = #swordProduction#,
				maceWeaponSmith = #maceProduction#
			where id = #playerID#
        </cfquery>
	</cfif>
	
<cfelseif eflag is "changeLand">
	<cfset usedM = player.ironMine * ironMineB.sq + player.goldMine * goldMineB.sq>
	<cfset freeM = player.Mland - usedM>		
	<cfset mLandChange = abs(val(form.mLandChange))>
	<cfif mLandChange gt 0>
		<cfset needGold = mLandChange * 100>
		<cfif mLandChange gt freeM>
			<cfset eflag_message = eflag_message & "You do not have that much free mountain land.<br>">
		<cfelseif needGold gt player.gold>
			<cfset eflag_message = eflag_message & "You do not have that much gold (need #needGold#)<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set 
					mLand = mLand - #mLandChange#,
					fLand = fLand + #mLandChange#,
					gold = gold - #needGold#
				where id = #playerID#
            </cfquery>
			<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        		select * from player where id = #playerID#
		    </cfquery>
			
		</cfif>
	</cfif>	
	
	<cfset usedF = player.hunter * hunterB.sq + player.woodcutter * woodCutterB.sq>	
	<cfset freeF = player.fland - usedF>	
	<cfset fLandChange = abs(val(form.fLandChange))>	
	<cfif fLandChange gt 0>
		<cfset needGold = fLandChange * 25>
		<cfif fLandChange gt freeF>
			<cfset eflag_message = eflag_message & "You do not have that much free forest land.<br>">
		<cfelseif needGold gt player.gold>
			<cfset eflag_message = eflag_message & "You do not have that much gold (need #needGold#)<br>">
		<cfelse>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
				update player set
					fLand = fLand - #fLandChange#,
					pLand = pLand + #fLandChange#,
					gold = gold - #needGold#
				where id = #playerID#
            </cfquery>
			
		</cfif>
	</cfif>	
<cfelseif eflag is "changeFoodRatio">
	<cfset fr = int(val(form.foodRatio))>
	<cfif fr gte -2 and fr lte 4>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set foodRatio = #fr# where id = #playerID#
        </cfquery>
	</cfif>	
</cfif>
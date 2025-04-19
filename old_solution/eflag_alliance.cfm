<cfif deathMatchMode>
	<font face="verdana" color=red size=2>Cannot view this page in deathmatch game.</font>
	<cfabort>
</cfif>

<cfif eflag is "join_alliance">
	<cfset joinAllianceID = val(form.joinAllianceID)>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select passwd, id, name, tag, news from alliance where id = #joinAllianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<!--- see if alliance has max members --->
		<cfquery name="am" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
        	select count(*) as cnt from player where allianceID = #joinAllianceID#
        </cfquery>
		<cfif am.cnt gte allianceMaxMembers>
			<cfset eflag_message = eflag_message & "This alliance already has maximum allowable number of members.<br>">
		<cfelse>		
			<cfset aPassword = trim(form.aPassword)>
			<cfif alliance.passwd is aPassword>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	                update player set allianceID = #joinAllianceID#, allianceMemberType=0 where id = #playerID#
	            </cfquery>
				<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	            	select id, name from player where id = #playerID#
	            </cfquery>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	                update alliance set news = '#alliance.news##chr(10)##theDate#: #player.name# (###player.id#) joined your alliance' where id = #alliance.id#
	            </cfquery>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
	                update player set hasAllianceNews = 1 where allianceID = #alliance.id#
	            </cfquery>
			<cfelse>
				<cfset eflag_message = eflag_message & "<br>Invalid Password.">
			</cfif>
		</cfif>
	</cfif>
<cfelseif eflag is "create_alliance">
	<cfset newTag = trim(newTag)>
	<!--- see if alliance with that tag already exists --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id from alliance where tag = '#newtag#'
    </cfquery>
	
	<cfset isValid = true>
	<cfloop from="1" to="#len(newTag)#" index="i">
		<cfset ch = asc(mid(newTag, i, 1))>
		<cfif (ch gte 65 and ch lte 90) or (ch gte 97 and ch lte 122) or ch is 32 or ch is 95 or (ch gte 48 and ch lte 57)>
		
		<cfelse>
			<cfset isValid = false>
		</cfif>
	</cfloop>
	<cfif newtag contains "  ">
		<cfset isValid = false>		
	</cfif>
	
	<cfif newTag is "">
		<cfset eflag_message = "Please provide alliance tag.">
	<cfelseif not isValid>
		<cfset eflag_message = "Alliance name can only contain spaces and alpha-numeric characters and cannot contain two spaces by each other.<br>">		
	<cfelseif alliance.recordcount gt 0>
		<cfset eflag_message = "Alliance with that tag already exists.">
	<cfelse>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            insert into alliance (tag, leaderID, passwd)
			values ('#newtag#', #playerID#, '#aPassword#')
        </cfquery>
		<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	select id from alliance where tag = '#newtag#' and leaderID = #playerID#
        </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
            update player set allianceID = #alliance.id#, allianceMemberType=1 where id = #playerID#
        </cfquery>
	</cfif>
<cfelseif eflag is "change_news">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<cfif alliance.leaderID is playerID>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update alliance set 
					news = '#news#'
				where id = #player.allianceID#
            </cfquery>		
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set hasAllianceNews = 1 where allianceID = #player.allianceID# and id <> #playerID#
            </cfquery>
		</cfif>
	</cfif>
<cfelseif eflag is "remove_from_alliance">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID, news from alliance where id = #player.allianceID#
    </cfquery>
	<cfset removeiD = val(removeID)>
	<cfquery name="rPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select name, allianceID from player where id = #removeID#
    </cfquery>
	<cfif alliance.recordcount gt 0 and rPlayer.recordcount gt 0>
		<cfif alliance.leaderID is playerID and rPlayer.allianceID is player.allianceID>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update alliance set news = '#alliance.news##chr(10)##theDate#: #rPlayer.name# (###removeID#) has been removed from your alliance' where id = #player.allianceID#
            </cfquery>		
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set hasAllianceNews = 1 where allianceID = #player.allianceID# and id <> #playerID#
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set allianceID = 0,allianceMemberType=0 where id = #removeID#
            </cfquery>
		</cfif>
	</cfif>
<cfelseif eflag is "give_leadership">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID, news from alliance where id = #player.allianceID#
    </cfquery>
	<cfset newLeader = val(newLeader)>
	<cfquery name="rPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select name, allianceID from player where id = #newLeader#
    </cfquery>
	<cfif alliance.recordcount gt 0 and rPlayer.recordcount gt 0>
		<cfif alliance.leaderID is playerID and rPlayer.allianceID is player.allianceID>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update alliance set leaderID = #newLeader#, news = '#alliance.news##chr(10)##theDate#: #rPlayer.name# (###newLeader#) is a new alliance leader' where id = #player.allianceID#
            </cfquery>		
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set hasAllianceNews = 1 where allianceID = #player.allianceID#
            </cfquery>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">
                update player set allianceMemberType=1 where id = #newLeader#
            </cfquery>
		</cfif>
	</cfif>	
<cfelseif eflag is "changeStatus">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID, news from alliance where id = #player.allianceID#
    </cfquery>
	<cfset memberID = val(memberID)>
	<cfquery name="rPlayer" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select name, allianceMemberType, allianceID from player where id = #memberID#
    </cfquery>
	<cfif alliance.recordcount gt 0 and rPlayer.recordcount gt 0>
		<cfif alliance.leaderID is playerID and rPlayer.allianceID is player.allianceID>
			<cfset newStatus = 1>
			<cfif rPlayer.allianceMemberType is 1><cfset newStatus = 0></cfif>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set allianceMemberType = #newStatus# where id = #memberID#
            </cfquery>		
		</cfif>
	</cfif>	
<cfelseif eflag is "change_password">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<cfif alliance.leaderID is playerID>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update alliance set passwd = '#aPassword#' where id = #player.allianceID#
            </cfquery>		
		</cfif>
	</cfif>
<cfelseif eflag is "finish_alliance">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<cfif alliance.leaderID is playerID>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update player set allianceID = 0, allianceMemberType=0 where allianceID = #player.allianceID#
            </cfquery>		
			<cfloop list="ally1,ally2,ally3,ally4,ally5,war1,war2,war3,war4,war5" index="i">
				<cfquery datasource="#dsn#">
    	            update alliance set #i# = 0 where #i# = #player.allianceID#
        	    </cfquery>
			</cfloop>
			<cfquery datasource="#dsn#">
                delete from alliance where id = #player.allianceID#
            </cfquery>
		</cfif>
	</cfif>

<cfelseif eflag is "leave_alliance">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, name, allianceID from player where id = #playerID#
	</cfquery>
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select id, news from alliance where id = #player.allianceID#
    </cfquery>	
	<cfif alliance.recordcount gt 0>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	    update player set allianceID = 0, alliancememberType=0 where id = #playerID#
	    </cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
        	update alliance set news = '#alliance.news##chr(10)##theDate#: #player.name# (###player.id#) left your alliance' where id = #alliance.id#
		</cfquery>
		<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    		update player set hasAllianceNews = 1 where allianceID = #alliance.id#
		</cfquery>	
		<cfset eflag_message = "You left '#allianceTag#' alliance.">
	</cfif>
<cfelseif eflag is "change_relations">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select * from alliance where id = #player.allianceID#
    </cfquery>
	<cfif alliance.recordcount gt 0>
		<cfif n_ally1 is alliance.id or n_ally2 is alliance.id or n_ally3 is alliance.id or n_ally4 is alliance.id or n_ally5 is alliance.id or n_war1 is alliance.id or n_war2 is alliance.id or n_war3 is alliance.id or n_war4 is alliance.id or n_war5 is alliance.id>
			<cfset eflag_message = "Cannot add your own alliance to war or ally list.">
		<cfelseif alliance.leaderID is playerID>
			<cfset theNews = alliance.news>
			<cfset myTag = alliance.tag>
			<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                update alliance set ally1 = #n_ally1#, ally2 = #n_ally2#, ally3 = #n_ally3#, ally4 = #n_ally4#, ally5 = #n_ally5#,
					war1 = #n_war1#, war2 = #n_war2#, war3 = #n_war3#, war4 = #n_war4#, war5 = #n_war5# where id = #player.allianceID#
            </cfquery>
			<cfset changedRelations = false>
			<cfloop from="1" to="5" index="i">
				<!--- process alliances --->
				<cfset oldAlly = evaluate("alliance.ally#i#")>
				<cfset newAlly = evaluate("n_ally#i#")>
				<cfif oldAlly is not newAlly><!--- changed relations --->
					<cfset changedRelations = true>
					<cfif oldAlly gt 0><!--- removed someone from being ally --->
						<cfquery name="qOldAlly" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        	select id, tag, news from alliance where id = #oldAlly#
                        </cfquery>
						<cfif qOldAlly.recordcount gt 0>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update alliance set news = '#qOldAlly.news##chr(10)#[red]#theDate#:[/red] #myTag# removed you from their ally list' where id = #qOldAlly.id#
                            </cfquery>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update player set hasAllianceNews = 1 where allianceID = #oldAlly#
                            </cfquery>
							<cfset thenews = thenews & '#chr(10)#[red]#theDate#:[/red] #qOldAlly.tag# has been removed from your ally list'>
						</cfif>
					</cfif>
					<cfif newAlly gt 0><!--- added new ally --->
						<cfquery name="qNewAlly" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        	select id, tag, news from alliance where id = #newAlly#
                        </cfquery>
						<cfif qNewAlly.recordcount gt 0>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update alliance set news = '#qNewAlly.news##chr(10)#[yellow]#theDate#:[/yellow] #myTag# put you on their ally list' where id = #qNewAlly.id#
                            </cfquery>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update player set hasAllianceNews = 1 where allianceID = #newAlly#
                            </cfquery>
							<cfset thenews = thenews & '#chr(10)#[yellow]#theDate#:[/yellow] #qNewAlly.tag# has been put on your ally list'>
						</cfif>					
					</cfif>
				</cfif>
				
				<!--- process war --->					
				<cfset oldWar = evaluate("alliance.war#i#")>
				<cfset newWar = evaluate("n_war#i#")>
				<cfif oldWar is not newWar><!--- changed relations --->
					<cfset changedRelations = true>
					<cfif oldWar gt 0>
						<cfquery name="qOldWar" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        	select id, tag, news from alliance where id = #oldWar#
                        </cfquery>
						<cfif qOldWar.recordcount gt 0>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update alliance set news = '#qOldWar.news##chr(10)#[yellow]#theDate#:[/yellow] #myTag# removed you from their war list' where id = #qOldWar.id#
                            </cfquery>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update player set hasAllianceNews = 1 where allianceID = #oldWar#
                            </cfquery>
							<cfset thenews = thenews & '#chr(10)#[yellow]#theDate#:[/yellow] #qOldWar.tag# has been removed from your war list'>
						</cfif>
					</cfif>
					<cfif newWar gt 0>
						<cfquery name="qNewWar" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                        	select id, tag, news from alliance where id = #newWar#
                        </cfquery>
						<cfif qNewWar.recordcount gt 0>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update alliance set news = '#qNewwar.news##chr(10)#[red]#theDate#:[/red] #myTag# put you on their war list' where id = #qNewWar.id#
                            </cfquery>
							<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                                update player set hasAllianceNews = 1 where allianceID = #newWar#
                            </cfquery>
							<cfset thenews = thenews & '#chr(10)#[red]#theDate#:[/red] #qNewWar.tag# has been added to your war list'>
						</cfif>					
					</cfif>
				</cfif>
			</cfloop>
			
			<cfif changedRelations>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update alliance set news = '#thenews#' where id = #alliance.id#
                </cfquery>
				<cfquery datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
                    update player set hasAllianceNews = 1 where allianceID = #alliance.id#
                </cfquery>
			</cfif>
		</cfif>
	</cfif>
<cfelseif eflag is "viewArmy">
	<cfquery name="player" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select allianceID from player where id = #playerID#
    </cfquery>
	<!--- see if the player is the leader of the alliance --->
	<cfquery name="alliance" datasource="#dsn#" username="#dsn_login#" password="#dsn_pw#">	
    	select leaderID from alliance where id = #player.allianceID#
    </cfquery>
	
	<cfset memberID = val(memberID)>
	
	<cfif alliance.recordcount gt 0>
		<cfif alliance.leaderID is playerID>
			<cfquery datasource="#dsn#" name="member">
            	select id, name, horseman, archers, tower, macemen, trainedPeasants, thieves, catapults, swordsman, uunit, civ
				from player where id = #memberID# and allianceID = #player.allianceID#
            </cfquery>
			<cfif member.recordcount gt 0>
				<cfset eflag_message = "<b>#member.name# (#member.id#)</b><br>#numberFormat(member.uunit)# #uunitNames[member.civ]#<br>#numberFormat(member.archers)# archers<br>#numberFormat(member.swordsman)# swordsman<br> #numberFormat(member.horseman)# horseman<br>#numberFormat(member.macemen)# macemen<br>#numberFormat(member.trainedPeasants)# trained peasants<br>#numberFormat(member.tower)# towers<br>#numberFormat(member.catapults)# catapults<br>#numberFormat(member.thieves)# thieves<br>">
			
			</cfif>
		</cfif>
	</cfif>	
</cfif>
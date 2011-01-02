<cfcomponent>	
	<!--- get guest record --->
	<cffunction access="remote" name="getGuest" output="false" returntype="query" displayname="getGuest">
		<cfargument name="guestuuid" type="string" required="no">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="guestaccessname" type="string" required="no">
		<cfargument name="password" type="string" required="no">
		<cfset var q_getGuest = "">
			<cftry>
				<cfquery name="q_getGuest" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT guestuuid, guestid, guestname, firstname, lastname, middleinitial, jobtitle, salutation, suffix, dateofbirth, gender, companyName
					FROM guest
					<cfif isDefined('arguments.guestaccessname') AND Len(arguments.guestaccessname) AND isDefined('arguments.password') AND Len(arguments.password)>
						INNER JOIN guestaccess ON guestaccess.guestid = guest.guestid
					</cfif>
					WHERE 1=1
					<cfif isDefined('arguments.guestuuid') AND Len(arguments.guestuuid)>
						AND guestuuid = '#arguments.guestuuid#'
					</cfif>
					<cfif isDefined('arguments.guestid') AND arguments.guestid>
						AND guestid = #arguments.guestid#
					</cfif>
					<cfif isDefined('arguments.guestaccessname') AND Len(arguments.guestaccessname) AND isDefined('arguments.password') AND Len(arguments.password)>
						AND guestaccessname = #arguments.guestaccessname#
						AND password = #arguments.password#
					</cfif>
				</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>		
		<cfreturn q_getGuest>
	</cffunction>

	<!--- get guest address --->
	<cffunction access="remote" name="getGuestAddress" output="false" returntype="query" displayname="getGuestAddress">
		<cfargument name="guestaddressid" type="numeric" required="no">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="limit" type="numeric" required="no">
		<cfargument name="useinprofile" type="boolean" required="no">
		<cfset var q_getGuestAddress = "">
			<cftry>
				<cfquery name="q_getGuestAddress" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT <!--- DISTINCT? ---><cfif isDefined('arguments.limit') AND arguments.limit>TOP #arguments.limit# </cfif>guestaddressid, guestaddressname, address1, address2, city, stateprovince, postalcode, countryid
					FROM guestaddress
					WHERE 1=1 
					<cfif isDefined('arguments.guestaddressid') AND arguments.guestaddressid>
						AND guestaddressid = #arguments.guestaddressid#
					</cfif>
					<cfif isDefined('arguments.guestid') AND arguments.guestid>
						AND guestid = #arguments.guestid#
					</cfif>
					<cfif isDefined('arguments.useinprofile') AND arguments.useinprofile>
						AND useinprofile = 1
					<cfelseif isDefined('arguments.useinprofile') AND NOT arguments.useinprofile>
						AND (useinprofile = 0 OR useinprofile IS NULL)
					</cfif>
					ORDER BY datemodified DESC
				</cfquery>
			<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn q_getGuestAddress>		
	</cffunction>
	
	<!--- get guest email --->
	<cffunction access="remote" name="getGuestEmail" output="false" returntype="query" displayname="getGuestEmail">
		<cfargument name="guestemailaddressid" type="numeric" required="no">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="limit" type="numeric" required="no">
		<cfargument name="useinprofile" type="boolean" required="no">
		<cfset var q_getGuestEmail = "">
			<cftry>
				<cfquery name="q_getGuestEmail" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT <!--- DISTINCT? ---><cfif isDefined('arguments.limit') AND arguments.limit>TOP #arguments.limit# </cfif>guestemailaddressid, guestemailaddressname, email
					FROM guestemailaddress
					WHERE 1=1 
					<cfif isDefined('arguments.guestemailaddressid') AND arguments.guestemailaddressid>
						AND guestemailaddressid = #arguments.guestemailaddressid#
					</cfif>
					<cfif isDefined('arguments.guestid') AND arguments.guestid>
						AND guestid = #arguments.guestid#
					</cfif>
					<cfif isDefined('arguments.useinprofile') AND arguments.useinprofile>
						AND useinprofile = 1
					<cfelseif isDefined('arguments.useinprofile') AND NOT arguments.useinprofile>
						AND (useinprofile = 0 OR useinprofile IS NULL)
					</cfif>
					ORDER BY datemodified DESC
				</cfquery>
			<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn q_getGuestEmail>		
	</cffunction>
	
	<!--- get guest phone --->
	<cffunction access="remote" name="getGuestPhone" output="false" returntype="query" displayname="getGuestPhone">
		<cfargument name="guestphoneid" type="numeric" required="no">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="limit" type="numeric" required="no">
		<cfargument name="useinprofile" type="boolean" required="no">
		<cfset var q_getGuestPhone = "">
			<cftry>
				<cfquery name="q_getGuestPhone" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT <!--- DISTINCT? ---><cfif isDefined('arguments.limit') AND arguments.limit>TOP #arguments.limit# </cfif>guestphoneid, guestphonename, workphone, homephone, mobilephone, fax
					FROM guestphone
					WHERE 1=1 
					<cfif isDefined('arguments.guestphoneid') AND arguments.guestphoneid>
						AND guestphoneid = #arguments.guestphoneid#
					</cfif>
					<cfif isDefined('arguments.guestid') AND arguments.guestid>
						AND guestid = #arguments.guestid#
					</cfif>
					<cfif isDefined('arguments.useinprofile') AND arguments.useinprofile>
						AND useinprofile = 1
					<cfelseif isDefined('arguments.useinprofile') AND NOT arguments.useinprofile>
						AND (useinprofile = 0 OR useinprofile IS NULL)
					</cfif>
					ORDER BY datemodified DESC
				</cfquery>
			<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn q_getGuestPhone>		
	</cffunction>
	
	<!--- get guest access --->
	<cffunction access="remote" name="getGuestAccess" output="false" returntype="query" displayname="getGuestAccess">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="login" type="string" required="no">
		<cfargument name="password" type="string" required="no">
		<cfargument name="guestUUID" type="string" required="no">
		<cfset var q_getGuestAccess = "">
			<cftry>
				<cfquery name="q_getGuestAccess" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT guestaccess.guestaccessid, guestaccess.guestid, guestaccess.secretQuestion, guestaccess.secretAnswer, guestaccess.guestaccessname, guestaccess.password, guest.guestUUID, guestemailaddress.email
					FROM guestaccess 
						INNER JOIN guest 
							ON guestaccess.guestid = guest.guestid 
						INNER JOIN guestemailaddress 
							ON guest.guestid = guestemailaddress.guestid
					WHERE (1 = 1) AND (guestemailaddress.useinprofile = 1)
					<cfif isDefined('arguments.guestid') AND arguments.guestid>
						AND guestaccess.guestid = #arguments.guestid#
					</cfif>	
					<cfif isDefined('arguments.login') AND Len(arguments.login)>
						AND guestemailaddress.email = '#arguments.login#'
					</cfif>
					<cfif isDefined('arguments.password') AND Len(arguments.password)>
						AND guestaccess.password = '#arguments.password#'
					</cfif>
					<cfif isDefined('arguments.guestUUID') AND Len(arguments.guestUUID)>
						AND guest.guestUUID = '#arguments.guestUUID#'
					</cfif>
				</cfquery>
                <!--- This accout doens't have a UUID need to fix that ASAP --->
                <cfif NOT IsDefined('q_getGuestAccess.guestUUID') AND q_getGuestAccess.RecordCount EQ 1 OR Len(Trim(q_getGuestAccess.guestUUID)) EQ 0 AND q_getGuestAccess.RecordCount EQ 1 >
                	<cfset newGuestUUID = createUUID()>
					<cfquery name="q_updateGuestUUID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
                    	UPDATE guest
                        SET guestuuid = '#newGuestUUID#'
                        WHERE guestID = #q_getGuestAccess.guestID#
                    </cfquery>
                    <cfset querySetCell(q_getGuestAccess,'guestUUID',newGuestUUID,1)>
				</cfif>
			<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn q_getGuestAccess>
	</cffunction>
	
	
	<!--- insert guest record --->	
	<!--- insert guest address --->	
	<!--- insert guest email --->
	<!--- insert guest phone --->	
	<!--- insert guest access --->
	
	<!--- delete guest record --->
	<cffunction access="remote" name="deleteAllGuestInfo" output="false" returntype="boolean" displayname="deleteGuest">
		<cfargument name="guestid" type="string" required="yes">
		<cfset var q_delete = "">
		<cfset var q_deleteGuestInfo = "">
		<cfset var success = 1>
			<cftry>
				<cftransaction>
					<cfloop list="#arguments.guestid#" index="i" delimiters=",">
						<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							DELETE
							FROM guest
							WHERE guestid = #i#
						</cfquery>
						<!--- delete all related data from other guest tables--->
						<cfset q_deleteGuestInfo = deleteGuestAddress(guestid = i)>
						<cfset q_deleteGuestInfo = deleteGuestEmail(guestid = i)>
						<cfset q_deleteGuestInfo = deleteGuestPhone(guestid = i)>
						<cfset q_deleteGuestInfo = deleteGuestAccess(guestid = i)>
						<cfset q_deleteGuestInfo = deleteGuestComposite(guestid = i)>
					</cfloop>
				</cftransaction>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn success>
	</cffunction>
		
	<!--- delete guest address --->	
	<cffunction access="remote" name="deleteGuestAddress" output="false" returntype="boolean" displayname="deleteGuestAddress">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="guestaddressid" type="numeric" required="no">
		<cfset var q_delete = "">
		<cfset var success = 1>
			<!--- only delete if an argument has been passed in (to prevent deleting all by mistake)--->
			<cfif isDefined('arguments.guestid') OR isDefined('arguments.guestaddressid')>
				<cftry>
					<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE
						FROM guestaddress
						WHERE 1=1
						<cfif isDefined('arguments.guestid') AND arguments.guestid>
							AND guestid = #arguments.guestid#
						</cfif>	
						<cfif isDefined('arguments.guestaddressid') AND arguments.guestaddressid>
							AND guestaddressid = #arguments.guestaddressid#
						</cfif>
					</cfquery>
				<cfcatch type="database">
						<cfset success = 0>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn success>
	</cffunction>
	
	<!--- delete guest email --->
	<cffunction access="remote" name="deleteGuestEmail" output="false" returntype="boolean" displayname="deleteGuestEmail">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="guestemailaddressid" type="numeric" required="no">
		<cfset var q_delete = "">
		<cfset var success = 1>
			<!--- only delete if an argument has been passed in (to prevent deleting all by mistake)--->
			<cfif isDefined('arguments.guestid') OR isDefined('arguments.guestemailaddressid')>
				<cftry>
					<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE
						FROM guestemailaddress
						WHERE 1=1
						<cfif isDefined('arguments.guestid') AND arguments.guestid>
							AND guestid = #arguments.guestid#
						</cfif>	
						<cfif isDefined('arguments.guestemailaddressid') AND arguments.guestemailaddressid>
							AND guestemailaddressid = #arguments.guestemailaddressid#
						</cfif>
					</cfquery>
				<cfcatch type="database">
						<cfset success = 0>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn success>
	</cffunction>
	
	<!--- delete guest phone --->
	<cffunction access="remote" name="deleteGuestPhone" output="false" returntype="boolean" displayname="deleteGuestPhone">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="guestphoneid" type="numeric" required="no">
		<cfset var q_delete = "">
		<cfset var success = 1>
			<!--- only delete if an argument has been passed in (to prevent deleting all by mistake)--->
			<cfif isDefined('arguments.guestid') OR isDefined('arguments.guestphoneid')>
				<cftry>
					<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE
						FROM guestphone
						WHERE 1=1
						<cfif isDefined('arguments.guestid') AND arguments.guestid>
							AND guestid = #arguments.guestid#
						</cfif>	
						<cfif isDefined('arguments.guestphoneid') AND arguments.guestphoneid>
							AND guestphoneid = #arguments.guestphoneid#
						</cfif>
					</cfquery>
				<cfcatch type="database">
						<cfset success = 0>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn success>
	</cffunction>
		
	<!--- delete guest access --->
	<cffunction access="remote" name="deleteGuestAccess" output="false" returntype="boolean" displayname="deleteGuestAccess">
		<cfargument name="guestid" type="numeric" required="no">
		<cfargument name="guestaccessid" type="numeric" required="no">
		<cfset var q_delete = "">
		<cfset var success = 1>
			<!--- only delete if an argument has been passed in (to prevent deleting all by mistake)--->
			<cfif isDefined('arguments.guestid') OR isDefined('arguments.guestaccessid')>
				<cftry>
					<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE
						FROM guestaccess
						WHERE 1=1
						<cfif isDefined('arguments.guestid') AND arguments.guestid>
							AND guestid = #arguments.guestid#
						</cfif>	
						<cfif isDefined('arguments.guestaccessid') AND arguments.guestaccessid>
							AND guestaccessid = #arguments.guestaccessid#
						</cfif>
					</cfquery>
				<cfcatch type="database">
						<cfset success = 0>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn success>
	</cffunction>
	
	<!--- delete from any guest frontend form --->	
	<cffunction access="remote" name="deleteGuestComposite" output="false" returntype="boolean" displayname="deleteGuestComposite">
		<cfargument name="guestid" type="numeric" required="yes">
		<cfset var q_FrontendGuestEnvID = "">
		<cfset var q_FrontendGuestFormObjs = "">
		<cfset var q_delete = "">
		<cfset var success = 1>			
			<!--- query for Frontend Guest Management form environment id --->
			<cfquery name="q_FrontendGuestEnvID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formenvironmentid
				FROM formenvironment
				WHERE formEnvironmentName = 'Frontend Guest Management'
			</cfquery>
			<cfif q_FrontendGuestEnvID.recordcount>
				<!--- query for all formobjects that use Frontend Guest Management form environment --->
				<cfquery name="q_FrontendGuestFormObjs" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT datatable
					FROM formobject
					WHERE formEnvironmentID = #q_FrontendGuestEnvID.formEnvironmentID#
				</cfquery>		
				<!--- loop thru formobjects & delete info for specified guest --->
				<cfloop list="#ValueList(q_FrontendGuestFormObjs.datatable)#" index="thisTable">
					<cftry>
						<cfquery name="q_delete" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							DELETE
							FROM #thisTable#
							WHERE guestid = #arguments.guestid#
						</cfquery>
					<cfcatch type="database">
							<cfset success = 0>
							<cfrethrow>
						</cfcatch>
					</cftry>
				</cfloop>
			</cfif>			
		<cfreturn success>
	</cffunction>
	<!--- Log user's activity in the system --->
	<cffunction access="public" name="logUserActivity" output="false" returntype="boolean" displayname="log User Activity">
		<cfargument name="guestid" displayname="guestid" type="string" required="yes">
		<cfargument name="objectid" displayname="objectid" type="numeric" required="yes">
		<cfargument name="instanceid" displayname="instanceid" type="numeric" required="no" default="0">
		<cfargument name="sekeyname" displayname="sekeyname" type="string" required="no" default="">
		<cfargument name="origin" displayname="origin" type="string" required="yes" default=" ">
		<cfset var q_logUserActivity = "">
		<cfset returnThis = false>
		<cftry>
			<!--- Check to make sure that we are not double-logging something that was just accessed --->
			<cfquery name="q_checkActivity" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT guestactivityid
				FROM guestactivity
				WHERE ((guestid = '#arguments.guestid#') AND (objectid = #arguments.objectid#) AND (<cfif ARGUMENTS.instanceid>instanceid = #arguments.instanceid#<cfelse>sekeyname = '#ARGUMENTS.sekeyname#'</cfif>)) AND (dateaccessed BETWEEN #createODBCDateTime(dateAdd("m",-5,now()))# AND #createODBCDateTime(now())#)
			</cfquery>
			<cfif q_checkActivity.recordcount EQ 0>
				<cfquery name="q_logUserActivity" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO guestactivity
						(guestid, objectid, instanceid, sekeyname, origin)
					VALUES
						(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.guestid#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.objectid#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.instanceid#">
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sekeyname#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.origin#">)
				</cfquery>
			</cfif>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn returnThis>
	</cffunction>
	
	<cffunction access="public" name="getUserActivity" output="false" returntype="query" displayname="get User Activity">
		<cfargument name="startDate" required="yes" type="date" default="#now()#">
		<cfargument name="guestUUID" required="no" type="string">
		<cfset var endDate = DateAdd('d','7',arguments.startDate)>
		<cftry>
			<cfquery name="q_getUserActivity" datasource="#APPLICATION.datasource#">
				SELECT *
				FROM v_guestActivity
				WHERE 
				<cfif isDefined("ARGUMENTS.guestUUID") AND len(ARGUMENTS.guestUUID)>
				 [Unique ID] = '#ARGUMENTS.guestUUID#' AND
				</cfif>
				DateAccessed >= <cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDate(arguments.startDate)#">
					AND DateAccessed <= #CreateODBCDate(endDate)#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getUserActivity>
	</cffunction>

</cfcomponent>
	

<cfcomponent>
	<cffunction access="public" name="getForm" output="false" returntype="query" displayname="getForm">
		<cfargument name="formobjectid" type="numeric" required="yes" displayname="Form Object ID">
		<cfset var q_getForm = "">
		<cftry>
			<cfquery name="q_getForm" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT  *
				FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
				<!--- WHERE  (formobject.formobjectid = <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#arguments.formobjectid#">) --->
				WHERE  (formobject.formobjectid = #arguments.formobjectid#)
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getForm>
	</cffunction>

	<cffunction access="public" name="getName" output="false" returntype="query" displayname="getName">
		<cfargument name="editfieldkeyvalue" type="string" required="no">
		<cfargument name="datatable" type="string" required="yes">
		<cfargument name="instanceString" type="string" required="no" displayname="can be 1 or more instance id's in a comma delmin list">
		<cfargument name="limit" type="numeric" required="no">
		<cfset var q_getName = "">
		<cftry>
			 <cfquery datasource="#application.datasource#" name="q_getName" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT <cfif isDefined('arguments.limit') AND arguments.limit>Top #arguments.limit# </cfif><cfif isDefined('arguments.editfieldkeyvalue') AND Len(Trim(arguments.editfieldkeyvalue))>#arguments.editfieldkeyvalue# AS thisName<cfelse>*</cfif>
				FROM #arguments.datatable#
				<cfif isDefined('arguments.instanceString') AND Len(Trim(arguments.instanceString))>
					WHERE #arguments.datatable#ID IN (#trim(arguments.instanceString)#)
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getName>
	</cffunction>
	
	<cffunction access="public" name="getSupervisor" output="false" returntype="query" displayname="getSupervisor">
		<cfargument name="userid" type="numeric" required="no">
		<cfargument name="supervisorid" type="numeric" required="no">
		<cfargument name="formobjectid" type="numeric" required="no">
		<cfargument name="supervisorsOnly" type="boolean" required="no">
		<cfargument name="limit" type="numeric" required="no">
		<cfset var q_getSupervisor = "">
		<cftry>					
			 <cfquery name="q_getSupervisor" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT <cfif isDefined('arguments.limit') AND arguments.limit>Top #arguments.limit# </cfif>supervisorid 
				FROM SupervisorRelationship
				WHERE formobject = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formobjectid#">
				<cfif isDefined('arguments.userid') AND arguments.userid>
					AND userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
				</cfif>
				<cfif isDefined('arguments.supervisorid') AND arguments.supervisorid>
					AND supervisorid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.supervisorid#">
				</cfif>
				<cfif isDefined('arguments.supervisorsOnly') AND arguments.supervisorsOnly>
					AND supervisorid <> userid
				</cfif>				 
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getSupervisor>
	</cffunction>
	
	<cffunction access="public" name="getSiteSupervisor" output="false" returntype="numeric" displayname="getSiteSupervisor">
		<cfset var q_getSiteSupervisor = "">
		<cfset var thisSiteSupservisorID = "">
		<cfif isDefined('application.supervisorid') AND application.supervisorid>
			<cfset thisSiteSupservisorID = application.supervisorid>
		<cfelse>
			<cftry>
				 <cfquery name="q_getSiteSupervisor" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT supervisorid FROM SiteSettings
				</cfquery>
				<cfset thisSiteSupservisorID = q_getSiteSupervisor.supervisorid>
					<cfcatch type="database">
						<cfrethrow>
					</cfcatch>
			</cftry>
		</cfif>
		<cfreturn thisSiteSupservisorID>
	</cffunction>
	
	<cffunction access="public" name="getFormObjectTable" output="false" returntype="query" displayname="getFormObjectTable">
		<cfargument name="formobjectid" type="numeric" required="yes">
		<cfset var q_FormObjectDataTable = "">
		<cftry>
			 <cfquery name="q_FormObjectDataTable" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable
				FROM formobject
				WHERE formobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formobjectid#">
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_FormObjectDataTable>
	</cffunction>
	
	<cffunction access="public" name="getNextID" output="false" returntype="query" displayname="getNextID">
		<cfargument name="TableName" type="string" required="yes">
		<cfset var q_getNextID = "">
		<cftry>
			 <cfquery name="q_getNextID" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT ID, ID AS thisNextID
				FROM tableID
				WHERE TableName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.tablename)#">
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getNextID>
	</cffunction>

	<cffunction access="public" name="getOrdinal" output="false" returntype="query" displayname="getOrdinal">
		<cfargument name="datatable" type="string" required="yes">
		<cfset var q_getOrdinal = "">
		<cftry>
			<cfquery name="q_getOrdinal" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT ISNULL(MAX(ordinal), 0) AS lastIn
				FROM #arguments.datatable#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getOrdinal>
	</cffunction>
	
	<cffunction access="public" name="getElements" output="false" returntype="query" displayname="getElements">
		<cfargument name="displayField" type="string" required="yes">
		<cfargument name="datatable" type="string" required="yes">
		<cfargument name="whereClause" type="string" required="yes">
		<cfargument name="displayFieldnames" type="string" required="no" default="" hint="used to determine joins if needed- added this arg instead of modifying displayField arg so doesnt mess up other calls">
		<cfset var q_getElements = "">
			<!--- use labels instead of displaying joining table ids & create join clause --->
			<cfif Len(arguments.displayFieldnames)>
				<cfset thisSelect = "">
				<cfset thisJoin = "">
				<cfloop list="#arguments.displayFieldnames#" index="i">
					<cfif Lcase(Right(i,2)) eq 'id' AND Lcase(Left(i,Len(i)-2)) neq Lcase(arguments.datatable)>
						<cfset thisSelect=thisSelect&"ISNULL(convert(varchar(255),#Left(i,Len(i)-2)#name), '')">
						<cfset thisJoin = thisJoin & " LEFT OUTER JOIN #Left(i,Len(i)-2)# ON #Left(i,Len(i)-2)#.#Left(i,Len(i)-2)#id = #arguments.datatable#.#Left(i,Len(i)-2)#id">
						<cfif i neq listLast(arguments.displayFieldnames)>
							<cfset thisSelect=thisSelect&"+' | '+">
						</cfif>
					<cfelse>
						<cfset thisField = arguments.datatable & '.' & i>
						<cfset thisSelect=thisSelect&"ISNULL(convert(varchar(255),#thisField#), '')">
						<cfif i neq listLast(arguments.displayFieldnames)>
							<cfset thisSelect=thisSelect&"+' | '+">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		
			<!--- Added active flag for ordinal tool. default will set it to active if there is no active column in the table --->
				<cftry>
					<cfquery datasource="#application.datasource#" name="q_getElements" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT <cfif isDefined('thisSelect') AND Len(thisSelect)>#preserveSingleQuotes(thisSelect)#<cfelse>#preserveSingleQuotes(arguments.displayField)#</cfif> AS thisValue, #arguments.datatable#id AS thisID, #arguments.datatable#.ordinal, ISNULL(#arguments.datatable#.active, 1) AS Active
						FROM #arguments.datatable#
						<cfif isDefined('thisJoin') AND Len(thisJoin)>#thisJoin#</cfif>
						<cfif isDefined("arguments.whereClause") AND len(trim(arguments.whereClause))>
							WHERE #arguments.whereClause#
						</cfif>
						ORDER BY #arguments.datatable#.ordinal ASC
					</cfquery>
						<cfcatch type="database">
							<cfif FindNoCase("active", CFCATCH.DETAIL) NEQ 0 OR FindNoCase("active", CFCATCH.Message) NEQ 0>
								<cfquery datasource="#application.datasource#" name="q_getElements" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
									SELECT <cfif isDefined('thisSelect') AND Len(thisSelect)>#preserveSingleQuotes(thisSelect)#<cfelse>#preserveSingleQuotes(arguments.displayField)#</cfif> AS thisValue, #arguments.datatable#id AS thisID, #arguments.datatable#.ordinal
									FROM #arguments.datatable#
									<cfif isDefined('thisJoin') AND Len(thisJoin)>#thisJoin#</cfif>
									<cfif isDefined("arguments.whereClause") AND len(trim(arguments.whereClause))>
										WHERE #arguments.whereClause#
									</cfif>
									ORDER BY #arguments.datatable#.ordinal ASC
								</cfquery>
							<cfelse>
								<cfrethrow>
							</cfif>
						</cfcatch>
				</cftry>
		<cfreturn q_getElements>
	</cffunction>
	
	<cffunction access="public" name="updateOrdinal" output="false" returntype="boolean" displayname="updateOrdinal">
		<cfargument name="datatable" type="string" required="yes">
		<cfargument name="datatableid" type="numeric" required="yes">
		<cfargument name="position" type="numeric" required="yes">
		<cfset var q_updateOrdinal = "">
		<cfset var success = 1>
		<cftry>
			<cfquery name="q_updateOrdinal" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE #arguments.datatable#
				SET ordinal = #arguments.position#
				WHERE  #arguments.datatable#id = #arguments.datatableid#
			</cfquery>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn success>
	</cffunction>
	
	<cffunction access="public" name="updatePageComponent" output="false" returntype="boolean" displayname="updatePageComponent">
		<cfargument name="contentObjectId" type="numeric" required="yes">
		<cfargument name="formobjectitemid" type="numeric" required="yes">
		<cfargument name="parentid" type="numeric" required="yes">
		<cfset var q_updatePageComponent = "">
		<cfset var success = 1>
		<cftry>
			<cfquery name="q_updatePageComponent" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE pagecomponent 
				SET contentObjectId = #trim(arguments.contentObjectId)# 
				WHERE contentObjectId IN (
					SELECT instanceItemId 
					FROM version 
					WHERE formobjectitemid = #arguments.formobjectitemid# 
					AND parentid = #arguments.parentid#
				)
			</cfquery>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn success>
	</cffunction>
	
	<cffunction access="public" name="determineSupervisor" output="false" returntype="struct" displayname="determineSupervisor">
		<cfargument name="userid" type="numeric" required="yes">
		<cfargument name="formobjectid" type="numeric" required="yes">
		<cfargument name="limit" type="numeric" required="no" default="0">
		<cfset var thisSupervisor = "">
		<cfset var thisVersionStatus = 100000>
		<cfset var q_getSupervisor = "">
		<cfset var q_getUserAsSupervisor = "">
		<cfset var thisStruct = StructNew()>
        
        	<!--- Get the ID of the supervisor for this userid --->
            <cfset q_getSupervisor = getSupervisor(userid=arguments.userid,formobjectid=arguments.formobjectid)>
            <!--- Check to see if the user has a supervisor --->
            <cfif q_getSupervisor.recordcount GTE 1>
            <!--- If user has supervisor check to see if supervisorid matchs the user id --->
            	<cfif q_getSupervisor.supervisorid EQ arguments.userid>
	                <!--- SupervisorID matched userid --->
                    <cfset thisSupervisor = arguments.userid>
                    <!--- set default status to Published --->
					<cfset thisVersionStatus = 100002>
                <cfelse>
                	<!--- SupervisorID DOES NOT matched userid --->
                    <cfset thisSupervisor = q_getSupervisor.supervisorid>
                </cfif>
			<cfelse>
            <!--- User doesn't have a supervisor lets see if they are a supervisor for this tool --->
            	<cfset q_getUserAsSupervisor = getSupervisor(supervisorid=arguments.userid,formobjectid=arguments.formobjectid,limit=arguments.limit)>
                <cfif q_getUserAsSupervisor.RecordCount GTE 1>
					<!--- user is supervisor for this tool --->
					<cfset thisSupervisor = arguments.userid>
					<cfset thisVersionStatus = 100002>                    
				<cfelse>
                	<!--- user is NOT supervisor for this tool --->
                    <cfset thisSupervisor = getSiteSupervisor()>
				</cfif>
			</cfif>
			<cfset thisStruct.supervisorid = thisSupervisor>
			<cfset thisStruct.versionstatusid = thisVersionStatus>
		<cfreturn thisStruct>
	</cffunction>
	
	<cffunction access="public" name="setPublishDates" output="false" returntype="struct" displayname="determineSupervisor">
		<cfargument name="timeToPublish" type="string" required="yes">
		<cfargument name="dateToPublish" type="string" required="yes">
		<cfargument name="dateToExpire" type="string" required="yes">
		<cfargument name="thisErrorMsg" type="string" required="no" default="">			
		<cfset var buildDate1 = "">
		<cfset var buildDate2 = "">
		<cfset var thisDateToPublish = "">
		<cfset var thisDateToExpire = "">
		<cfset var hasError = 0>
		<cfset var ErrorMsg = "">
		<cfset var thisStruct = StructNew()>
	
		<!--- If the scheduled publication module is in play, validate dates --->
		<cfif len(arguments.dateToPublish) OR len(arguments.dateToExpire)>
			<cfif arguments.timeToPublish neq "">
				<cfset buildDate1 = "#arguments.dateToPublish# #arguments.timeToPublish#">
			<cfelse><!---cmc 12/20/05 had to put this in b/c wasn't working if timeToPublish=""--->
				<cfset buildDate1 = "#arguments.dateToPublish#">
			</cfif>
			<cfif form.timeToExpire neq "">
				<cfset buildDate2 = "#arguments.dateToExpire# #arguments.timeToExpire#">
			<cfelse><!---cmc 12/20/05 had to put this in b/c wasn't working if timeToExpire=""--->					
				<cfset buildDate2 = "#arguments.dateToExpire#">
			</cfif>
			<cfif isDate(buildDate1)>
				<cfset thisDateToPublish = createODBCDateTime(buildDate1)>
			<cfelse>
				<cfset thisDateToPublish = "NULL">
			</cfif>
			<cfif isDate(buildDate2)>
				<cfset thisDateToExpire = createODBCDateTime(buildDate2)>
			<cfelse>
				<cfset thisDateToExpire = "NULL">
			</cfif>
			<cfif (len(thisDateToExpire) AND thisDateToPublish NEQ "NULL") AND (len(thisDateToExpire) AND thisDateToExpire NEQ "NULL")>
				<cfif dateCompare(thisDateToExpire,thisDateToPublish) LTE 0>
					<cfset hasError=1>
					<cfset ErrorMsg=arguments.thisErrorMsg&"<li>Your publish date/time cannot be later than your expiration date.</li>">
				</cfif>
			</cfif>
		<cfelse><!--- if empty, set to empty, so as to overwrite anything in the column --->
			<cfif NOT len(arguments.dateToPublish)>
				<cfset thisDateToPublish = "NULL">
			</cfif>
			<cfif NOT len(arguments.dateToExpire)>
				<cfset thisDateToExpire = "NULL">
			</cfif>
		</cfif>
		<cfset thisStruct.dateToPublish = thisDateToPublish>
		<cfset thisStruct.dateToExpire = thisDateToExpire>
		<cfset thisStruct.hasError = hasError>
		<cfset thisStruct.ErrorMsg = ErrorMsg>
		<cfreturn thisStruct>
	</cffunction>
	<cffunction access="public" name="getTablesFromIDs" output="false" returntype="query" description="retrieve table names from form object table">
		<cfargument name="formObjectIds" required="yes" type="string">
		<cftry>
			<cfquery name="q_getTablesFromIDs" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable, formobjectid
				FROM formobject
				WHERE  formobjectid IN (#ARGUMENTS.formObjectIds#)
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getTablesFromIDs>
	</cffunction>
	<!--- generic table access function  --->
	<cffunction access="public" name="getFormData" output="false" returntype="query">
		<cfargument name="selectClause" required="yes" >
		<cfargument name="fromClause" required="no" >
		<cfargument name="whereClause" required="no" >
		<cfargument name="orderVar" required="no" >
		<cfset var usageCount = arrayNew(1)>
		<cftry>
			<cfquery name="q_getKeyFields" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #lcase(ARGUMENTS.selectClause)#
				FROM #lcase(ARGUMENTS.fromClause)#
				<cfif isDefined('ARGUMENTS.whereClause') AND len(trim(ARGUMENTS.whereClause))>
					WHERE #preserveSingleQuotes(ARGUMENTS.whereClause)#
				</cfif>
				<cfif isDefined('ARGUMENTS.orderVar') AND len(trim(ARGUMENTS.orderVar))>
					ORDER BY #ARGUMENTS.orderVar#
				</cfif>
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getKeyFields>
	</cffunction>
</cfcomponent>
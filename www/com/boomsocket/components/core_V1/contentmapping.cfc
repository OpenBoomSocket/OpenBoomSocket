<cfcomponent>
	<!--- this function returns the join and where clauses for mapping rules using a logical OR (union) --->
	<!--- TBD this function  also needs to return clauses for mapping rules using a logical AND (intersection) --->
	<!--- TBD this maybe roled into a switch case or rolled out to a seperate function --->
	<cffunction access="public" name="getMappingQueryClauses" output="false" returntype="struct" displayname="Get Whitepapers">
		<cfargument name="masterinfo" required="yes" type="array" displayname="master info" hint="masterinfo.tablename, masterinfo.instanceid">
		<cfargument name="associatetablename" required="yes" type="string" displayname="associate table name">
		<cfset var returnStruct = StructNew()>
		<cfset var tempMasterInfoStruct = StructNew()>
		<cfset var instanceIDs = "">
		<cfset var ruleIDs = "">
		<cfset var masterIDs = "">
		<cfset returnStruct.joinClause = "">
		<cfset returnStruct.whereClause = "">
		
		<!--- loop through all master objects & create instance id list & rule id list --->
		<cfloop from="1" to="#ArrayLen(arguments.masterinfo)#" index="i">
			<cfset infoSruct = structNew()>
			<cfset infoSruct = arguments.masterinfo[i]>
			<cfif isDefined('infoSruct.sekeyname') AND len(trim(infoSruct.sekeyname)) AND Left(arguments.masterinfo[i].tablename,4) neq 'http'>
				<cftry>
					<cfquery name="q_IDfromSekeyname" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT #arguments.masterinfo[i].tablename#ID
						FROM #arguments.masterinfo[i].tablename#
						WHERE #arguments.masterinfo[i].tablename#.sekeyname = '#arguments.masterinfo[i].sekeyname#'
					</cfquery>
					<cfset arguments.masterinfo[i].instanceid = evaluate("q_IDfromSekeyname.#arguments.masterinfo[i].tablename#ID")>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>				
			</cfif>		
			<cfset tempMasterInfoStruct = arguments.masterinfo[i]>
			<cfif isDefined('tempMasterInfoStruct.instanceid') AND isDefined('tempMasterInfoStruct.tablename') AND isNumeric(tempMasterInfoStruct.instanceid) AND len(trim(tempMasterInfoStruct.tablename))>			
				<cfset instanceIDs = ListAppend(instanceIDs, getInstanceIDsForQuery(masterformobjecttable='#tempMasterInfoStruct.tablename#',associateformobjecttable='#arguments.associatetablename#',masterforminstanceid=tempMasterInfoStruct.instanceid))>
				<cfset ruleIDs = ListAppend(ruleIDs, getMappingRule(masterformobjecttable='#tempMasterInfoStruct.tablename#',associateformobjecttable='#arguments.associatetablename#').contentmappingruleid)>
				<cfset masterIDs = listAppend(masterIDs, tempMasterInfoStruct.instanceid)>
			</cfif>
		</cfloop>
		<!--- make the instance list unique so that no duplicates are selected --->
		<cfset uniquelist = "">
		<cfloop list="#instanceIDs#" index="j">
			<cfif NOT listfindnocase(uniquelist, j)>
				<cfset uniquelist = listappend(uniquelist, j)>
			</cfif>
		</cfloop>
		<cfset instanceIDs = uniquelist>
		<!--- set up join clause & where clause for local query --->
		<cfset returnStruct.joinClause = "INNER JOIN contentmapping ON " & arguments.associatetablename & "." & arguments.associatetablename & "id = contentmapping.associateforminstanceid">
		<cfif Len(instanceIDs)>
			<cfset returnStruct.whereClause = "AND (contentmapping.contentmappingruleid IN (" & ruleIDs & ")) AND (" & associatetablename & "." & associatetablename & "id IN (" & instanceIDs & ")) AND (contentmapping.masterforminstanceid IN (" & masterIDs & "))">
		<cfelse>
			<cfset returnStruct.whereClause = "AND 1 <> 1">
		</cfif>
		
		<cfreturn returnStruct>		
	</cffunction>
	
	<!--- check to see if content mapping exists for this scenario (if formobject.useMappedContent = 1) --->
	<cffunction access="remote" name="UseMappedContent" output="false" returntype="boolean" displayname="RuleExists">
		<cfargument name="formobjectid" type="numeric" required="yes" hint="master object (ie: solutions)">
		<cfset var q_getMapping = "">
		<cfset var UseMappedContent = 0>
			<cftry>
				<cfquery name="q_getMapping" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT UseMappedContent
					FROM formobject
					WHERE formobjectid = #arguments.formobjectid#
				</cfquery>
				<cfif q_getMapping.recordcount>
					<cfset UseMappedContent = 1>
				</cfif>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>			
		<cfreturn UseMappedContent>
	</cffunction>	
	
	
	<cffunction access="remote" name="RuleExists" output="false" returntype="boolean" displayname="RuleExists">
		<cfargument name="masterformobjectid" type="numeric" required="yes" hint="master object (ie: solutions)">
		<cfargument name="associateformobjectid" type="numeric" required="yes" hint="associate object (ie: articles)">
		<cfset var q_checkRuleExists = "">
		<cfset var ruleExists = 0>
			<cftry>
				<cfquery name="q_checkRuleExists" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT contentmappingruleid
					FROM contentmappingrule
					WHERE masterformobjectid = #arguments.masterformobjectid#
						AND associateformobjectid = #arguments.associateformobjectid#
				</cfquery>
				<cfif q_checkRuleExists.recordcount>
					<cfset ruleExists = 1>
				</cfif>
				<cfcatch type="database">
					<cfset success = 0>
					<cfrethrow>
				</cfcatch>
			</cftry>			
		<cfreturn ruleExists>
	</cffunction>	
	
	<!--- Get formobjectid list (called by getFormObjects)  --->
	<!--- 12/13/2006 DRK Added role revesal --->	
	<cffunction access="remote" name="getObjectIDList" output="false" returntype="string" displayname="getObjectIDList">
		<!--- arguments.masterformobjectid: if not defined, get masters; if defined, get list of associated objects --->
		<cfargument name="masterformobjectid" type="numeric" required="no" default="0" hint="master formobjectid">
		<cfargument name="associateformobjectid" type="numeric" required="no" default="0" hint="master formobjectid">
		<cfset var q_getFormObjectIDs = "">
		<cfset var formObjectIDList = "">
			<cftry>
				<cfquery name="q_getFormObjectIDs" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT DISTINCT <cfif isDefined('arguments.associateformobjectid') AND arguments.associateformobjectid>masterformobjectid AS formobjectid<cfelseif isDefined('arguments.masterformobjectid') AND arguments.masterformobjectid>associateformobjectid AS formobjectid<cfelse>masterformobjectid AS formobjectid</cfif>
					FROM contentmappingrule
					WHERE 1 = 1
					<cfif isDefined('arguments.masterformobjectid') AND arguments.masterformobjectid>
						AND masterformobjectid = #arguments.masterformobjectid#
					<cfelseif isDefined('arguments.associateformobjectid') AND arguments.associateformobjectid>
						AND associateformobjectid = #arguments.associateformobjectid#
					</cfif>				
				</cfquery>
				<cfif q_getFormObjectIDs.recordcount>
					<cfset formObjectIDList = ValueList(q_getFormObjectIDs.formobjectid)>
				</cfif>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn formObjectIDList>
	</cffunction>
	
	<!--- get formobject info by formobjectid list --->
	<!--- 12/13/2006 DRK Added role revesal --->
	<cffunction access="public" name="getFormObjects" output="false" returntype="query" displayname="getFormObjects">
		<!--- arguments.masterFormobjectid: if not defined, get all masters; if defined, get list of associated objects for this ID --->
		<cfargument name="masterformobjectid" type="numeric" required="no" default="0" hint="master formobjectid">
		<!--- arguments.associateFormobjectid: if defined, get list of master objects for this ID --->
		<cfargument name="associateformobjectid" type="numeric" required="no" default="0" hint="associate formobjectid">
		<!--- datatable, used in local queries to get formobjectid --->
		<cfargument name="datatable" type="string" required="no">
		<cfset var q_getFormObjects = "">
		<cfset var formObjectIDList = "">
		<cfif NOT IsDefined('arguments.datatable') OR Len(trim(arguments.datatable)) EQ 0>
			<cfif (arguments.masterFormobjectid AND (NOT arguments.associateFormobjectid)) 
				OR ((NOT arguments.masterFormobjectid) AND (NOT arguments.associateFormobjectid))>
				<cfset formObjectIDList = getObjectIDList(masterFormobjectid=arguments.masterFormobjectid)>
			<cfelseif arguments.associateFormobjectid AND NOT arguments.masterFormobjectid>
				<cfset formObjectIDList = getObjectIDList(associateFormobjectid=arguments.associateFormobjectid)>
			<cfelse>
				<cfthrow type="exception" message="To many arguments." detail="Only one/none argument(s) should be passed.">
			</cfif>
		</cfif>
		<cfif Len(formObjectIDList) OR (isDefined('arguments.datatable') AND Len(arguments.datatable))>
			<cftry>
				<cfquery name="q_getFormObjects" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT formobjectid, formobjectname, label
					FROM formobject
					WHERE 
						<cfif isDefined('arguments.datatable') AND Len(arguments.datatable)>
							datatable = '#arguments.datatable#'
						<cfelse>
							formobjectid IN(#formObjectIDList#)
						</cfif>
				</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn q_getFormObjects>
	</cffunction>
	
	<!--- Get instanceid list of items mapped to a particular masterformobject instance (ie all articleids mapped to a specific solution --->
	<!--- 12/13/2006 DRK Added role revesal --->
	<cffunction access="public" name="getMappedInstanceIDs" output="false" returntype="string" displayname="getMappedInstanceIDs">
		<cfargument name="masterformobjectid" type="numeric" required="yes" hint="master object (ie: solutions)">
		<cfargument name="masterforminstanceid" type="numeric" required="no" hint="master instance (ie: solution 1)">
		<cfargument name="associateforminstanceid" type="numeric" required="no" hint="master instance (ie: solution 1)">
		<cfargument name="associateFormobjectid" type="numeric" required="yes" hint="associate object (ie: articles)">
		<cfset var q_getMappedInstances = "">
		<cfset var formInstanceIDList = "">
			<cfif ((NOT isDefined('arguments.masterforminstanceid')) AND (NOT isDefined('arguments.associateforminstanceid'))) OR (isDefined('arguments.masterforminstanceid') AND isDefined('arguments.associateforminstanceid'))>
				<cfthrow type="exception" message="Argument error" detail="Only one instance is required.">
			<cfelse>
				<cftry>
					<cfif isDefined('arguments.masterforminstanceid')>
						<cfquery name="q_getMappedInstances" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT contentmapping.associateforminstanceid
							FROM contentmapping INNER JOIN contentmappingrule
								ON contentmapping.contentmappingruleid = contentmappingrule.contentmappingruleid
							WHERE masterformobjectid = #arguments.masterformobjectid#
								AND contentmappingrule.associateformobjectid = #arguments.associateformobjectid#
								AND contentmapping.masterforminstanceid = #arguments.masterforminstanceid#
						</cfquery>
						<cfset formInstanceIDList = ValueList(q_getMappedInstances.associateforminstanceid)>
					<cfelse>
						<cfquery name="q_getMappedInstances" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT contentmapping.masterforminstanceid
							FROM contentmapping INNER JOIN contentmappingrule
								ON contentmapping.contentmappingruleid = contentmappingrule.contentmappingruleid
							WHERE masterformobjectid = #arguments.masterformobjectid#
								AND contentmappingrule.associateformobjectid = #arguments.associateformobjectid#
								AND contentmapping.associateforminstanceid = #arguments.associateforminstanceid#
						</cfquery>
						<cfset formInstanceIDList = ValueList(q_getMappedInstances.masterforminstanceid)>
					</cfif>
				<cfcatch type="database">
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfif>
		<cfreturn formInstanceIDList>	
	</cffunction>
	
	<!--- get instance info (id & name) --->
	<cffunction access="remote" name="getAllInstances" output="false" returntype="query" displayname="getInstanceInfo">
		<cfargument name="formobjectid" type="numeric" required="yes">
		<cfset var q_getDataTable = "">
		<cfset var q_getInstances = "">
		<cfset var a_dataArray = ArrayNew(1)>
		<cftry>
			<!--- query for datatable name --->
			<cfquery name="q_getDataTable" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT datatable, editFieldKeyValue2, useWorkFlow
				FROM formobject
				WHERE formobjectid = #arguments.formobjectid#
			</cfquery>
			<!--- query for id, name from datatable 
				! Do we need to take into account versioning here?!--->
			<cfset selectVar = #q_getDataTable.datatable#&"id,">
			<cfif q_getDataTable.datatable EQ 'page'>
				<cfset selectVar = selectVar&"sitesection.sitesectionname + ':' + ">
			</cfif>
			<cfset selectVar = selectVar&#q_getDataTable.datatable#&"name">
			<cfif q_getDataTable.datatable EQ 'page'>
				<cfset selectVar = selectVar&" AS pagename">
			</cfif>
			<cfloop list="#q_getDataTable.editFieldKeyValue2#" index="j">
				<cfif (NOT findnocase(j,"#q_getDataTable.datatable#name")) AND (NOT findnocase(j,"#q_getDataTable.datatable#id"))>
					<cfif (q_getDataTable.datatable EQ 'page') AND findnocase(j,"sitesectionid")>
						<cfset selectVar = selectVar&",sitesection.sitesectionLabel AS sitesectionid">
					<cfelse>
						<cfset selectVar = selectVar&","&lcase(q_getDataTable.datatable)&".">
						<cfset selectVar = selectVar&""&lcase(j)>
					</cfif>
				</cfif>
			</cfloop>
			<cfset fromVar = "#q_getDataTable.datatable# ">
			<cfif q_getDataTable.datatable EQ 'page'>
				<cfset fromVar = fromVar&"RIGHT OUTER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid">
			</cfif>
			<cfif q_getDataTable.recordcount>
				<cfif q_getDataTable.useWorkFlow eq 1>
					<cfmodule template="#application.CustomTagPath#/versioncheck.cfm" formobjectname="#q_getDataTable.datatable#">
				</cfif>
				<cfquery name="q_getInstances" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT #preservesinglequotes(selectVar)#
					FROM #fromVar#
					<cfif q_getDataTable.useWorkFlow eq 1>
						#joinclause#
					</cfif>
					WHERE 1 = 1 
					<cfif q_getDataTable.useWorkFlow eq 1>
						<!--- can't use whereclause b/c only pulls published items  --->
						AND (version.archive IS NULL OR version.archive = 0) 
						AND (version.formobjectitemid = #arguments.formobjectid#)
					</cfif>
					ORDER BY #q_getDataTable.datatable#name
				</cfquery>					
			</cfif>		
		<cfcatch type="database">
				<cfset success = 0>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getInstances>
	</cffunction>
	
	<!--- get contentmappingrule by master object, associate object--->
	<cffunction access="remote" name="getMappingRule" output="false" returntype="query" displayname="getMappingRule">
		<cfargument name="masterformobjectid" type="numeric" required="no" hint="master object id (ie: solutions)">
		<cfargument name="associateformobjectid" type="numeric" required="no" hint="associate object id (ie: articles)">
		<!--- CMC MOD 12/19/06: allow to pass in table names, not just ids --->
		<cfargument name="masterformobjecttable" type="string" required="no">
		<cfargument name="associateformobjecttable" type="string" required="no">
		<cfset var q_getRule = "">
		<!--- set master/associate form object ids depending up args passed in (id vs tablename)--->
		<cfset var thisMasterObjectID = 0>
		<cfset var thisAssociateObjectID = 0>
		<cfif isDefined('arguments.masterformobjectid') AND arguments.masterformobjectid>
			<cfset thisMasterObjectID =  arguments.masterformobjectid>
		<cfelseif isDefined('arguments.masterformobjecttable') AND Len(trim(arguments.masterformobjecttable))>
			<cfif StructKeyExists(APPLICATION.tool,arguments.masterformobjecttable)>
				<cfset thisMasterObjectID = APPLICATION.tool[arguments.masterformobjecttable]>
			</cfif>
			<!--- 
				ERJ 1/8/07 REM'D lines below because we can use the application.tool structure to get the ID's
				Delete this comment and below if no bugs form
			 --->
			<!--- <cfset q_masterformobject=getFormObjects(datatable=arguments.masterformobjecttable)>
			<cfif q_masterformobject.recordcount>
				<cfset thisMasterObjectID=q_masterformobject.formobjectid>
			</cfif> --->
		</cfif>
		<cfif isDefined('arguments.associateformobjectid') AND arguments.associateformobjectid>
			<cfset thisAssociateObjectID =  arguments.associateformobjectid>
		<cfelseif isDefined('arguments.associateformobjecttable') AND Len(trim(arguments.associateformobjecttable))>
			<cfif StructKeyExists(APPLICATION.tool,arguments.associateformobjecttable)>
				<cfset thisAssociateObjectID = APPLICATION.tool[arguments.associateformobjecttable]>
			</cfif>
			<!--- 
				ERJ 1/8/07 REM'D lines below because we can use the application.tool structure to get the ID's
				Delete this comment and below if no bugs form
			 --->
			<!--- <cfset q_associateformobject=getFormObjects(datatable=arguments.associateformobjecttable)>
			<cfif q_associateformobject.recordcount>
				<cfset thisAssociateObjectID=q_associateformobject.formobjectid>
			</cfif> --->
		</cfif>
			<!--- query for rule --->
			<cftry>
				<cfquery name="q_getRule" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT contentmappingruleid, masterformobjectid
					FROM contentmappingrule 
					WHERE (1=1)
					<cfif isDefined('thisMasterObjectID') AND thisMasterObjectID >
						AND (masterformobjectid = #thisMasterObjectID#)
					</cfif>
					<cfif isDefined('thisAssociateObjectID') AND thisAssociateObjectID>
						AND (associateformobjectid = #thisAssociateObjectID#)
					</cfif>
				</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn q_getRule>		
	</cffunction>
	
	<!--- delete mappings--->
	<cffunction access="remote" name="deleteMappings" output="false" returntype="boolean" displayname="deleteMappings">
		<cfargument name="masterformobjectid" type="numeric" required="no" default="0" hint="master object (ie: solutions)">
		<cfargument name="associateformobjectid" type="numeric" required="no" default="0" hint="associate object (ie: articles)">
		<cfargument name="masterforminstanceid" type="numeric" required="no" hint="master instance (ie: solution 1)">
		<cfargument name="associateforminstanceid" type="numeric" required="no" hint="associate instance (ie: articles1)">
		<cfset var success = 1>
		<cfset var q_getRule = "">
		<cfset var q_deleteMappings = "">
			<cftry>
				<cfset q_getRule = getMappingRule(masterformobjectid=arguments.masterformobjectid,associateFormobjectid=arguments.associateFormobjectid)>
				<cfif q_getRule.recordcount>
					<cfquery name="q_deleteMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						DELETE
						FROM contentmapping 
						WHERE (contentmappingruleid = #q_getRule.contentmappingruleid#)
						<cfif isDefined('arguments.masterforminstanceid') AND arguments.masterforminstanceid GT 0>
							AND (masterforminstanceid = #arguments.masterforminstanceid#)
						</cfif>	
						<cfif isDefined('arguments.associateforminstanceid') AND arguments.associateforminstanceid GT 0>
							AND (associateforminstanceid = #arguments.associateforminstanceid#)
						</cfif>						
					</cfquery>
				</cfif>
			<cfcatch type="database">
				<cfset success = 0>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn success>
	</cffunction>
	
	<cffunction access="remote" name="deleteMappingsForInstances" output="false" returntype="boolean" displayname="deleteMappings">
		<cfargument name="formobjectid" type="numeric" required="yes">
		<cfargument name="instanceidList" type="string" required="yes">
		<cfset var success = 1>
		<cfset var deleteThisMapping = "">
			<cftry>
				<cfloop list="#arguments.instanceidList#" index="i">
					<!--- delete mappings where instance is master --->
					<cfset deleteThisMapping = deleteMappings(masterformobjectid=arguments.formobjectid,masterforminstanceid=i)>
					<!--- delete mappings where instance is associate --->
					<cfset deleteThisMapping = deleteMappings(associateformobjectid=arguments.formobjectid,associateforminstanceid=i)>
				</cfloop>
			<cfcatch type="database">
				<cfset success = 0>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn success>	
	</cffunction>
	
	<!--- insert/update mappings for a particular instance --->
	<!--- 12/13/2006 DRK Added role revesal --->
	<cffunction access="remote" name="insertUpdateMappings" output="false" returntype="boolean" displayname="insertUpdateMappings">
		<cfargument name="masterformobjectid" type="numeric" required="yes" hint="master object (ie: solutions)">
		<cfargument name="associateformobjectid" type="numeric" required="yes" hint="associate object (ie: articles)">
		<cfargument name="masterforminstanceid" type="numeric" required="no" hint="master instance (ie: solution 1)">
		<cfargument name="associateforminstanceidList" type="string" required="no" hint="list of associateforminstanceids, in correct order for ordinal">
		<cfargument name="associateforminstanceid" type="numeric" required="no" hint="master instance (ie: solution 1)">
		<cfargument name="masterforminstanceidList" type="string" required="no" hint="list of associateforminstanceids, in correct order for ordinal">
		<cfset var success = 1>
		<cfset var q_getRule = "">
		<cfset var q_insertMappings = "">
		<cfset var deleteExistingMappings = "">
		<cfset var count = 1>
			<cfif ((NOT isDefined('arguments.associateforminstanceid')) AND (NOT isDefined('arguments.masterforminstanceidList')) AND isDefined('arguments.masterforminstanceid') AND isDefined('arguments.associateforminstanceidList')) OR ((NOT isDefined('arguments.masterforminstanceid')) AND (NOT isDefined('arguments.associateforminstanceidList')) AND isDefined('arguments.associateforminstanceid') AND isDefined('arguments.masterforminstanceidList'))>
			<cftry>
				<cftransaction>
					<cfset q_getRule = getMappingRule(masterformobjectid=arguments.masterformobjectid,associateFormobjectid=arguments.associateFormobjectid)>
					<cfif isDefined('arguments.masterforminstanceid') AND isDefined('arguments.associateforminstanceidList')>
						<cfset deleteExistingMappings = deleteMappings(masterformobjectid=arguments.masterformobjectid,associateformobjectid=arguments.associateformobjectid,masterforminstanceid=arguments.masterforminstanceid)>
						<!--- insert mappings --->
						<cfloop list="#arguments.associateforminstanceidList#" index="i">
							<cfquery name="q_insertMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								INSERT INTO contentmapping (contentmappingruleid, masterforminstanceid, associateforminstanceid, ordinal)
								VALUES(
									#q_getRule.contentmappingruleid#,
									#arguments.masterforminstanceid#,
									#i#,
									#count#
								)						
							</cfquery>
							<cfset count = count + 1>
						</cfloop>
					<cfelseif isDefined('arguments.associateforminstanceid') AND isDefined('arguments.masterforminstanceidList')>
						<cfset deleteExistingMappings = deleteMappings(masterformobjectid=arguments.masterformobjectid,associateformobjectid=arguments.associateformobjectid,associateforminstanceid=arguments.associateforminstanceid)>
						<!--- insert mappings --->
						<cfloop list="#arguments.masterforminstanceidList#" index="i">
							<cfquery name="q_insertMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								INSERT INTO contentmapping (contentmappingruleid, masterforminstanceid, associateforminstanceid, ordinal)
								VALUES(
									#q_getRule.contentmappingruleid#,
									#i#,
									#arguments.associateforminstanceid#,
									#count#
								)						
							</cfquery>
							<cfset count = count + 1>
						</cfloop>

					</cfif>
				</cftransaction>
			<cfcatch type="database">
				<cfset success = 0>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfelse>
			<cfthrow type="exception" message="Argument error" detail="Pass either master/associate list or associate/master list">
		</cfif>
		<cfreturn success>		
	</cffunction>
	
	<!--- get mapped instance ids to be used in a local query --->
	<cffunction access="public" name="getInstanceIDsForQuery" output="false" returntype="string" displayname="getInstanceIDsForQuery">
		<cfargument name="masterformobjecttable" type="string" required="yes" hint="datatable name">
		<cfargument name="associateformobjecttable" type="string" required="yes" hint="datatable name">
		<cfargument name="masterforminstanceid" type="numeric" required="yes">
			<cfset var q_masterformobject="">
			<cfset var q_associateformobject="">
			<cfset var thisMasterFormobjectid="">
			<cfset var thisAssociateFormobjectid="">
			<cfset var thisMasterForminstanceid="">
			<cfset var instanceidList="">	
				
			<!--- get master & associate form objects based on datatable --->
				<cfif StructKeyExists(APPLICATION.tool,arguments.masterformobjecttable)>
					<cfset thisMasterFormobjectid = APPLICATION.tool[arguments.masterformobjecttable]>
				</cfif>
				<cfif StructKeyExists(APPLICATION.tool,arguments.associateformobjecttable)>
					<cfset thisAssociateFormobjectid = APPLICATION.tool[arguments.associateformobjecttable]>
				</cfif>
				<!--- 
					ERJ 1/8/07 REM'D lines below because we can use the application.tool structure to get the ID's
					Delete this comment and below if no bugs form
				 --->
				<!--- <cfset q_masterformobject=getFormObjects(datatable=arguments.masterformobjecttable)>
				<cfset q_associateformobject=getFormObjects(datatable=arguments.associateformobjecttable)>
				<cfif q_masterformobject.recordcount>
					<cfset thisMasterFormobjectid=q_masterformobject.formobjectid>
				</cfif>
				<cfif q_associateformobject.recordcount>
					<cfset thisAssociateFormobjectid=q_associateformobject.formobjectid>
				</cfif> --->

				<cfset thisMasterForminstanceid=arguments.masterforminstanceid>
				<cfset instanceidList=getMappedInstanceIDs(masterformobjectid=thisMasterFormobjectid,masterforminstanceid=thisMasterForminstanceid,associateFormobjectid=thisAssociateFormobjectid)>				
			<cfreturn instanceidList>		
	</cffunction>
	
	<!--- swap out IDs for mappings that where entered during new instance creation --->
	<cffunction name="updateID" displayname="updateID" returntype="boolean">
		<cfargument name="tempID" required="yes" type="numeric">
		<cfargument name="realID" required="yes" type="numeric">
		<cfset returnValue = false>
		<cftry>
			<cftransaction>
				<!--- update for associate role --->
				<cfquery name="q_updateMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE contentmapping
					SET associateforminstanceid = #ARGUMENTS.realID#
					WHERE associateforminstanceid = #ARGUMENTS.tempID#
				</cfquery>
				<!--- update for master role --->
				<cfquery name="q_updateMappings" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE contentmapping
					SET masterforminstanceid = #ARGUMENTS.realID#
					WHERE masterforminstanceid = #ARGUMENTS.tempID#
					<!--- WHERE contentmappingid = #thiscontentmappingid# --->
				</cfquery>
			</cftransaction>
			<cfset returnValue = true>
			<cfcatch type="any">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn returnValue>
	</cffunction>
</cfcomponent>

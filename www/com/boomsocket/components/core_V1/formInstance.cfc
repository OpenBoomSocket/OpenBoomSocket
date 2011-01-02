<!---
[[.COPYRIGHT: Digital Positions, Inc. 2002-2006 ]]
[[.FILENAME: formInstance.cfc ]]
[[.AUTHOR: Darin Kohles ]]
[[.PRODUCT: i3SiteTools ]]
[[.PURPOSE: consolidate data interactions for creating env level forms]]
[[.COMMENTS: none]]
[[.VERSION: 5.0.1 ]]
[[.INPUTVARS: function dependant]]
[[.OUTPUTVARS: function dependant]]
[[.ENVVARS: session, session.user, application]]
[[.RETURNS: none]]
[[.HISTORY:
	11/08/2005 Script created
]]
--->
<cfcomponent>
	<!---
	[[ Database interface parsing and data acquisition ]]
	----->
	
	<!--- fetch information about current tool from db --->
	<!--- uses additional functions to perform  --->
	<cffunction access="remote" name="getToolInfo" output="false" returntype="query" displayname="getToolInfo" hint="returns tool from database">
		<cfargument name="toolid" type="numeric" required="no">
		<cfargument name="dataSource" required="no" default="#APPLICATION.dataSource#" >
		<cfargument name="dbUserName" required="no" default=""/>
		<cfargument name="dbpassword" required="no" default=""/>
		<cfargument name="permissionbased" required="no" type="boolean">
		<cfif (NOT isDefined('APPLICATION.datasource')) AND isDefined('ARGUMENTS.dataSource')>
			<cfset APPLICATION.datasource = ARGUMENTS.dataSource>
		</cfif>
		<cfif (NOT isDefined('APPLICATION.dbUserName')) AND isDefined('ARGUMENTS.dbUserName')>
			<cfset APPLICATION.dbUserName = ARGUMENTS.dbUserName>
		</cfif>
		<cfif (NOT isDefined('APPLICATION.dbpassword')) AND isDefined('ARGUMENTS.dbpassword')>
			<cfset APPLICATION.dbpassword = ARGUMENTS.dbpassword>
		</cfif>
		<cftry>
			<cfif isDefined('arguments.permissionbased') AND arguments.permissionbased>
				<cfquery name="q" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT formobjectid
					FROM userpermission
					WHERE userid = #session.user.id#
				</cfquery>
				<cfset toollist = valuelist(q.formobjectid)>
			</cfif>
			<cfquery name="q_getToolInfo" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM  formobject
				<cfif isDefined('ARGUMENTS.toolid')>
					WHERE formobjectid = #ARGUMENTS.toolid#
				</cfif>
				<cfif isDefined('arguments.permissionbased') AND arguments.permissionbased>
					WHERE formobjectid in (#toollist#) AND toolcategoryid <> 100001 AND toolcategoryid <> 100004 AND formobjectid = parentid AND isNull(datatable,'0') <> '0'
				</cfif>
				ORDER BY formobjectname
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getToolInfo>
	</cffunction>
	
	<!--- generic table access function  --->
	<cffunction access="remote" name="getFormData" output="false" returntype="query">
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
		<cfif findnocase("contentobject",ARGUMENTS.fromClause)>
			<cfloop query="q_getKeyFields"> 
				<cftry>
					<cfquery name="q_getUsage" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT pagecomponent.pageid, page.pagename + ' (' + sitesection.sitesectionname + ')' AS pagename
						FROM page INNER JOIN pagecomponent
							ON page.pageid = pagecomponent.pageid INNER JOIN sitesection
							ON page.sitesectionid = sitesection.sitesectionid RIGHT OUTER JOIN contentobject
							ON pagecomponent.contentobjectid = contentobject.contentobjectid
						WHERE contentobject.contentobjectid = #q_getKeyFields.contentobjectid#
					</cfquery>
					<cfcatch type="database">
						<cfrethrow>
					</cfcatch>
				</cftry>
				<cfset usageCount[q_getKeyFields.currentrow] = q_getUsage>
			</cfloop>
			<cfset newcol = queryAddColumn(q_getKeyFields,'usecount',usageCount)>
		</cfif>
		<cfif findnocase("displayhandler",ARGUMENTS.fromClause)>
			<cfloop query="q_getKeyFields">
				<cftry>
					<cfquery name="q_getUsage" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT pagecomponent.pageid, page.pagename + ' (' + sitesection.sitesectionname + ')' AS pagename
						FROM page INNER JOIN pagecomponent
							ON page.pageid = pagecomponent.pageid INNER JOIN sitesection
							ON page.sitesectionid = sitesection.sitesectionid RIGHT OUTER JOIN displayhandler
							ON pagecomponent.contentobjectid = displayhandler.displayhandlerid
						WHERE displayhandler.displayhandlerid = #q_getKeyFields.displayhandlerid#
					</cfquery>
					<cfcatch type="database">
						<cfrethrow>
					</cfcatch>
				</cftry>
				<cfset usageCount[q_getKeyFields.currentrow] = q_getUsage>
			</cfloop>
			<cfset newcol = queryAddColumn(q_getKeyFields,'usecount',usageCount)>
		</cfif>
		<cfreturn q_getKeyFields>
	</cffunction>
	
	<!--- verify meta data integrity --->
	<cffunction access="public" name="isTableValid" output="false" returntype="boolean" displayname="isTableValid" hint="check for existance of table and column">
		<cfargument name="keyField" type="string" required="yes" >
		<cfargument name="displayField" type="string" required="yes" >
		<cfargument name="tableName" type="string" required="yes" >
		<cftry>
			<cfquery name="q_test4table" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT count(#ARGUMENTS.keyField#) FROM #ARGUMENTS.tableName#
			</cfquery>
			<cfset tableExists=1>
			<cfcatch type="Database"><cfset tableExists=0></cfcatch>
		</cftry>
		<cftry>
			<cfquery name="q_test4column" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #ARGUMENTS.displayField# FROM #ARGUMENTS.tableName#
			</cfquery>
			<cfset columnExists=1>
			<cfcatch type="Database"><cfset columnExists=0></cfcatch>
		</cftry>
		<cfreturn (tableExists AND columnExists)>
	</cffunction>
	
	<!---
	[[ Tool interface functions - return data to front facing tool ]]
	----->
	
	<!--- manage information request and return formatting --->
	<cffunction access="remote" name="getFormDataFlex" output="false" returntype="array" displayname="getFormDataFlex" hint="returns form data meta and listing">
		<cfargument name="toolid" type="numeric" required="yes">
		<cfargument name="selectClause" required="yes" >
		<cfargument name="fromClause" required="yes" >
		<cfargument name="whereClause" required="no" default="" >
		<cfargument name="orderVars" required="no" default="" >
		<cfargument name="dataSource" required="no" default="#APPLICATION.dataSource#" >
		<cfset var formData = arrayNew(1)>
		<cfif (NOT isDefined('APPLICATION.datasource')) AND isDefined('ARGUMENTS.dataSource')>
			<cfset APPLICATION.datasource = ARGUMENTS.dataSource>
		</cfif>
		<cfset formData[1] = getToolInfo(toolid)>		
		<cfset formData[2] = getFormData(selectClause=#ARGUMENTS.selectClause#,fromClause=#ARGUMENTS.fromClause#,whereClause=#ARGUMENTS.whereClause#,orderVar=#ARGUMENTS.orderVars#)>
		<cfreturn formData>
	</cffunction>
	<cffunction access="remote" name="deleteFormDataFlex" output="false" returntype="void" displayname="getFormDataFlex" hint="returns form data meta and listing">
		<cfargument name="tablename" type="string" required="yes">
		<cfargument name="instanceids" required="yes" >
		<cfargument name="dataSource" required="no" default="#APPLICATION.dataSource#" >
		<cfif listlen(arguments.instanceids)>
			<cftry>
				<cfquery name="q_deleteItems" datasource="#arguments.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					DELETE FROM #ARGUMENTS.tablename#
					WHERE #ARGUMENTS.tablename#id in (#ARGUMENTS.instanceids#)
				</cfquery>
				<cfcatch type="any">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
</cfcomponent>
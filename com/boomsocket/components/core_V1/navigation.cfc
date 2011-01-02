<cfcomponent displayname="Navigation CFC">
	<cffunction access="public" name="getAllNavSettings" output="false" returntype="query" displayname="getAllNavSettings">
		<cfset var q_getAllNavSettings = ''>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getAllNavSettings" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT dynamicnavigationSettings.*, dynamicnavigationgroup.groupType, dynamicnavigationgroup.dynamicnavigationgroupid
				FROM dynamicnavigationgroup 
					INNER JOIN dynamicnavigationSettings ON dynamicnavigationgroup.dynamicnavigationsettingsid = dynamicnavigationSettings.dynamicnavigationSettingsid
			</cfquery>
			
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getAllNavSettings>
	</cffunction>

	<cffunction access="public" name="getNavGroups" output="false" returntype="query" displayname="getNavGroups">
		<cftry>
			<cfquery name="q_getNavGroups" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT dynamicnavigationgroupid, groupname, grouptype
				FROM dynamicnavigationgroup
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getNavGroups>
	</cffunction>
	<cffunction access="remote" name="addNavGroup" output="false" returntype="string" displayname="addNavGroup">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cftransaction>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="dynamicnavigationgroup" datasource="#APPLICATION.datasource#">
				<cfquery name="q_addNavGroup" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO dynamicnavigationgroup (dynamicnavigationgroupid, groupname, datecreated, datemodified) VALUES (#newID#,'#ARGUMENTS.dataStruct.groupname#',#CreateODBCDateTime(now())#,#CreateODBCDateTime(now())#)
				</cfquery>
			</cftransaction>
			<cfset message = message&"Navigation Group <em>#arguments.dataStruct.groupname#</em> added!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Group <em>#arguments.dataStruct.groupname#</em> <strong>failed</strong> to add!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>
	<cffunction access="remote" name="updateNavGroup" output="false" returntype="string" displayname="updateNavGroup">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_updateNavGroup" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE dynamicnavigationgroup
				SET groupname = '#ARGUMENTS.dataStruct.groupname#', datemodified =#CreateODBCDateTime(now())#
				WHERE dynamicnavigationgroupid = #arguments.dataStruct.dynamicnavigationgroupid#
			</cfquery>
			<cfset message = message&"Navigation Group <em>#arguments.dataStruct.groupname#</em> updated!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Group <em>#arguments.dataStruct.groupname#</em> <strong>failed</strong> to update!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>
	<cffunction access="remote" name="delNavGroup" output="false" returntype="string" displayname="del Group Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_delNavGroup" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM dynamicnavigationgroup		
				WHERE dynamicnavigationgroupid = #arguments.dataStruct.dynamicnavigationgroupid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.groupname#</em> deleted!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.groupname#</em> <strong>failed</strong> to delete!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="public" name="getNavSettings" output="false" returntype="query" displayname="getNavSettings">
		<cfargument name="q_allNavSettings" displayname="all nav settings query" required="yes" type="query">
		<cfargument name="navigationID" displayname="navigationID" required="yes" type="numeric">
		<cfset var q_getNavSettings = ''>
		<cftry>
			<cfquery dbtype="query" name="q_getNavSettings" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM arguments.q_allNavSettings
				WHERE dynamicnavigationgroupid = #arguments.navigationID#
			</cfquery>		
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getNavSettings>
	</cffunction>

	<cffunction access="remote" name="getAllNavigation" output="false" returntype="query" displayname="getAllNavigation">
		<cfargument name="dynamicnavigationgroupid" required="no" type="numeric" displayname="dynamicnavigationgroupid">
		<cfargument name="fromflex" required="no" type="numeric" displayname="fromflex">
		<cfset var q_getAllNavigation = ''>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getAllNavigation" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT  dynamicnavigation.*, page.sitesectionid, page.pagename, sitesection.sitesectionname, upload1.uploadid as uploadidOFF, upload2.uploadid as uploadidON, upload3.uploadid as uploadidAT, upload1.uploaddescription, upload2.uploaddescription, upload3.uploaddescription, upload1.filetype, upload2.filetype, upload3.filetype, '/uploads/' + uploadcategory1.foldername + '/' + upload1.filename AS onState, '/uploads/' + uploadcategory2.foldername + '/' + upload2.filename AS offState, '/uploads/' + uploadcategory3.foldername + '/' + upload3.filename AS atState
				FROM  dynamicnavigation 
					LEFT OUTER JOIN upload upload1 ON dynamicnavigation.imageOn = upload1.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory1 ON upload1.uploadcategoryid = uploadcategory1.uploadcategoryid 
					LEFT OUTER JOIN upload upload2 ON dynamicnavigation.imageOff = upload2.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory2 ON upload2.uploadcategoryid = uploadcategory2.uploadcategoryid 
					LEFT OUTER JOIN upload upload3 ON dynamicnavigation.imageAt = upload3.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory3 ON upload3.uploadcategoryid = uploadcategory3.uploadcategoryid
					LEFT OUTER JOIN page ON page.pageid = dynamicnavigation.pageid
					LEFT OUTER JOIN sitesection ON page.sitesectionid = sitesection.sitesectionid
				<cfif IsDefined('arguments.dynamicnavigationgroupid') AND arguments.dynamicnavigationgroupid GT 0>
					WHERE (dynamicnavigation.dynamicnavigationgroupid = #arguments.dynamicnavigationgroupid#)
				</cfif>
				ORDER BY dynamicnavigation.ordinal ASC
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getAllNavigation>
	</cffunction>
	
	<cffunction access="public" name="getNavigation" output="false" returntype="query" displayname="getNavigation">
	<cfargument name="navType" displayname="navigation type: Image Rollovers, Text Only" required="yes" type="string">
	<!--- Image Rollovers and Text Only --->
	<cfargument name="navigationID" displayname="navigationID" required="no" type="numeric">
	<cfargument name="datatable" displayname="datatable" required="no" type="string">
	<cfargument name="navigationgroupid" displayname="navigationgroupid" required="no" type="numeric">
	<cfargument name="alphaordering" type="boolean" required="no" displayname="alphaordering" >
	<cfargument name="active" type="boolean" required="yes" displayname="Active" default="1">
		<cfset var q_getNavigation = ''>
		<cftry>
			<!--- Image Rollovers, Text Only --->	
			<cfquery dbtype="query" name="q_getNavigation" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">			
				SELECT  *
				FROM  application.allNavigation
				WHERE 1=1 AND (dynamicnavigationgroupid = #arguments.navigationID#)
					<cfif arguments.active> AND (active = #arguments.active#)</cfif>
				<cfif arguments.navType eq "Image Rollovers">
					AND (parentid = dynamicnavigationid)
				</cfif>
				<cfif isDefined('arguments.alphaordering') AND arguments.alphaordering EQ 1>
					ORDER BY name ASC
				<cfelse>
					ORDER BY ordinal ASC
				</cfif>
			</cfquery>				
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getNavigation>
	</cffunction>
	
	<cffunction access="public" name="updateMenuItem" output="false" returntype="string" displayname="update Menu Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_updateNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE dynamicnavigation
				SET name = '#arguments.dataStruct.label#', <cfif isNumeric(arguments.dataStruct.pageid)>pageid = #arguments.dataStruct.pageid#,</cfif> href = '#arguments.dataStruct.href#', target = '#arguments.dataStruct.target#', parentid = #arguments.dataStruct.parentid#, datemodified = #CreateODBCDateTime(now())#, active = #arguments.dataStruct.active#<cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>, imageOn = #ListFirst(arguments.dataStruct.imageOn,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>, imageOff = #ListFirst(arguments.dataStruct.imageOff,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>, imageAt = #ListFirst(arguments.dataStruct.imageAt,'~')#</cfif>
				WHERE dynamicnavigationid = #arguments.dataStruct.dynamicnavigationid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> updated!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to update!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="public" name="addMenuItem" output="false" returntype="string" displayname="addMenuItem">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cftransaction>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="dynamicnavigation" datasource="#APPLICATION.datasource#">
				<cfquery name="q_updateNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO dynamicnavigation
						(dynamicnavigationid, dynamicnavigationgroupid, name, pageid, href, target, parentid, datemodified, datecreated, active<cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>, imageOn</cfif><cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>, imageOff</cfif><cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>, imageAt</cfif>)
					VALUES
						(#newID#, #arguments.dataStruct.dynamicnavigationgroupid#, '#arguments.dataStruct.label#', <cfif arguments.dataStruct.pageid GT 0>#arguments.dataStruct.pageid#<cfelse>NULL</cfif>, '#arguments.dataStruct.href#', '#arguments.dataStruct.target#', <cfif arguments.dataStruct.parentid GT 0>#arguments.dataStruct.parentid#<cfelse>#newid#</cfif>, #CreateODBCDateTime(now())#, #CreateODBCDateTime(now())#, #arguments.dataStruct.active#<cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>, #ListFirst(arguments.dataStruct.imageOn,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>, #ListFirst(arguments.dataStruct.imageOff,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>, #ListFirst(arguments.dataStruct.imageAt,'~')#</cfif>)
				</cfquery>
			</cftransaction>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> added!<br>">
				<cfif isDefined('arguments.dataStruct.FieldsSave')>
					<cfset arguments.dataStruct.FieldsSave = ListAppend(arguments.dataStruct.FieldsSave, newID)>
				<cfelse>
					<cfset arguments.dataStruct.FieldsSave = newID>
				</cfif>
				<cfset message = message & updateMenuOrder(arguments.dataStruct)>
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to add!<br>">
				<cfset message = message&CFCATCH.Detail&"<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="public" name="delMenuItem" output="false" returntype="string" displayname="del Menu Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_deleteNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM dynamicnavigation		
				WHERE dynamicnavigationid = #arguments.dataStruct.dynamicnavigationid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> deleted!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to delete!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="public" name="updateMenuOrder" output="false" returntype="string" displayname="update Menu Order">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cfset var ordinalCount = 1>
		<cfif IsDefined('arguments.dataStruct.parentID') AND arguments.dataStruct.parentID GT 0 and ListLen(arguments.dataStruct.fieldsSave) GT 1>
			<cfset arguments.dataStruct.FieldsSave = ListDeleteAt(arguments.dataStruct.fieldsSave,ListFindNoCase(arguments.dataStruct.fieldsSave,parentID))>
		</cfif>
		<cftry>
			<cfloop index="thisPos" list="#arguments.dataStruct.FieldsSave#" delimiters=",">
				<cfset thisOrdinalValue = ordinalCount>
				<cfquery name="q_UpdateNavOrdinal" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE dynamicnavigation
					SET ordinal = #thisOrdinalValue#
					WHERE dynamicnavigationid = #thisPOS#
				</cfquery>
				<cfset ordinalCount = ordinalCount+1>
			</cfloop>
				<cfset message = message&"Navigation Order updated!<br>">
				<cfset application.allnavigation = getAllNavigation()>
			<cfcatch type="database">
				<cfset message = message&"Navigation Order <strong>failed</strong> to update!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="public" name="getParents" output="false" returntype="query" displayname="get Parents">
		<cfargument name="masterQuery" displayname="Master Query to Query Against" required="yes" type="query">
		<cftry>
			<cfquery name="q_getParents" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				select * 
				from masterQuery
				where parentid = dynamicnavigationid
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getParents>
	</cffunction>

	<cffunction access="public" name="getDetails" output="false" returntype="query" displayname="get Details">
		<cfargument name="masterQuery" displayname="Master Query to Query Against" required="yes" type="query">
		<cfargument name="navItems" displayname="navItems" required="no" type="numeric">
		<cfargument name="parentID" displayname="parentID" required="no" type="numeric">
		<cfif NOT IsDefined('navItems') AND NOT IsDefined('parentID')>
			<cfthrow type="exception" message="You must pass in a navitemID or a parent id to this function">
		</cfif>
		<cftry>
			<cfquery name="q_getDetails" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				select * 
				from masterQuery
				where dynamicnavigationid = <cfif IsDefined('arguments.navItems') AND arguments.navItems GT 0>#arguments.navItems#<cfelse>#arguments.parentID#</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getDetails>
	</cffunction>

	<cffunction access="public" name="getChildren" output="false" returntype="query" displayname="get Children">
		<cfargument name="masterQuery" displayname="Master Query to Query Against" required="yes" type="query">
		<cfargument name="parentID" displayname="parentID" required="no" type="numeric">
		<cftry>
			<cfquery name="q_getChildren" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				select * 
				from masterQuery
				where parentid = #arguments.parentID#
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getChildren>
	</cffunction>

	<cffunction access="public" name="getPages" output="false" returntype="query" displayname="get Pages">
		<cftry>
			<cfquery name="q_getPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT page.pageid, page.pagename, page.sitesectionid, sitesection.sitesectionname
				FROM page 
					INNER JOIN sitesection 
						ON page.sitesectionid = sitesection.sitesectionid
				Order BY sitesection.sitesectionname ASC
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getPages>
	</cffunction>
	
	<cffunction access="public" name="getParentFromPageID" output="false" returntype="numeric" displayname="getParentFromPageID">
		<cfargument name="pageid" displayname="Page id" required="yes" type="numeric">
		<cfargument name="navigationid" displayname="Navigation id" required="no" type="numeric">
		<cftry>
			<cfquery name="q_getParentFromPageID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT parentid
				FROM dynamicnavigation
				WHERE pageID = #arguments.pageID# 
				<cfif IsDefined('arguments.navigationid') AND arguments.navigationid>
					AND dynamicnavigationgroupid = #arguments.navigationid#
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfif q_getParentFromPageID.recordcount>
			<cfreturn q_getParentFromPageID.parentid>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>
	<cffunction access="public" name="getSectionID" output="false" returntype="numeric" description="getSectionID" hint="returns the section ID for a given page base on either the pageid">
		<cfargument name="pageid" type="numeric" required="yes" default="0">
		<cfset q_getSectionID="0">
		<cftry>
			<cfquery name="q_getSectionID" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT sitesectionid
				FROM page
				WHERE pageid = #arguments.pageid#
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getSectionID.sitesectionid>
	</cffunction>
	<cffunction name="getUltimateParent" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="groupid" type="numeric" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif currentId EQ q_data.dynamicnavigationid AND currentId NEQ q_data.parentid>
				<cfset currentId=getUltimateParent(q_data=q_data,groupid=arguments.groupid,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction name="getGetSecondGenerationParent" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="groupid" type="numeric" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset ultimateParent=getUltimateParent(q_data=q_data,groupid=arguments.groupid,currentID=q_data.parentid)>
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif currentId EQ q_data.dynamicnavigationid AND ultimateParent NEQ q_data.parentid>
				<cfset currentId=getGetSecondGenerationParent(q_data=q_data,groupid=arguments.groupid,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction name="getNavIdFromPageID" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="currentpageid" type="numeric" required="yes">
		<cfset defaultnavid=0>
		<cfquery name="q_getNavIdFromPageID" dbtype="query" maxrows="1" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT dynamicnavigationid
			FROM q_data
			WHERE pageid = #currentpageid#
		</cfquery>
		<cfset currentnavid=0>
		<cfif q_getNavIdFromPageID.recordcount GT 0>
			<cfreturn q_getNavIdFromPageID.dynamicnavigationid>
		<cfelse>
			<cfreturn defaultnavid>
		</cfif>
	</cffunction>
</cfcomponent>

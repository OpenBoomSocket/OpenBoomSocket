<cfcomponent displayname="Navigation CFC">
	<cffunction access="remote" name="getNavGroups" output="false" returntype="query" displayname="getNavGroups">
		<cftry>
			<cfquery name="q_getNavGroups" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT navgroupid, navgroupname, grouptype
				FROM navgroup
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
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="navgroup" datasource="#APPLICATION.datasource#">
				<cfquery name="q_addNavGroup" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO navgroup (navgroupid, navgroupname, datecreated, datemodified, grouptype) VALUES (#newID#,'#ARGUMENTS.dataStruct.navgroupname#',#CreateODBCDateTime(now())#,#CreateODBCDateTime(now())#,'#ARGUMENTS.dataStruct.grouptype#')
				</cfquery>
			</cftransaction>
			<cfset message = message&"Navigation Group <em>#arguments.dataStruct.navgroupname#</em> added!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Group <em>#arguments.dataStruct.navgroupname#</em> <strong>failed</strong> to add!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>
	<cffunction access="remote" name="updateNavGroup" output="false" returntype="string" displayname="updateNavGroup">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_updateNavGroup" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE navgroup
				SET navgroupname = '#ARGUMENTS.dataStruct.navgroupname#', datemodified =#CreateODBCDateTime(now())#
				WHERE navgroupid = #arguments.dataStruct.navgroupid#
			</cfquery>
			<cfset message = message&"Navigation Group <em>#arguments.dataStruct.navgroupname#</em> updated!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Group <em>#arguments.dataStruct.navgroupname#</em> <strong>failed</strong> to update!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>
	<cffunction access="remote" name="delNavGroup" output="false" returntype="string" displayname="del Group Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_delNavGroup" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM navgroup		
				WHERE navgroupid = #arguments.dataStruct.navgroupid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.navgroupname#</em> deleted!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.navgroupname#</em> <strong>failed</strong> to delete!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>
	
	<cffunction access="remote" name="getAllNavigation" output="false" returntype="query" displayname="getAllNavigation">
		<cfargument name="navgroupid" required="no" type="numeric" displayname="navgroupid">
		<cfargument name="fromflex" required="no" type="numeric" displayname="fromflex">
		<cfargument name="usePermissions" required="no" type="boolean" displayname="usePermissions for admin nav">
		<cfargument name="active" type="boolean" required="yes" displayname="Active" default="1">
		<cfset var q_getAllNavigation = ''>
		<cfset var toolIDs = ''>
		<cfif isDefined('ARGUMENTS.usePermissions') AND ARGUMENTS.usePermissions>
			<!--- Build list of tools user is allowed to see --->
			<cfloop from="1" to="#arrayLen(session.user.tools)#" index="i">
				<cfif session.user.tools[i][2].access EQ 1>
					<cfset toolIDs=listAppend(toolIDs,session.user.tools[i][1])>
				</cfif>
			</cfloop>
		</cfif>
		<cftry>
			<cfquery datasource="#application.datasource#" name="q_getAllNavigation" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT  navitem.*, navitemaddress.navitemaddressid, navitemaddress.navitemaddressname, upload1.uploadid as uploadidOFF, upload2.uploadid as uploadidON, upload3.uploadid as uploadidAT, upload1.uploaddescription, upload2.uploaddescription, upload3.uploaddescription, upload1.filetype, upload2.filetype, upload3.filetype, '/uploads/' + uploadcategory1.foldername + '/' + upload1.filename AS onState, '/uploads/' + uploadcategory2.foldername + '/' + upload2.filename AS offState, '/uploads/' + uploadcategory3.foldername + '/' + upload3.filename AS atState, navitemaddress.formobjecttableid, navitemaddress.objectinstanceid, navitemaddress.urlpath
				FROM  navitem 
					LEFT OUTER JOIN upload upload1 ON navitem.imageOn = upload1.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory1 ON upload1.uploadcategoryid = uploadcategory1.uploadcategoryid 
					LEFT OUTER JOIN upload upload2 ON navitem.imageOff = upload2.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory2 ON upload2.uploadcategoryid = uploadcategory2.uploadcategoryid 
					LEFT OUTER JOIN upload upload3 ON navitem.imageAt = upload3.uploadid 
					LEFT OUTER JOIN uploadcategory uploadcategory3 ON upload3.uploadcategoryid = uploadcategory3.uploadcategoryid
					INNER JOIN navitemaddress ON navitemaddress.navitemaddressid = navitem.navitemaddressid
				WHERE (1=1)
				<cfif arguments.active> AND (navitem.active = #arguments.active#)</cfif>
				<cfif IsDefined('arguments.navgroupid') AND arguments.navgroupid GT 0>
					AND (navitem.navgroupid = #arguments.navgroupid#)
				</cfif>
				<cfif isDefined('ARGUMENTS.usePermissions') AND ARGUMENTS.usePermissions>
					AND (((navitemaddress.formobjecttableid IN (#toolIDs#)) AND navitemaddress.permissionbased = 1) OR (isNull(navitemaddress.permissionbased,0) = 0))
				</cfif>
				ORDER BY navitem.ordinal ASC
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getAllNavigation>
	</cffunction>
	
	<!--- <cffunction access="remote" name="getNavigation" output="false" returntype="query" displayname="getNavigation">
	<cfargument name="navType" displayname="navigation type: Image Rollovers, Text Only, or DHTML" required="yes" type="string">
	<cfargument name="navitemID" displayname="navitemID" required="no" type="numeric">
	<cfargument name="navgroupid" displayname="navigationgroupid" required="no" type="numeric">
	<cfargument name="alphaordering" type="boolean" required="no" displayname="alphaordering" >
	<cfargument name="active" type="boolean" required="yes" displayname="Active" default="1">
		<cfset var q_getNavigation = ''>
		<cftry>
			<cfquery dbtype="query" name="q_getNavigation">			
				SELECT  *
				FROM  application.allNavigation
				WHERE 1=1 AND (navitemID = #arguments.navitemID#)
				<cfif arguments.active> AND (active = #arguments.active#)</cfif>
				<cfif arguments.navType eq "Image Rollovers">
					AND (parentid = navitemID)
				</cfif>
				<cfif isDefined('arguments.alphaordering') AND arguments.alphaordering EQ 1>
					ORDER BY navitemname ASC
				<cfelse>
					ORDER BY ordinal ASC
				</cfif>
			</cfquery>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getNavigation>
	</cffunction> --->
	
	<cffunction access="remote" name="updateMenuItem" output="false" returntype="string" displayname="update Menu Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfif NOT isNumeric(arguments.dataStruct.navitemaddressid) OR NOT (arguments.dataStruct.navitemaddressid GT 0)>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="navitemaddress" datasource="#APPLICATION.datasource#">
				<cfquery name="q_address" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO navitemaddress (navitemaddressid,navitemaddressname,datecreated,datemodified,urlpath)
					VALUES (#newID#,'#arguments.dataStruct.label#', #CreateODBCDateTime(now())#, #CreateODBCDateTime(now())#,'#arguments.dataStruct.urlpath#')
				</cfquery>
				<cfset arguments.dataStruct.navitemaddressid = newID>
			<cfelse>
				<cfquery name="q_updateadd" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					UPDATE navitemaddress
					SET navitemaddressname = '#arguments.dataStruct.label#', datemodified = #CreateODBCDateTime(now())#, urlpath = '#arguments.dataStruct.urlpath#'
					WHERE navitemaddressid = #arguments.dataStruct.navitemaddressid#
				</cfquery>
			</cfif>
			<cfquery name="q_updateNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				UPDATE navitem
				SET navitemname = '#arguments.dataStruct.label#', <cfif isNumeric(arguments.dataStruct.navitemaddressid)>navitemaddressid = #arguments.dataStruct.navitemaddressid#,</cfif> target = '#arguments.dataStruct.target#', parentid = #arguments.dataStruct.parentid#, pageid = #arguments.dataStruct.pageid#, datemodified = #CreateODBCDateTime(now())#, active = #arguments.dataStruct.active#, imageOn = <cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>#ListFirst(arguments.dataStruct.imageOn,'~')#<cfelse>''</cfif>, imageOff = <cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>#ListFirst(arguments.dataStruct.imageOff,'~')#<cfelse>''</cfif>, imageAt = <cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>#ListFirst(arguments.dataStruct.imageAt,'~')#<cfelse>''</cfif>, catonly = #arguments.dataStruct.catonly#
				WHERE navitemid = #arguments.dataStruct.navitemid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> updated!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to update!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="remote" name="addMenuItem" output="false" returntype="string" displayname="addMenuItem">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfif NOT isNumeric(arguments.dataStruct.navitemaddressid) OR NOT (arguments.dataStruct.navitemaddressid GT 0)>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="navitemaddress" datasource="#APPLICATION.datasource#">
				<cfquery name="q_address" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO navitemaddress (navitemaddressid,navitemaddressname,datecreated,datemodified,urlpath)
					VALUES (#newID#,'#arguments.dataStruct.urlpath#', #CreateODBCDateTime(now())#, #CreateODBCDateTime(now())#,'#arguments.dataStruct.urlpath#')
				</cfquery>
				<cfset arguments.dataStruct.navitemaddressid = newID>
			<cfelseif len(trim(arguments.dataStruct.urlpath))>
				UPDATE navitemaddress
				SET navitemaddressname = #arguments.dataStruct.urlpath#, datemodified = #CreateODBCDateTime(now())#, urlpath = #arguments.dataStruct.urlpath#
				WHERE navitemaddressid = #arguments.dataStruct.navitemaddressid#
			</cfif>
			<cftransaction>
				<cfmodule template="#application.customTagPath#/assignID.cfm" tablename="navitem" datasource="#APPLICATION.datasource#">
				<cfquery name="q_updateNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					INSERT INTO navitem
						(navitemid, navgroupid, navitemname, navitemaddressid, target, parentid, pageid, datemodified, datecreated, active<cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>, imageOn</cfif><cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>, imageOff</cfif><cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>, imageAt</cfif>, catonly)
					VALUES
						(#newID#, #arguments.dataStruct.navgroupid#, '#arguments.dataStruct.label#', <cfif arguments.dataStruct.navitemaddressid GT 0>#arguments.dataStruct.navitemaddressid#<cfelse>NULL</cfif>, '#arguments.dataStruct.target#', <cfif arguments.dataStruct.parentid GT 0>#arguments.dataStruct.parentid#<cfelse>#newid#</cfif>, #arguments.dataStruct.pageid#, #CreateODBCDateTime(now())#, #CreateODBCDateTime(now())#, #arguments.dataStruct.active#<cfif IsDefined('arguments.dataStruct.imageOn') and Len(Trim(ListFirst(arguments.dataStruct.imageOn,'~')))>, #ListFirst(arguments.dataStruct.imageOn,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageOff') and Len(Trim(ListFirst(arguments.dataStruct.imageOff,'~')))>, #ListFirst(arguments.dataStruct.imageOff,'~')#</cfif><cfif IsDefined('arguments.dataStruct.imageAt') and Len(Trim(ListFirst(arguments.dataStruct.imageAt,'~')))>, #ListFirst(arguments.dataStruct.imageAt,'~')#</cfif>, #arguments.dataStruct.catonly#)
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
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to add!<br> ">
				<cfset message = message&CFCATCH.Detail&"<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="remote" name="delMenuItem" output="false" returntype="string" displayname="del Menu Item">
		<cfargument name="dataStruct" displayname="Form Data Struct" required="yes" type="struct">
		<cfset var message = "">
		<cftry>
			<cfquery name="q_deleteNav" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM navitem		
				WHERE navitemid = #arguments.dataStruct.navitemid#
			</cfquery>
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> deleted!<br>">
			<cfcatch type="database">
				<cfset message = message&"Navigation Item <em>#arguments.dataStruct.label#</em> <strong>failed</strong> to delete!<br>">
			</cfcatch>
		</cftry>
		<cfreturn message>
	</cffunction>

	<cffunction access="remote" name="updateMenuOrder" output="false" returntype="string" displayname="update Menu Order">
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
					UPDATE navitem
					SET ordinal = #thisOrdinalValue#
					WHERE navitemid = #thisPOS#
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

	<cffunction access="remote" name="getParents" output="false" returntype="query" displayname="get Parents">
		<cfargument name="masterQuery" displayname="Master Query to Query Against" required="yes" type="query">
		<cftry>
			<cfquery name="q_getParents" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				select * 
				from masterQuery
				where parentid = navitemid
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getParents>
	</cffunction>

	<cffunction access="remote" name="getDetails" output="false" returntype="query" displayname="get Details">
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
				where navitemid = <cfif IsDefined('arguments.navItems') AND arguments.navItems GT 0>#arguments.navItems#<cfelse>#arguments.parentID#</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getDetails>
	</cffunction>

	<cffunction access="remote" name="getChildren" output="false" returntype="query" displayname="get Children">
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
	
	<cffunction access="remote" name="getPages" output="false" returntype="query" displayname="get Pages">
		<cfargument name="pageid" required="no" type="numeric">
		<cftry>
			<cfquery name="q_getPages" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT page.pageid, page.pagename, page.sitesectionid, sitesection.sitesectionname
				FROM page 
					INNER JOIN sitesection 
						ON page.sitesectionid = sitesection.sitesectionid
				<cfif isDefined('ARGUMENTS.pageid')>
					WHERE page.pageid = #ARGUMENTS.pageid#
				</cfif>
				Order BY sitesection.sitesectionname ASC
			</cfquery>
			<!--- append all tool ids as assigned from display handlers --->
			<cfif q_getPages.recordcount>
				<cfset linkedTables = arrayNew(1)>
				<cfloop query="q_getPages">
					<cfquery name="q_linkedTables" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT displayhandler.toolid
						FROM page
						INNER JOIN displayhandler INNER JOIN pagecomponent
							ON displayhandler.displayhandlerid = pagecomponent.displayhandlerid
							ON page.pageid = pagecomponent.pageid
						WHERE page.pageid = #q_getPages.pageid# AND isNull(displayhandler.toolid,0) <> 0
					</cfquery>
					<!--- check on navigation status in formobject --->
					<cfif q_linkedTables.recordcount>
						<cfset linkedTables[q_getPages.currentrow] = valueList(q_linkedTables.toolid)>
					<cfelse>
						<cfset linkedTables[q_getPages.currentrow] = "">
					</cfif>
				</cfloop>
				<cfset blah = queryAddColumn(q_getPages,"linkedTables",linkedTables)>
			</cfif>
			<cfcatch type="database">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn q_getPages>
	</cffunction>

	<cffunction access="remote" name="getnavAddresses" output="false" returntype="query" displayname="getnavAddresses">
		<cfargument name="formobjecttableid" displayname="form object id" type="numeric" required="no">
		<cftry>
			<cfquery name="q_getnavAddresses" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT navitemaddressid, navitemaddressname, objectinstanceid, formobjecttableid<cfif isDefined('ARGUMENTS.formobjecttableid') AND ARGUMENTS.formobjecttableid EQ 103>, sitesection.sitesectionname</cfif>
				FROM navitemaddress 				
				<cfif isDefined('ARGUMENTS.formobjecttableid') AND ARGUMENTS.formobjecttableid GT 0>
					<cfif ARGUMENTS.formobjecttableid EQ 103>
						INNER JOIN page
							ON page.pageid = navitemaddress.objectinstanceid
						INNER JOIN sitesection 
							ON page.sitesectionid = sitesection.sitesectionid
					</cfif>
					WHERE formobjecttableid = #ARGUMENTS.formobjecttableid#
				</cfif>
				<cfif  isDefined('ARGUMENTS.formobjecttableid') AND ARGUMENTS.formobjecttableid EQ 103>
					ORDER BY navitemaddress.objectinstanceid, navitemaddress.ordinal, navitemaddress.navitemaddressid
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getnavAddresses>
	</cffunction>

	<cffunction access="remote" name="getParentFromPageID" output="false" returntype="numeric" displayname="getParentFromPageID">
		<cfargument name="pageid" displayname="Page id" required="yes" type="numeric">
		<cfargument name="navitemid" displayname="Navigation id" required="no" type="numeric">
		<cftry>
			<cfquery name="q_getParentFromPageID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT parentid
				FROM navitem
				WHERE pageID = #arguments.pageID# 
				<cfif IsDefined('arguments.navitemid') AND arguments.navitemid>
					AND navgroupid = #arguments.navitemid#
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
	<cffunction access="remote" name="getSectionID" output="false" returntype="numeric" description="getSectionID" hint="returns the section ID for a given page base on either the pageid">
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
	<cffunction name="getUltimateParent" access="remote" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="navgroupid" type="numeric" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif currentId EQ q_data.navitemid AND currentId NEQ q_data.parentid>
				<cfset currentId=getUltimateParent(q_data=q_data,navgroupid=arguments.navgroupid,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction name="getGetSecondGenerationParent" access="remote" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="navgroupid" type="numeric" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset ultimateParent=getUltimateParent(q_data=q_data,navgroupid=arguments.navgroupid,currentID=q_data.parentid)>
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif currentId EQ q_data.navitemid AND ultimateParent NEQ q_data.parentid>
				<cfset currentId=getGetSecondGenerationParent(q_data=q_data,navgroupid=arguments.navgroupid,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction name="getNavIdFromPageID" access="remote" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="currentpageid" type="numeric" required="yes">
		<cfargument name="navgroupid" type="numeric" required="no">
		<cfargument name="urlstring" type="string" required="no">
		<cfset defaultnavid=0>
		<!--- retrieve nav id associated with this page (use group if available) --->
		<cfquery name="q_getNavIdFromPageID" datasource="#APPLICATION.datasource#" maxrows="1" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT navitem.navitemid
			FROM navitem
			LEFT OUTER JOIN navitemaddress ON navitemaddress.objectinstanceid = navitem.pageid
			WHERE (navitem.pageid = #currentpageid#) AND (navitemaddress.formobjecttableid = 103)
			<cfif isDefined('ARGUMENTS.navgroupid')>
				AND navitem.navgroupid = #ARGUMENTS.navgroupid#
			</cfif>
		</cfquery>
		<cfif q_getNavIdFromPageID.recordcount GT 0>
			<cfset defaultnavid=q_getNavIdFromPageID.navitemid>
		</cfif>
		<!--- check if sekey passed in URL: potential nav item associted --->
		<cfif listContains(ARGUMENTS.urlstring,"key=","&")>
			<!--- capture key value --->
			<cfset urlKey = listLast(listGetAt(ARGUMENTS.urlstring,listContains(ARGUMENTS.urlstring,"key=","&"),"&"),"=")>
			<!--- get page (with table ids appended as assigned from display handlers) --->
			<cfset pageList = getPages(pageid=currentpageid)>
			<!--- if current page has table/tool associations, get nav items whose nav address has same association --->
			<cfif listLen(pageList.linkedTables)>
				<cfquery name="q_navItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT navitem.navitemid, navitemaddress.formobjecttableid, navitemaddress.objectinstanceid
					FROM navitem
					INNER JOIN navitemaddress ON navitem.navitemaddressid = navitemaddress.navitemaddressid
					WHERE (pageid = #ARGUMENTS.currentpageid#) AND (navitemaddress.formobjecttableid IN (#pageList.linkedTables#)) AND isNull(navitemaddress.objectinstanceid,0) <> 0
				</cfquery>
				<cfif q_navItems.recordcount>
					<!--- compare key value with sekeyname from navitem info (joined to proper table) --->
					<cfloop query="q_navItems">
						<!--- if table not passed get table name otherwise use passed table name --->
						<cfif listContains(ARGUMENTS.urlstring,"table=","&")>
							<cfset q_tableInfo = structNew()>
							<cfset q_tableInfo.datatable = listLast(listGetAt(ARGUMENTS.urlstring,listContains(ARGUMENTS.urlstring,"table=","&"),"&"),"=")>
						<cfelse>
							<cfquery name="q_tableInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								SELECT datatable
								FROM formobject
								WHERE formobjectid = #q_navItems.formobjecttableid#
							</cfquery>
						</cfif>
						<!--- get matching instance --->
						<cfquery name="q_getInstance" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT sekeyname
							FROM #q_tableInfo.datatable#
							WHERE #q_tableInfo.datatable#ID = #q_navItems.objectinstanceid# AND sekeyname = '#urlKey#'
						</cfquery>
						<!--- override page nav item default with instance nav if found --->
						<cfif q_getInstance.recordcount>
							<cfset defaultnavid=q_navItems.navitemid>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
		</cfif>
		<cfreturn defaultnavid>
	</cffunction>
</cfcomponent>

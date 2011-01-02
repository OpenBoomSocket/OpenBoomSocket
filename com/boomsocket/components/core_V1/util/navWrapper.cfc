<!---
FILE:			wrapper.cfc
NAME:           wrapper component for nested structures
CREATED:		04/19/2006
LAST MODIFIED:	07/07/2006
AUTHOR:         Darin Kohles #APPLICATION.adminEmail#

DESCRIPTION:    wrapper is a custom component for generating wrapped html content based on
				a supplied query object wrapping each sub level.  It will create the 
				wrapping with infite deep levels using recursion.  Perfect tag 
				for any content management system. Here used for link tags.

ARGUMENTS:		q_querydata : The data object
				currentNavID: choose a data item to pre-select (OPTIONAL)
				currentPageID: at state by page (optional)
				classBase: a text string that makes to basis of the class name for each wrapped data item
				parentCol: a column/property name that contains the parent id information
				idCol: a column/property name that contains the id for each item
				wrapLevel: current wrapping level (OPTIONAL default 0)
				CMC MOD 05/22/06: editmode: boolean- 1-nav edit mode, 0- not in edit mode;

RETURN:			returns a wrapped list with selection set

--->
<cfcomponent>
	<cffunction access="public" name="doWrapUL" output="true" returntype="string" displayname="doWrapLU" description="used for list navigation" hint="wraps &lt;A&gt; tags in UL/LI tags">
		<cfargument name="q_querydata" type="query" required="yes" displayname="item data for recursion" >
		<cfargument name="currentNavID" type="numeric" required="no" displayname="currentNavID" hint="nav id for the preselected data item" >
		<cfargument name="currentPageID" type="numeric" required="no" displayname="currentPageID" hint="page id for preselected current page">
		<cfargument name="classBase" type="string" required="yes" default="" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="parentCol" type="string" required="yes" default="parentid" displayname="parentCol" hint="the column/propertyname for the parent relationship">
		<cfargument name="idCol" type="string" required="yes" default="dynamicnavigationid" displayname="idCol" hint="the column/property name for the current items ID">
		<cfargument name="wrapLevel" type="numeric" required="yes" default="0" displayname="wrapLevel" hint="identifies the current recursion level">
		<cfargument name="currentParentID" type="numeric" required="no" displayname="currentParentID" hint="optional parent of the current level">
		<cfargument name="groupID" type="numeric" required="yes" default="100000" displayname="navigationgroupid" hint="identifies which navigation group is required">
		<cfargument name="topOnly" type="boolean" required="yes" default="false" displayname="topOnly" hint="turn off recursion">
		<cfargument name="singleSectionID" type="numeric" required="no" displayname="singleSectionID" hint="section id of section page">
		<cfargument name="editmode" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="textOnly" type="boolean" required="no" displayname="ingore nav images" hint="ignore nave images" default="0">
		<cfargument name="subsOnly" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="alphaordering" type="boolean" required="no" displayname=" alphaordering" hint="edit mode" default="0">
		<cfargument name="showAllSubs" type="boolean" required="no" displayname="showAllSubs" hint="show all subnavs expanded out" default="0">
		<cfset var thisGroupId = "">
		<cfset var thisCurrentID = "">
		<cfset var thisParentID = "">
		<cfset var thisNavID = "">
		<cfset var thisParentCol = "">
		<cfset var thisIdCol = "">
		<cfset var thisWrapLevel = "">
		<cfset var thisName = "">
		<cfset var thisParent = 0>
		<cfset var thisClassBase = "">
		<cfset var innerQuery = "">
		<cfset var thisInnerQuery = "">
		<cfset var returnValue = "">
		<!--- <cfsilent> --->
		<cfparam name="thisParent" default="0">
		<cfif isDefined('arguments.currentParentID') AND arguments.currentParentID GT 0>
			<cfset thisParent=arguments.currentParentID>
		</cfif>
		<cfquery name="thisInnerQuery" dbtype="query">
				SELECT *
				FROM arguments.q_querydata
				WHERE dynamicnavigationgroupid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.groupID#">
				<cfif isDefined('arguments.alphaordering') and arguments.alphaordering EQ 1>
					ORDER BY name
				</cfif>
		</cfquery>
		<cfif arguments.wrapLevel IS 0>
			<cfset returnValue="<input type='hidden' id='navgroup_#arguments.groupID#' name='navgroup_#arguments.groupID#' value='#arguments.groupID#'>">
		<cfelse>
			<cfset returnValue="">
		</cfif>
		
		<cfif NOT arguments.subsOnly>
			<cfset returnValue=trim(returnValue)&"<UL id='#arguments.classBase##arguments.wraplevel#' class='#arguments.classBase##arguments.wraplevel#'>">
		</cfif>
		<!--- set up for recursion--->
		
		<cfset innerQuery =  duplicate(thisInnerQuery)>
		<cfif isDefined('arguments.currentPageID')>
			<cfset thisCurrentID = arguments.currentPageID>
			<cfset arguments.currentNavID = getNavIdFromPageID(currentpageid=arguments.currentPageID,q_data=thisInnerQuery)>
		</cfif>
		<cfset thisParentCol = arguments.parentCol>
		<cfset thisIdCol = arguments.idCol>
		<cfset thisWrapLevel = arguments.wrapLevel>
		<cfset thisClassBase = arguments.classBase>
		<cfset thisGroupId = arguments.groupID>
		<cfloop query="innerQuery">
			<cfset thisParentID = innerQuery.parentID>
			<cfset thisNavID = innerQuery.dynamicnavigationid>
			<cfset thisName = innerQuery.name>
			<!--- Test for conditional inclusion in nav tree:
			Condition 1: test if top level and not required single section
			Condition 2: test if top level and is in required section
			Condition 3: test if item is parent of selected item --->
			<cfif ((thisNavID IS thisParentID) AND (thisWrapLevel IS 0) AND (NOT isDefined('arguments.singleSectionID'))) OR ((thisParentID IS thisParent) AND (thisNavID NEQ thisParent) AND (thisWrapLevel GT 0) ) OR ((thisNavID IS thisParentID) AND (thisWrapLevel IS 0) AND isDefined('arguments.singleSectionID') AND (arguments.singleSectionID IS innerQuery.sitesectionid))>
<cfif NOT arguments.subsOnly>			
				<cfset returnValue=trim(returnValue)&"<li">
				<!--- Test for currently selected navigation item and set class and id as selected --->
				<cfif (isDefined('arguments.currentNavID') AND thisNavID EQ arguments.currentNavID) OR (isDefined('arguments.currentPageID') AND innerQuery.pageid EQ arguments.currentPageID)>
					<cfset returnValue=trim(returnValue)&" class='#thisClassBase#selected' id='#thisClassBase#selected'">
				</cfif>
				<cfif innerQuery.active IS 0>
					<cfset returnValue=trim(returnValue)&" style='display: none;'">
				</cfif>

				<cfset returnValue=trim(returnValue)&">">
				<cfset returnValue=trim(returnValue)&"<a href=""">
				<!--- CMC MOD 5/22/06- generate link for edit mode --->
				<cfif arguments.editmode>
					<cfset returnValue=trim(returnValue)&"#request.page#?instanceid=#thisNavID#">
				<cfelseif len(trim(innerQuery.href))>
					<cfset returnValue=trim(returnValue)&"#innerQuery.href#">
				<cfelseif len(trim(innerQuery.sitesectionid))>
					<cfset returnValue=trim(returnValue)&"/#replacenocase(request.getSectionPath(innerQuery.sitesectionid,'true'),'\','/')#/#innerQuery.pagename#">
				<cfelse>
					<cfset returnValue=trim(returnValue)&"##">
				</cfif>
			<cfset returnValue=trim(returnValue)&""" id='nav_#thisNavID#' name='nav_#thisNavID#'">
			<cfif isDefined('innerQuery.target') AND len(trim(innerQuery.target))>
				<cfset returnValue=trim(returnValue)&" target='#innerQuery.target#'">
			</cfif>
			<cfif (len(trim(innerQuery.offState)) OR len(trim(innerQuery.onState)) OR len(trim(innerQuery.atState))) AND NOT arguments.textOnly>
				<cfset returnValue=trim(returnValue)&" onMouseOver='javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src=">
				<cfif len(trim(innerQuery.onState))>
					<cfset returnValue=trim(returnValue)&'"#innerQuery.onState#"#chr(39)#;'>
				<cfelseif len(trim(innerQuery.atState))>
					<cfset returnValue=trim(returnValue)&'"#innerQuery.atState#"#chr(39)#;'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'"#innerQuery.offState#"#chr(39)#;'>
				</cfif>
				<cfif (isDefined('arguments.currentNavID') AND thisNavID EQ arguments.currentNavID) OR (isDefined('arguments.currentPageID') AND innerQuery.pageid EQ arguments.currentPageID)>
					<cfset returnValue=trim(returnValue)&" onMouseOut='javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src=">
					<cfif len(trim(innerQuery.atState))>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.atState#"#chr(39)#;'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.onState#"#chr(39)#;'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.offState#"#chr(39)#;'>
					</cfif>
				<cfelse>
					<cfset returnValue=trim(returnValue)&" onMouseOut='javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src=">
					<cfif len(trim(innerQuery.offState))>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.offState#"#chr(39)#;'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.onState#"#chr(39)#;'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'"#innerQuery.atState#"#chr(39)#;'>
					</cfif>
				</cfif>
				<cfset returnValue=trim(returnValue)&"><img src='">
				<cfif (isDefined('arguments.currentNavID') AND thisNavID EQ arguments.currentNavID) OR (isDefined('arguments.currentPageID') AND innerQuery.pageid EQ arguments.currentPageID)>
					<cfif len(trim(innerQuery.atState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.atState##chr(39)#></a>'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.onState##chr(39)#></a>'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#innerQuery.offState##chr(39)#></a>'>
					</cfif>
				<cfelse>
					<cfif len(trim(innerQuery.offState))>

						<cfset returnValue=trim(returnValue)&'#innerQuery.offState##chr(39)#></a>'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.onState##chr(39)#></a>'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#innerQuery.atState##chr(39)#></a>'>
					</cfif>
				</cfif>	
			<cfelse>
				<cfset returnValue=trim(returnValue)&">#innerQuery.name#</a>">
			</cfif>
</cfif>
			<!--- <cfif isDefined('arguments.currentParentID') AND ((arguments.currentParentID EQ thisParentID)OR(thisParentID EQ getUltimateParent(currentid=arguments.currentParentID,groupid=thisGroupId,q_data=innerQuery)AND checkIsParent(q_navdata=innerQuery,groupid=thisGroupId,currentID=arguments.currentNavID,parentcandidate=thisNavID)))> --->	
			<cfif (isDefined('arguments.currentNavID') AND checkIsParent(q_navdata=innerQuery,groupid=thisGroupId,currentID=arguments.currentNavID,parentcandidate=thisNavID)) OR (arguments.currentNavID EQ thisNavID) OR arguments.showAllSubs EQ 1>
			<!--- Here we do a query of queries to see if there are child elements, if so recurse --->
				
				<cfset q_dataChildren="">
				<cfquery name="q_dataChildren" dbtype="query" >
					SELECT *
					FROM innerQuery
					WHERE parentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisNavID#">
				</cfquery>
				<cfif q_dataChildren.recordcount GTE 1 AND (NOT arguments.topOnly)>
					<cfif isDefined('arguments.currentNavID')><!--- <cfoutput>thisNavID=#thisNavID#</cfoutput> --->
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,currentNavID=arguments.currentNavID,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					<cfelseif isDefined('arguments.currentPageID')>
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,currentPageID=arguments.currentPageID,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					<cfelse>
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					</cfif>
				</cfif>
			<cfelseif NOT isDefined('arguments.currentParentID')>
			<!--- Here we do a query of queries to see if there are child elements, if so recurse --->
				<cfset q_dataChildren="">
				<cfquery name="q_dataChildren" dbtype="query" >
					SELECT *
					FROM innerQuery
					WHERE parentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisNavID#">
				</cfquery>
				<cfif q_dataChildren.recordcount GTE 1 AND (NOT arguments.topOnly)>
					<cfif isDefined('arguments.currentNavID')>
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,currentNavID=arguments.currentNavID,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					<cfelseif isDefined('arguments.currentPageID')>
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,currentPageID=arguments.currentPageID,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					<cfelse>
						<cfset returnValue=trim(returnValue)&doWrapUL(q_querydata=innerQuery,classBase=thisClassBase,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId,alphaordering=arguments.alphaordering,showallsubs=arguments.showallsubs)>
					</cfif>
				</cfif>
			</cfif>
<cfif NOT arguments.subsOnly>
			<cfset returnValue=trim(returnValue)&"</li>">
</cfif>
			
		</cfif>
		</cfloop>
		<cfif NOT arguments.subsOnly>
			<cfset returnValue=trim(returnValue)&"</UL>">
		</cfif>
		<!--- </cfsilent> --->
		<cfreturn returnValue>
	</cffunction>
	<cffunction access="public" name="doWrapOption" output="true" returntype="string" displayname="doWrapOption" description="used for select listing of navigation" hint="wraps &lt;A&gt; tags in UL/LI tags">
		<cfargument name="q_querydata" type="query" required="yes" displayname="item data for recursion" >
		<cfargument name="currentID" type="numeric" required="no" default="0" displayname="currentID" hint="id for the preselected data item" >
		<cfargument name="parentCol" type="string" required="yes" default="parentid" displayname="parentCol" hint="the column/propertyname for the parent relationship">
		<cfargument name="classBase" type="string" required="yes" default="level" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="idCol" type="string" required="yes" default="dynamicnavigationid" displayname="idCol" hint="the column/property name for the current items ID">
		<cfargument name="wrapLevel" type="numeric" required="yes" default="0" displayname="wrapLevel" hint="identifies the current recursion level">
		<cfargument name="currentParentID" type="numeric" required="no" displayname="currentParentID" hint="optional parent of the current level">
		<cfargument name="groupID" type="numeric" required="yes" default="100000" displayname="navigationgroupid" hint="identifies which navigation group is required">
		<cfargument name="topOnly" type="boolean" required="yes" default="false" displayname="topOnly" hint="turn off recursion">
		<cfargument name="singleSectionID" type="numeric" required="no" displayname="singleSectionID" hint="dynamic anvigation id of section page">
		<cfset var thisCurrentID = "">
		<cfset var thisParentID = "">
		<cfset var thisNavID = "">
		<cfset var thisParentCol = "">
		<cfset var thisIdCol = "">
		<cfset var thisWrapLevel = "">
		<cfset var thisName = "">
		<cfset var thisparent = "">
		<cfset var innerQuery = "">
		<cfset var returnValue = "">
		<cfsilent>
		<cfparam name="thisparent" default="0">
		<cfif isDefined('arguments.currentParentID') AND arguments.currentParentID GT 0>
			<cfset thisparent=arguments.currentParentID>
		</cfif>
		
		<cfset innerQuery=arguments.q_querydata>
		 <cfif arguments.wrapLevel EQ 0>
			<cfquery name="innerQuery" dbtype="query">
				SELECT *
				FROM arguments.q_querydata
				WHERE dynamicnavigationgroupid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.groupID#">
					and active = 1
			</cfquery>
		</cfif>
		
		<!--- set up for recursion--->
		<cfset thisCurrentID = arguments.currentID>
		<cfset thisParentCol = arguments.parentCol>
		<cfset thisIdCol = arguments.idCol>
		<cfset thisWrapLevel = arguments.wrapLevel>
		<cfset innerQuery =  duplicate(arguments.q_querydata)>
		<cfloop query="innerQuery">
			<cfset thisParentID = innerQuery.parentID>
			<cfset thisNavID = innerQuery.dynamicnavigationid>
			<cfset thisName = innerQuery.name>
			<cfif ((thisNavID IS thisParentID) AND (thisWrapLevel EQ 0) AND (NOT isDefined('arguments.singleSectionID'))) OR ((thisParentID IS thisparent) AND (thisNavID NEQ thisparent) AND (thisWrapLevel GT 0)) OR ((thisNavID IS thisParentID) AND (thisWrapLevel IS 0) AND isDefined('arguments.singleSectionID') AND (arguments.singleSectionID EQ thisNavID)) >
			<cfset returnValue=trim(returnValue)&"<option id='nav_#thisNavID#' value='#thisNavID#' class='#arguments.classBase#_#thisWrapLevel#'">
			<cfif thisNavID EQ thisCurrentID><cfset returnValue=trim(returnValue)&" selected='selected'"></cfif>
			<cfset returnValue=trim(returnValue)&">#repeatstring("-",thisWrapLevel)##thisName#</option>">
			<!--- Here we do a query of queries to see if there are child elements, if so recurse --->
			<cfset q_dataChildren="">
			<cfquery name="q_dataChildren" dbtype="query" >
				SELECT *
				FROM innerQuery
				WHERE parentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisNavID#">
					and active = 1
			</cfquery>
			<cfif q_dataChildren.recordcount GTE 1 AND (NOT arguments.topOnly)>
				<cfset returnValue=trim(returnValue)&doWrapOption(q_querydata=innerQuery,currentID=thisCurrentID,parentCol=thisParentCol,idCol=thisIdCol,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,classBase=arguments.classBase)>
			</cfif>
		</cfif>
		</cfloop>
		</cfsilent>
		<cfreturn returnValue>
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
	<cffunction name="getUltimateParent" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="groupid" type="numeric" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif (currentId EQ q_data.dynamicnavigationid) AND (currentId NEQ q_data.parentid)>
				<cfset currentId=getUltimateParent(q_data=q_data,groupid=arguments.groupid,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction name="getUltimateParentXML" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="currentid" type="numeric" required="yes">
		<cfset currentId=arguments.currentid>
		<cfloop query="q_data">
			<cfif (currentId EQ q_data.navitemid) AND (currentId NEQ q_data.parentid)>
				<cfset currentId=getUltimateParentXML(q_data=q_data,currentID=q_data.parentid)>
			</cfif>
		</cfloop>
		<cfreturn currentId>
	</cffunction>
	<cffunction access="public" name="checkIsParent" output="false" returntype="boolean" displayname="checkIsParent">
		<cfargument name="q_navdata" type="query" required="yes">
		<cfargument name="currentID" type="numeric" required="yes">
		<cfargument name="parentcandidate" type="numeric" required="yes">
		<cfset isParent=false>
		<cfloop query="q_navdata">
			<cfif (currentID EQ q_navdata.dynamicnavigationid) AND (parentcandidate EQ q_navdata.parentid)>
				<cfset isParent=true>
				<cfbreak>
			<cfelseif (currentID EQ q_navdata.dynamicnavigationid) AND (currentID NEQ q_navdata.parentid)>
				<cfset isParent=checkIsParent(q_navdata=q_navdata,currentID=q_navdata.parentid,parentcandidate=arguments.parentcandidate)>
			</cfif>
		</cfloop>
		<cfreturn isParent>
	</cffunction>
	<cffunction access="public" name="checkIsParentXML" output="false" returntype="boolean" displayname="checkIsParent">
		<cfargument name="q_navdata" type="query" required="yes">
		<cfargument name="currentID" type="numeric" required="yes">
		<cfargument name="parentcandidate" type="numeric" required="yes">
		<cfset isParent=false>
		<cfloop query="q_navdata">
			<cfif (currentID EQ q_navdata.navitemid) AND (parentcandidate EQ q_navdata.parentid)>
				<cfset isParent=true>
				<cfbreak>
			<cfelseif (currentID EQ q_navdata.navitemid) AND (currentID NEQ q_navdata.parentid)>
				<cfset isParent=checkIsParentXML(q_navdata=q_navdata,currentID=q_navdata.parentid,parentcandidate=arguments.parentcandidate)>
			</cfif>
		</cfloop>
		<cfreturn isParent>
	</cffunction>
	<cffunction name="getNavIdFromPageID" access="public" returntype="numeric">
		<cfargument name="q_data" type="query" required="yes">
		<cfargument name="currentpageid" type="numeric" required="yes">
		<cfset defaultnavid=0>
		<cfquery name="q_getNavIdFromPageID" dbtype="query" maxrows="1">
			SELECT dynamicnavigationid
			FROM q_data
			WHERE pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#currentpageid#">
		</cfquery>
		<cfif q_getNavIdFromPageID.recordcount GT 0>
			<cfreturn q_getNavIdFromPageID.dynamicnavigationid>
		<cfelse>
			<cfreturn defaultnavid>
		</cfif>
	</cffunction>
	<cffunction access="public" name="getNavXML" output="true" returntype="string" displayname="doMasterWrapperUL" description="used for list navigation" hint="wraps &lt;A&gt; tags in UL/LI tags">
		<cfargument name="q_querydata" type="query" required="yes" displayname="item data for recursion" >
		<cfargument name="wrapLevel" type="numeric" required="yes" default="0" displayname="wrapLevel" hint="identifies the current recursion level">
		<cfargument name="currentParentID" type="numeric" required="no" displayname="currentParentID" hint="optional parent of the current level">
		<cfargument name="groupID" type="numeric" required="yes" default="100000" displayname="navigationgroupid" hint="identifies which navigation group is required">
		<cfargument name="alphaordering" type="boolean" required="no" displayname=" alphaordering" hint="edit mode" default="0">
		<cfset var thisGroupId = "">
		<cfset var thisCurrentID = "">
		<cfset var thisParentID = "">
		<cfset var thisNavID = "">
		<cfset var thisParentCol = "">
		<cfset var thisIdCol = "">
		<cfset var thisWrapLevel = "">
		<cfset var thisName = "">
		<cfset var thisParent = 0>
		<cfset var thisClassBase = "">
		<cfset var innerQuery = "">
		<cfset var thisInnerQuery = "">
		<cfset var returnValue = "">
		<cfsilent>
		<cfparam name="thisParent" default="0">
		<cfif isDefined('arguments.currentParentID') AND arguments.currentParentID GT 0>
			<cfset thisParent=arguments.currentParentID>
		</cfif>
		<!--- grab group item from entire navigation --->
		<cfquery name="thisInnerQuery" dbtype="query">
				SELECT *
				FROM arguments.q_querydata
				WHERE navgroupid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.groupID#">
				<cfif isDefined('arguments.alphaordering') and arguments.alphaordering EQ 1>
					ORDER BY navitemname
				</cfif>
		</cfquery>
		<cfquery name="q_group" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT grouptype, navgroupname
			FROM navgroup
			WHERE navgroupid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.groupID#">
		</cfquery>
		<cfif arguments.wrapLevel IS 0>
			<cfset returnValue='<navtree groupid="#arguments.groupID#" grouptype="#q_group.grouptype#" groupname="#q_group.navgroupname#">'>
		<cfelse>
			<cfset returnValue="">
		</cfif>
		
		<cfset returnValue=trim(returnValue)&'<navlevel level="#arguments.wraplevel#">'>
		<!--- set up for recursion--->
		
		<cfset innerQuery =  duplicate(thisInnerQuery)>
		<cfset thisWrapLevel = arguments.wrapLevel>
		<cfset thisGroupId = arguments.groupID>
		<cfloop query="innerQuery">
			<cfset thisParentID = innerQuery.parentID>
			<cfset thisNavID = innerQuery.navitemid>
			<cfset thisName = innerQuery.navitemname>
			<!--- Test for conditional inclusion in nav tree:
			Condition 1: test if top level and no parent or matches parent section
			Condition 2: test if not top level and is in required section --->
			<cfif ((thisNavID IS thisParentID) AND (thisWrapLevel IS 0) AND ((thisParent Is 0) OR (thisNavID IS thisParent))) OR ((thisParentID IS thisParent) AND (thisNavID NEQ thisParent) AND (thisWrapLevel GT 0))>			
				<cfset returnValue=trim(returnValue)&'<navitem'>
				<cfset returnValue=trim(returnValue)&' id="#thisNavID#"'>
				<cfset returnValue=trim(returnValue)&' addressid="#innerQuery.navitemaddressid#"'>
				<cfif len(innerQuery.pageid)>
					<cfquery name="q_pathInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
						SELECT page.pagename, page.sitesectionid, sitesection.sitesectionname
						FROM page
						INNER JOIN sitesection ON sitesection.sitesectionid = page.sitesectionid
						WHERE pageid = <cfqueryparam cfsqltype="cf_sql_integer" value="#innerQuery.pageid#">
					</cfquery>
					<cfset returnValue=trim(returnValue)&' sectionid="#q_pathInfo.sitesectionid#"'>
				</cfif>
				<cfset returnValue=trim(returnValue)&' href="'>
				<cfif len(trim(innerQuery.urlpath)) AND (NOT len(trim(innerQuery.catonly)) OR innerQuery.catonly EQ 0)>
					<cfset returnValue=trim(returnValue)&'#replacenocase(innerQuery.urlpath,'&','&amp;','all')#"'>
				<cfelseif len(trim(innerQuery.catonly)) AND innerQuery.catonly EQ 1>
					<cfset returnValue = trim(returnValue)&'##"' >
				<cfelse>
					<cfif q_pathInfo.recordcount>
						<cfset thisurlPath='/#replacenocase(APPLICATION.getSectionPath(q_pathInfo.sitesectionid,'true'),'\','/','all')#/'>
					<cfelse>
						<cfset thisUrlPath = "">
					</cfif>
					<cfif len(trim(innerQuery.formobjecttableid)) AND innerQuery.formobjecttableid EQ 103>
						<cfset thisUrlPath=trim(thisUrlPath)&'#q_pathInfo.pagename#'>
					<cfelseif len(trim(innerQuery.formobjecttableid)) AND len(trim(innerQuery.objectinstanceid))>
						<cfquery name="q_tableName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT datatable
							FROM formobject
							WHERE formobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#innerQuery.formobjecttableid#">
						</cfquery>
						<cfquery name="q_getKey" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT sekeyname
							FROM #q_tableName.datatable#
							WHERE #q_tableName.datatable#ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#innerQuery.objectinstanceid#">
						</cfquery>
						<cfif q_tableName.recordcount AND q_getKey.recordcount>
							<cfset thisUrlPath=trim(thisUrlPath)&'#listFirst(q_pathInfo.pagename,'.')#/#q_getKey.sekeyname#/'>
						</cfif>
					</cfif>
					<cfset returnValue=trim(returnValue)&'#thisUrlPath#"'>
				</cfif>
				<cfset returnValue=trim(returnValue)&' pageid="#innerQuery.pageid#" pagename="#q_pathInfo.pagename#"'>
				<cfset returnValue=trim(returnValue)&' objectid="#innerQuery.formobjecttableid#" instanceid="#innerQuery.objectinstanceid#"'>
				<cfif isDefined('innerQuery.target') AND len(trim(innerQuery.target))>
					<cfset returnValue=trim(returnValue)&' target="#innerQuery.target#"'>
				</cfif>
				<!--- Add image info --->
				<cfif len(trim(innerQuery.offState)) OR len(trim(innerQuery.onState)) OR len(trim(innerQuery.atState))>
					<cfset returnValue=trim(returnValue)&' imageOn="'>
					<cfif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.onState#"'>
					<cfelseif len(trim(innerQuery.atState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.atState#"'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#innerQuery.offState#"'>
					</cfif>
					<cfset returnValue=trim(returnValue)&' imageAt="'>
					<cfif len(trim(innerQuery.atState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.atState#"'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.onState#"'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#innerQuery.offState#"'>
					</cfif>
					<cfset returnValue=trim(returnValue)&' imageOff="'>
					<cfif len(trim(innerQuery.offState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.offState#"'>
					<cfelseif len(trim(innerQuery.onState))>
						<cfset returnValue=trim(returnValue)&'#innerQuery.onState#"'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#innerQuery.atState#"'>
					</cfif>
				</cfif>
				<cfset returnValue=trim(returnValue)&' name="#replacenocase(innerQuery.navitemname,'&','&amp;','all')#"'>
				<!--- Here we do a query of queries to see if there are child elements, if so recurse --->
				<cfset q_dataChildren="">
				<cfquery name="q_dataChildren" dbtype="query" >
					SELECT *
					FROM innerQuery
					WHERE parentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#thisNavID#">
				</cfquery>
				<cfif q_dataChildren.recordcount GTE 1>
					<cfset returnValue=trim(returnValue)&'>'>
					<cfset returnValue=trim(returnValue)&getNavXML(q_querydata=innerQuery,wrapLevel=val(thisWrapLevel+1),currentParentID=thisNavID,groupID=thisGroupId)>
					<cfset returnValue=trim(returnValue)&'</navitem>'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'/>'>
				</cfif>			
			</cfif>
		</cfloop>
		<cfset returnValue=trim(returnValue)&'</navlevel>'>
		<cfif arguments.wrapLevel IS 0>
			<cfset returnValue=trim(returnValue)&'</navtree>'>
		</cfif>
		</cfsilent>
		<cfreturn returnValue>
	</cffunction>
	<cffunction access="public" name="buildListingNav" output="false" returntype="string" displayname="buildListingNav" hint="turn nav XML into UL/LI">
		<cfargument name="classBase" type="string" required="yes" default="" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="navDataSource" required="yes" type="array">
		<cfargument name="topOnly" type="boolean" required="yes" default="false" displayname="topOnly" hint="turn off recursion">
		<cfargument name="editmode" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="textOnly" type="boolean" required="no" displayname="ingore nav images" hint="ignore nave images" default="1">
		<cfset var returnValue = "">
		<cfset var subNav = "">
		<cfset var navXML = ARGUMENTS.navDataSource[1]>
		<cfset var thisLevel = navXML.XMLAttributes["level"]>
		<!--- Convert XML into UL/LI struct --->
		<cfif thisLevel EQ 0>
			<cfset returnValue=trim(returnValue)&'<div id="#arguments.classBase#" class="#arguments.classBase#" >'>
		</cfif>
		<cfset returnValue=trim(returnValue)&'<UL id="#arguments.classBase##thisLevel#" class="#arguments.classBase##thisLevel#">'>
		<cfloop from="1" to="#arrayLen(navXML.XMLChildren)#" index="r">
			<cfset returnValue=trim(returnValue)&'<LI '>
			<cfif thisLevel EQ 0>
				<cfset returnValue=trim(returnValue)&' class="button" '>
			</cfif>
			<cfset thisNode = navXML.XMLChildren[r]>
			<cfset returnValue=trim(returnValue)&' id="#ARGUMENTS.classBase#_#thisNode.XMLAttributes['id']#">'>
			<cfif thisLevel EQ 0>
				<!--- <cfset returnValue=trim(returnValue)&'<div class="parent">'> --->
				<cfset returnValue=trim(returnValue)&'<div class="parent"'>	
				<!--- make sure image stays on 'on' state when hover over children --->			
				<cfif (NOT ARGUMENTS.textOnly) AND isDefined('thisNode.XMLAttributes.imageOff')>
					<cfset returnValue=trim(returnValue)&' onMouseOver=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOn']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&' onMouseOut=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOff']##chr(34)#;#chr(39)#'>				
				</cfif>
				<cfset returnValue=trim(returnValue)&'>'>
				<!--- --->
			</cfif>
			<cfset returnValue=trim(returnValue)&'<a href="#thisNode.XMLAttributes['href']#"'>
			<cfif isDefined('thisNode.XMLAttributes') AND isDefined('thisNode.XMLAttributes.target')>
				<cfset returnValue=trim(returnValue)&' target="#thisNode.XMLAttributes['target']#"'>
			</cfif>
			<cfif (NOT ARGUMENTS.textOnly) AND isDefined('thisNode.XMLAttributes.imageOff')>
				<cfset returnValue=trim(returnValue)&' onMouseOver=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
				<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOn']##chr(34)#;#chr(39)#'>
				<cfset returnValue=trim(returnValue)&' onMouseOut=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
				<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOff']##chr(34)#;#chr(39)#'>
				<cfset returnValue=trim(returnValue)&'><img border="0" src="'>
				<cfset returnValue=trim(returnValue)&'#navXML.XMLChildren[r].XMLAttributes['imageOff']#" /></a>'>
				<cfset returnValue=trim(returnValue)&'<div'>
				<cfif thisLevel EQ 0>
					<cfset returnValue=trim(returnValue)&' class="dropdown">'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'>'>
				</cfif>
			<cfelse>
				<cfset returnValue=trim(returnValue)&'>#navXML.XMLChildren[r].XMLAttributes['name']#</a>'>
				<cfset returnValue=trim(returnValue)&'<div'>
				<cfif thisLevel EQ 0>
					<cfset returnValue=trim(returnValue)&' class="dropdown">'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'>'>
				</cfif>
			</cfif>
			<cfset subNav = "">
			<cfif NOT ARGUMENTS.topOnly AND arrayLen(navXML.XMLChildren[r].XMLChildren)>
				<cfset subNav = buildListingNav(navDataSource=navXML.XMLChildren[r].XMLChildren,topOnly=ARGUMENTS.toponly,textOnly=ARGUMENTS.textOnly,classBase=ARGUMENTS.classBase)>
				<!--- <cfif len(trim(subNav)) EQ 0>
					<cfset returnValue = left(trim(returnValue),val(len(trim(returnValue))-5))>
				<cfelse> --->
					<cfset returnValue=trim(returnValue)&subNav>
				<!--- </cfif> --->
			</cfif>
			<!--- <cfif len(trim(subNav)) NEQ 0> --->
				<cfset returnValue=trim(returnValue)&'</div>'>
			<!--- </cfif> --->
			<cfif thisLevel EQ 0>
				<cfif NOT findNoCase("<LI",subNav)>
					<cfset returnValue = left(returnValue,len(returnValue)-28)>
				</cfif>
				<cfset returnValue=trim(returnValue)&'</div>'>
			</cfif>
			<cfset returnValue=trim(returnValue)&'</LI>'>
		</cfloop>
		<cfset returnValue=trim(returnValue)&'</UL>'>
		<cfif thisLevel EQ 0>
			<cfset returnValue=trim(returnValue)&'<br class="brclear" /></div>'>
		</cfif>
		<cfif findNoCase("<LI",returnValue)>
			<cfreturn returnValue>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
	<cffunction access="public" name="sectionListing" output="false" returntype="string" displayname="sectionListing" hint="returns only one nav section">
		<cfargument name="navItemID" type="numeric" required="no" displayname="navItemID" hint="section id of section page">
		<cfargument name="subsOnly" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="classBase" type="string" required="yes" default="" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="groupID" type="numeric" required="yes" default="100000" displayname="navigationgroupid" hint="identifies which navigation group is required">
		<cfargument name="q_querydata" type="query" required="yes" displayname="item data for recursion" >
		<cfargument name="alphaordering" type="boolean" required="no" displayname=" alphaordering" hint="edit mode" default="0">
		<cfargument name="topOnly" type="boolean" required="yes" default="false" displayname="topOnly" hint="turn off recursion">
		<cfargument name="editmode" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="textOnly" type="boolean" required="no" displayname="ingore nav images" hint="ignore nave images" default="1">
		<cfset navXML = getNavXML(alphaordering=ARGUMENTS.alphaordering,groupid=ARGUMENTS.groupID,q_querydata=ARGUMENTS.q_querydata,currentParentID=getUltimateParentXML(currentid=ARGUMENTS.navItemID,q_data=ARGUMENTS.q_querydata))>
		<cfset navData = buildListingNav(navDataSource=XMLParse(navXML).XMLRoot.XMLChildren,topOnly=ARGUMENTS.toponly,textOnly=ARGUMENTS.textOnly,editmode=ARGUMENTS.editmode,classBase=ARGUMENTS.classBase)>
		<cfset navTop = XMLParse(replacenocase(navData,'&','&amp;','all')).XMLRoot.UL.LI>
		<!--- <cfdump var="#navData#">
		<cfabort> --->
		<cfif ARGUMENTS.subsonly AND isDefined('navTop.div.UL')>
			<cfreturn toString(navTop.div.UL)>
		<cfelse>
			<cfreturn navData>
		</cfif>
	</cffunction>

	<cffunction access="public" name="setSelectedXML" output="true" returntype="string" displayname="setSelected" hint="sets class for selection status">
		<cfargument name="classBase" type="string" required="yes" default="" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="navData" required="yes" type="string">
		<cfargument name="navItemID" required="yes" type="numeric">
		<cfargument name="baseXML" required="no">
		<cfset var navXML = "">
		<cfset var ULBase = "">
		<cfset var divBase = "">
		<cfset var newNav = "">
		<cfset var newNode = "">
		<cfset var divXML = "">
		<cfset var linkXML = "">
		<!--- <cfset var imgXML = ""> --->
		<cfset var divBaseSub1 = "">
		<cfset var ULBaseSub1 = "">
		<cfset var divBaseSub2 = "">
		<cfset var ULBaseSub2 = "">
		<cfset var r = ""> <!--- top nav child itereator --->
		<cfset var s = ""> <!--- 1st sub-nav child iterator --->
		<cfset var t = ""> <!--- 2nd sub-nav child iterator --->
		<cfset newNav = XMLNew()>
		<cfset divBase = XMLElemNew(newNav,"div")>
		<cfset divBase.XMLAttributes = XMLParse(replacenocase(navData,'&','&amp;','all')).XMLRoot.XMLAttributes>
		<cfset divBase.XMLAttributes['class'] = "#arguments.classBase#">
		<cfset divBase.XMLAttributes['id'] = "#arguments.classBase#">
		<!--- <cfdump var="#navItemID#">
		<cfabort> --->
		<cfset navXML = XMLParse(replacenocase(navData,'&','&amp;','all')).XMLRoot.XMLChildren[1].XMLChildren>
		<!--- swap out with APPLICATION.allNavigation when available --->
		<cfif (NOT isDefined('application.allNavigation#arguments.classBase#') AND NOT isDefined('session.allNavigation')) OR isDefined("URL.initializeApp")>
			<cfset q_navigation = APPLICATION.navObj.getAllNavigation()>
		<cfelseif isDefined('APPLICATION.allNavigation#arguments.classBase#')>
			<cfset q_navigation = evaluate("APPLICATION.allNavigation#arguments.classBase#")>
		<cfelseif isDefined('SESSION.allNavigation#arguments.classBase#')>
			<cfset q_navigation = evaluate("SESSION.allNavigation#arguments.classBase#")>
		</cfif>
		<!--- <cfset q_navigation=application.allNavigation> --->
		<cfset ULBase = XMLElemNew(newNav,"UL")>
		<cfset ULBase.XMLAttributes['id'] = "#arguments.classBase#0">
		<cfloop from="1" to="#arrayLen(navXML)#" index="r">
			<cfset thisNode = navXML[r]>
			<cfset newNode = XMLElemNew(newNav,"LI")>
			<cfset ULBase.XMLChildren[r] = newNode>
			<cfset ULBase.XMLChildren[r].XMLAttributes = thisNode.XMLAttributes>
			<!--- need to parse out new a tag and if defined new img tag --->
			<cfset divXML = XMLElemNew(newNav,"div")>
			<cfset divXML.XMLAttributes['class'] = "parent">
			<cfset ULBase.XMLChildren[r].XMLChildren[1] = divXML>
			<cfset linkXML = XMLElemNew(newNav,"A")>
			<!--- <cfdump var="#thisNode#"> --->
			<!--- ERJ Debug A --->
			<cfif StructKeyExists(thisNode.XMLChildren[1],'a')>
                <cfset linkXML.XMLAttributes = thisNode.XMLChildren[1]['a'].XMLAttributes>
            <cfelse>
                <cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug A<cfdump var="#thisNode#" label="thisNode"></cfmail>
                <cfset linkXML.XMLAttributes = thisNode.XMLChildren[1]['a'].XMLAttributes>
            </cfif>
			<cfset thisA = thisNode.XMLChildren[1]['a']>
			<cfif isDefined('thisA.img')>
				<cfset imgXML = XMLElemNew(newNav,"img")>
				<cfset imgXML.XMLAttributes = thisA['img'].XMLAttributes>
				<cfset linkXML.XMLChildren[1] = imgXML>
			<cfelse>
				<!--- ERJ Debug B --->
				<cfif StructKeyExists(thisNode.XMLChildren[1],'a')>
                    <cfset linkXML.XMLText = thisNode.XMLChildren[1]['a'].XMLText>
                <cfelse>
                    <cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug B<cfdump var="#thisNode#" label="thisNode"></cfmail>
                    <cfset linkXML.XMLText = thisNode.XMLChildren[1]['a'].XMLText>
                </cfif>
				<cfset structDelete(VARIABLES,"imgXML")>
			</cfif>
			<cfif right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)) EQ ARGUMENTS.navItemID>
				<cfset ULBase.XMLChildren[r].XMLAttributes['class'] = "button open">
				<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#selected">
				<!--- swap out a tag image for at state --->
				<cfif isDefined('imgXML')>
					<cfloop query="q_navigation">
						<cfif q_navigation.navitemid EQ ARGUMENTS.navItemID>
							<!--- replace image --->
							<cfif len(q_navigation.atState)>
								<cfset imgXML.XMLAttributes['src'] = q_navigation.atState>
							<cfelseif len(q_navigation.onState)>
								<cfset imgXML.XMLAttributes['src'] = q_navigation.onState>
							<cfelseif len(q_navigation.offState)>
								<cfset imgXML.XMLAttributes['src'] = q_navigation.offState>
							<cfelse>
								<cfset imgXML.XMLAttributes['src'] = ''>
							</cfif>
							<cfset linkXML.XMLChildren[1] = imgXML>
							<!--- replace rollover/out state --->
							<cfset rollOverText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
							<cfset rollOutText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
							<cfif len(q_navigation.atState)>
								<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.atState##chr(34)#;'>
							<cfelseif len(q_navigation.onState)>
								<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.onState##chr(34)#;'>
							<cfelseif len(q_navigation.onState)>
								<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.offState##chr(34)#;'>
							<cfelse>
								<cfset rollOutText = rollOutText&'&quot;&quot;'>
							</cfif>
							<cfif len(q_navigation.atState)>
								<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.atState##chr(34)#;'>
							<cfelseif len(q_navigation.onState)>
								<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.atState##chr(34)#;'>
							<cfelseif len(q_navigation.onState)>
								<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.offState##chr(34)#;'>
							<cfelse>
								<cfset rollOverText = rollOverText&'&quot;&quot;'>
							</cfif>
							<cfset linkXML.XMLAttributes['onMouseOver'] = rollOverText>
							<cfset linkXML.XMLAttributes['onMouseOut'] = rollOutText>
						</cfif>
					</cfloop>
				</cfif>
			<cfelseif checkIsParentXML(q_navdata=q_navigation,currentID=ARGUMENTS.navItemID,parentcandidate=right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)))>
				<cfset ULBase.XMLChildren[r].XMLAttributes['class'] = "button open">
				<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#parent">
			</cfif>
			<cfset ULBase.XMLChildren[r].XMLChildren[1].XMLChildren[1] = linkXML>
			<!--- first sub nav --->
			<cfif isDefined('thisNode.div.div') AND isDefined('thisNode.div.div.UL') AND isDefined('thisNode.div.div.UL.LI')>
				<!--- <cfset newUL = XMLElemNew(newNav,"UL")>
				<cfset selectedUL=XMLParse(setSelectedXML(classBase=ARGUMENTS.classBase,navItemID=ARGUMENTS.navItemID,level=1,navData=toString(thisNode.UL)))>
				<cfset copyNode(xmlDoc=newNav,newNode=newUL,oldNode=selectedUL.XMLRoot)>
				<cfset blah = arrayAppend(ULBase.XMLChildren[r].XMLChildren, newUL)> --->
				<cfset divBaseSub1 = XMLElemNew(newNav,"div")>
				<cfset divBaseSub1.XMLAttributes['class'] = "dropdown">
				<cfset navXMLSub1 = thisNode.div.div.UL.XMLChildren>
				<cfset ULBaseSub1 = XMLElemNew(newNav,"UL")>
				<cfset ULBaseSub1.XMLAttributes = thisNode.div.div.UL.XMLAttributes>
				<cfloop from="1" to="#arrayLen(navXMLSub1)#" index="s">
					<cfset thisNode = navXMLSub1[s]>
					<cfset newNode = XMLElemNew(newNav,"LI")>
					<cfset ULBaseSub1.XMLChildren[s] = newNode>
					<cfset ULBaseSub1.XMLChildren[s].XMLAttributes = thisNode.XMLAttributes>
					<!--- need to parse out new A tag and if defined new img tag --->
					<cfset linkXML = XMLElemNew(newNav,"A")>
					<!--- ERJ Debug C --->
					<cfif StructKeyExists(thisNode,'A')>
                    	<cfset linkXML.XMLAttributes = thisNode['a'].XMLAttributes>
					<cfelse>
                    	<cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug C<cfdump var="#thisNode#" label="thisNode"></cfmail>
                        <cfset linkXML.XMLAttributes = thisNode['A'].XMLAttributes>
					</cfif>
					
					<!--- ERJ Debug D --->
					<cfif StructKeyExists(thisNode,'A')>
                    	<cfset thisA = thisNode['A']>
					<cfelse>
                    	<cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug D<cfdump var="#thisNode#" label="thisNode"></cfmail>
                        <cfset thisA = thisNode['A']>
					</cfif>					
					<cfif isDefined('thisA.img')>
						<cfset imgXML = XMLElemNew(newNav,"img")>
						<cfset imgXML.XMLAttributes = thisA['img'].XMLAttributes>
						<cfset linkXML.XMLChildren[1] = imgXML>
					<cfelse>
						<!--- ERJ Debug E --->
						<cfif StructKeyExists(thisNode,'A')>
                            <cfset linkXML.XMLText = thisNode['A'].XMLText>
                        <cfelse>
                            <cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug E<cfdump var="#thisNode#" label="thisNode"></cfmail>
                            <cfset linkXML.XMLText = thisNode['A'].XMLText>
                        </cfif>
						<cfset structDelete(VARIABLES,"imgXML")>
					</cfif>
					<cfif right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)) EQ ARGUMENTS.navItemID>
						<cfset ULBase.XMLChildren[r].XMLAttributes['class'] = "open">
						<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#selected">
						<!--- swap out A tag image for at state --->
						<cfif isDefined('VARIABLES.imgXML')>
							<cfloop query="q_navigation">
								<cfif q_navigation.navitemid EQ ARGUMENTS.navItemID>
									<!--- replace image --->
									<cfif len(q_navigation.atState)>
										<cfset imgXML.XMLAttributes['src'] = q_navigation.atState>
									<cfelseif len(q_navigation.onState)>
										<cfset imgXML.XMLAttributes['src'] = q_navigation.onState>
									<cfelseif len(q_navigation.offState)>
										<cfset imgXML.XMLAttributes['src'] = q_navigation.offState>
									<cfelse>
										<cfset imgXML.XMLAttributes['src'] = ''>
									</cfif>
									<cfset linkXML.XMLChildren[1] = imgXML>
									<!--- replace rollover/out state --->
									<cfset rollOverText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
									<cfset rollOutText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
									<cfif len(q_navigation.atState)>
										<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.atState##chr(34)#;'>
									<cfelseif len(q_navigation.onState)>
										<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.onState##chr(34)#;'>
									<cfelseif len(q_navigation.onState)>
										<cfset rollOutText = rollOffText&'#chr(34)##q_navigation.offState##chr(34)#;'>
									<cfelse>
										<cfset rollOutText = rollOutText&'#chr(34)##chr(34)#'>
									</cfif>
									<cfif len(q_navigation.onState)>
										<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.onState##chr(34)#;'>
									<cfelseif len(q_navigation.atState)>
										<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.atState##chr(34)#;'>
									<cfelseif len(q_navigation.onState)>
										<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.offState##chr(34)#;'>
									<cfelse>
										<cfset rollOverText = rollOverText&'&quot;&quot;'>
									</cfif>
									<cfset linkXML.XMLAttributes['onMouseOver'] = rollOverText>
									<cfset linkXML.XMLAttributes['onMouseOut'] = rollOutText>
								</cfif>
							</cfloop>
						</cfif>
					<cfelseif checkIsParentXML(q_navdata=q_navigation,currentID=ARGUMENTS.navItemID,parentcandidate=right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)))>
						<cfset ULBaseSub1.XMLChildren[s].XMLAttributes['class'] = " open">
						<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#parent">
					</cfif>
					<cfset ULBaseSub1.XMLChildren[s].XMLChildren[1] = linkXML>
					<!--- second sub nav --->
					<cfif isDefined('thisNode.div') AND isDefined('thisNode.div.UL') AND isDefined('thisNode.div.UL.LI')>
						<cfset divBaseSub2 = XMLElemNew(newNav,"div")>
						<cfset navXMLSub2 = thisNode.div.UL.XMLChildren>
						<cfset ULBaseSub2 = XMLElemNew(newNav,"UL")>
						<cfset ULBaseSub2.XMLAttributes = thisNode.div.UL.XMLAttributes>
						<cfloop from="1" to="#arrayLen(navXMLSub2)#" index="t">
							<cfset thisNode = navXMLSub2[t]>
							<cfset newNode = XMLElemNew(newNav,"LI")>
							<cfset ULBaseSub2.XMLChildren[t] = newNode>
							<cfset ULBaseSub2.XMLChildren[t].XMLAttributes = thisNode.XMLAttributes>
							<!--- need to parse out new A tag and if defined new img tag --->
							<cfset linkXML = XMLElemNew(newNav,"A")>
							<!--- ERJ Debug F --->
							<cfif StructKeyExists(thisNode,'a')>
                               <cfset linkXML.XMLAttributes = thisNode['a'].XMLAttributes>
                            <cfelse>
                                <cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug F<cfdump var="#thisNode#" label="thisNode"></cfmail>
                                <cfset linkXML.XMLAttributes = thisNode['a'].XMLAttributes>
                            </cfif>
							<!--- ERJ Debug G --->
							<cfif StructKeyExists(thisNode,'a')>
								<cfset thisA = thisNode['a']>
                            <cfelse>
                            	<cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug G<cfdump var="#thisNode#" label="thisNode"></cfmail>
                                <cfset thisA = thisNode['a']>
                            </cfif>
							<cfif isDefined('thisA.img')>
								<cfset imgXML = XMLElemNew(newNav,"img")>
								<cfset imgXML.XMLAttributes = thisA['img'].XMLAttributes>
								<cfset linkXML.XMLChildren[1] = imgXML>
							<cfelse>
								<!--- ERJ Debug H --->
							<cfif StructKeyExists(thisNode,'a')>
								<cfset linkXML.XMLText = thisNode['a'].XMLText>
                            <cfelse>
                            	<cfmail to="#APPLICATION.adminEmail#" from="#APPLICATION.adminEmail#" type="html" subject="NavWrapper Node Error"> #Application.sitemapping# :: Error navWrapper CFC ERJ Debug H<cfdump var="#thisNode#" label="thisNode"></cfmail>
                                <cfset linkXML.XMLText = thisNode['a'].XMLText>
                            </cfif>
								<cfset structDelete(VARIABLES,"imgXML")>
							</cfif>
							<cfif right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)) EQ ARGUMENTS.navItemID>
								<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#selected">
								<!--- swap out A tag image for at state --->
								<cfif isDefined('VARIABLES.imgXML')>
									<cfloop query="q_navigation">
										<cfif q_navigation.navitemid EQ ARGUMENTS.navItemID>
											<!--- replace image --->
											<cfif len(q_navigation.atState)>
												<cfset imgXML.XMLAttributes['src'] = q_navigation.atState>
											<cfelseif len(q_navigation.onState)>
												<cfset imgXML.XMLAttributes['src'] = q_navigation.onState>
											<cfelseif len(q_navigation.offState)>
												<cfset imgXML.XMLAttributes['src'] = q_navigation.offState>
											<cfelse>
												<cfset imgXML.XMLAttributes['src'] = ''>
											</cfif>
											<cfset linkXML.XMLChildren[1] = imgXML>
											<!--- replace rollover/out state --->
											<cfset rollOverText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
											<cfset rollOutText = 'javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
											<cfif len(q_navigation.atState)>
												<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.atState##chr(34)#;'>
											<cfelseif len(q_navigation.onState)>
												<cfset rollOutText = rollOutText&'#chr(34)##q_navigation.onState##chr(34)#;'>
											<cfelseif len(q_navigation.onState)>
												<cfset rollOutText = rollOffText&'#chr(34)##q_navigation.offState##chr(34)#;'>
											<cfelse>
												<cfset rollOutText = rollOutText&'#chr(34)##chr(34)#'>
											</cfif>
											<cfif len(q_navigation.onState)>
												<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.onState##chr(34)#;'>
											<cfelseif len(q_navigation.atState)>
												<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.atState##chr(34)#;'>
											<cfelseif len(q_navigation.onState)>
												<cfset rollOverText = rollOverText&'#chr(34)##q_navigation.offState##chr(34)#;'>
											<cfelse>
												<cfset rollOverText = rollOverText&'&quot;&quot;'>
											</cfif>
											<cfset linkXML.XMLAttributes['onMouseOver'] = rollOverText>
											<cfset linkXML.XMLAttributes['onMouseOut'] = rollOutText>
										</cfif>
									</cfloop>
								</cfif>
							<cfelseif checkIsParentXML(q_navdata=q_navigation,currentID=ARGUMENTS.navItemID,parentcandidate=right(thisNode.XMLAttributes.id,len(thisNode.XMLAttributes.id)-findnocase('_',thisNode.XMLAttributes.id)))>
								<cfset ULBaseSub2.XMLChildren[t].XMLAttributes['class'] = "#ARGUMENTS.classBase# open">
								<cfset linkXML.XMLAttributes['class'] = "#ARGUMENTS.classBase#parent">
							</cfif>
							<cfset ULBaseSub2.XMLChildren[t].XMLChildren[1] = linkXML>
							<!--- 3rd sub nav --->
							<cfif isDefined('navXMLSub1.div.UL') AND isDefined('navXMLSub1.div.UL.LI')>
								
								
							</cfif>
						</cfloop>
						<cfset divBaseSub2.XMLChildren[1] = ULBaseSub2>
						<cfset blah = arrayAppend(ULBaseSub1.XMLChildren[s].XMLChildren,divBaseSub2)>
					</cfif>
				</cfloop>
				
				<cfset divBaseSub1.XMLChildren[1] = ULBaseSub1> 
				<!--- <cfset ULBase.XMLChildren[r].XMLChildren[1].XMLChildren[2] = divBaseSub1>--->
				<cfset blah = arrayAppend(ULBase.XMLChildren[r].XMLChildren[1].XMLChildren,divBaseSub1)>
			</cfif>
		</cfloop>
		<cfset blah = arrayAppend(divBase.XMLChildren,ULBase)>
		<cfset brXML = XMLElemNew(newNav,"br")>
		<cfset brXML.XMLAttributes['class'] = "brclear">
		<cfset blah = arrayAppend(divBase.XMLChildren,brXML)>
		<cfset newNav.XMLRoot = divBase>
		<cfreturn toString(newNav)>
	</cffunction>
	<!--- the following code adopted from http://www.spike.org.uk/blog/index.cfm?do=blog.entry&entry=B495C724-D565-E33F-3A31D0EE819F1050 --->
	<cffunction name="copyNode" access="public" output="false" returntype="void" hint="Copies a node from one document into a second document">
		<cfargument name="xmlDoc">
		<cfargument name="newNode">
		<cfargument name="oldNode">
		<cfset var key = "" />
		<cfset var index = "" />
		<cfset var i = "" />
		<cfif isDefined('oldNode.xmlComment') AND len(trim(oldNode.xmlComment))>
			<cfset newNode.xmlComment = trim(oldNode.xmlComment) />
		</cfif>
		<cfif isDefined('oldNode.xmlCData') AND len(trim(oldNode.xmlCData))>
			<cfset newNode.xmlCData = trim(oldNode.xmlCData)>
		</cfif>
		<cfif isDefined('oldNode.XMLAttributes')>
			<cfset newNode.XMLAttributes = oldNode.XMLAttributes>
		</cfif>
		<cfif isDefined('oldNode.xmlText')>
			<cfset newNode.xmlText = trim(oldNode.xmlText) />
		</cfif>
		<cfloop from="1" to="#arrayLen(oldNode.xmlChildren)#" index="i">
			<cfset newNode.xmlChildren[i] = xmlElemNew(xmlDoc,oldNode.xmlChildren[i].xmlName) />
			<cfset copyNode(xmlDoc=xmlDoc,newNode=newNode.xmlChildren[i],oldNode=oldNode.xmlChildren[i]) />
		</cfloop>
	</cffunction>
	<cffunction access="public" name="buildListingNavWithSelection" output="false" returntype="string" displayname="buildListingNavWithSelection" hint="turn nav XML into UL/LI">
		<cfargument name="classBase" type="string" required="yes" default="" displayname="classBase" hint="the base naming scheme for the class type">
		<cfargument name="navDataSource" required="yes" type="array">
		<cfargument name="topOnly" type="boolean" required="yes" default="false" displayname="topOnly" hint="turn off recursion">
		<cfargument name="editmode" type="boolean" required="no" displayname="edit mode" hint="edit mode" default="0">
		<cfargument name="textOnly" type="boolean" required="no" displayname="ingore nav images" hint="ignore nave images" default="1">
		<cfargument name="navItemID" required="yes" type="numeric">
		<cfset var returnValue = "">
		<cfset var subNav = "">
		<cfset var navXML = ARGUMENTS.navDataSource[1]>
		<cfset var thisLevel = navXML.XMLAttributes["level"]>
		<!--- swap out with APPLICATION.allNavigation when available --->
		<cfif (NOT isDefined('application.allNavigation#arguments.classBase#') AND NOT isDefined('session.allNavigation')) OR isDefined("URL.initializeApp")>
			<cfset q_navigation = APPLICATION.navObj.getAllNavigation()>
		<cfelseif isDefined('APPLICATION.allNavigation#arguments.classBase#')>
			<cfset q_navigation = evaluate("APPLICATION.allNavigation#arguments.classBase#")>
		<cfelseif isDefined('SESSION.allNavigation#arguments.classBase#')>
			<cfset q_navigation = evaluate("SESSION.allNavigation#arguments.classBase#")>
		</cfif>
		<!--- Convert XML into UL/LI struct --->
		<cfif thisLevel EQ 0>
			<cfset returnValue=trim(returnValue)&'<div id="#arguments.classBase#" class="#arguments.classBase#" >'>
		</cfif>
		<cfif thisLevel EQ 0>
			<cfset returnValue=trim(returnValue)&'<UL id="#arguments.classBase##thisLevel#">'>
		<cfelse>
			<cfset returnValue=trim(returnValue)&'<UL id="#arguments.classBase##thisLevel#" class="#arguments.classBase##thisLevel#">'>
		</cfif>
		<cfloop from="1" to="#arrayLen(navXML.XMLChildren)#" index="r">
			<cfset thisNode = navXML.XMLChildren[r]>
			<cfset returnValue=trim(returnValue)&'<LI '>
			<cfset selectedNav = false>
			<!--- check for selection status --->
			<cfif thisNode.XMLAttributes['id'] EQ ARGUMENTS.navItemID>
				<cfset selectedNav = true>
			</cfif>
			<cfset parentNav = false>
			<!--- check for selection status --->
			<cfif checkIsParentXML(q_navdata=q_navigation,currentID=ARGUMENTS.navItemID,parentcandidate=thisNode.XMLAttributes['id'])>
				<cfset parentNav = true>
			</cfif>
			<cfif thisLevel EQ 0>
				<cfif parentNav OR selectedNav>
					<cfset returnValue=trim(returnValue)&' class="button open" '>
				<cfelse>
					<cfset returnValue=trim(returnValue)&' class="button" '>
				</cfif>
			<cfelse>
				<cfif parentNav OR selectedNav>
					<!--- <cfset returnValue=trim(returnValue)&' class="open" '> --->
				</cfif>
			</cfif>
			<cfset returnValue=trim(returnValue)&' id="#ARGUMENTS.classBase#_#thisNode.XMLAttributes['id']#">'>
			<cfif thisLevel EQ 0>
				<!--- <cfset returnValue=trim(returnValue)&'<div class="parent">'> --->
				<cfset returnValue=trim(returnValue)&'<div class="parent"'>	
				<!--- make sure image stays on 'on' state when hover over children --->			
				<cfif (NOT ARGUMENTS.textOnly) AND isDefined('thisNode.XMLAttributes.imageOff')>
					<cfset returnValue=trim(returnValue)&' onMouseOver=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOn']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&' onMouseOut=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<!--- if on this nav item or subs, use at state --->
					<cfif parentNav OR selectedNav>
						<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageAt']##chr(34)#;#chr(39)#'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOff']##chr(34)#;#chr(39)#'>
					</cfif>	
					<!--- --->			
				</cfif>
				<cfset returnValue=trim(returnValue)&'>'>
				<!--- --->
			</cfif>
			<cfset returnValue=trim(returnValue)&'<a href="#thisNode.XMLAttributes['href']#"'>
			<!--- check for selection status --->
			<cfif selectedNav>
				<cfset returnValue=trim(returnValue)&' class="#ARGUMENTS.classBase#selected"'>
			<cfelseif isDefined('thisNode.XMLAttributes') AND isDefined('thisNode.XMLAttributes.id') AND checkIsParentXML(q_navdata=q_navigation,currentID=ARGUMENTS.navItemID,parentcandidate=thisNode.XMLAttributes['id'])>
			<!--- mark parent status for selected nav item --->
				<cfset returnValue=trim(returnValue)&' class="#ARGUMENTS.classBase#parent"'>
			</cfif>
			<cfif isDefined('thisNode.XMLAttributes') AND isDefined('thisNode.XMLAttributes.target')>
				<cfset returnValue=trim(returnValue)&' target="#thisNode.XMLAttributes['target']#"'>
			</cfif>
			<cfif (NOT ARGUMENTS.textOnly) AND isDefined('thisNode.XMLAttributes.imageOff')>
				<cfif selectedNav>
					<cfset returnValue=trim(returnValue)&' onMouseOver=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOn']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&' onMouseOut=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageAt']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&'><img border="0" src="'>
					<cfset returnValue=trim(returnValue)&'#navXML.XMLChildren[r].XMLAttributes['imageAt']#" /></a>'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&' onMouseOver=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOn']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&' onMouseOut=#CHR(39)#javascript:this.getElementsByTagName(#chr(34)#img#chr(34)#)[0].src='>
					<cfset returnValue=trim(returnValue)&'#chr(34)##navXML.XMLChildren[r].XMLAttributes['imageOff']##chr(34)#;#chr(39)#'>
					<cfset returnValue=trim(returnValue)&'><img border="0" src="'>
					<!--- if on this nav item or subs, use at state --->
					<cfif parentNav OR selectedNav>
						<cfset returnValue=trim(returnValue)&'#navXML.XMLChildren[r].XMLAttributes['imageAt']#" /></a>'>
					<cfelse>
						<cfset returnValue=trim(returnValue)&'#navXML.XMLChildren[r].XMLAttributes['imageOff']#" /></a>'>
					</cfif>
					<!--- --->
				</cfif>
				<cfset returnValue=trim(returnValue)&'<div'>
				<cfif thisLevel EQ 0>
					<cfset returnValue=trim(returnValue)&' class="dropdown">'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'>'>
				</cfif>
			<cfelse>
				<cfset returnValue=trim(returnValue)&'>#navXML.XMLChildren[r].XMLAttributes['name']#</a>'>
				<cfset returnValue=trim(returnValue)&'<div'>
				<cfif thisLevel EQ 0>
					<cfset returnValue=trim(returnValue)&' class="dropdown">'>
				<cfelse>
					<cfset returnValue=trim(returnValue)&'>'>
				</cfif>
			</cfif>
			<cfset subNav = "">
			<cfif NOT ARGUMENTS.topOnly AND arrayLen(navXML.XMLChildren[r].XMLChildren)>
				<cfset subNav = buildListingNavWithSelection(navDataSource=navXML.XMLChildren[r].XMLChildren,topOnly=ARGUMENTS.toponly,textOnly=ARGUMENTS.textOnly,classBase=ARGUMENTS.classBase,navItemID=ARGUMENTS.navItemID)>
				<!--- <cfif len(trim(subNav)) EQ 0>
					<cfset returnValue = left(trim(returnValue),val(len(trim(returnValue))-5))>
				<cfelse> --->
					<cfset returnValue=trim(returnValue)&subNav>
				<!--- </cfif> --->
			</cfif>
			<!--- <cfif len(trim(subNav)) NEQ 0> --->
				<cfset returnValue=trim(returnValue)&'</div>'>
			<!--- </cfif> --->
			<cfif thisLevel EQ 0>
				<cfif NOT findNoCase("<LI",subNav)>
					<cfset returnValue = left(returnValue,len(returnValue)-28)>
				</cfif>
				<cfset returnValue=trim(returnValue)&'</div>'>
			</cfif>
			<cfset returnValue=trim(returnValue)&'</LI>'>
		</cfloop>
		<cfset returnValue=trim(returnValue)&'</UL>'>
		<cfif thisLevel EQ 0>
			<cfset returnValue=trim(returnValue)&'<br class="brclear" /></div>'>
		</cfif>
		<cfif findNoCase("<LI",returnValue)>
			<cfreturn returnValue>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
</cfcomponent>
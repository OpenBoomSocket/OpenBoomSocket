<!---
FILE:			categoryindent.cfc
NAME:           core code taken from (CF_SiteMap by Mike Brennan: mjb14@acsu.buffalo.edu)
CREATED:		11/01/2005
LAST MODIFIED:	1/01/2005
AUTHOR:         Darin Kohles #APPLICATION.adminEmail#

DESCRIPTION:    categoryindent is a custom CFML tag for generating a sitemap from 
				a table tracking item and item_parent.  It will create the 
				sitemap with infite deep levels using recursion.  Perfect tag 
				for any content management system. Here used for option tags.

ARGUMENTS:		ID : The base value for the parent ids.  Default is 0.  (OPTIONAL)
				plickLevel: "parent" or "current" chooses which category to pre-select (OPTIONAL)
				
SAMPLE INFORMATION:	http://www.acsu.buffalo.edu/~mjb14/sitemap/index.html


RETURN:			returns an option list with appropriate selection set

--->
<cfcomponent>
	<cffunction access="public" name="doIndent" output="true" returntype="void">
		<cfargument name="ID" type="numeric" required="no" default="0" displayname="Category ID" hint="ID value for category level to start the listing">
		<cfargument name="pickLevel" type="string" required="no" default="current" displayname="Pick Level" hint="chose which item to select &quot;current&quot; or &quot;parent&quot;">
		<cfargument name="idColumn" type="string" required="no" default="uploadcategoryid" displayname="Table ID Colimn" hint="column containing IDs of categories">
		<cfargument name="displayColumn" type="string" required="no" default="uploadcategorytitle" displayname="Display Column" hint="column containing text to be displayed in select list">
		<cfargument name="parentIdColumn" type="string" required="no" default="parentid" displayname="Parent ID" hint="ID of &quot;parent&quot; object containing &quot;current&quot; object">
		<cfargument name="tableName" type="string" required="no" default="uploadcategory" displayname="Table Name" hint="name of table containing parent/child relationship">
		<cfargument name="dbName" type="string" required="no" default="#application.datasource#" displayname="Database Name" hint="name of database containing desired table">
		<cfargument name="orderByColumn" type="string" required="no" default="uploadcategorytitle" displayname="Order By Column" hint="Name of column on which to sort results">
		<cfargument name="pickID" type="numeric" required="no" default="100000" displayname="Pick ID" hint="ID to set as selected item in list">
		<cfargument name="nameLengthLimit" type="numeric" required="no" default="0" displayname="Name Length Limit" hint="truncate text in name">
	
		<!--- set up for recursion--->
		<cfparam name="request.mycatcount" default="-1">
		<cfset request.mycatcount=request.mycatcount+1>

		<!--- Capture children who have a specified/default parent id --->
		<cfquery name="getChildren" datasource="#arguments.dbName#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT	#arguments.idColumn#,
				#arguments.displayColumn#,
				#arguments.parentIdColumn#
		FROM	#arguments.tableName#
		WHERE	#arguments.parentIdColumn# = #arguments.ID#
		ORDER BY #arguments.orderByColumn#
		</cfquery>
		<cfif arguments.pickLevel EQ "parent">
			<cfquery name="q_getParent" datasource="#arguments.dbName#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT parentid
			FROM #arguments.tableName#
			WHERE #arguments.idColumn# = #listFirst(form.uploadcategoryid,"|")#
			</cfquery>
			<cfset pickID=q_getParent.parentid>
		<cfelseif arguments.pickLevel EQ "current">
				<cfset pickID=listFirst(form.uploadcategoryid,"|")>
		</cfif>
		
		<cfif getChildren.recordcount GT 0>
			<cfoutput query="getChildren">

			<cfif (arguments.pickLevel NEQ "parent") OR ((arguments.pickLevel EQ "parent") AND Evaluate('getChildren.'&arguments.idColumn) NEQ listFirst(form.uploadcategoryid,"|"))>	
				<option value="#uploadcategoryid#|#uploadcategorytitle#"<cfif Evaluate('getChildren.'&arguments.idColumn) eq pickID> selected</cfif>><cfloop from="1" to="#request.mycatcount#" index="iii">&nbsp;&nbsp;</cfloop><cfloop from="1" to="#request.mycatcount#" index="iii">-&nbsp;</cfloop><cfif isDefined('arguments.nameLengthLimit') AND arguments.nameLengthLimit GT 0>#left(Evaluate('getChildren.' & arguments.displayColumn),arguments.nameLengthLimit)#<cfelse>#Evaluate('getChildren.' & arguments.displayColumn)#</cfif> </option>
			</cfif>
			
		
			<cfset newID = Evaluate("getChildren." & arguments.idColumn)>

			<!--- recursive call to traverse through table --->
			<cftry>
			<cfinvoke component="#application.cfcpath#.util.categoryindent" method="doIndent">
				<cfinvokeargument name="ID" value="#newID#">
				<cfinvokeargument name="pickLevel" value="#arguments.pickLevel#">
				<cfinvokeargument name="idColumn" value="#arguments.idColumn#">
				<cfinvokeargument name="displayColumn" value="#arguments.displayColumn#">
				<cfinvokeargument name="parentIdColumn" value="#arguments.parentIdColumn#">
				<cfinvokeargument name="tableName" value="#arguments.tableName#">
				<cfinvokeargument name="dbName" value="#arguments.dbName#">
				<cfinvokeargument name="orderByColumn" value="#arguments.orderByColumn#">
				<cfinvokeargument name="nameLengthLimit" value="#arguments.nameLengthLimit#">
			</cfinvoke>
			<cfcatch type="any">
				<cfmail to="#application.adminemail#" from="#application.adminemail#" subject="dump" type="html"><cfdump var="#newID#"></cfmail>
			</cfcatch>	
			</cftry>
		
			</cfoutput>
		</cfif>
		<cfset request.mycatcount=request.mycatcount-1>
	</cffunction>
	<cffunction access="public" name="doIndentFromSelfJoin" output="true" returntype="void">
		<cfargument name="ID" type="string" required="no" default="0" displayname="Category ID" hint="ID value for category level to start the listing">
		<cfargument name="pickLevel" type="string" required="no" default="current" displayname="Pick Level" hint="chose which item to select &quot;current&quot; or &quot;parent&quot;">
		<cfargument name="idColumn" type="string" required="no" default="uploadcategoryid" displayname="Table ID Colimn" hint="column containing IDs of categories">
		<cfargument name="displayColumn" type="string" required="no" default="uploadcategorytitle" displayname="Display Column" hint="column containing text to be displayed in select list">
		<cfargument name="parentIdColumn" type="string" required="no" default="parentid" displayname="Parent ID" hint="ID of &quot;parent&quot; object containing &quot;current&quot; object">
		<cfargument name="childIdColumn" type="string" required="no" default="childid" displayname="Child ID" hint="ID of &quot;child&quot; object contained by &quot;parent&quot; object">
		<cfargument name="tableName" type="string" required="no" default="uploadcategory" displayname="Table Name" hint="name of table item details">
		<cfargument name="jointableName" type="string" required="no" default="uploadcategory" displayname="Table Name" hint="name of table containing parent/child relationship">
		<cfargument name="dbName" type="string" required="no" default="#application.datasource#" displayname="Database Name" hint="name of database containing desired table">
		<cfargument name="orderByColumn" type="string" required="no" default="uploadcategorytitle" displayname="Order By Column" hint="Name of column on which to sort results">
		<cfargument name="pickID" type="string" required="no" default="" displayname="Pick ID" hint="ID to set as selected item in list">
		<cfargument name="nameLengthLimit" type="numeric" required="no" default="0" displayname="Name Length Limit" hint="truncate text in name">
	
		<!--- set up for recursion--->
		<cfparam name="request.mycatcount" default="-1">
		<cfset request.mycatcount=request.mycatcount+1>

		<!--- Capture parents --->
		<cfquery name="getParents" datasource="#arguments.dbName#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT	Cast([#arguments.jointableName#].#arguments.parentidColumn# AS  varchar(10))+'^'+Cast([#arguments.jointableName#].#arguments.childidColumn# AS  varchar(10)) AS keyValue,
				[#arguments.tableName#].#arguments.displayColumn#
		FROM	#arguments.jointableName#
		INNER JOIN #arguments.tableName# ON [#arguments.tableName#].#arguments.idColumn# = [#arguments.jointableName#].#arguments.childIdColumn#
		WHERE ([#arguments.jointableName#].#arguments.parentIdColumn# = [#arguments.jointableName#].#arguments.childIdColumn#)
		ORDER BY #arguments.orderByColumn#
		</cfquery>
		
		<cfif getParents.recordcount GT 0>
			<cfoutput query="getParents">

				<cfif (arguments.pickLevel NEQ "parent") OR ((arguments.pickLevel EQ "parent") AND ((listFirst(getParents.keyValue,'|') EQ listFirst(ID,'|')) OR (len(trim(ID)) EQ 0))) >
				
					<option value="#keyValue#"<cfif listfindnocase(pickID,getParents.keyValue) gt 0> selected</cfif>><cfif isDefined('arguments.nameLengthLimit') AND arguments.nameLengthLimit GT 0>#left(Evaluate('getParents.' & arguments.displayColumn),arguments.nameLengthLimit)#<cfelse>#Evaluate('getParents.' & arguments.displayColumn)#</cfif> </option>
				
			
					<cfset parentID = listFirst(getParents.keyValue,'^')>
					<cfquery name="getChildren" datasource="#arguments.dbName#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT	Cast([#arguments.jointableName#].#arguments.parentidColumn# AS  varchar(10))+'^'+Cast([#arguments.jointableName#].#arguments.childidColumn# AS  varchar(10)) AS keyValue,
							[#arguments.tableName#].#arguments.displayColumn#
					FROM	#arguments.jointableName#
					INNER JOIN #arguments.tableName# ON [#arguments.tableName#].#arguments.idColumn# = [#arguments.jointableName#].#arguments.childIdColumn#
					WHERE	([#arguments.jointableName#].#arguments.parentIdColumn# = #parentID#)
						AND ([#arguments.jointableName#].#arguments.parentIdColumn# <> [#arguments.jointableName#].#arguments.childIdColumn#)
					ORDER BY #arguments.orderByColumn#
					</cfquery>
					<cfif getChildren.recordcount GT 0>
						<cfloop query="getChildren">
							<option value="#keyValue#"<cfif listfindnocase(pickID,getChildren.keyValue) gt 0> selected</cfif>>&nbsp;&nbsp;-&nbsp;<cfif isDefined('arguments.nameLengthLimit') AND arguments.nameLengthLimit GT 0>#left(Evaluate('getChildren.' & arguments.displayColumn),arguments.nameLengthLimit)#<cfelse>#Evaluate('getChildren.' & arguments.displayColumn)#</cfif> </option>
						</cfloop>
					</cfif>
	
				</cfif>
			</cfoutput>
		</cfif>
	</cffunction>
</cfcomponent>
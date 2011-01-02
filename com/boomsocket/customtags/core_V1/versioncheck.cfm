<!--- CF_VERSIONCHECK
This tag is designed facilitate the checking of a versions
publishing status. It returns to local vars:
joinclause : Inner join SQL statement to append to your FROM clause in the query
whereclause : Where SQL statement to prepend to your WHERE clause in the query
 --->
<cfif thisTag.executionmode EQ "start">
	<cftry>
		<cfparam name="attributes.formobjectname" default="">
		<!--- 
			ERJ 1/8/07 REM'D lines below because we can use the application.tool structure to get the ID's
			Delete this comment and below if no bugs form
		 --->
		<!--- <cfquery datasource="#application.datasource#" name="q_getToolID">
			SELECT formobjectid FROM formobject WHERE formname = '#attributes.formobjectname#'
		</cfquery> --->
		<cfif StructKeyExists(application.tool,attributes.formobjectname)>
		<!--- 
			ERJ 1/8/07 REM'D lines below because we can use the application.tool structure to get the ID's
			Delete this comment and below if no bugs form
		 --->
		<!--- <cfif q_getToolID.recordcount> --->
			<!--- <cfset thisFormObjectID = q_getToolID.formobjectid>  --->
			<cfset thisFormObjectID = application.tool[attributes.formobjectname]> 
			<cfset caller.joinclause="INNER JOIN version ON #attributes.formobjectname#.#attributes.formobjectname#id = version.instanceItemID">
			<cfset caller.whereclause="(version.archive IS NULL OR version.archive = 0) AND (version.versionStatusID = 100002) AND (version.formobjectitemid = #thisFormObjectID#) AND (((version.dateToPublish <= { fn NOW() }) AND (version.dateToExpire >= { fn NOW() })) OR ((version.dateToPublish <= { fn NOW() }) AND (version.dateToExpire IS NULL)) OR (version.dateToPublish IS NULL)) ">
		<cfelse>
			<h1>ERROR</h1>
			The formobjectname you passed does not match anything in the database.
		</cfif>
		<cfcatch type="Any">
			<h1>ERROR encountered using custom tag: versioncheck.cfm</h1>
			Make sure you are passing the <strong>formobjectname</strong> variable and that it is a valid name.
			<cfmodule template="#application.customTagPath#/errorHandler.cfm" cfcatchStruct="#cfcatch#">
		</cfcatch>
	</cftry>
</cfif>

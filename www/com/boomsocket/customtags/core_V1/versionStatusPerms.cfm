<cfif thisTag.executionMode EQ "start">
	<cfparam name="attributes.userid" default="">
	<cfparam name="attributes.instanceid" default="">
	<cfparam name="attributes.formobjectid" default="">
	<cfparam name="caller.canApprove" default="0">
	<cfparam name="caller.canReject" default="0">
	<cfparam name="caller.canPublish" default="0">
	<cfparam name="caller.canDelete" default="0">
	<cfparam name="caller.canEdit" default="0">
	<cfparam name="caller.canChangeOwner" default="0">
	<cfparam name="caller.isOwner" default="0">
	<cfparam name="caller.isSupervisor" default="0">
	
	<cfif NOT LEN(attributes.userid)>
		<cfexit method="EXITTAG">
	</cfif>
	<!--- do they have a supervisor above them? --->
	<cfquery name="q_getSupers" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT TOP 1 supervisorid 
		FROM supervisorrelationship 
		WHERE userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.userid#">
        	AND formobject = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.formobjectid#">
            AND supervisorid <> userid
	</cfquery>
	<!---If the user is not found at all in the SupervisorRelationship table as a supervisor, then they were not set up accurately 
	by the Site administrator.  As a safeguard, all users must have a supervisorrelationship, if none exists, the main site 
	supervisor is considered the supervisor--->
	<!---Check supervisorrelationship table for supervisorid--->
	<cfquery name="q_getUserAsSupervisor" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT TOP 1 supervisorid 
		FROM supervisorrelationship 
		WHERE supervisorid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.userid#">
        	AND formobject = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.formobjectid#">
	</cfquery>
	<cfif NOT q_getSupers.recordcount AND q_getUserAsSupervisor.recordcount>
		<cfset caller.canApprove=1>
		<cfset caller.canReject=1>
		<cfset caller.canPublish=1>
		<cfset caller.canDelete=1>
		<cfset caller.canEdit=1>
		<cfset caller.canChangeOwner=1>
		<cfset caller.isOwner=1>
		<cfset caller.isSupervisor=1>
		<!-- if they are their own supervisor, they can edit -->
	<cfelseif q_getSupers.recordcount AND q_getUserAsSupervisor.recordcount AND q_getUserAsSupervisor.supervisorid EQ attributes.userid>
		<cfset caller.canApprove=1>
		<cfset caller.canReject=1>
		<cfset caller.canPublish=1>
		<cfset caller.canDelete=1>
		<cfset caller.canEdit=1>
		<cfset caller.canChangeOwner=1>
		<cfset caller.isOwner=1>
		<cfset caller.isSupervisor=1>
	<!---If they aren't in the supervisorrelationship table at all, then check to see if they are the 
	site administrator and if so, give them rights--->
	<cfelseif NOT q_getSupers.recordcount AND NOT q_getUserAsSupervisor.recordcount>
		<cfquery name="q_getSiteSupervisor" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT supervisorid FROM sitesettings
		</cfquery>
		<cfif attributes.userid EQ q_getSiteSupervisor.supervisorid>
			<cfset caller.canApprove=1>
			<cfset caller.canReject=1>
			<cfset caller.canPublish=1>
			<cfset caller.canDelete=1>
			<cfset caller.canEdit=1>
			<cfset caller.canChangeOwner=1>
		</cfif>
	</cfif>
	
	<!---If an instanceid was passed, check permissions specific to the version the user is viewing--->
	<cfif LEN(attributes.instanceid)>
		<cfquery name="q_getVersionInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT * 
			FROM version 
			WHERE instanceitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#trim(attributes.instanceid)#">
            	AND formobjectitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.formobjectid#">
		</cfquery>
		<cfset caller.versionstatusid = q_getVersionInfo.versionstatusid>
			<!---If the user (attributes.userid) is the owner (q_getVersionInfo.ownerid), let them edit the copy--->
			<cfif attributes.userid eq q_getVersionInfo.ownerid>
				<cfset caller.canEdit=1>
				<cfset caller.canChangeOwner=1>
				<cfset caller.isOwner=1>
			</cfif>
			
		<!--- If this user is the supervisor for this item--->
		<cfif q_getVersionInfo.supervisorid EQ session.user.id>
			<cfset caller.canApprove=1>
			<cfset caller.canReject=1>
			<cfset caller.canDelete=1>
			<cfset caller.canEdit=1>
			<cfset caller.canChangeOwner=1>
			<cfset caller.isSupervisor=1>
		</cfif>
	</cfif>
<!--- If current owner then you can delete! --->
		<!--- if current tool is review queue or home (session.i3currentTool = ""), use attributes.reviewqueue, otherwise use session.i3currentTool--->
		<cfif isDefined('session.i3CurrentTool') AND session.i3CurrentTool neq 119 AND session.i3CurrentTool neq "">
			<cfset thistool = session.i3currentTool>
		<cfelse>
			<cfset thistool = attributes.formobjectid>
		</cfif>
		<cfquery name="q_getObjectName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT formobjectname, datatable
			FROM formobject 
			WHERE formobjectid = <cfqueryparam cfsqltype="cf_sql_integer" value="#thistool#">
		</cfquery>
		<cfif isDefined("#q_getObjectName.datatable#id") AND len(evaluate(q_getObjectName.datatable&"id"))>
			<cfquery name="q_getOwner" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT version.ownerid
				FROM version INNER JOIN #q_getObjectName.datatable# ON version.instanceitemid = #q_getObjectName.datatable#.#q_getObjectName.datatable#id
				WHERE version.instanceitemid = <cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate(q_getObjectName.datatable&'id')#">
			</cfquery>
			<cfif q_getOwner.ownerid EQ attributes.userid>
				<cfset caller.canDelete=1>
				<cfset caller.canChangeOwner=1>
				<cfset caller.isOwner=1>
			</cfif>
		</cfif>
</cfif>

<!--- User Type: i_preshowform.cfm --->
<cfquery name="request.q_customQuery_roleid" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
		SELECT roleid AS lookupkey, rolename AS lookupdisplay
		FROM Role
		WHERE roleid > #session.user.accessLevel# AND active=1
		ORDER BY roleid
	</cfquery>
<cfif isDefined("instanceid")>
	<cfquery name="q_getAccessLevel" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT roleid
		FROM UserType
		WHERE usertypeid = #url.instanceid#
	</cfquery>
	<cfif session.user.accessLevel NEQ 1>
		<cfif session.user.accessLevel GTE q_getAccessLevel.roleid>
			<cflocation url="#request.page#?successMsg=#URLEncodedFormat('You do not have permission to edit this!')#" addtoken="no">
		</cfif>
	</cfif>
	<cfquery name="q_getSections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT sitesectionid
		FROM UserTypes_Sections
		WHERE usertypeid = #url.instanceid#
	</cfquery>
	<cfset form.sitesectionid = valueList(q_getSections.sitesectionid)>
</cfif>

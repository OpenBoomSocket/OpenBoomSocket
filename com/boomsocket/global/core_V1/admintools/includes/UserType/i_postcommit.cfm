<!--- i_postcommit.cfm --->
<cfif isDefined("deleteinstance")>

	<cfmodule template="#application.customTagPath#/dbaction.cfm"
			tablename="usertypepermission"
			datasource="#application.datasource#"
			action="DELETE"
			whereclause="usertypeid = #deleteinstance#">
			
	<cfmodule template="#application.customTagPath#/dbaction.cfm"
			tablename="usertypes_sections"
			datasource="#application.datasource#"
			action="DELETE"
			whereclause="usertypeid IN (#deleteinstance#)">
<cfelse>
	<cfif isDefined("instanceid")>
		<cfset thiscontentid = #instanceid#>
	<cfelse>
		<cfset thiscontentid = #insertid#>
	</cfif>
	<cfquery name="q_deleteUserTypes_Sections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		DELETE FROM UserTypes_Sections
		WHERE usertypeid = #thiscontentid#
	</cfquery>
	<cfloop list="#form.sitesectionid#" index="i">
		<cfquery name="q_insertUserTypes_Sections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			INSERT INTO UserTypes_Sections
			(usertypeid, sitesectionid)
			VALUES
			(#thiscontentid#, #ListFirst(i, "~")#)
		</cfquery>
	</cfloop>
</cfif>


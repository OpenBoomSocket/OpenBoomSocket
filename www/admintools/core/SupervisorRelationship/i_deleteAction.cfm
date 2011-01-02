<cfset count=1>
<cfloop list="#form.deleteInstance#" index="i">
	<cfif count eq 1>
		<cfset sqlWhere = "SupervisorRelationshipID = " & #i#>
	<cfelse>
		<cfset sqlWhere = sqlWhere & " OR SupervisorRelationshipID = " & #i#>
	</cfif>
	<cfset count = incrementValue(count)>
</cfloop>

<cfoutput>
<cfquery name="q_deleteSupervisorRelationships" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	DELETE FROM
	SupervisorRelationship
	WHERE #sqlWhere#
</cfquery>
</cfoutput>
<cfset errorRootDir = '/#application.sitemapping#/includes/errors'>
<cfif IsDefined('error.rootcause.type') AND Len(Trim(error.rootcause.type))>
	<cfswitch expression="#error.rootcause.type#">
		<cfcase value="Expression">
			<cfif IsDefined('error.rootcause.element') AND error.rootcause.element EQ 'INSTANCE.PAGEID'>
				<cfinclude template="#errorRootDir#/i_instancePageIdMissing.cfm">
			<cfelse>
				<cfinclude template="#errorRootDir#/i_expression.cfm">
			</cfif>
		</cfcase>
		<cfcase value="Database">
			<cfinclude template="#errorRootDir#/i_database.cfm">
		</cfcase>
		<cfdefaultcase>
			<cfinclude template="#errorRootDir#/i_default.cfm">
		</cfdefaultcase>
	</cfswitch>
<cfelse>
	<cfoutput>
		<h2>You've encountered an error while browsing out site.</h2>
		<p>We apologize for any inconvenience this might cause you. Our support team has
		  been notified and we will begin working on the issues shortly.</p>
		<p>If you would like to provide more information about what you did to get this page please email it to #application.adminemail#</p>
	</cfoutput>
</cfif>
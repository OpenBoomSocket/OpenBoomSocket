<!--- This custom tag traps errors and conditionally displays them
based on the login status of the user --->
<cfif isDefined("session.user.accessLevel") AND session.user.accessLevel eq 1>
	<cfoutput>
		<h1>ERROR!</h1>
		<cfdump var="#attributes.cfcatchStruct#">
	</cfoutput>
<cfelse>
	<cfmail type="HTML" to="#application.adminemail#" from="i3SiteTools Admin <#application.adminemail#>" subject="Error has Occured on: #application.sitename#">
		<h1>ERROR!</h1>
		<cfdump var="#attributes.cfcatchStruct#">
	</cfmail>
</cfif>


 

<cftry>
	<cfset filepath = evaluate("q_getForm.#includeFile#")>
	<cfif FileExists('#application.installPath#\#filepath#')>
		<cfinclude template="/#application.sitemapping#/#filepath#">
	<cfelse>
		<cfinclude template="#application.globalPath#/#filepath#">
	</cfif>
	<cfcatch type="MissingInclude">
		<cfoutput><h1>Yo, #filepath# include was not found!</h1></cfoutput>
		<cfmodule template="#application.customTagPath#/catcherror.cfm" message="#cfcatch.message#" detail="#cfcatch.detail#">
	</cfcatch>
</cftry>
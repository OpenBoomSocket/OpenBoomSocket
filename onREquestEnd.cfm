<cfif IsDefined('application.sitemode') AND application.sitemode EQ "prototyping">
	<cfmodule template="#application.customTagPath#/devNotes/DevNotes.cfm" devnotesdsn="#application.sitemapping#" devappname = "#application.installURL#">
</cfif>
<!---
[[.COPYRIGHT: Digital Positions, Inc. 2002-2006 ]]
[[.FILENAME: clearAppVars.cfm ]]
[[.AUTHOR: Ben Wakeman ]]
[[.PRODUCT: i3SiteTools ]]
[[.PURPOSE: Clears out various application vars cached in the system]]
[[.COMMENTS: none]]
[[.VERSION: 4.1 ]]
[[.INPUTVARS: none]]
[[.OUTPUTVARS: none]]
[[.RETURNS: none]]
[[.HISTORY:
	07/19/2005 Script created
]]
--->
<cfcomponent displayname='Clear Application Variables' hint='clearAppVars CFC' >

	<cffunction name="clearPageQuery" displayname="Clear Page Query" hint="Destroys the cached application query of all page data." access="public" returntype="void">
		<cfset var temp = structDelete(application,"q_getpageInfoload")>
	</cffunction>
	
	<cffunction name="clearJavascriptQuery" displayname="Clear JavaScript Query" hint="Destroys the cached application query of all javascripts and their page assignments." access="public" returntype="void">
		<cfset var temp = structDelete(application,"q_getjavascript")>
	</cffunction>
	
</cfcomponent>
<cfcomponent displayname='Clear Application Variables' hint='clearAppVars CFC' >

	<cffunction name="clearPageQuery" displayname="Clear Page Query" hint="Destroys the cached application query of all page data." access="public" returntype="void">
		<cfset var temp = structDelete(application,"q_getpageInfoload")>
	</cffunction>
	
	<cffunction name="clearJavascriptQuery" displayname="Clear JavaScript Query" hint="Destroys the cached application query of all javascripts and their page assignments." access="public" returntype="void">
		<cfset var temp = structDelete(application,"q_getjavascript")>
	</cffunction>
	
</cfcomponent>
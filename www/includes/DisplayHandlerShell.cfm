<cfsilent><!---
[[.COPYRIGHT: Digital Positions, Inc. 2002-2006 ]]
[[.FILENAME: DisplayHandlerShell.cfm ]]
[[.AUTHOR: Darin Kohles, Ben Wakeman, Colleen Cox ]]
[[.PRODUCT: i3SiteTools ]]
[[.PURPOSE: custom tag to wrap display handler include files and pass parameters ]]
[[.COMMENTS: non-default paramenters passed through dataStruct structure ]]
[[.VERSION: 5.0 ]]
[[.INPUTVARS: includePath, viewMode, limit, dataStuct, objectname]]
[[
	includePath: full path to include display handler file e.g. /#APPLICATION.sitemapping#/includes/whitepaper.cfm
	viewMode: listing|detail (otherwise custom as required by include file)
	limit: used for listing mode to limit the number of returns (like topnum in cfc)
	dataStruct: a structure of data items that don't correspond to other attributes or url scope data
	objectname: cfc name to be objectified 
]]
[[.OUTPUTVARS: contents of include file ]]
[[.HISTORY: 
	12/20/2006 Script created
	1/2/2007 DRK removed url struct since it gets passed to custom tags
	1/2/2007 DRK wrapped object creation in check for existance or re-init 'init3d=1'
	1/8/2007 DRK added guestObj creation for tracking of resource links
]]
---></cfsilent>

<cfif thistag.executionmode is "START">
	<!---<cfsilent>--->
	<!--- Create an instance of the data object and set to application scope if we are LIVE --->
	<!--- copy to local scope for use in include --->
		<cfset error = false>
		<cfif listLen(trim(ATTRIBUTES.objectname))>
			<cfloop list="#ATTRIBUTES.objectname#" index="thisObj">
				<cftry>
					<cfif APPLICATION.sitemode EQ "live">
						<!--- if object not created already create it now --->
						<cfif NOT isDefined('APPLICATION.#thisObj#Obj') OR (isDefined('URL.init3d') AND URL.init3d)>
							<cfset "APPLICATION.#thisObj#Obj" = CreateObject('component','#application.sitemapping#.components.#thisObj#')>
						</cfif>
						<cfset "#thisObj#Obj" = evaluate('APPLICATION.#thisObj#Obj')>
					<cfelse>
						<cfset "#thisObj#Obj" = CreateObject('component','#application.sitemapping#.components.#thisObj#')>
					</cfif>
					<!--- Site specific object call - if this include gets moved to Custom Tag directory - move this code to application.cfm START --->
					<!--- <cfif NOT isDefined('APPLICATION.guestObj') OR (isDefined('URL.init3d') AND URL.init3d)>
						<cfset APPLICATION.guestObj = createObject("component","#APPLICATION.cfcpath#.guest")>
					</cfif> 
					<cfset guestObj = APPLICATION.guestObj>--->
					<!--- Site specific object call - if this include gets moved to Custom Tag directory - move this code to application.cfm END --->
					<cfcatch type="any">
						<cflog log="application" text="error occured">
						<cflog log="application" text="#cfcatch# #thisObj#">
						<cfset error = true>
					</cfcatch>
				</cftry>
			</cfloop>
		<!--- <cfelse>
			<cfset error = true>
		</cfif>	
		<cfif error>
			<h3>You cannot use DisplayHandlerShell without passing a valid objectname</h3>
			<cfexit method="exittag"> --->
		</cfif>
		<!--- grab attributes and assign them a local scope --->
		<cfparam name="ATTRIBUTES.includePath" default="" >
		<cfif len(trim(ATTRIBUTES.includePath)) AND fileExists(expandPath(ATTRIBUTES.includePath)) >
			<cfset includePath = ATTRIBUTES.includePath>
		<cfelse>
			<cfset error = true>
		</cfif>
		<cfif error>
			<h3>You cannot use DisplayHandlerShell without passing a valid path for the include</h3>
			<cfexit method="exittag">
		</cfif>
		<cfparam name="ATTRIBUTES.viewMode" default="" >
		<cfif len(trim(ATTRIBUTES.viewMode))>
			<cfset viewMode = ATTRIBUTES.viewMode>
		</cfif>
		<cfparam name="ATTRIBUTES.limit" default="" >
		<cfif len(trim(ATTRIBUTES.limit))>
			<cfset limit = ATTRIBUTES.limit>
		</cfif>
		<cfparam name="ATTRIBUTES.dataStuct" default="" >
		<cfif isStruct(ATTRIBUTES.dataStuct)>
			<cfset dataStuct = ATTRIBUTES.dataStuct>
		</cfif>
	<!---</cfsilent>--->
	<!--- Include specified file (file specific content passed in dataStruct) --->
	<cfinclude template="#includePath#">
</cfif>


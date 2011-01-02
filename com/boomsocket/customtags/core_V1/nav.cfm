<cfif thisTag.executionmode EQ "start">
	<cfsilent>
		<cfparam name="attributes.navgroupID" default="0">
		<cfparam name="attributes.editmode" default="0">
		<!--- <cfparam name="attributes.returnType" default=""> --->
		<cfparam name="attributes.wraplevel" default="0">
		<cfparam name="attributes.thisPageID" default="0">
		<cfparam name="attributes.topOnly" default="0">
		<cfparam name="attributes.classBase" default="">
		<cfparam name="attributes.showSingleSection" default="0">
		<cfparam name="attributes.alphaordering" default="0">
		<cfparam name="attributes.active" default="1">
		<cfparam name="attributes.textOnly" default="1">
		<cfparam name="attributes.subsOnly" default="0">
		<cfparam name="attributes.showAllSubs" default="0">
		<cfparam name="attributes.usePermissions" default="0"><!--- for tool/socket based nav --->
		<cfparam name="attributes.isSecure" default="0">
		<!--- create nav item object --->
		<cfif NOT isDefined('APPLICATION.navObj') OR isDefined("URL.initializeApp")>
			<cfset APPLICATION.navObj = createObject("component","#APPLICATION.CFCPath#.navitem")>
		</cfif>
		<!--- create nav wapper utility object --->
		<cfif NOT isDefined('APPLICATION.navUtilObj') OR isDefined("URL.initializeApp")>
			<cfset APPLICATION.navUtilObj = createObject("component","#APPLICATION.CFCPath#.util.navWrapper")>
		</cfif>
		<!--- set session scope --->
		<cfif isDefined('attributes.isSecure') AND attributes.isSecure EQ 1>
			<cfset allNavScope = "SESSION">
		<cfelse>
			<cfset allNavScope = "APPLICATION">
		</cfif>
		<!--- build all navigation list --->
		<cfif NOT isDefined('#allNavScope#.allNavigation#attributes.classBase#') OR isDefined("URL.initializeApp")>
			<cfif attributes.usePermissions>
				<cfset "#allNavScope#.allNavigation#attributes.classBase#" = APPLICATION.navObj.getAllNavigation(usePermissions=1)>
			<cfelse>
				<cfset "#allNavScope#.allNavigation#attributes.classBase#" = APPLICATION.navObj.getAllNavigation()>
			</cfif>
		</cfif>
		<!--- distinguish alpha ordered vy ordinal base --->
		<cfif attributes.alphaordering>
			<cfset XMLdata = "navXML_#attributes.navgroupID##attributes.classBase#_alpha">
		<cfelse>
			<cfset XMLdata = "navXML_#attributes.navgroupID##attributes.classBase#">
		</cfif>
		<!--- Build XML from navigation --->
		<cfif NOT isDefined('#allNavScope#.#XMLdata#') OR isDefined("URL.initializeApp")>
			<cfset "#allNavScope#.#XMLdata#" = APPLICATION.navUtilObj.getNavXML(alphaordering=attributes.alphaordering,groupid=attributes.navgroupID,q_querydata=evaluate("#allNavScope#.allNavigation#attributes.classBase#"))>
		</cfif>
		<!--- distinguish single section nav --->
		<cfif attributes.showSingleSection>
			<cfset navData = "navData_#attributes.navgroupID##attributes.classBase#_#request.sitesectionid#">
		<cfelse>
			<cfset navData = "navData_#attributes.navgroupID##attributes.classBase#">
		</cfif>
		<!--- grab current nav item to set selected --->
		<cfif isDefined('request.thispageid')>
			<cfset currentNavId = APPLICATION.navObj.getNavIdFromPageID(currentpageid=request.thispageid,navgroupid=attributes.navgroupID,q_data=evaluate("#allNavScope#.allNavigation#attributes.classBase#"),urlstring=CGI.QUERY_STRING)>
		<cfelse>
			<cfset currentNavId = 0>
		</cfif>
		<!--- re/build raw html nav listing --->
		<cfif NOT isDefined('#allNavScope#.#navData#') OR isDefined('URL.initializeApp')>
			<cfset "#allNavScope#.#navData#" = APPLICATION.navUtilObj.buildListingNav(navDataSource=XMLParse(evaluate("#allNavScope#.#XMLdata#")).XMLRoot.XMLChildren,navItemId=currentNavID,topOnly=attributes.topOnly,textOnly=attributes.textOnly,editmode=attributes.editmode,classBase=attributes.classBase)>
			<cfif attributes.showSingleSection>
				<cfset "#allNavScope#.#navData#" = APPLICATION.navUtilObj.sectionListing(navItemId=currentNavID,subsOnly=attributes.subsOnly,groupid=attributes.navgroupID,textOnly=attributes.textOnly,editmode=attributes.editmode,classBase=attributes.classBase,q_querydata=evaluate("#allNavScope#.allNavigation#attributes.classBase#"))>
			</cfif>
		</cfif>
	</cfsilent>
	<cfoutput>
		<!--- if current page drives nav selection then set it --->
		<cfif currentNavId GT 0>			<!--- #trim(APPLICATION.navUtilObj.setSelectedXML(classBase=attributes.classBase,navData=evaluate("#allNavScope#.#navData#"),navItemID=currentNavID))# --->
#trim(APPLICATION.navUtilObj.buildListingNavWithSelection(classBase=attributes.classBase,navData=evaluate("#allNavScope#.#navData#"),navdatasource=XMLParse(evaluate("#allNavScope#.#XMLdata#")).XMLRoot.XMLChildren,navItemID=currentNavID,textOnly=attributes.textOnly,topOnly=attributes.topOnly))#
		<!--- otherwise dump full raw nav --->
		<cfelse>
			#evaluate("#allNavScope#.#navData#")#
		</cfif>
	</cfoutput>
</cfif>
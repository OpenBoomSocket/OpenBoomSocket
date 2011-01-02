<cfcomponent displayname="Site Map CFC" hint="Manages data for site maps">	
	<!--- get all section paths & return in list --->
	<cffunction access="public" name="getAllSectionPaths" output="false" returntype="string" displayname="Site section paths in list format">
		<cfargument name="orderby" type="string" required="no" default="sitesectionname">
		<cfset var q_getAllSections = "">
		<cfset var sectionPathList = "">
		<cftry>
			<cfquery name="q_getAllSections" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT sitesectionid, sitesectionlabel, sitesectionparent
				FROM sitesection					 
				WHERE sitesection.active = 1
				ORDER BY #arguments.orderby#
			</cfquery>
			<cfloop query="q_getAllSections"> 
			  <!---Get the path of the section---> 
			  <cfset thisPath = #application.getSectionPath(q_getAllSections.sitesectionid,"true")#>
			  <cfif sectionPathList EQ ""> 
				   <cfset sectionPathList = "#thisPath#:#q_getAllSections.sitesectionlabel#:#q_getAllSections.sitesectionid#"> 
			  <cfelse> 
				   <cfset sectionPathList = listAppend(sectionPathList,"#thisPath#:#q_getAllSections.sitesectionlabel#:#q_getAllSections.sitesectionid#")> 
			  </cfif> 
			</cfloop> 
			<cfif arguments.orderby eq "sitesectionname">
				<cfset sectionPathList = ListSort(#sectionPathList#, "textnocase", "asc")>
			</cfif>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn sectionPathList>	
	</cffunction>
	
	<!--- get all pages in a specific section --->
	<cffunction access="public" name="getPages" output="false" returntype="query" displayname="Grab all pages in this section">
		<cfargument name="sectionid" required="yes" type="numeric">
		<cfargument name="orderby" type="string" required="no" default="pagetitle">
		<cfset var q_getPages = "">
		<cftry>
			<cfquery name="q_getPages" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT pageid, pagename, pagetitle, sitesectionid, parentid
				FROM page
				WHERE sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sectionid#"> AND page.active = 1
				ORDER BY #arguments.orderby#
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getPages>	
	</cffunction>
	
	<!--- get all top level sections (for column formatting purposes) --->
	<cffunction access="public" name="getTopSections" output="false" returntype="query" displayname="Get all top level sections">
		<cfset var q_getTopSections = "">
		<cftry>
			<cfquery name="q_getTopSections" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT sitesectionid
				FROM sitesection
				WHERE sitesectionparent = sitesectionid					 
				ORDER BY sitesectionname		
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getTopSections>	
	</cffunction>
	
	<!--- query for tool based info --->
	<cffunction access="public" name="getToolBasedItems" output="false" returntype="query" displayname="Get all top level sections">
		<cfargument name="dbtable" required="yes" type="string">
		<cfargument name="fields" required="yes" type="string">
		<cfargument name="hasWorkflow" required="yes" type="boolean">
		<cfargument name="orderby" required="yes" type="string">
		<cfargument name="where" required="yes" type="string">
		<cftry>
		<cfif hasWorkflow><cfmodule template="#APPLICATION.customtagpath#/versioncheck.cfm" formobjectname="#arguments.dbtable#"></cfif>
			<cfquery name="q_getToolBasedItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT #fields#
				FROM #dbtable#	<cfif hasWorkflow AND isDefined('joinclause')>#joinclause#</cfif>
				Where 1 = 1
				<cfif Len(Trim(arguments.where))>AND #arguments.where# </cfif>
				<cfif hasWorkflow AND isDefined('whereclause')>AND #whereclause# </cfif>
				<cfif Len(Trim(arguments.orderby))>ORDER BY #orderby#</cfif>	
			</cfquery>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getToolBasedItems>	
	</cffunction>
	
	<!--- get parent section --->
	<cffunction access="public" name="getParentSection" output="false" returntype="query" displayname="Get all top level sections">
		<cfargument name="sectionid" required="yes" type="numeric">
		<cfset var q_getParentID = "">
		<cfset var q_getParentInfo = "">
		<cftry>
			<cftransaction>
				<cfquery name="q_getParentID" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT sitesectionparent
					FROM sitesection
					WHERE sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sectionid#">
				</cfquery>
				<cfquery name="q_getParentInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT sitesectionname
					FROM sitesection
					WHERE sitesectionid = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getParentID.sitesectionparent#">
				</cfquery>
			</cftransaction>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn q_getParentInfo>	
	</cffunction>
	
	<!--- get Ignore Pages list --->
	<cffunction access="public" name="getIgnorePages" output="false" returntype="string" displayname="Get list of pages that don't show on the stiemap">
		<cfset var q_getIgnorePages = "">
		<cfset var ignorePagesList = "">
		<cftry>
			<cftransaction>
				<cfquery name="q_getIgnorePages" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT pageid
					FROM page
					WHERE omitSitemap = 1			 	
				</cfquery>
				<cfloop query="q_getIgnorePages">
					<cfset ignorePagesList = ListAppend(ignorePagesList,#q_getIgnorePages.pageid#)>
				</cfloop>
			</cftransaction>
		<cfcatch type="database">
			<cfrethrow>
		</cfcatch>
		</cftry>
		<cfreturn ignorePagesList>	
	</cffunction>
</cfcomponent>

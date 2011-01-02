<cfmodule template="#application.customTagPath#/htmlshell.cfm" 
			css="site.css,admintools.css" 
			bgcolor="333333" 
			padding="8" 
			onload="self.focus();">

	<cfquery datasource="#application.datasource#" name="q_getSections" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
		SELECT sitesectionname,sitesectionid FROM sitesection ORDER BY sitesectionname ASC
	</cfquery> 
	<cfparam name="sectionPathList" default=""> 
		<cfloop query="q_getSections"> 
			 <!---Get the path of the section---> 
			 <cfset thisPath = #application.getSectionPath(q_getSections.sitesectionid,"true")#> 
			 <cfif sectionPathList EQ ""> 
			   <cfset sectionPathList = "#thisPath#:#q_getSections.sitesectionid#"> 
			 <cfelse> 
			   <cfset sectionPathList = listAppend(sectionPathList,"#thisPath#:#q_getSections.sitesectionid#")> 
			 </cfif> 
		</cfloop> 
		<!--- Sort list of section paths:IDs ASC --->
		<cfset listAsc = ListSort(#sectionPathList#, "textnocase", "asc")> 
		<!--- Create Top Level Structure to contain Site Tree --->
		<cfset site=structNew()>
		<!--- Loop over section paths and build distinct nested structures --->
		<cfloop list="#listAsc#" index="j">
			<cfquery datasource="#application.datasource#" name="q_getLabel" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
				SELECT sitesectionlabel 
				FROM sitesection 
				WHERE sitesectionid = #listLast(j,":")#
			</cfquery> 
			<cfset thisName=replaceNoCase(listFirst(j,":"),"\",".","all")>
			<cfset "site.#thisName#"=structNew()>
			<cfset "site.#thisName#.id"=listLast(j,":")>
			<cfset "site.#thisName#.name"=q_getLabel.sitesectionlabel>
			<cfset "site.#thisName#.type"="section">
			<!--- Query for pages within this section --->
			<cfquery datasource="#application.datasource#" name="q_getPages" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
				SELECT pagename,pageid,pagetitle
				FROM page 
				WHERE sitesectionid = #listLast(j,":")#
				ORDER BY pagename ASC
			</cfquery>
			<!--- Loop over pages in this Section and build structures --->
			<cfloop query="q_getPages">
				<cfset "site.#thisName#.#listFirst(q_getPages.pagename,".")#"=structNew()>
				<cfset "site.#thisName#.#listFirst(q_getPages.pagename,".")#.id"=q_getPages.pageid>
				<cfset "site.#thisName#.#listFirst(q_getPages.pagename,".")#.name"=q_getPages.pagetitle>
				<cfset "site.#thisName#.#listFirst(q_getPages.pagename,".")#.type"="page">
				<!--- Query for pagecomponents --->
				<cfquery datasource="#application.datasource#" name="q_getComponents" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#"> 
					SELECT contentobject.contentobjectname, contentobject.contentobjectid, displayhandler.displayhandlerid, displayhandler.displayhandlername
					FROM pagecomponent INNER JOIN displayhandler ON pagecomponent.displayhandlerid = displayhandler.displayhandlerid 
									   LEFT OUTER JOIN contentobject ON pagecomponent.contentobjectid = contentobject.contentobjectid
					WHERE pageid = #q_getPages.pageid#
					ORDER BY displayhandler.displayhandlerid ASC, contentobject.contentobjectname ASC
				</cfquery>
				<cfset a_components=arrayNew(2)>
				<cfloop query="q_getComponents">
					<cfif len(q_getComponents.contentobjectname)>
						<cfset a_components[q_getComponents.currentrow][1]=q_getComponents.contentobjectid>
						<cfset a_components[q_getComponents.currentrow][2]="BC"><!---body content type --->
						<cfset a_components[q_getComponents.currentrow][3]=q_getComponents.contentobjectname>
					<cfelse>
						<cfset a_components[q_getComponents.currentrow][1]=q_getComponents.displayhandlerid>
						<cfset a_components[q_getComponents.currentrow][2]="DH"><!---Data Driven Display type --->
						<cfset a_components[q_getComponents.currentrow][3]=q_getComponents.displayhandlername>
					</cfif>
				</cfloop>
				<cfset "site.#thisName#.#listFirst(q_getPages.pagename,".")#.components"=a_components>
			</cfloop>
		</cfloop>

	<cfmodule template="#application.customTagPath#/containerShell.cfm" padding=6 width=100%>
		
	<cfset attributes.currentStruct=site>
	<cfinclude template="showTree.cfm">
		
	</cfmodule>	
</cfmodule>

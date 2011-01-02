<cfcomponent displayname="Prototyping">
	<cffunction access="public" name="getNotes" output="false" returntype="query" displayname="get Notes">
	<cfargument name="pageID" displayname="Page ID" required="yes" type="numeric">
	<cfargument name="pageSpecificOnly" displayname="Page Specific Notes" required="no" type="boolean">
	<cfargument name="sitewideOnly" displayname="Sitewide Notes" required="no" type="boolean">
	<cfset var q_getNotes = "">
		<cftry>
			<cfmodule template="#application.customTagPath#/versioncheck.cfm" formobjectname="prototypenote">
			<cfquery name="q_getNotes" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT prototypenote.prototypenoteid, prototypenote.datecreated, prototypenote.datemodified, prototypenote.ordinal, prototypenote.prototypenotename, prototypenote.notebody, prototypenote.testphase, prototypenote.testscriptPDF, prototypenote.testedby, prototypenotecategory.prototypenotecategoryname, prototypenotecategory.class, prototypenotepriority.prototypenotepriorityname
				FROM prototypenote #joinclause#
					LEFT OUTER JOIN prototypenotecategory 
						ON prototypenote.prototypenotecategoryid = prototypenotecategory.prototypenotecategoryid
					LEFT OUTER JOIN prototypenotepriority 
						ON prototypenote.prototypenotepriorityid = prototypenotepriority.prototypenotepriorityid
				WHERE (pageid = #arguments.pageID# OR prototypenotecategory.prototypenotecategoryid = 100016)
				AND (#whereclause#)
				<cfif isDefined('arguments.pageSpecificOnly') AND arguments.pageSpecificOnly>
					AND prototypenotecategory.prototypenotecategoryid <> 100016
				</cfif>
				<cfif isDefined('arguments.sitewideOnly') AND arguments.sitewideOnly>
					AND prototypenotecategory.prototypenotecategoryid = 100016
				</cfif>
				ORDER BY prototypenotecategory.ordinal, prototypenotecategory.prototypenotecategoryname, prototypenote.ordinal, prototypenote.prototypenoteid
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getNotes>
	</cffunction>
	
	<!--- get Site Planning folder name--->
	<cffunction access="public" name="getSitePlanFolder" output="false" returntype="string" displayname="get Site Planning Folder Name">
		<cfset var FolderName = "">
		<cftry>
			<cfquery name="q_getFolderName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT foldername
				FROM uploadcategory 
				WHERE uploadcategorytitle = 'Site Planning'
			</cfquery>
			<cfif q_getFolderName.recordcount>
				<cfset FolderName = q_getFolderName.foldername>
			</cfif>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn FolderName>
	</cffunction>
	<!--- get FlowChart for current page --->
	<cffunction access="public" name="getFlowChartName" output="false" returntype="string" displayname="get Site Planning Flow Chart Filename">
	<cfargument name="pageid" required="yes" type="numeric">
		<cfset var FlowChartName = "">
		<cftry>
			<cfquery name="q_getFlowChartName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT upload.filename
				FROM page 
					INNER JOIN upload ON page.flowchartpdf = upload.uploadid
				WHERE pageid = #arguments.pageid#
			</cfquery>
			<cfif q_getFlowChartName.recordcount>
				<cfset FlowChartName = q_getFlowChartName.filename>
			</cfif>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn FlowChartName>
	</cffunction>
	<!--- get Test Script for specific prototypenote --->
	<cffunction access="public" name="getTestScriptName" output="false" returntype="string" displayname="get Site Planning Test Script Filename">
	<cfargument name="prototypenoteid" required="yes" type="numeric">
		<cfset var TestScriptName = "">
		<cftry>
			<cfquery name="q_getTestScriptName" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT upload.filename
				FROM prototypenote 
					INNER JOIN upload ON prototypenote.testscriptPDF = upload.uploadid
				WHERE prototypenoteid = #arguments.prototypenoteid#
			</cfquery>
			<cfif q_getTestScriptName.recordcount>
				<cfset TestScriptName = q_getTestScriptName.filename>
			</cfif>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn TestScriptName>
	</cffunction>
	<cffunction access="public" name="getPageStatus" output="false" returntype="query" displayname="get Page Status">
		<cfargument name="pageid" type="numeric" required="no">
		<cfset var q_getPageStatus = "">
		<cftry>
			<cfquery name="q_getPageStatus" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT prototypepagestatus.prototypepagestatusid, prototypepagestatus.prototypepagestatusname, prototypepagestatus.highlightcolor, upload.filename, uploadcategory.foldername, '/uploads/' + uploadcategory.foldername + '/' + upload.filename AS iconPath
				FROM  prototypepagestatus 
				<cfif isDefined('arguments.pageid')>
					INNER JOIN page ON page.prototypepagestatusid = prototypepagestatus.prototypepagestatusid
				</cfif>
				 LEFT OUTER JOIN upload ON upload.uploadid = prototypepagestatus.icon
				 LEFT OUTER JOIN uploadcategory ON uploadcategory.uploadcategoryid = upload.uploadcategoryid
				WHERE prototypepagestatus.active = 1
				<cfif isDefined('arguments.pageid') AND arguments.pageid>
					AND page.pageid = #arguments.pageid#
				</cfif>
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getPageStatus>
	</cffunction>
	
	<cffunction access="public" name="updatePageStatus" output="false" returntype="numeric" displayname="update Page Status">
		<cfargument name="prototypepagestatusid" type="numeric" required="yes">
		<cfargument name="pageid" type="numeric" required="yes">
		<cfset var updateComplete = "0">
			<cftry>
				<cfquery name="q_updatePageStatus" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					Update page
					SET prototypepagestatusid = #arguments.prototypepagestatusid#
					WHERE pageid = #arguments.pageid#
				</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
			</cftry>
		<cfreturn updateComplete>
	</cffunction>

	<cffunction access="public" name="getPagesByStatus" output="false" returntype="query" displayname="get Pages By Status">
		<cfargument name="prototypepagestatusid" type="numeric" required="yes">
		<cfargument name="ignorepages" type="string" required="no">
		<cfset var q_getPagesByStatus = "">
		<cftry>
			<cfquery name="q_getPagesByStatus" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT page.pageid, page.pagename, page.pagetitle, sitesection.sitesectionid, sitesection.sitesectionname, sitesection.sitesectionlabel
				FROM  page INNER JOIN sitesection 
					ON page.sitesectionid = sitesection.sitesectionid
				WHERE (page.prototypepagestatusid = #arguments.prototypepagestatusid#
				<!--- if this is the default status, check for prototypepagestatusid = NULL as well --->
				<cfif arguments.prototypepagestatusid eq 100001>
					OR page.prototypepagestatusid IS NULL
				</cfif>)
				<cfif isDefined('arguments.ignorepages') AND Len(arguments.ignorepages)>
					AND page.pagename NOT IN(
						<cfset count=1>
						<cfloop list="#arguments.ignorepages#" index="i">
							<cfif count gt 1>,</cfif>'#i#'
							<cfset count = count +1>
						</cfloop>
						)
				</cfif>
				ORDER by page.sitesectionid
			</cfquery>
				<cfcatch type="database">
					<cfrethrow>
				</cfcatch>
		</cftry>
		<cfreturn q_getPagesByStatus>
	</cffunction>
	
	<cffunction access="public" name="getPagesForPTNav" output="false" returntype="query" displayname="get Pages By Status">
		<cfargument name="ignorepages" type="string" required="no">
		<cfset var q_getPagesForPTNav = "">
			<cftry>
				<cfquery name="q_getPagesByStatus" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT page.pageid, page.pagename, page.pagetitle, sitesection.sitesectionid, sitesection.sitesectionname, sitesection.sitesectionlabel, prototypepagestatus.highlightcolor
					FROM  page INNER JOIN sitesection 
						ON page.sitesectionid = sitesection.sitesectionid LEFT OUTER JOIN prototypepagestatus
						ON page.prototypepagestatusid = prototypepagestatus.prototypepagestatusid
					WHERE 1=1
					<cfif isDefined('arguments.ignorepages') AND Len(arguments.ignorepages)>
						AND page.pagename NOT IN(
							<cfset count=1>
							<cfloop list="#arguments.ignorepages#" index="i">
								<cfif count gt 1>,</cfif>'#i#'
								<cfset count = count +1>
							</cfloop>
							)
					</cfif>
					ORDER by page.sitesectionid
				</cfquery>
				<cfcatch type="any">
					<cfrethrow>
				</cfcatch>
			</cftry>
			<cfreturn q_getPagesByStatus>	
	</cffunction>
</cfcomponent>
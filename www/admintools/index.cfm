<cfsilent>
	<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	<cfheader name="pragma" value="no-cache">
	<cfheader name="expires" value="#getHttpTimeString(now())#">
	
	<!--- Turn live edit off (only on in /admintools/liveEditMain.cfm) --->
	<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
		<cfset session.user.liveEdit=0>
	</cflock>

	<cfif isDefined("killtool")>
		<cfset structDelete(session,"i3currenttool")>
	</cfif>
	
	<cfif isDefined("i3currenttool")>
		<cfset session.i3currenttool=i3currenttool>
		<!--- Login Tracker Code to track EU movements in system :: Records Access to tools
		<cfscript>
			toolSearch = StructFindValue(application.tool, '#SESSION.i3currentTool#');
			if(ArrayLen(toolSearch) AND toolSearch[1].key NEQ 'loginTracker'){
				APPLICATION.loginTracker.insertActivity(
					loginTrackerName = SESSION.user.login,
					httpRemoteAddr = CGI.REMOTE_ADDR,
					httpRemoteHost = CGI.REMOTE_HOST,
					httpUserAgent = CGI.HTTP_USER_AGENT,
					httpReferrer = CGI.HTTP_REFERER,
					activity = '#SESSION.user.name# accessed Tool #toolSearch[1].key#'
				);
			}
		</cfscript> --->
	</cfif>
	<cfif isDefined("i3displayMode")>
		<cfset session.i3currenttool="">
	</cfif>
	<!--- if there is a session for tool and it is a formbuilder ID --->
	<cfif isDefined("session.i3currenttool") AND len(session.i3currenttool) AND isNumeric(session.i3currenttool)>
		<cfset i3displayMode="toolView">
	</cfif>
	<cfif Isdefined('URL.adminPage') and Len(Trim(URL.adminPage))>
		<cfset session.i3currenttool="">
		<cfset i3DisplayMode="AdminPageView">
	</cfif>
	<cfif isDefined('URL.excelExport') and Len(Trim(URL.excelExport))>
		<cfset session.i3currenttool=153>
		<cfset i3DisplayMode="toolView">
		<cfif isDefined('URL.preview')>
			<cfset request.admintemplate = 'blank'>
		</cfif>
	</cfif>
	<cfif Isdefined('URL.fileform') and Len(Trim(URL.fileform))>
		<cfset i3DisplayMode="FileManager">
	</cfif>				

	<cfparam name="i3displayMode" default="AdminPageView">
	<cfparam name="REQUEST.admintemplate" default="main">
	<cfif isDefined("URL.admintemplate")>
		<cfset REQUEST.admintemplate = URL.admintemplate>
	</cfif>
	<cfswitch expression="#i3displayMode#">
	<!--- *** Home *** --->
		<cfcase value="home">
			<cfsavecontent variable="adminOutput">
				<cfinclude template="home.cfm">
			</cfsavecontent>
		</cfcase>
	<!--- *** editLive *** --->
		<cfcase value="editLive">
			<cfset REQUEST.admintemplate = "editlive">
			<cfsavecontent variable="adminOutput">
				<cfinclude template="liveEditMain.cfm">
			</cfsavecontent>
		</cfcase>
	<!--- *** filemanager *** --->
		<cfcase value="FileManager">
			<cfset REQUEST.admintemplate = "popup">
			<cfsavecontent variable="adminOutput">
				<cfinclude template="#application.globalPath#/fileManager/i_main.cfm">
			</cfsavecontent>
		</cfcase>
	<!--- *** Help *** --->
		<cfcase value="help">
			<cfsavecontent variable="adminOutput">
				<cfinclude template="help.cfm">
			</cfsavecontent>
		</cfcase>
	<!--- *** Contact DP *** --->
		<cfcase value="contactDP">
			<cfsavecontent variable="adminOutput">
				<cfinclude template="contactDP.cfm">
			</cfsavecontent>
		</cfcase>
	<!--- *** Tool Views *** --->
		<cfcase value="toolView">
			<cfquery name="q_getAllTools" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT formobject.formname, formobject.externalTool, formenvironment.engineDefaultPath,
					   formenvironment.engineDefaultName, formenvironment.htmlShell
				FROM formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
				WHERE formobject.formobjectid = #session.i3currenttool#</cfquery>
			<cfif q_getAllTools.externalTool EQ 1>
			<cfset thisToolPath="/#application.sitemapping#/#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#/#q_getAllTools.engineDefaultName#">
			<cfset thisToolPathi3Global="#application.globalPath#/#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#/#q_getAllTools.engineDefaultName#">
				<cfif q_getAllTools.htmlShell>
					<cfsavecontent variable="adminOutput">
						<cfif FileExists("#application.InstallPath#\#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#\#q_getAllTools.engineDefaultName#")>
							<cfinclude template="#thisToolPath#">
						<cfelse>
							<cfinclude template="#thisToolPathi3Global#">
						</cfif>
					</cfsavecontent>
				<cfelse>
					<cfsavecontent variable="adminOutput">
						<cfif FileExists("#application.InstallPath#\#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#\#q_getAllTools.engineDefaultName#")>
							<cfinclude template="#thisToolPath#">
						<cfelse>
							<cfinclude template="#thisToolPathi3Global#">
						</cfif>
					</cfsavecontent>
				</cfif>
			<cfelse>
				<cfsavecontent variable="adminOutput">
					<cfmodule template="#application.customTagPath#/formprocess.cfm" formobjectid="#session.i3currenttool#" />
				</cfsavecontent>
			</cfif>
		</cfcase>
		<!--- *** Admin Pages *** --->
		<cfdefaultcase>
			<cfif directoryExists("#APPLICATION.installpath#\admintools\pages")>
				<cfset adminPageIncludeDir = "/admintools/pages">
			<cfelse>
				<cfset adminPageIncludeDir = "#APPLICATION.globalPath#/admintools/pages">
			</cfif>
			<cfsavecontent variable="adminOutput">
				<cfparam name="URL.adminPage" default="welcome.cfm">
				<cfif ListLast(URL.adminPage,'.') EQ 'cfm'>
					<cfinclude template="#adminPageIncludeDir#/#trim(URLDecode(URL.adminPage))#">
				</cfif>
			</cfsavecontent>
		</cfdefaultcase>
	</cfswitch>
</cfsilent>
<cfmodule template="#application.customTagPath#/adminskin.cfm" admintemplate="#REQUEST.admintemplate#" css="">
	<cfoutput>#adminOutput#</cfoutput>
</cfmodule>

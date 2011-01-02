<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
<cfheader name="pragma" value="no-cache">
<cfheader name="expires" value="#getHttpTimeString(now())#">
<cfif isDefined("killtool")>
	<cfset structDelete(session,"i3currenttool")>
</cfif>

<cfif isDefined("i3currenttool")>
		<cflock type="EXCLUSIVE" timeout="5" scope="SESSION">
			<cfset session.i3currenttool=i3currenttool>
		</cflock>
		<!--- Login Tracker Code to track EU movements in system :: Records Access to tools--->
<!--- 		<cfscript>
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
<cfif isDefined("session.user")>
	<cfset windowHeight=arrayLen(session.user.tools)*20>
<cfelse>
	<cfset windowHeight=300>
</cfif>
<cfset defaulti3displaymode="home">
<cfparam name="i3displayMode" default="#defaulti3displaymode#">
<cfswitch expression="#i3displayMode#">
<!--- *** Home *** --->
	<cfcase value="home">
		<cfoutput>
			<img src="/admintools/media/images/spacer.gif" width="1" height="#windowHeight#" border="0" align="left">
		</cfoutput>
		<cfinclude template="home.cfm">
	</cfcase>
<!--- *** Help *** --->
	<cfcase value="help">
		<cfinclude template="help.cfm">
	</cfcase>
<!--- *** Contact DP *** --->
	<cfcase value="contactDP">
		<cfinclude template="contactDP.cfm">
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
				<cfoutput>
					<img src="/admintools/media/images/spacer.gif" width="1" height="#windowHeight#" border="0" align="left">
				</cfoutput>
				<cfif FileExists("#application.InstallPath#\#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#\#q_getAllTools.engineDefaultName#")>
					<cfinclude template="#thisToolPath#">
				<cfelse>
					<cfinclude template="#thisToolPathi3Global#">
				</cfif>
			<cfelse>
				<cfif FileExists("#application.InstallPath#\#replaceNoCase(q_getAllTools.engineDefaultPath,'*',q_getAllTools.formname,'all')#\#q_getAllTools.engineDefaultName#")>
					<cfinclude template="#thisToolPath#">
				<cfelse>
					<cfinclude template="#thisToolPathi3Global#">
				</cfif>
			</cfif>
		<cfelse>
			<cfoutput>
				<img src="/admintools/media/images/spacer.gif" width="1" height="#windowHeight#" border="0" align="left">
			</cfoutput>
			<cfmodule template="#application.customTagPath#/formprocess.cfm" formobjectid="#session.i3currenttool#" />
		</cfif>
	</cfcase>
</cfswitch>
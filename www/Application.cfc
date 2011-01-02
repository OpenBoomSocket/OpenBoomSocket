<cfcomponent displayname="BoomSocket Application">
	<cfsetting enablecfoutputonly="Yes">
	<cfinclude template="/i_clientCode.cfm">
	
	<!--- Initialize application --->
	<cfset THIS.name = thisClientCode>
	<!--- Turn on session management. --->
	<cfset THIS.sessionManagement = true>
	<cfset this.path = GetDirectoryFromPath(GetCurrentTemplatePath()) />
	<cfset THIS.mappings["/boomsocket"]= this.path>
	<cfset THIS.customtagpaths = expandPath('boomsocket/customtags/core_V1')>
	<!--- SQL Injection Prevention --->
	<cfset THIS.scriptprotect = "all">
	
	<cfif findNoCase('admintools',CGI.SCRIPT_NAME)>
	   <cfset THIS.sessionTimeOut = createTimeSpan(0,2,0,0)>
	   <cfset THIS.applicationTimeOut = createTimeSpan(0,8,0,0)>
	<cfelse>
		<cfset THIS.applicationTimeOut = createTimeSpan(1,0,0,0)>
		<cfset THIS.sessionTimeOut = createTimeSpan(0,2,0,0)>
	</cfif>
	
	<cffunction access="public" name="onApplicationStart" output="false" returntype="Boolean">
		
		<cfinclude template="config.cfm">
		<cfmodule template="#APPLICATION.customTagPath#/createSiteMeta.cfm">
		<!--- Load User Defined Functions --->
		<cfinclude template="#APPLICATION.udfPath#">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onApplicationEnd" returntype="boolean" output="false">

		<cfreturn true>
	</cffunction>
	
	<cffunction name="onRequestStart" returntype="boolean" output="true">
		<!--- SQL Injection Prevention (only if not logged into admintools --->
		<cfif NOT isDefined('SESSION.user')>
			<cfinclude template="#APPLICATION.customTagPath#/SQLInjectionFix/i_SQLInjectionFix.cfm">
		</cfif>
		<!--- End SQL Injection Prevention --->
		<cfif isDefined("URL.initializeApp")>
			<cfset onApplicationStart()>
			<cfif isDefined('APPLICATION.globalError')>
				<cfset structDelete(application,'globalError')>
			<cfelse>
				<cfset APPLICATION.globalError = createobject('component','#application.cfcpath#.util.globalError')>
			</cfif>
		</cfif>
		
		<!----------------------------------------------------------------------!>
			If the query string variable siteUpTest=1 is added to URL, the hosting
			company is doing a test to check if site is running.
			Also, siteUpTest=2 or siteUpTest=diagnose lets us see a diagnostic 
			page on site.
		<------------------------------------------------------------------------>
		<cfif isDefined('URL.siteUpTest')> 
			<cf_siteUpTest datasource="#APPLICATION.datasource#">
		</cfif>		

		<!--- The below snippet needs to be taken out once all request.page instances in core, installer, global are changed to request.thispage--->
		<cfif cgi.script_name NEQ '/index.cfm'>
			<cfset REQUEST.page=cgi.script_name>
			<cfset REQUEST.pageback=reverse(REQUEST.page)>
			<cfset REQUEST.slash = Find( "/",REQUEST.pageback, 1)>
			<cfset REQUEST.page = reverse(left(REQUEST.pageback,REQUEST.slash-1))>
			<cftry>
				<cfset REQUEST.pageback = Right(REQUEST.pageback,len(REQUEST.pageback)-REQUEST.slash)>
				<cfset REQUEST.slash = Find( "/",REQUEST.pageback, 1)>
				<cfset REQUEST.section  = reverse(left(REQUEST.pageback,REQUEST.slash-1))>
				<cfcatch>
					<cfset REQUEST.section  = "root">
				</cfcatch>
			</cftry>
		</cfif> 
		<!--- end snippet --->
		
		<!--- Catch Errors --->
		<cfif NOT IsDefined('dpViewIt') OR dpViewIt NEQ true>
			<cfif IsDefined('APPLICATION.sitemode') AND APPLICATION.sitemode EQ "live" AND IsDefined('APPLICATION.browserdetect') AND APPLICATION.browserdetect() NEQ 'Unknown'>
				<cferror type="exception" template="home\error.cfm" mailto="#APPLICATION.adminemail#" exception="any">
				<cferror type="request" template="home\requestError.cfm" mailto="#APPLICATION.adminemail#" exception="any">
			</cfif>
		</cfif>
		
		<cfif findNoCase('admintools',CGI.SCRIPT_NAME)>
			<cfsavecontent variable="request.versionInfo">
				<cfoutput>
					<img src="/admintools/media/images/version_icon.gif" width="24" height="21" border="0"><span style="color: ##000000; vertical-align: middle;">v4.0</span>
				</cfoutput>
			</cfsavecontent>
		
			<cfif findNoCase('login.cfm',CGI.SCRIPT_NAME) EQ 0 AND findNoCase('help.cfm',CGI.SCRIPT_NAME) EQ 0 AND listfindnocase(CGI.SCRIPT_NAME,'tasks','/') EQ 0>
				<cfif NOT isDefined("session.user")>
					<cflocation url="login.cfm" addtoken="No">
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Set up the HTTP Header --->
		<cfheader name="Content-Type" value="text/html; charset=UTF-8">
		<cfcontent type="text/html; charset=UTF-8">
		<cfset setencoding("FORM", "UTF-8")>
		<cfset setencoding("URL", "UTF-8")>
		<!--- <cfinclude template="i_APPLICATION.cfm"> --->
		
		<cfif NOT isDefined('APPLICATION.installurl') OR 'http://#CGI.SERVER_NAME#' NEQ APPLICATION.installurl>
			<cfset APPLICATION.installurl="http://#CGI.SERVER_NAME#">
		</cfif>
		<cfif NOT isDefined('APPLICATION.installurlsecure') OR 'https://#CGI.SERVER_NAME#' NEQ APPLICATION.installurlsecure>
			<cfset APPLICATION.installurlsecure="https://#CGI.SERVER_NAME#">
		</cfif>	
		
		<!--- Show Debugging? Need to test this... --->
		<cfif (IsDefined("SESSION.debug"))>
			<cfsetting enablecfoutputonly="no" showdebugoutput="#SESSION.debug#">
			<cfset REQUEST.debug=1>
		<cfelse>
			<cfsetting enablecfoutputonly="no" showdebugoutput="yes">
			<cfset REQUEST.debug=0>
		</cfif>
		<cfparam name="REQUEST.section" default="root">
		<!--- Run page constructor to load the dynamically built page --->
		<cfif listFirst(CGI.SCRIPT_NAME,"/") NEQ "admintools" AND CGI.SCRIPT_NAME NEQ "/index.cfm">
			<cfmodule template="#APPLICATION.customTagPath#/pageconstructor.cfm" />
		</cfif>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onRequestEnd" returntype="boolean" output="true">
		<cfreturn true>
	</cffunction>
	<cfsetting enablecfoutputonly="No">
</cfcomponent>
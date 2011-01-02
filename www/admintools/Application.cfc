<cfcomponent extends="ApplicationProxy">
	<cfinclude template="/i_clientCode.cfm">
	<!--- Initialize application --->
	<cfset THIS.name = thisClientCode>
	<cfset THIS.applicationTimeOut = createTimeSpan(1,0,0,0)>
	<!--- Turn on SESSION management. --->
	<cfset THIS.sessionManagement = true>
	<cfset THIS.sessionTimeOut = createTimeSpan(0,2,0,0)>

	
	<cffunction access="public" name="onApplicationStart" output="false" returntype="Boolean">
		<cfinclude template="/config.cfm">
		<cfmodule template="#APPLICATION.customTagPath#/createSiteMeta.cfm">
		<!--- Load User Defined Functions --->
		<cfinclude template="#APPLICATION.udfPath#">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onRequestStart" returntype="boolean" output="true">
	<!---Session Check functionality not working so commented out of code
	- Jamie Lynn --->
		<!---<cfsavecontent variable="javascriptTimeout">
            <cfoutput>
               <script type="text/javascript">
			   		var answer;
			   		<cfoutput>
						var #toScript(((THIS.sessionTimeout)*1000)-5000,"sTimeout")#
					</cfoutput>
					<!--- alert(sTimeout);
					setTimeout('sessionWarning()', sTimeout); --->

					function sessionWarning() 
					{
   						answer = confirm("Your session is about to timeout, would you like to extend your session?");   
						if (answer)
						{
							<cfoutput>
								<cfset This.sessionTimeOut = createTimeSpan(0,0,0,10)>
							</cfoutput>
						}
					}
					
					<!--- function checkSession()
					{
						var xmlHttp;
						xmlHttp=new XMLHttpRequest();
						xmlHttp.onreadystatechange=function()
						{
							if(xmlHttp.readyState==4)
							{

								var text = xmlHttp.responseText;
								index = text.lastIndexOf('/script>');
								if (index > 0)
									text = text.substring(index);
								index = text.lastIndexOf('<?xml');
								text = text.substring(index);
								alert(index);
							}
						}
						xmlHttp.open('GET','sessionCheck.cfm',true);
    					xmlHttp.send(null);
						
					}
                    setTimeout("checkSession()",3000); --->
                </script>
             </cfoutput>
         </cfsavecontent>
        <cfhtmlhead text="#javascriptTimeout#"> --->
		
		<cfset REQUEST.page=listLast(CGI.SCRIPT_NAME,"/")>
		<cfset request.pagepath=CGI.SCRIPT_NAME> 
		<cfif request.page NEQ "login.cfm" AND request.page NEQ "help.cfm" AND request.page NEQ "forgotpassword.cfm" AND listfindnocase(CGI.SCRIPT_NAME,'tasks','/') EQ 0>
			<cfif NOT isDefined("session.user")>
				<cflocation url="login.cfm" addtoken="No">
			</cfif>
		</cfif>
		<cfif isDefined("URL.initializeApp")>
			<cfset onApplicationStart()>
		</cfif>
		<cfif isDefined('APPLICATION.globalError')>
			<cfset structDelete(application,'globalError')>
		<cfelse>
			<cfset APPLICATION.globalError = createobject('component','#application.cfcpath#.util.globalError')>
		</cfif>
		
		<!--- Catch Errors --->
		<cfif NOT IsDefined('dpViewIt') OR dpViewIt NEQ true>
			<cfif IsDefined('APPLICATION.sitemode') AND APPLICATION.sitemode EQ "live" AND IsDefined('APPLICATION.browserdetect') AND APPLICATION.browserdetect() NEQ 'Unknown'>
				<cferror type="exception" template="\home\error.cfm" mailto="#APPLICATION.adminemail#" exception="any">
				<cferror type="request" template="\home\requestError.cfm" mailto="#APPLICATION.adminemail#" exception="any">
			</cfif>
		</cfif>
		<!--- Set up the HTTP Header --->
		<cfheader name="Content-Type" value="text/html; charset=utf-8">
		<cfcontent type="text/html; charset=utf-8">
		<cfset setencoding("FORM", "utf-8")>
		<cfset setencoding("URL", "utf-8")>
		
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
		
		<!--- Begin finding the page name and directory name --->
		<cfparam name="REQUEST.section" default="root">
		
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="3">
			<cfparam name="session.currentURL" default="">
			<cfset session.previousURL=session.currentURL>
			<cfset session.currentURL="#request.page#?#cgi.query_string#">
		</cflock>
		<cfsavecontent variable="request.versionInfo">
			<cfoutput>
				<img src="/admintools/media/images/version_icon.gif" width="24" height="21" border="0"><span style="color: ##000000; vertical-align: middle;">v4.0</span>
			</cfoutput>
		</cfsavecontent>
		
		<!--- Run page constructor to load the dynamically built page --->
		<cfif listFirst(CGI.SCRIPT_NAME,"/") NEQ "admintools" AND CGI.SCRIPT_NAME NEQ "/index.cfm">
			<cfmodule template="#APPLICATION.customTagPath#/pageconstructor.cfm">
		</cfif>
		<cfreturn true>
	</cffunction>
</cfcomponent>
<!---
[[.COPYRIGHT: Digital Positions, Inc. 2002-2006 ]]
[[.FILENAME: topNav.cfc ]]
[[.AUTHOR: Jenny Walsh ]]
[[.PRODUCT: i3SiteTools ]]
[[.PURPOSE: This displays the top navigation in the frameset of all i3sitetools installs]]
[[.COMMENTS: Shows top nav and site's custom header image]]
[[.VERSION: 1 ]]
[[.INPUTVARS: Uses application vars]]
[[.OUTPUTVARS: no vars, just HTML]]
[[.RETURNS: HTML for the nav and header image]]
[[.HISTORY:
	9/30/2004 Creation
	10/25/2004 Added link to new help system
]]
--->

<cfcomponent hint="Top Navigation">
<!--- Init method --->
   <cffunction name="Init"
               returntype="void"
               hint="Outputs top navigation">
		<cfset clientName=application.sitename>
		<cfset clientNameColor="9AD24B">
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" 
				  css="admintools.css"
				  bgcolor="ffffff"
				  onload="javascript:goToForm();">
		<cfoutput>#buildJS()#</cfoutput>
		<cfmodule template="#application.customTagPath#/chromeShell.cfm" 
			textbottomleft="#dayofWeekAsString(dayOfWeek(now()))# #dateFormat(now(),"mmmm d, yyyy")# #timeFormat(now(),"h:mm tt")#" 
			textbottomright="#buildNav()#" texttopright="&copy; #year(now())# digital positions">
		<cfoutput>#buildImg()#</cfoutput>
		</cfmodule>
		</cfmodule>
   </cffunction>
<!--- Build Nav method --->
   <cffunction name="buildNav"
               returntype="string"
               hint="Builds navigation">
		<cfsavecontent variable="navText">
			<cfoutput>
				<a href="/admintools/help.cfm" target='_blank'>help</a> | 
				<cfif session.user.id EQ 100000>
					<a href="##" onclick="window.open('#application.globalPath#/ProtoTypeContent/ProtoTypeContent.cfm','PrototypeContent','scrollbars,resizeable')">Prototype Content</a> | 
				</cfif>
				<a href="/" target="_blank">live site</a> | 
				<a href="login.cfm?logout=yes" target="_top">log out</a>
			</cfoutput>
		</cfsavecontent>
		<cfreturn navText>
   </cffunction>

<!--- Build Javascript method --->
   <cffunction name="buildJS"
               returntype="string"
               hint="Builds javascript for navigation">
		<cfsavecontent variable="navJS">
			<cfoutput>
				<script type="text/JavaScript">
					function goToForm() {
						<cfif isDefined("url.trouble")>
							<!---  Build query string to pass to trouble ticket form --->
							<cfquery name="q_getUser" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								SELECT firstname,lastname FROM users WHERE usersid = #session.user.id#
							</cfquery>
							<cfif isDefined("session.i3currenttool") AND len(session.i3currenttool)>
								<cfquery name="q_getTool" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
									SELECT label FROM formobject WHERE formobjectid = #session.i3currenttool#
								</cfquery>
								<cfset currenttool="currenttool=#urlencodedformat(q_getTool.label)#">
							<cfelse>
								<cfset currenttool="currenttool=No%20tool">
							</cfif>
							<cfset clientcode="clientcode=#listFirst(application.applicationname,'_')#">
							<cfset currentuser="currentuser=#q_getUser.firstname#%20#q_getUser.lastname#">
					parent.mainFrame.location.href="/admintools/main.cfm?i3currenttool=#application.tool.troubleticket#";
						<cfelse>
							var goNow=false;
						</cfif>
					}
				</script>
			</cfoutput>
		</cfsavecontent>
		<cfreturn navJS>
   </cffunction>

<!--- Get Header Image method --->
   <cffunction name="buildImg"
               returntype="string"
               hint="Builds header image">
		<cfhtmlhead text="<script type='text/javascript' src='#application.globalPath#/javascript/Flash/objectImport.js'></script>">
		<cfsilent><cfsavecontent variable="headImg"><cfoutput><div id="menuContentTop" style="height: 50px;"><div id="flashContent" style="float:left;"><script type="text/javascript" language="javascript">createFPObject("flashContent", "clientHeader", 500, 50, "#application.globalPath#/media/swf/", "transparent", 6, [{name:"clientNameStr",value:"#urlEncodedFormat(clientName)#"},{name:"colorStr",value:"0x#clientNameColor#"}])</script></div><div style="float:right; width: 172px;"><img src="/admintools/media/images/green_i3SiteTools_logo.gif" width="172" height="55" border="0" alt="i3SiteTools: Content Management Made Simple" hspace="6" style="float:right"></div></div></cfoutput></cfsavecontent></cfsilent>
		<cfreturn headImg>
   </cffunction>
</cfcomponent>
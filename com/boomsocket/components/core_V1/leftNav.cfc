<cfcomponent hint="Top Navigation">
<cfset toolIDs="">
<cfset xmlFilePath="#application.installpath#\admintools\media\swf\userNav_#session.user.id#.xml">
<cfif CGI.SERVER_PORT EQ 443>
	<cfset xmlFileURL="#application.installurlsecure#/admintools/media/swf/userNav_#session.user.id#.xml">
<cfelse>
	<cfset xmlFileURL="/admintools/media/swf/userNav_#session.user.id#.xml">
</cfif>
<!--- Init --->
	<cffunction name="Init"
               returntype="void"
               hint="Outputs left navigation" output="true">
		<cfargument name="useFlash" type="boolean" required="Yes" default="true" displayname="Use Flash" hint="This boolean value determines whether we should use the Flash menu or the HTML.">
		<cfargument name="menuType" type="string" required="Yes" default="i3Nav" displayname="Menu Type" hint="This string value determines which SWF we should use.">
		<cfmodule template="#application.customTagPath#/htmlshell.cfm" 
				css="admintools.css" 
				bgcolor="F4F4F4">
		<cfmodule template="#application.customTagPath#/chromeShell.cfm">
	<!--- Query for tools --->
		<cfset q_getAllTools = getToolList()>
	<!--- Build XML File --->
		<cfset createXML()>
	<!--- output menu --->
		<cfoutput>
			<cfif useFlash>
				#buildFlashNav(menuType)#
			<cfelse>
				#buildHTMLNav()#
			</cfif>
		</cfoutput>
		</cfmodule>
		</cfmodule>
	</cffunction>
<!--- Query for tool list --->
	<cffunction name="getToolList"
               returntype="query"
               hint="Queries database for tool list" output="false">
		<!--- Build list of tools user is allowed to see --->
		<cfloop from="1" to="#arrayLen(session.user.tools)#" index="i">
			<cfif session.user.tools[i][2].access EQ 1>
				<cfset toolIDs=listAppend(toolIDs,session.user.tools[i][1])>
			</cfif>
		</cfloop>
		<!--- Execute query --->
		<cfquery datasource="#application.datasource#" name="q_getAllTools" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT formobject.formname, formobject.externalTool, formobject.formobjectid, formobject.label, formobject.toolcategoryid, toolcategory.toolcategoryname
			FROM formobject INNER JOIN toolcategory ON formobject.toolcategoryid = toolcategory.toolcategoryid
			WHERE formobject.formobjectid IN (<cfif Len(Trim(toolIDs))>#toolIDs#<cfelse>''</cfif>) AND toolcategory.active = 1
			ORDER BY toolcategory.ordinal ASC, toolcategory.toolcategoryname, formobject.ordinal, formobject.label
		</cfquery>
		<cfreturn q_getAllTools>
	</cffunction>

<!--- Create XML Blob --->
	<cffunction name="createXML"
               returntype="void"
               hint="Writes XML file for nav" output="false">
		<cfsavecontent variable="xmlNavBlob">
		<?xml version="1.0" encoding="iso-8859-1"?>
		<root>
		<cfif q_getAllTools.RecordCount>
			<cfoutput query="q_getAllTools" group="toolcategoryname">
				<menu label="#q_getAllTools.toolcategoryname#" icon="icon_i3">
				<cfoutput>
				<submenu label="#q_getAllTools.label#" href="/admintools/main.cfm?i3currenttool=#q_getAllTools.formobjectid#" target="mainFrame" />
				</cfoutput>
				</menu>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<menu label="i3SiteTools" icon="icon_i3">
				<cfoutput>
				<submenu label="Dashboard" href="/admintools/main.cfm" target="mainFrame" />
				</cfoutput>
				</menu>
			</cfoutput>
		</cfif>
		</root>
		</cfsavecontent>
		<cffile action="WRITE"
				file="#xmlFilePath#"
				output="#xmlNavBlob#"
				addnewline="No">
	</cffunction>

<!--- Build Flash Nav --->
	<cffunction name="buildFlashNav"
               returntype="string"
               hint="Builds Flash nav" output="false">
		<cfargument name="menuType" type="string" required="Yes" default="i3Nav" displayname="Menu Type" hint="This string value determines which SWF we should use.">
		<cfsavecontent variable="flashNav">
			<cfoutput>
			<div id="menuContentLeft">
				<script type="text/javascript" src="#application.globalPath#/javascript/Flash/objectImport.js">
				</script>
				<script type="text/javascript" language="javascript">
					createFPObject("menuContentLeft", "#arguments.menuType#", 162, 600, "#application.globalPath#/media/swf/", "transparent", 7, [{name:"flashContentURL",value:"#request.page#?hasFlash=true"},{name:"xmlFilePath",value:"#xmlFileURL#"},{name:"toolUserName",value:"#session.user.name#"},{name:"liveEditMode",value:"#session.user.liveedit#"}])
				</script>
			</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn flashNav>
	</cffunction>
<!--- Build HTML Nav --->
	<cffunction name="buildHTMLNav"
               returntype="string"
               hint="Builds HTML nav">
		<cfsavecontent variable="htmlNav">
			<table width="100%" border="0" cellspacing="0" cellpadding="5">
			<tr>
				<td colspan="2">
				<cfoutput>
				<script language="JavaScript">
					function toggleEdit(status) {
						if (status == "on") {
							window.open("/admintools/login.cfm?liveEdit=1","editWin");
							location.reload();
						}else {
							window.open("/admintools/login.cfm?liveEdit=1","_top");
						}
					}
				</script>
				<cfif session.user.liveedit>
				<a href="javascript:void(0);" name="off" onclick="javascript:toggleEdit(this.name);"><img src="/admintools/media/images/liveEdit_off.gif" border="0" title="Turn Live Edit Off" width="132" height="16"></a>
				<cfelse>
			<a href="javascript:void(0);" name="on" onclick="javascript:toggleEdit(this.name);"><img src="/admintools/media/images/liveEdit_on.gif" border="0" title="Turn Live Edit On" width="132" height="16"></a>
				</cfif>
				</td>
			</tr>
			<tr>
				<td valign="top" colspan="2"><a href="main.cfm?i3displayMode=home" title="Return to Homepage" target="mainFrame"><img src="/admintools/media/images/icon_home.gif" border="0"></a></td>
			</tr></cfoutput>
			
			<cfoutput query="q_getAllTools" group="toolcategoryname">
			<cfset counter=0>
			<cfset thisCategory=q_getAllTools.toolcategoryname>
				<cfquery name="q_thisCategory" dbtype="query" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
					SELECT *
					FROM q_getAllTools
					WHERE toolcategoryname='#thisCategory#'
				</cfquery>
				
			<cfloop query="q_thisCategory">
				<cfloop from="1" to="#arrayLen(session.user.tools)#" index="i">
					<cfif (session.user.tools[i][1] EQ q_thisCategory.formobjectid) AND (session.user.tools[i][2].access EQ 1)>
						<cfset counter=counter+1>
					</cfif>
				</cfloop>
			</cfloop>
			<cfif counter>
			<tr>
				<td class="toolCatHeading" colspan="2">#q_getAllTools.toolcategoryname#</td>
			</tr>
			<tr>	
				<td width="3"><img src="media/images/spacer.gif" border="0" width="3" height="3"></td>
				<td valign="top">
			<cfoutput>
				
				<cfloop from="1" to="#arrayLen(session.user.tools)#" index="i"> 
						<cfif (session.user.tools[i][1] eq q_getAllTools.formobjectid) AND (session.user.tools[i][2].access EQ 1)> 
						
				<a href="main.cfm?i3currenttool=#q_getAllTools.formobjectid#" title="#q_getAllTools.label#" target="mainFrame" class="leftNavItem">#q_getAllTools.label#</a><br />
						
						<cfbreak>
					</cfif> 
				</cfloop>
			</cfoutput>
				</td>
			</tr>
			</cfif>
			</cfoutput>
			<cfoutput>
			<tr>
				<td align="center" colspan="2"><strong>Note:</strong> a better version of this menu is available if you install the Flash Player 7 plugin:<br>
					<a href="http://www.macromedia.com/go/getflashplayer" target="_blank"><img src="http://www.macromedia.com/images/shared/download_buttons/get_flash_player.gif" border="0"></a>
				</td>
			</tr>
			</cfoutput>
			</table>
		</cfsavecontent>
		<cfreturn htmlNav>
	</cffunction>

</cfcomponent>
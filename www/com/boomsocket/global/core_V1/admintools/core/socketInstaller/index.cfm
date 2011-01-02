<!------------------------------------------------- >
	ORIGINAL AUTHOR ::::::::: Darin Kay (DK)
	CREATION DATE ::::::::::: ???
	LAST MODIFIED AUTHOR :::: Emile Melbourne (EOM)
	LAST MODIFIED DATE :::::: 6/24/2008
	EDIT HISTORY :::::::::::: 
								  :: 6/24/2008 EOM :: 
	FILENAME :::::::::::::::: index.cfm
	DEPENDENCIES :::::::::::: CFC/core_V1a/socketInstaller.cfc, ./includes/{i_detail.cfm, i_import.cfm, i_importconfirm.cfm, i_uninstall.cfm, i_uninstallconfirm.cfm}
	DESCRIPTION ::::::::::::: Socket installer/uninstaller page,  This page is called from Socket Library link on the main BoomSocket admintools Nav.
----------------------------------------------------->


<cfsetting enablecfoutputonly="yes">
 <!---<cfdump var="#FORM#">---> 
 <!--- If this is NOT a page reload from a form submit, check for elligible sockets for installed/unistalled.  --->
<cfif NOT isDefined('FORM.formAction')OR (isDefined('FORM.formAction') AND (NOT isDefined('FORM.importname') AND NOT isDefined('FORM.uninstallid')))>
	
	<cfinvoke component="#APPLICATION.cfcPath#.socketInstaller" 
				method="getSocketDirectoryList" 
				returnvariable="q_socketDirectoryList" />
			<cfoutput>
			
			<!--- The following javascript sets a hidden field to either "importconfirm", "uninstallconfirm" or ""(empty string). This will control the display. --->
			<script type="text/javascript">
				function manageAction(thisBtn){
					switch(thisBtn.value){
						case "Import Selected":
							document.getElementById('formAction').value="importconfirm";
						break;
						case "Uninstall Selected":
							document.getElementById('formAction').value="uninstallconfirm";
						break;
						default:
							document.getElementById('formAction').value="";
						break;
					}
					window.location="#request.page#";
				}
			</script>
			
			<div id="socketformheader">
				<h2>Socket Library</h2>
			</div><div style="clear: both;"></div>
			<div class="subtoolheader" style="text-align:right;">
				#q_socketDirectoryList.recordcount# Sockets Found
			</div><br />
			<form id="manageSockets" name="manageSockets" method="post" action="#request.page#">
			<input type="hidden" name="formAction" id="formAction" value="">
			<!--- display plugin status listing --->
			<table width="98%" border="0" cellpadding="3" cellspacing="1" align="center">
					<tbody>
					<tr class="columnheaderrow">
						<td>Import</td><td>Uninstall</td><td>Socket Name</td><td>Creator</td><td>Version</td><td>Date Installed</td>
					</tr>
					<cfloop query="q_socketDirectoryList">
					<cfsilent>
						<cfset q_pluginInfo = querynew("socketid,socketname,datemodified,creator,version,formobjectid")>
						<!--- EOM :: Why is the q_pluginInfo query variable created Here if statement right below it a < cfquery > tag with the same name will create query variable? BDW states this is in case the query failed.  There should have been error checking.  That way if the query failed it would fail gracefully, and since it wouldn't return an query object, we would still have an empty q_pluginInfo variable with the correct query structure --->
						<!--- Check if the socket already exists in the Socket table.  More specifically ensure that there is not a data table with the same name. Sockets in socket table added via Socket Tool Builder --->
						<cfinvoke component="#APPLICATION.cfcPath#.socketInstaller" 
									method="getSocketData" 
									socketName="#q_socketDirectoryList.name#" 
									returnvariable="q_pluginInfo">

						<cfif q_plugininfo.recordcount EQ 0>
							<!--- If socket DOES NOT exist in socket library (Socket Table), check for data on socket in Formobject table. --->
							<!--- This is a check ensuring we don't write over and destroy a preexisting socket of the same name --->
							<cfinvoke component="#APPLICATION.cfcPath#.socketInstaller" 
										method="getSocketDataFromFormObjectTable" 
										socketName="#q_socketDirectoryList.name#" 
										returnvariable="q_pluginInfo">
							<cfif q_plugininfo.recordcount EQ 0>
								<cfset queryAddRow(q_plugininfo,1)><!--- EOM :: Why is it necessary to add a datarow to the q_plugininfo query--->
							</cfif>
							<!--- Read xmlInfo file on current socket we are about to install. Get all relevant data on socket and it description. --->
							<cffile action="read" 
									file="#APPLICATION.installpath#\admintools\sockets\#q_socketDirectoryList.name#\info\info.xml" 
									variable="infoXML">
							<cfset infoXML = xmlParse(infoXML)> <!--- Nice to have :: Add xml schema file for infoXML.  Check for additional XML files. --->
							<cfset version = arrayNew(1)>
							<cfif isDefined('infoXML.xmlRoot.version') AND len(trim(infoXML.xmlRoot.version.xmlText))>
								<cfset version[1] = infoXML.xmlRoot.version.xmlText>
							<cfelse>
								<cfset version[1] = "Unknown">
							</cfif>
							<cfset blah = queryAddColumn(q_pluginInfo,"version",version)>
							<cfset creator = arrayNew(1)>
							<cfif isDefined('infoXML.xmlRoot.creator') AND len(trim(infoXML.xmlRoot.creator.xmlText))>
								<cfset creator[1] = infoXML.xmlRoot.creator.xmlText>
							<cfelse>
								<cfset creator[1] = "Anonymous">
							</cfif>
							<cfset blah = queryAddColumn(q_pluginInfo,"creator",creator)>
							<cfif q_socketDirectoryList.status EQ 0><!--- Socket not installed --->
								<cfif isDefined('infoXML.xmlRoot.toolname') AND len(trim(infoXML.xmlRoot.toolname.xmlText))>
									<cfset q_pluginInfo.socketname = infoXML.xmlRoot.toolname.xmlText>
								<cfelse>
									<cfset q_pluginInfo.socketname = q_socketDirectoryList.name>
								</cfif>
							</cfif>
							<cfset description = arrayNew(1)>
							<cfif isDefined('infoXML.xmlRoot.description') AND len(trim(infoXML.xmlRoot.description.xmlText))>
								<cfset description[1] = infoXML.xmlRoot.description.xmlText>
							<cfelse>
								<cfset description[1] = "No details available.">
							</cfif>
							<cfset blah = queryAddColumn(q_pluginInfo,"description",description)>
						</cfif>
					</cfsilent>
					<cfif q_pluginInfo.currentrow MOD 2>
						<cfset rowClass = "evenrow">
					<cfelse>
						<cfset rowClass = "oddrow">
					</cfif>
					<tr class="#rowClass#">
						<td align="center"><input type="checkbox" name="importname" value="#q_socketDirectoryList.name#" <cfif q_socketDirectoryList.status EQ 1>disabled="DISABLED"</cfif>></td>
						<td align="center"><input type="checkbox" name="uninstallid" value="#q_plugininfo.formobjectid#" <cfif q_socketDirectoryList.status EQ 0>disabled="DISABLED"</cfif>></td>
						<td title="#q_pluginInfo.description#">#q_pluginInfo.socketname#</td>
						<td>#q_pluginInfo.creator#</td>
						<td>#q_pluginInfo.version#</td>
						<td>#q_pluginInfo.datemodified#</td>
					</tr>
					</cfloop>
					<tr><td class="formiteminput" align="center" colspan="6"><input type="submit" class="submitbutton" value="Import Selected" onclick="javascript:manageAction(this);"><input type="submit" class="submitbutton" value="Uninstall Selected" onclick="javascript:manageAction(this);"></td></tr>
				</tbody>
			</table>
			</form>
			</cfoutput>
<cfelse>
	<cfswitch expression="#FORM.formAction#">
		<cfcase value="detail">
			<!---  --->
			<cfinclude template="includes/i_detail.cfm">
		</cfcase>
		<cfcase value="import">
			<!--- import a tool that has been added a site's  --->
			<cfif FORM.submitBtn EQ "Normal Install">
				<cfinclude template="includes/i_import.cfm">
				<!--- Should have a confirm screen somewhere here. Perhaps on this page with feed back stating a list of successful installs. s--->
			<cfelseif FORM.submitBtn EQ "Custom Install">
				<cfinclude template="includes/i_socketCustomInstall.cfm">
			</cfif>
		</cfcase>
		<cfcase value="custominstall">
			<!-- perform a custom install --->
			<!---<cfinclude template="includes/i_import.cfm">---> <!--- This is a normal install plug --->
			<cfinclude template="includes/i_doSocketCustomInstall.cfm">
		</cfcase>
		<cfcase value="importconfirm">
			<!---  --->
			<!---<cfinclude template="includes/i_importconfirm.cfm">--->
			<cfinclude template="includes/i_socketInstallWizard.cfm">
		</cfcase>
		<cfcase value="uninstall">
			<!---  --->
			<cfinclude template="includes/i_uninstall.cfm">
		</cfcase>
		<cfcase value="uninstallconfirm">
			<!---  --->
			<cfinclude template="includes/i_uninstallconfirm.cfm">
		</cfcase>
	</cfswitch>
</cfif>
<cfsetting enablecfoutputonly="no">
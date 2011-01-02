<cfsetting enablecfoutputonly="yes">
<!--- <cfdump var="#form#"> --->
<cfif NOT isDefined('FORM.formAction')OR (isDefined('FORM.formAction') AND (NOT isDefined('FORM.importname') AND NOT isDefined('FORM.uninstallid')))>
	<!--- display plugin status listing --->
	<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="getPluginStatus" returnvariable="q_pluginlist" />
			<cfoutput>
			<script type="text/javascript">
				function manageAction(thisBtn){
					switch(thisBtn.value){
						case "Import Selected":
							document.getElementById('formAction').value="importconfirm";
						break;
						case "Unistall Selected":
							document.getElementById('formAction').value="uninstallconfirm";
						break;
						default:
							document.getElementById('formAction').value="";
						break;
					}
					window.location="#request.page#";
				}
			</script>
			<div style="clear:both;"></div>
			<div>
			<img src="/admintools/media/images/spacer.gif" width="1" <!--- height="#windowHeight#" ---> border="0" align="left">
			<form id="manageSockets" name="manageSockets" method="post" action="#request.page#">
			<input type="hidden" name="formAction" id="formAction" value="">
			<table width="930" class="toolTable" border="0" cellpadding="0" cellspacing="0">
			<tbody>
				<tr><td class="toolheader">Socket Library</td></tr>
				<tr><td align="right" class="subtoolheader">#q_pluginlist.recordcount# Sockets Found</td></tr>
				<tr><td><table width="100%" border="0" cellpadding="0" cellspacing="1">
					<tbody>
					<thead>
						<th class="formiteminput">Import</th><th class="formiteminput">Uninstall</th><th class="formiteminput">Socket Name</th><th class="formiteminput">Creator</th><th class="formiteminput">Version</th><th class="formiteminput">Date Installed</th>
					</thead>
					<cfloop query="q_pluginlist">
					<cfsilent>
						<cfset q_pluginInfo = querynew("socketid,socketname,datemodified,creator,version,formobjectid")>
						<cfquery name="q_pluginInfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT socketid,socketname,datemodified,creator,version,formobjectid
							FROM socket
							WHERE tablename = '#q_pluginlist.name#'		
						</cfquery>
						<cfif q_plugininfo.recordcount EQ 0>
							<cfquery name="q_plugininfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
								SELECT formobjectname AS socketname, datemodified, formobjectid
								FROM formobject
								WHERE datatable = '#q_pluginlist.name#'	
							</cfquery>
							<cfif q_plugininfo.recordcount EQ 0>
								<cfset queryAddRow(q_plugininfo,1)>
							</cfif>
							<cffile action="read" file="#APPLICATION.installpath#\admintools\sockets\#q_pluginlist.name#\info\info.xml" variable="infoXML">
							<cfset infoXML = xmlParse(infoXML)>
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
							<cfif q_pluginlist.status EQ 0>
								<cfif isDefined('infoXML.xmlRoot.toolname') AND len(trim(infoXML.xmlRoot.toolname.xmlText))>
									<cfset q_pluginInfo.socketname = infoXML.xmlRoot.toolname.xmlText>
								<cfelse>
									<cfset q_pluginInfo.socketname = q_pluginlist.name>
								</cfif>
							</cfif>
						</cfif>
					</cfsilent>
					<tr>
						<td class="formitemlabelreq" align="center"><input type="checkbox" name="importname" value="#q_pluginlist.name#" <cfif q_pluginlist.status EQ 1>disabled="DISABLED"</cfif>></td>
						<td class="formitemlabelreq" align="center"><input type="checkbox" name="uninstallid" value="#q_plugininfo.formobjectid#" <cfif q_pluginlist.status EQ 0>disabled="DISABLED"</cfif>></td>
						<td class="formitemlabelreq">#q_pluginInfo.socketname#</td>
						<td class="formitemlabelreq">#q_pluginInfo.creator#</td>
						<td class="formitemlabelreq">#q_pluginInfo.version#</td>
						<td class="formitemlabelreq">#q_pluginInfo.datemodified#</td>
					</tr>
					</cfloop>
					</tbody>
				</table></td></tr>
				<tr><td class="formiteminput" align="center"><input type="submit" class="submitbutton" value="Import Selected" onclick="javascript:manageAction(this);"><input type="submit" class="submitbutton" value="Unistall Selected" onclick="javascript:manageAction(this);"></td></tr>
				</tbody>
			</table>
			</form>
			</div>
			</cfoutput>
<cfelse>
	<cfswitch expression="#FORM.formAction#">
		<cfcase value="detail">
		</cfcase>
		<cfcase value="import">
			<cfloop list="#FORM.importname#" index="thisSocket">
				<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="importPlugin" returnvariable="errorMsg">
					<cfinvokeargument name="pluginname" value="#thisSocket#">
				</cfinvoke>
				<cfif len(trim(errorMsg))>
					<cfif len(trim(request.errorMessage))>
						<cfset request.errorMessage = request.errorMessage&'br />'&errorMsg>
					<cfelse>
						<cfset request.errorMessage = errorMsg>
					</cfif>
				</cfif>
			</cfloop>
			<cflocation url="#request.page#">
		</cfcase>
		<cfcase value="importconfirm">
					<cfoutput>
					<div style="clear:both;"></div>
					<div>
					<h3>Import these Sockets</h3>
					<ul>
					<cfloop list="#FORM.importname#" index="pluginid">
						<li>#pluginid#</li>
					</cfloop>
					</ul>
					&nbsp;
					<form name="import" method="post" action="#request.page#">
						<input type="hidden" name="importname" id="importname" value="#FORM.importname#">
						<input type="hidden" name="formAction" id="formAction" value="import">
						<input value="Import" type="submit" class="submitbutton">
						<input value="Cancel" type="button" class="submitbutton" onclick="javascript:window.location='#request.page#';">
					</form>
					</div>
					</cfoutput>
		</cfcase>
		<cfcase value="uninstall">
			<cfloop list="#FORM.uninstallid#" index="thisSocket">
				<cfinvoke component="#APPLICATION.cfcPath#.util.plugin" method="uninstallPlugin" returnvariable="errorMsg">
					<cfinvokeargument name="formObjectID" value="#thisSocket#">
				</cfinvoke>
				<cfif len(trim(errorMsg))>
					<cfif len(trim(request.errorMessage))>
						<cfset request.errorMessage = request.errorMessage&'br />'&errorMsg>
					<cfelse>
						<cfset request.errorMessage = errorMsg>
					</cfif>
				</cfif>
			</cfloop>
			<cflocation url="#request.page#">
		</cfcase>
		<cfcase value="uninstallconfirm">
					<cfoutput>
					<div style="clear:both;"></div>
					<div>
					<h3>Un-Install these Sockets</h3>
					<ul>
					<cfloop list="#FORM.uninstallid#" index="pluginid">
						<cfquery name="q_plugininfo" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
							SELECT formobjectname AS socketname
							FROM formobject
							WHERE formobjectid = #pluginid#	
						</cfquery>
						<li>#q_plugininfo.socketname#</li>
					</cfloop>
					</ul>
					&nbsp;
					<form name="uninstall" method="post" action="#request.page#">
						<input type="hidden" name="uninstallid" id="uninstallid" value="#FORM.uninstallid#">
						<input type="hidden" name="formAction" id="formAction" value="uninstall">
						<input value="Unistall" type="submit" class="submitbutton">
						<input value="Cancel" type="button" class="submitbutton" onclick="javascript:window.location='#request.page#';">
					</form>
					</div>
					</cfoutput>
		</cfcase>
	</cfswitch>
</cfif>
<cfsetting enablecfoutputonly="no">
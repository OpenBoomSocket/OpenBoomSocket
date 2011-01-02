<script language="JavaScript">
	function resetBase(versionid){
	var agree=confirm("Are you certain you wish to reset the base version?  Doing so will permanently delete all versions created prior to this item.");
		if (agree) {									
		window.location=<cfoutput>"#request.page#?manageVersions=yes&parentid=#url.parentid#&formobjectid=#url.formobjectid#&versionid="+versionid+"&setBase=yes"</cfoutput>;
		}else {
			return false;
		}
	}
	function delVersions(){
	var agree=confirm("Are you certain you wish to permanently delete all checked versions?");
		if (agree) {									
		document.getElementById('deleteChecked').submit();
		}else {
			return false;
		}
	}
</script>		
<cfset q_Versions = ReviewQueue.getVersions(parentid=#url.parentid#,formobjectitemid=#url.formobjectid#)>
<!--- Find out if is Form Object Supervisor or Main Site Supervisor (only they see 'set as base') --->
<cfset canSetBase=0>
<cfset canDeleteAll=0>
<cfset variables.thisFormobjectid = 0>
<cfif q_Versions.recordcount>
	<cfset variables.thisFormobjectid = q_Versions.formobjectitemid>
<cfelseif isDefined('url.formobjectid')>
	<cfset variables.thisFormobjectid = url.formobjectid>
</cfif>
	<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.thisFormobjectid#">

<cfquery datasource="#application.datasource#" name="q_getSiteSupervisor" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT supervisorid
	FROM sitesettings
</cfquery>
<cfif isSupervisor OR q_getSiteSupervisor.supervisorid eq session.user.id>
	<cfset canSetBase=1>
	<cfset canDeleteAll=1>
</cfif>						
<!--- Query for preview content --->
<cfif isDefined('url.previewid') AND Len(Trim(url.previewid))>
<cfset q_Preview = ReviewQueue.getPreview(versionid=#url.previewid#,formobjectid=#url.formobjectid#)>	
</cfif>
										
<cfif isDefined('url.manageVersions') AND FindNoCase('yes',Trim(url.manageVersions))>
	<!--- Delete Versions Form Processing--->
	<cfif isDefined('form.VersionID')>
		<cfif ListLen(form.versionid) gte 1>
			<cfset bool_DelVersions = ReviewQueue.delVersions(versionids=form.Versionid)>
			<cfset ReOrderVersions_parentid = ReviewQueue.reOrderVersions(parentid=#url.parentid#,formobjectitemid=#url.formobjectid#)>
			<cfif bool_DelVersions>
				<cfset successmsg = "#Trim(bool_DelVersions)# item(s) have been deleted.">
			</cfif>	
			<cfif ReOrderVersions_parentid>
				<cfset successmsg = successmsg & "<br>The item(s) have been reordered.">
				<!--- update url.parentid to be newly set parentid--->
				<cfset successmsg = urlencodedformat(successmsg)>
			</cfif>
			<cflocation url="#request.page#?manageVersions=yes&parentid=#ReOrderVersions_parentid#&formobjectid=#url.formobjectid#&successmsg=#successmsg#" addtoken="no">
										
		</cfif>				
	</cfif>
	<!--- Set new 'base' version processing--->
	<cfif isDefined('url.setBase') AND url.setBase eq "yes">
		<cfset thisData = StructNew()>
		<cfset thisData.versionid = url.versionid>
		<cfset thisData.parentid = url.parentid>
		<cfset thisData.formobjectitemid = url.formobjectid>
		<cfset bool_DelVersions = ReviewQueue.delVersions(baseStruct=thisData)>
		<cfset ReOrderVersions_parentid = ReviewQueue.reOrderVersions(parentid=#url.parentid#,formobjectitemid=#url.formobjectid#)>
		<cfif bool_DelVersions>
			<cfset successmsg = "Your base version has been reset.">
		</cfif>	
		<cfif ReOrderVersions_parentid>
			<cfset successmsg = successmsg & "<br>The item(s) have been reordered.">
			<!--- update url.parentid to be newly set parentid--->
			<cfset successmsg = urlencodedformat(successmsg)>
			<cflocation url="#request.page#?manageVersions=yes&parentid=#ReOrderVersions_parentid#&formobjectid=#url.formobjectid#&successmsg=#successmsg#" addtoken="no">
		</cfif>	
	</cfif> 

	<div id="socketformheader"><h2>Manage Versions</h2></div><div style="clear:both;"></div>
	<table id="socketindextable" border="0" cellpadding="0" cellspacing="0">
	<cfif isDefined('url.successmsg') AND Len(Trim(url.successmsg))>
		<tr><td colspan="9"><cfoutput>#url.successmsg#</cfoutput></td></tr>
	</cfif>
	<tr>
	<td colspan="9">
	<cfoutput>
	<a href="#request.page#">Condensed View</a> | <a href="#request.page#?viewByStatus=yes">Version Inventory</a> | <a href="##" onmouseover="javascript:showColorKey();" onmouseout="javascript:hideColorKey();">Color Key</a> &nbsp;
	 <span id="colorkey" style="position: absolute; visibility:hidden; background-color:##FFFFFF; border:1px solid; padding:5px;">
	 	<cfloop query="q_Status">
			<span style="color:#q_Status.colorcode#">#q_Status.status#</span><br />
		</cfloop></span>
	</cfoutput>
	</td>
</tr>
	<tr>
		<td valign="top" width="60%">
			<table cellpadding="5" cellspacing="1" border="0" class="tooltable" width="100%">
				<tr class="columnheaderrow">
					<cfif canSetBase><td class="formiteminput" width="85">Set as 'base'</td></cfif>
					<td class="formiteminput" width="50">Delete</td>
					<td class="formiteminput">Version</td>
					<td class="formiteminput">Created</td>
					<td class="formiteminput">Modified</td>
					<td class="formiteminput" width="50">Preview</td>
				</tr>
				<cfset isNewerThanLive = 0>
				<form name="deleteChecked" id="deleteChecked" method="post" action="#request.page#?manageVersions=yes&parentid=#url.parentid#&formobjectid=#url.formobjectid#">
				<cfloop query="q_Versions">
					<!--- if can't delete all, need to get their permissions for this instance--->
					<cfif NOT canDeleteAll>
						<cfset canDelete=0>
						<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#q_Versions.formobjectitemid#" instanceid="#q_Versions.instanceitemid#">
					</cfif>					
					<cfoutput>
					<cfif q_Versions.currentrow MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
					<tr class="#rowclass#">
						<cfif canSetBase><td width="85" align="center" valign="top">
						<!--- only allow to set as base if live version or older --->
						<cfif isNewerThanLive eq 0>
							<a href="##" onclick="resetBase(#q_versions.versionid#);"><img src="#application.globalPath#/media/images/icon_selectTarget.gif" border="0" title="set as base"/></a>
						</cfif>
						</td></cfif>
						<td width="50" align="center" valign="top"><input name="VersionID" type="checkbox" <cfif q_Versions.versionStatusid eq 100002 OR (NOT canDeleteALL and NOT canDelete)>disabled="disabled"</cfif> value="#q_versions.versionid#"/>
						</td>
						<td valign="top" bgcolor="#q_Versions.colorcode#" class="versionColorCell">#q_Versions.label# #q_Versions.version#</td>
						<td width="110" valign="top">#dateFormat(q_versions.datecreated, 'MM/DD/YY')#&nbsp;#timeFormat(q_versions.datecreated, 'h:mm tt')#</td>
						<td width="110" valign="top">#dateFormat(q_versions.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(q_versions.datemodified, 'h:mm tt')#</td>
						<td width="50" align="center" valign="top">
							<a href="#request.page#?manageVersions=yes&parentid=#url.parentid#&formobjectid=#url.formobjectid#&previewid=#q_versions.versionid#"><img src="#application.globalPath#/media/images/icon_preview.gif" border="0" title="preview"/></a>
						</td>
					</tr>
					</cfoutput>
					<cfif isNewerThanLive eq 0 AND q_Versions.versionStatusid eq 100002>
						<cfset isNewerThanLive = 1>
					</cfif>
				</cfloop>
				<tr>
					<td colspan="6" bgcolor="#cccccc" align="center"><input type="button" value="Delete Checked" onclick="delVersions();" class="deleteButton" /></td>
				</tr>
				</form>
			</table>
		</td>
		<td valign="top" width="40%">
			<table cellpadding="5" cellspacing="1" border="0" class="tooltable" width="100%">
				<tr class="columnheaderrow">
					<td class="formiteminput"><cfoutput><a href="#request.page#?manageVersions=yes&parentid=#url.parentid#&formobjectid=#url.formobjectid#">Instructions</a>/Preview</cfoutput></td>
				</tr>
				<tr class="oddrow">
					<td id="PreviewContainer" height="350" valign="top"><div id="previewContainer" style="overflow:auto;height:350;"><cfif isDefined('q_Preview') AND Len(Trim(q_Preview))><cfoutput>#q_Preview#</cfoutput><cfelse>
						<strong><font size="2" color="##000000">Welcome to the new version management section!</font></strong>
						<p>From here you have the ability to view and manage all versions of an element. Versions are ordered top to bottom from oldest (by create date) to newest.</p>
						<cfif canSetBase>
							<p>The first way to manage versions is to reset the "base" <img src="#application.globalPath#/media/images/icon_selectTarget.gif" border="0" title="set as base"/>.  The base version is the oldest version (by create date).  If you reset the base, any older versions will be deleted and the remaining versions will be renumbered 1-n.</p>
						</cfif>
						<p>You can <cfif canSetBase>also </cfif>choose to delete versions that you no longer need. To do so, check the checkbox next to the version(s) you wish to delete and click the "Delete Checked" button at the bottom of the version table.  The remaining versions will be renumbered 1-n.</p>
						<p><strong>Note:</strong><cfif NOT canDeleteAll> You are only able to delete items you have permission to delete.</cfif> No one can delete a published item.</p>
						
						<p>In order to preview content before performing an action, click on <img src="#application.globalPath#/media/images/icon_preview.gif" border="0" title="preview"/> next to the version you wish to preview.</p>
						
						<p style="color:#CC0000;">WARNING: When managing versions, any deleted items are permanently deleted!</p>				
					</cfif></div></td>
				</tr>
			</table>
		</td>
	</tr>
	</table>						
</cfif>	
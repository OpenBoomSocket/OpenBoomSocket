<cfset q_reviewQueue = ReviewQueue.getDirectiveElements()>
<cfset q_directives = ReviewQueue.getDirectives()>
<cfset q_Recent = ReviewQueue.getRecentElements(directiveVersions=ValueList(q_reviewQueue.versionid))>
<div id="socketformheader"><h2>Review Queue</h2></div><div style="clear:both;"></div>
<table id="socketindextable" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="9">
	<cfoutput>
	<cfif isDefined("url.viewall")>
		<a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Show My Content</a>
	<cfelse>
		<a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Condensed View</a>
	</cfif>
	 | <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&viewByStatus=yes">Version Inventory</a>
	| <a href="##" onmouseover="javascript:showColorKey();" onmouseout="javascript:hideColorKey();">Color Key</a> &nbsp;
	 <span id="colorkey" style="position: absolute; visibility:hidden; background-color:##FFFFFF; border:1px solid; padding:5px;">
	 	<cfloop query="q_Status">
			<span style="color:#q_Status.colorcode#">#q_Status.status#</span><br />
		</cfloop></span>
	 </cfoutput>
	</td>
</tr>
<tr>
		<td colspan="9" valign="top">		
		<table border="0" cellpadding="0" cellspacing="1" width="100%">
		<tr class="columnheaderrow">
		<cfoutput>
		<td colspan="2" class="formiteminput"><strong>Version</strong></td>
		<td class="formiteminput"><strong>Status/Directive</strong></td>
		<td class="formiteminput"><strong>Owner</strong></td>
		<td class="formiteminput"><strong>Modified</strong></td>
		<td class="formiteminput"><strong>&nbsp;</strong></td>
		</cfoutput>
	</tr>
	<!--- Directives --->
	<cfoutput query="q_reviewQueue" group="versiondirectivename">
	<tr bgcolor="##dadada">
		<td colspan="9"><strong>#q_reviewQueue.versiondirectivename# </strong></td>
	</tr>
		<cfoutput>
		<!--- set variables & get user permissions --->
			<cfset variables.versionid = q_ReviewQueue.versionid>
			<cfset variables.versiondirectiveid = q_ReviewQueue.versiondirectiveid>
			<cfset variables.colorcode = q_ReviewQueue.colorcode>
			<cfset variables.versionstatusid = q_ReviewQueue.versionstatusid>
			<cfset variables.ownerinitials = q_ReviewQueue.ownerInitials>
			<cfset variables.supervisorid = q_ReviewQueue.supervisorid>		
			<cfset variables.datemodified = q_ReviewQueue.datemodified>		
			<cfset variables.formobjectid = Trim(q_ReviewQueue.formobjectitemid)>
			<cfset variables.instanceitemid = q_ReviewQueue.instanceitemid>		
			<cfset AccessPermissions = application.getPermissions("access",variables.formobjectid)>
			<cfset canApprove=0>
			<cfset canReject=0>
			<cfset canPublish=0>
			<cfset canDelete=0>
			<cfset canEdit=0>
			<cfset canChangeOwner=0>
			<cfset isOwner=0>
			<cfset isSupervisor=0>
			<cfset canAccessVersionMgt=0>
			<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#variables.instanceitemid#">
			<cfif canDelete>
				<cfset canAccessVersionMgt = 1>
			</cfif>
			<!--- get all possible owners --->
			<cfset q_userNames = ReviewQueue.q_getUsers(formobjectid=#variables.formobjectid#,versionsupid=#variables.supervisorid#)>
			<!--- display row--->
			<cfif q_Recent.currentrow MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
			<cfset formname="status#variables.versionid#">
			<form method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;" action="#request.page#" name="#formname#">
			<input type="Hidden" id="RQformobjectid" name="RQformobjectid" value="#q_RQformobjectid.formobjectid#">
			<input type="Hidden" name="formobject" id="formobject" value="#q_reviewQueue.formobjectitemid#">
			<input type="Hidden" name="parentid" id="parentid" value="#q_reviewQueue.parentid#">
			<input type="Hidden" id="pageview" name="pageview" value="dashboard">
			<input type="hidden" id="requestpage" name="requestpage" value="#request.page#"/>
			<input type="Hidden" id="canAccess" name="canAccess" value="#AccessPermissions#">			
			<input type="Hidden" name="versionid" id="versionid" value="#variables.versionid#">
			
			<input type="hidden" id="#variables.versionid#_currStatus" name="#variables.versionid#_currStatus" value="#variables.versionstatusid#"/>
			<input type="hidden" id="#variables.versionid#_currStatusColor" name="#variables.versionid#_currStatusColor" value="#variables.colorcode#"/>
			<input type="hidden" id="#variables.versionid#_canPublish" name="canPublish" value="#variables.versionid#_#canPublish#"/>
			<input type="hidden" id="#variables.versionid#_canReject" name="#variables.versionid#_canReject" value="#canReject#"/>
			<input type="hidden" id="#variables.versionid#_canApprove" name="#variables.versionid#_canApprove" value="#canApprove#"/>
			
				<tr class="#rowclass#">
					<td id="editLink#variables.versionid#"><cfif AccessPermissions><a href="index.cfm?i3currenttool=#q_reviewQueue.formobjectitemid#&instanceid=#variables.instanceitemid#&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a></cfif><cfif canAccessVersionMgt> <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&manageVersions=yes&parentid=#q_reviewQueue.parentid#&formobjectid=#q_reviewQueue.formobjectitemid#"><img src="#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /></a></cfif></td>
					<td nowrap="nowrap" width="125">#q_ReviewQueue.formobjectlabel#: #q_ReviewQueue.label# #q_ReviewQueue.version#</td>
					<td id="statusCol#variables.versionid#" bgcolor="#variables.colorcode#" class="versionColorCell" height="36">
						<!--- only allow them to update status if have permissions to edit this form object--->
						<select id="versionstatusid#q_ReviewQueue.versionid#" name="versionstatusid" style="font-size: 9px;" <cfif NOT canEdit> disabled</cfif> onchange="javascript:checkStatusPerm('#formname#',this.value);">
							<cfloop query="q_Status">
								<option value="#q_Status.versionstatusid#" style="color: #q_Status.colorcode#; background-color: white;"<cfif variables.versionstatusid eq q_Status.versionstatusid> selected</cfif>>#q_Status.status#</option>
							</cfloop>
						</select>
						<cfif canEdit>
							<!---directive dd to show when status is changed--->
							<div id="directiveDropdown#variables.versionid#">
							<select id="versiondirectiveid#variables.versionid#" name="versiondirectiveid" style="font-size: 9px;">
								<option value="0">-- Change directive --</option>
								<cfloop query="q_directives">
									<option value="#q_directives.versiondirectiveid#"<cfif variables.versiondirectiveid eq q_directives.versiondirectiveid> selected</cfif>>#q_directives.versiondirectivename#</option>
								</cfloop>
							</select>
							</div>
						</cfif>
					</td>
					<td>				
						<select id="ownerselect#variables.versionid#" name="ownerid" style="font-size: 10px;" <cfif NOT canChangeOwner> disabled</cfif>>
							<cfloop query="q_userNames">
								<option value="#q_userNames.usersid#" <cfif q_userNames.initials eq variables.ownerInitials> SELECTED</cfif>>#ucase(q_userNames.initials)#</option>
							</cfloop>
						</select>
					</td>
					<td id="datemodified#variables.versionid#" class="queueRow">#dateFormat(variables.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(variables.datemodified, 'h:mm tt')#</td>
					<td class="queueRow"><input type="image" src="#application.globalPath#/media/images/icon_save.gif" /></td>
				</tr>
			</form>
		</cfoutput>
	</cfoutput>
	<cfoutput>
	<!--- Recently Modified Items --->
	<tr class="evenrow">
		<td colspan="9"><strong>Recently Modified</strong></td>
	</tr>
	<cfloop query="q_Recent">
		<cfset canApprove=0>
		<cfset canReject=0>
		<cfset canPublish=0>
		<cfset canDelete=0>
		<cfset canEdit=0>
		<cfset canChangeOwner=0>
		<cfset isOwner=0>
		<cfset isSupervisor=0>
		<cfset canAccessVersionMgt=0>
		<cfset AccessPermissions = application.getPermissions("access",q_Recent.formobjectid)>
		<cfset variables.colorcode = q_Recent.colorcode>
		<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#q_Recent.formobjectid#" instanceid="#q_Recent.instanceitemid#">
		<cfif canDelete>
			<cfset canAccessVersionMgt = 1>
		</cfif>
		<cfif q_Recent.currentrow MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
		<tr class="#rowclass#">
			<td id="editLink#q_Recent.versionid#"><cfif AccessPermissions><a href="index.cfm?i3currenttool=#q_Recent.formobjectid#&instanceid=#q_Recent.instanceitemid#&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a></cfif><cfif canAccessVersionMgt> <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&manageVersions=yes&parentid=#q_Recent.parentid#&formobjectid=#q_Recent.formobjectid#"><img src="#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /></a></cfif></td>
			<td nowrap="nowrap" width="125">#q_Recent.formobjectlabel#: #q_Recent.label# #q_Recent.version#</td>
			<td bgcolor="#variables.colorcode#" class="versionColorCell">#q_Recent.status#</td>
			<td>#q_Recent.ownerInitials#</td>
			<td colspan="2">#dateFormat(q_Recent.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(q_Recent.datemodified, 'h:mm tt')#</td>
		</tr>
	</cfloop>
	</table></td></tr></table>
</cfoutput>

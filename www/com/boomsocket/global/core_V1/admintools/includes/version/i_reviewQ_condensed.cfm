<cfset q_reviewQueue = ReviewQueue.getCondensedElements(instanceid=#varInstanceid#,viewall=#varViewall#,sortBy=#varSortby#,statusFilter=#varStatusFilter#,viewByStatus=#varViewByStatus#)>
<div id="socketformheader"><h2>Review Queue</h2></div><div style="clear:both;"></div>
<table id="socketindextable" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="9">
	<cfoutput>
	<cfif isDefined("url.viewall")>
		<a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Show My Content</a>
	<cfelse>
		<a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&viewall=yes<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Show Everyone's Content</a>
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
			<td class="formiteminput"><strong>Status</strong></td>
			<td class="formiteminput"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>><strong>Creator</strong></td>
			<td class="formiteminput"><strong>Owner</strong></td>
			<td class="formiteminput"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>><strong>Supervisor</strong></td>
			<td class="formiteminput"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>><strong>Created</strong></td>
			<td class="formiteminput"><strong>Modified</strong></td>
			</cfoutput>
		</tr>
		<cfoutput query="q_reviewQueue" group="FormObjectItemID">
			<cfset formobjectlabel = ReviewQueue.getFormObjectLabel(formobjectid=#q_reviewQueue.FormObjectItemID#)>
			<tr class="evenrow">
				<td colspan="9"><strong>#formobjectlabel# </strong></td>
			</tr>
			<cfoutput>
			<!--- get all non-published Versions for this item & determine which should be selected initially --->
			<cfset q_Versions = ReviewQueue.getVersions(parentid=#q_reviewQueue.parentid#,formobjectitemid=#q_reviewQueue.formobjectitemid#,getPublished=0)>
			<cfif q_Versions.recordcount gt 0>
				<cfset SelectedRow = 1>
				<cfset variables.versionid = q_Versions.versionid>
				<!--- just updated status (not to published) or owner for one of these versions, select the updated version --->
				<cfif UpdatedVersion neq 0 AND ListFind(Valuelist(q_Versions.versionid),UpdatedVersion)>
					<cfset SelectedRow = ListFind(ValueList(q_Versions.versionid),UpdatedVersion)>
						<cfset variables.versionid = UpdatedVersion>
				<!--- viewing "My Content, select first version the user owns, supervises, or created--->
				<cfelseif varViewall neq "yes">
					<cfset SelectedRow = 0>
					<cfloop query="q_Versions">
						<cfif (q_Versions.ownerid eq session.user.id OR q_Versions.supervisorid eq session.user.id OR q_Versions.creatorid eq session.user.id) AND SelectedRow eq 0>
							<cfset SelectedRow = q_Versions.currentrow>
							<cfset variables.versionid = q_Versions.versionid>
						</cfif>
					</cfloop>
				</cfif>
				<!--- set variables for row info to be displayed --->
				<cfset variables.colorcode = q_Versions.colorcode[SelectedRow]>
				<cfset variables.versionstatusid = q_Versions.versionstatusid[SelectedRow]>
				<cfset variables.ownerinitials = q_Versions.ownerInitials[SelectedRow]>
				<cfset variables.supervisorid = q_Versions.supervisorid[SelectedRow]>
				<cfset variables.supervisorfirstname = q_Versions.supervisorFirstName[SelectedRow]>
				<cfset variables.supervisorlastname = q_Versions.supervisorLastName[SelectedRow]>
				<cfset variables.supervisorinitials = q_Versions.supervisorInitials[SelectedRow]>
				<cfset variables.creatorfirstname = q_Versions.creatorfirstname[SelectedRow]>
				<cfset variables.creatorlastname = q_Versions.creatorlastname[SelectedRow]>
				<cfset variables.creatorinitials = q_Versions.creatorinitials[SelectedRow]>
				<cfset variables.datemodified = q_Versions.datemodified[SelectedRow]>
				<cfset variables.datecreated = q_Versions.datecreated[SelectedRow]>
				<cfset variables.formobjectid = Trim(q_Versions.formobjectitemid[SelectedRow])>
				<cfset variables.instanceitemid = q_Versions.instanceitemid[SelectedRow]>
				<!--- get form object permissions, delete permissions --->
				<cfset AccessPermissions = application.getPermissions("access",variables.formobjectid)>
				<cfset canDelete=0>
				<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#variables.instanceitemid#">
				<!--- display row--->
				<cfif q_reviewQueue.currentrow MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
					<tr class="#rowclass#">
						<cfset formname="status#variables.versionid#">
						<form method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;" action="#request.page#" name="#formname#">
						<input type="Hidden" id="RQformobjectid" name="RQformobjectid" value="#q_RQformobjectid.formobjectid#">
						<cfif isDefined("url.sortBy")><input type="hidden" name="sortBy" value="#url.sortBy#"></cfif>
						<cfif isDefined("url.viewall")><input type="hidden" name="viewall" value="#url.viewall#"></cfif>
						<input type="Hidden" name="formobject" id="formobject" value="#q_reviewQueue.formobjectitemid#">
						<input type="Hidden" name="parentid" id="parentid" value="#q_reviewQueue.parentid#">
						<input type="Hidden" id="pageview" name="pageview" value="reviewqueue">
						<input type="hidden" id="requestpage" name="requestpage" value="#request.page#"/>
						<input type="Hidden" id="canAccess" name="canAccess" value="#AccessPermissions#">
						<input type="Hidden" id="allversionids" name="allversionids" value="#ValueList(q_Versions.versionid)#">
						
					<!--- instance specific hidden fields to be used by version.js --->
					<cfset canAccessVersionMgt=0>
					<cfloop query="q_Versions">
						<cfset canApprove=0>
						<cfset canReject=0>
						<cfset canPublish=0>
						<cfset canDelete=0>
						<cfset canEdit=0>
						<cfset canChangeOwner=0>
						<cfset isOwner=0>
						<cfset isSupervisor=0>
						<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#q_Versions.instanceitemid#">
						<cfif canDelete>
							<cfset canAccessVersionMgt = 1>
						</cfif>
						<input type="Hidden" id="#q_Versions.versionid#_canAccessVersionMgt" name="#q_Versions.versionid#_canAccessVersionMgt" value="#canAccessVersionMgt#">
						<input type="Hidden" id="#q_Versions.versionid#_canAccess" name="#q_Versions.versionid#_canAccess" value="#AccessPermissions#">
						<input type="Hidden" name="#q_Versions.versionid#_formobject" id="#q_Versions.versionid#_formobject" value="#q_Versions.formobjectitemid#">
						<input type="Hidden" name="#q_Versions.versionid#_parentid" id="#q_Versions.versionid#_parentid" value="#q_Versions.parentid#">
						<input type="hidden" id="#q_Versions.versionid#_status" name="#q_Versions.versionid#_status" value="#q_Versions.versionstatus#"/>
						<input type="hidden" id="#q_Versions.versionid#_colorcode" name="#q_Versions.versionid#_colorcode" value="#q_Versions.colorcode#"/>
						<input type="hidden" id="#q_Versions.versionid#_versionstatusid" name="#q_Versions.versionid#_versionstatusid" value="#q_Versions.versionstatusid#"/>
						<input type="hidden" id="#q_Versions.versionid#_ownerid" name="#q_Versions.versionid#_ownerid" value="#q_Versions.ownerid#"/>
						<input type="hidden" id="#q_Versions.versionid#_ownerfirstname" name="#q_Versions.versionid#_ownerfirstname" value="#q_Versions.ownerfirstname#"/>
						<input type="hidden" id="#q_Versions.versionid#_ownerlastname" name="#q_Versions.versionid#_ownerlastname" value="#q_Versions.ownerlastname#"/>
						<input type="hidden" id="#q_Versions.versionid#_ownerinitials" name="#q_Versions.versionid#_ownerinitials" value="#q_Versions.ownerinitials#"/>
						<input type="hidden" id="#q_Versions.versionid#_creatorfirstname" name="#q_Versions.versionid#_creatorfirstname" value="#q_Versions.creatorfirstname#"/>
						<input type="hidden" id="#q_Versions.versionid#_creatorlastname" name="#q_Versions.versionid#_creatorlastname" value="#q_Versions.creatorlastname#"/>
						<input type="hidden" id="#q_Versions.versionid#_supervisorfirstname" name="#q_Versions.versionid#_supervisorfirstname" value="#q_Versions.supervisorfirstname#"/>
						<input type="hidden" id="#q_Versions.versionid#_supervisorlastname" name="#q_Versions.versionid#_supervisorlastname" value="#q_Versions.supervisorlastname#"/>
						<input type="hidden" id="#q_Versions.versionid#_supervisorinitials" name="#q_Versions.versionid#_supervisorinitials" value="#q_Versions.supervisorinitials#"/>
						<input type="hidden" id="#q_Versions.versionid#_creatorinitials" name="#q_Versions.versionid#_creatorinitials" value="#q_Versions.creatorinitials#"/>
						<input type="hidden" id="#q_Versions.versionid#_datemodified" name="#q_Versions.versionid#_datemodified" value="#DateFormat(q_Versions.datemodified,'short')# #TimeFormat(q_Versions.datemodified, "short")#"/>
						<input type="hidden" id="#q_Versions.versionid#_datecreated" name="#q_Versions.versionid#_datecreated" value="#DateFormat(q_Versions.datecreated,'short')# #TimeFormat(q_Versions.datecreated, "short")#"/>
						<input type="hidden" id="#q_Versions.versionid#_instanceitemid" name="#q_Versions.versionid#_instanceitemid" value="#q_Versions.instanceitemid#"/>
						<input type="hidden" id="#q_Versions.versionid#_canDelete" name="#q_Versions.versionid#_canDelete" value="#canDelete#"/>
						<input type="hidden" id="#q_Versions.versionid#_canEdit" name="#q_Versions.versionid#_canEdit" value="#canEdit#"/>
						<input type="hidden" id="#q_Versions.versionid#_canChangeOwner" name="#q_Versions.versionid#_canChangeOwner" value="#canChangeOwner#"/>
						<input type="hidden" id="#q_Versions.versionid#_canPublish" name="#q_Versions.versionid#_canPublish" value="#canPublish#"/>
						<input type="hidden" id="#q_Versions.versionid#_canReject" name="#q_Versions.versionid#_canReject" value="#canReject#"/>
						<input type="hidden" id="#q_Versions.versionid#_canApprove" name="#q_Versions.versionid#_canApprove" value="#canApprove#"/>
						<input type="hidden" id="#q_Versions.versionid#_isOwner" name="#q_Versions.versionid#_isOwner" value="#isOwner#"/>
						<input type="hidden" id="#q_Versions.versionid#_isSupervisor" name="#q_Versions.versionid#_isSupervisor" value="#isSupervisor#"/>
					</cfloop>
					<input type="Hidden" id="canAccessVersionMgt" name="canAccessVersionMgt" value="#canAccessVersionMgt#">
					<!--- get all possible owners --->
					<cfset q_userNames = ReviewQueue.q_getUsers(formobjectid=#variables.formobjectid#,versionsupid=#variables.supervisorid#)>
					<!--- reset permissions for displayed version --->
					<cfset canApprove=0>
					<cfset canReject=0>
					<cfset canPublish=0>
					<cfset canDelete=0>
					<cfset canEdit=0>
					<cfset canChangeOwner=0>
					<cfset isOwner=0>
					<cfset isSupervisor=0>
					<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#variables.instanceitemid#">
					<td class="queueRow" id="editLink#variables.versionid#"><cfif AccessPermissions><a href="index.cfm?i3currenttool=#q_reviewQueue.formobjectitemid#&instanceid=#variables.instanceitemid#&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a></cfif><cfif canAccessVersionMgt> <a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&manageVersions=yes&parentid=#q_reviewQueue.parentid#&formobjectid=#q_reviewQueue.formobjectitemid#"><img src="#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /></a></cfif>
						</td>
					<td>
						<select name="versionid" style="font-size: 9px;" onchange="javascript:updateRowVersion('#variables.versionid#',this.value);">
							<cfloop query="q_Versions">
								<option value="#q_Versions.versionid#" style="color: #q_Versions.colorcode#; background-color: white;"<cfif q_Versions.versionid eq variables.versionid> selected</cfif>>#Left(q_Versions.label,50)# #q_Versions.version#</option>
							</cfloop>
							</select>
						</td>
						<td id="statusCol#variables.versionid#" bgcolor="#variables.colorcode#" class="versionColorCell" height="36">
							<!--- only allow them to update status if have permissions to edit this form object--->
							<select id="versionstatusid#variables.versionid#" name="versionstatusid" style="font-size: 9px;" onchange="javascript:reAssign('#formname#','status');"<cfif NOT canEdit> disabled</cfif>>
								<cfloop query="q_Status">
									<option value="#q_Status.versionstatusid#" style="color: #q_Status.colorcode#; background-color: white;"<cfif variables.versionstatusid eq q_Status.versionstatusid> selected</cfif>>#q_Status.status#</option>
								</cfloop>
							</select>
						</td>
						<td id="creator#variables.versionid#"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>><a href="javascript: void(0)" title="#variables.creatorFirstName# #variables.creatorLastName#" class="nottalink">#ucase(variables.creatorInitials)#</a> 
						</td>
						<td>
						
						<select id="ownerselect#variables.versionid#" name="ownerid" style="font-size: 10px;" onchange="javascript:reAssign('#formname#','owner');"<cfif NOT canChangeOwner> disabled</cfif>>
							<cfloop query="q_userNames">
								<option value="#q_userNames.usersid#" <cfif q_userNames.initials eq variables.ownerInitials> SELECTED</cfif>>#ucase(q_userNames.initials)#</option>
							</cfloop>
						</select>
						</td>
						</form>
						<td id="supervisor#variables.versionid#"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>><a href="javascript: void(0)" title="#variables.supervisorFirstName# #variables.supervisorLastName#" class="nottalink">#ucase(variables.supervisorInitials)#</a></td>
						
						<td id="datecreated#variables.versionid#" class="queueRow"<cfif variables.pageview neq "reviewq"> style="display:none;"</cfif>>#dateFormat(variables.datecreated, 'MM/DD/YY')#&nbsp;#timeFormat(variables.datecreated, 'h:mm tt')#</td>
						<td id="datemodified#variables.versionid#" class="queueRow">#dateFormat(variables.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(variables.datemodified, 'h:mm tt')#</td>
					</tr>
			</cfif>
			</cfoutput>
</cfoutput>
</table></td></tr></table>
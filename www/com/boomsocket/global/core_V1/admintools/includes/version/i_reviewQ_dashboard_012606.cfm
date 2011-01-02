<br>&nbsp;&nbsp;
		<table cellpadding="5" cellspacing="1" border="0" class="tooltable" width="100%">
		<tr>
			<td colspan="9" class="toolheader">Review Queue</td>
		</tr>
		<tr>
			<td colspan="9" class="formiteminput"><cfoutput><a href="index.cfm?i3currenttool=#q_RQformobjectid.formobjectid#&viewByStatus=yes">View Version Inventory</a></cfoutput></td>
		</tr>
		<tr class="subtoolheader">
			<cfoutput>
			<td colspan="2" class="formiteminput"><a href="#request.page#?i3displayMode=home&sortBy=label<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'labelasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif>"><strong>Version</strong></a></td>
			<td class="formiteminput"><a href="#request.page#?i3displayMode=home&sortBy=label<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'labelasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif>"><strong>Status</strong></a></td>
			<td class="formiteminput"><a href="#request.page#?i3displayMode=home&sortBy=ownerInitials<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'ownerInitialsasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif>"><strong>Owner</strong></a></td>
			<td class="formiteminput"><a href="#request.page#?i3displayMode=home&sortBy=datemodified<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'datemodifiedasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif>"><strong>Modified</strong></a></td>
			</cfoutput>
		</tr>
		<cfif q_reviewQueue.recordcount>
		<cfoutput query="q_reviewQueue" group="FormObjectLabel">
			<!--- Only display this header if there are items under review (the query is pulling live data but not displaying)--->
			<cfset showHeader = 0>
			<cfoutput>
				<!--- get all Versions --->
				<cfset q_Versions = ReviewQueue.getVersions(parentid=#q_reviewQueue.parentid#,formobjectitemid=#q_reviewQueue.formobjectitemid#)>
				<!--- check if has items under review --->
				<cfif q_Versions.recordcount gt 1 OR q_Versions.versionstatusid neq 100002>
					<cfset showHeader = 1>
				</cfif>
			</cfoutput>
			<cfif showHeader eq 1>
				<tr bgcolor="##dadada">
					<td colspan="6"><strong>#q_reviewQueue.FormObjectLabel#</strong></td>
				</tr>
			</cfif>
			<cfoutput>
			<!--- get all Versions --->
			<cfset q_Versions = ReviewQueue.getVersions(parentid=#q_reviewQueue.parentid#,formobjectitemid=#q_reviewQueue.formobjectitemid#)>
			<!--- don't show this row if the only version is published --->
			<cfif q_Versions.recordcount gt 1 OR q_Versions.versionstatusid neq 100002>
				<!--- if just updated status or owner for one of these versions, you'll want the updated version to be selected--->
				<cfif UpdatedVersion neq 0 AND ListFind(Valuelist(q_Versions.versionid),UpdatedVersion)>
					<cfset SelectedRow = ListFind(ValueList(q_Versions.versionid),UpdatedVersion)>
						<cfset variables.versionid = UpdatedVersion>				
						<cfset variables.colorcode = q_Versions.colorcode[SelectedRow]>
						<cfset variables.versionstatus = q_Versions.versionstatus[SelectedRow]>
						<cfset variables.versionstatusid = q_Versions.versionstatusid[SelectedRow]>
						<cfset variables.ownerfirstname = q_Versions.ownerFirstName[SelectedRow]>
						<cfset variables.ownerlastname = q_Versions.ownerLastName[SelectedRow]>
						<cfset variables.ownerinitials = q_Versions.ownerInitials[SelectedRow]>
						<cfset variables.datemodified = q_Versions.datemodified[SelectedRow]>
						<cfset variables.formobjectid = q_Versions.formobjectitemid[SelectedRow]>
						<cfset variables.instanceitemid = q_Versions.instanceitemid[SelectedRow]>
				<cfelse>
					<!--- set default values for this row (first version): only need to change these if first version in query is live (live versions won't display)--->
					<cfset variables.versionid = q_Versions.versionid>
					<cfset variables.colorcode = q_Versions.colorcode>
					<cfset variables.versionstatus = q_Versions.versionstatus>
					<cfset variables.versionstatusid = q_Versions.versionstatusid>
					<cfset variables.ownerfirstname = q_Versions.ownerFirstName>
					<cfset variables.ownerlastname = q_Versions.ownerLastName>
					<cfset variables.ownerinitials = q_Versions.ownerInitials>
					<cfset variables.datemodified = q_Versions.datemodified>
					<cfset variables.formobjectid = q_Versions.formobjectitemid>
					<cfset variables.instanceitemid = q_Versions.instanceitemid>
					<!--- If the first version is live, get the values to display for the next version  --->
					<cfif q_Versions.versionstatusid eq 100002>
						<cfset variables.versionid = q_Versions.versionid[2]>					
						<cfset variables.colorcode = q_Versions.colorcode[2]>
						<cfset variables.versionstatus = q_Versions.versionstatus[2]>
						<cfset variables.versionstatusid = q_Versions.versionstatusid[2]>
						<cfset variables.ownerfirstname = q_Versions.ownerFirstName[2]>
						<cfset variables.ownerlastname = q_Versions.ownerLastName[2]>
						<cfset variables.ownerinitials = q_Versions.ownerInitials[2]>
						<cfset variables.datemodified = q_Versions.datemodified[2]>
						<cfset variables.formobjectid = q_Versions.formobjectitemid[2]>
						<cfset variables.instanceitemid = q_Versions.instanceitemid[2]>
					</cfif>
				</cfif>
				<cfset AccessPermissions = application.getPermissions("access",variables.formobjectid)>
				<!--- set permissions for displayed version --->
				<cfset canApprove=0>
				<cfset canReject=0>
				<cfset canPublish=0>
				<cfset canDelete=0>
				<cfset canEdit=0>
				<cfset canChangeOwner=0>
				<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#variables.instanceitemid#">
				<cfif q_reviewQueue.currentrow MOD 2><cfset rowbg="##cccccc"><cfelse><cfset rowbg="##dadada"></cfif>
				<tr bgcolor="#rowbg#">
					<td class="queueRow" id="editLink#q_reviewQueue.versionid#"><cfif AccessPermissions><a href="index.cfm?i3currenttool=#q_reviewQueue.formobjectitemid#&instanceid=#q_reviewQueue.instanceitemid#&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0"/></a></cfif></td>
					<cfset formname="status#q_reviewQueue.versionid#">
					<form method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;" action="#request.page#" name="#formname#">
						<cfif isDefined("url.sortBy")><input type="hidden" name="sortBy" value="#url.sortBy#"></cfif>
						<cfif isDefined("url.viewall")><input type="hidden" name="viewall" value="#url.viewall#"></cfif>
						<input type="Hidden" id="formobject" name="formobject" value="#q_reviewQueue.formobjectitemid#">
						<input type="Hidden" id="parentid" name="parentid" value="#q_reviewQueue.parentid#">
						<input type="Hidden" id="pageview" name="pageview" value="homepage">
						<input type="Hidden" id="canAccess" name="canAccess" value="#AccessPermissions#">
						<input type="Hidden" id="allversionids" name="allversionids" value="#ValueList(q_reviewQueue.versionid)#">
					<td>
				<cfloop query="q_Versions">
					<!--- get permissions for each version --->
					<cfset canApprove=0>
					<cfset canReject=0>
					<cfset canPublish=0>
					<cfset canDelete=0>
					<cfset canEdit=0>
					<cfset canChangeOwner=0>
					<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#q_Versions.instanceitemid#">
					<!--- don't show live items --->
					<cfif q_Versions.versionstatusid neq 100002>
					<input type="hidden" id="#q_Versions.versionid#_status" name="#q_Versions.versionid#_status" value="#q_Versions.versionstatus#"/>
					<input type="hidden" id="#q_Versions.versionid#_colorcode" name="#q_Versions.versionid#_colorcode" value="#q_Versions.colorcode#"/>
					<input type="hidden" id="#q_Versions.versionid#_versionstatusid" name="#q_Versions.versionid#_versionstatusid" value="#q_Versions.versionstatusid#"/>
					<input type="hidden" id="#q_Versions.versionid#_ownerfirstname" name="#q_Versions.versionid#_ownerfirstname" value="#q_Versions.ownerfirstname#"/>
					<input type="hidden" id="#q_Versions.versionid#_ownerlastname" name="#q_Versions.versionid#_ownerlastname" value="#q_Versions.ownerlastname#"/>
					<input type="hidden" id="#q_Versions.versionid#_ownerinitials" name="#q_Versions.versionid#_ownerinitials" value="#q_Versions.ownerinitials#"/>
					<input type="hidden" id="#q_Versions.versionid#_datemodified" name="#q_Versions.versionid#_datemodified" value="#DateFormat(q_Versions.datemodified,'short')# #TimeFormat(q_Versions.datemodified, "short")#"/>
					<input type="hidden" id="#q_Versions.versionid#_instanceitemid" name="#q_Versions.versionid#_instanceitemid" value="#q_Versions.instanceitemid#"/>
					<input type="hidden" id="#q_Versions.versionid#_canEdit" name="#q_Versions.versionid#_canEdit" value="#canEdit#"/>
					<input type="hidden" id="#q_Versions.versionid#_canPublish" name="#q_Versions.versionid#_canPublish" value="#canPublish#"/>
					<input type="hidden" id="#q_Versions.versionid#_canReject" name="#q_Versions.versionid#_canReject" value="#canReject#"/>
					<input type="hidden" id="#q_Versions.versionid#_canApprove" name="#q_Versions.versionid#_canApprove" value="#canApprove#"/>
					<input type="hidden" id="#q_Versions.versionid#_isOwner" name="#q_Versions.versionid#_isOwner" value="#isOwner#"/>
					<input type="hidden" id="#q_Versions.versionid#_isSupervisor" name="#q_Versions.versionid#_isSupervisor" value="#isSupervisor#"/>
					</cfif>
				</cfloop>
				<!--- reset permissions for displayed version --->
				<cfset canApprove=0>
				<cfset canReject=0>
				<cfset canPublish=0>
				<cfset canDelete=0>
				<cfset canEdit=0>
				<cfset canChangeOwner=0>
				<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#variables.formobjectid#" instanceid="#variables.instanceitemid#">
						<select name="versionid" style="font-size: 9px;" onchange="javascript:updateRowVersion('#q_reviewQueue.versionid#',this.value);">
						<cfloop query="q_Versions">
						<!--- don't show live items --->
							<cfif q_Versions.versionstatusid neq 100002>
								<option value="#q_Versions.versionid#" style="color: #q_Versions.colorcode#; background-color: white;"<cfif q_Versions.versionid eq variables.versionid> selected</cfif>>#Left(q_Versions.label,50)# #q_Versions.version#</option>
							</cfif>
						</cfloop>
						</select>
					</td>
					<td id="statusCol#q_reviewQueue.versionid#" bgcolor="#variables.colorcode#" class="versionColorCell">
							<!--- only allow them to update status if have permissions to edit this form object--->
							<select id="versionstatusid#q_reviewQueue.versionid#" name="versionstatusid" style="font-size: 9px;" onchange="javascript:reAssign('#formname#','status');"<cfif NOT canEdit> disabled</cfif>>
								<cfloop query="q_Status">
									<option value="#q_Status.versionstatusid#" style="color: #q_Status.colorcode# ; background-color: white;"<cfif variables.versionstatusid eq q_Status.versionstatusid> selected</cfif>>#q_Status.status#</option>
								</cfloop>
							</select>
					</td>
					</form>
					<td id="owner#q_reviewQueue.versionid#"><a href="javascript: void(0);" title="#variables.ownerfirstname# #variables.ownerlastname#" class="nottalink">#ucase(variables.ownerinitials)#</a></td>				
					<td class="queueRow" id="datemodified#q_reviewQueue.versionid#">#dateFormat(variables.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(variables.datemodified, 'h:mm tt')#</td>
				</tr>
			</cfif>
			</cfoutput>
		</cfoutput>
		<cfelse>
			<cfoutput>
				<tr bgcolor="##dadada">
					<td colspan="6">There are currently no items for you to review in your personal queue. <br>You can <a href="index.cfm?i3currenttool=#application.tool.version#&viewall=yes" style="text-decoration:underline;">view all items</a> in the master queue.</td>
				</tr>
			</cfoutput>
		</cfif>
		</table>
<cfset q_reviewQueue = ReviewQueue.getAllContentElements(instanceid=#varInstanceid#,viewall=#varViewall#,sortBy=#varSortby#,statusFilter=#varStatusFilter#,viewByStatus=#varViewByStatus#)>
<div id="socketformheader"><h2>Version Inventory</h2></div><div style="clear:both;"></div>
<table id="socketindextable" border="0" cellpadding="0" cellspacing="0">
<tr>
	<td colspan="9">
	<cfoutput>
	<cfif isDefined("url.viewall")>
		<a href="#request.page#?viewByStatus=yes<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Show My Content</a>
	<cfelse>
		<a href="#request.page#?viewall=yes&viewByStatus=yes<cfif isDefined('url.sortBy')>&sortBy=#url.sortBy#</cfif>">Show Everyone's Content</a>
	</cfif>
	 | <a href="#request.page#">Condensed View</a>
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
		<td colspan="2" class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=status<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'statusasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Status</strong></a> <select name="statusFilter" style="font-size: 10px;" onchange="window.location='#SCRIPT_NAME#?viewByStatus=yes&<cfif find('&statusFilter', QUERY_STRING)>#left(QUERY_STRING, find('&statusFilter', QUERY_STRING))#<cfelse>#QUERY_STRING#</cfif>&statusFilter='+this.value;"><option value='' <cfif isDefined('url.statusFilter')><cfif url.statusFilter EQ 0>selected</cfif></cfif>>All</option><cfloop query="q_Status"><option value='#q_Status.versionstatusid#' style="color: white; background-color: #q_Status.colorcode#" <cfif isDefined('url.statusFilter')><cfif url.statusFilter EQ q_Status.versionstatusid>selected</cfif></cfif>>#q_Status.status#</option></cfloop></select></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=label<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'labelasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Name</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=version<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'versionasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Version</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=creatorInitials<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'creatorInitialsasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Creator</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=ownerInitials<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'ownerInitialsasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Owner</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=supervisorInitials<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'supervisorInitialsasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Supervisor</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=datecreated<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'datecreatedasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Created</strong></a></td>
		<td class="formiteminput"><a href="#request.page#?viewByStatus=yes&sortBy=datemodified<cfif isDefined('url.sortBy')><cfif url.sortBy EQ 'datemodifiedasc'>desc<cfelse>asc</cfif><cfelse>asc</cfif><cfif isDefined('url.statusFilter')>&statusFilter=#url.statusFilter#</cfif><cfif isDefined('url.viewall')>&viewall=yes</cfif>"><strong>Modified</strong></a></td>
		</cfoutput>
	</tr>
	<cfoutput query="q_reviewQueue" group="FormObjectLabel">
		<!--- get all possible owners for elements of this formobject--->
		<cfset q_userNames = ReviewQueue.q_getUsers(formobjectid=#q_reviewQueue.formobjectitemid#, versionsupid=#q_reviewQueue.supervisorid#)>
		<tr class="evenrow">
			<td colspan="9"><strong>#q_reviewQueue.FormObjectLabel#</strong></td>
		</tr>
		<cfoutput>
		<!--- check to see if can access version mgt (can delete ANY instance) --->
		<cfset q_Versions = ReviewQueue.getVersions(parentid=#q_reviewQueue.parentid#,formobjectitemid=#q_reviewQueue.formobjectitemid#,getPublished=1)>
		<cfset canAccessVersionMgt=0>
		<cfloop query="q_Versions">
			<cfset canDelete=0>
			<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#q_reviewQueue.formobjectitemid#" instanceid="#q_Versions.instanceitemid#">
			<cfif canDelete>
				<cfset canAccessVersionMgt=1>
			</cfif>
		</cfloop>
		
		<cfset AccessPermissions = application.getPermissions("access",q_reviewQueue.formobjectitemid)>
		<cfset canApprove=0>
		<cfset canReject=0>
		<cfset canPublish=0>
		<cfset canDelete=0>
		<cfset canEdit=0>
		<cfset canChangeOwner=0>
		<cfmodule template="#application.customTagPath#/versionStatusPerms.cfm" userid="#session.user.id#" formobjectid="#q_reviewQueue.formobjectitemid#" instanceid="#q_reviewQueue.instanceitemid#">
		<cfif q_reviewQueue.currentrow MOD 2><cfset rowclass="oddrow"><cfelse><cfset rowclass="evenrow"></cfif>
		<tr class="#rowclass#">
			<td class="queueRow"><cfif AccessPermissions><a href="index.cfm?i3currenttool=#q_reviewQueue.formobjectitemid#&instanceid=#q_reviewQueue.instanceitemid#&displayForm=1&formstep=showform&reviewQueue=yes" class="littleLink"><img src="#application.globalPath#/media/images/icon_editVersion.gif" border="0" title="edit" /></a></cfif><cfif canAccessVersionMgt> <a href="#request.page#?manageVersions=yes&parentid=#q_reviewQueue.parentid#&formobjectid=#q_reviewQueue.formobjectitemid#"><img src="#application.globalPath#/media/images/icon_manageVersions.gif" border="0" title="version management" /></a></cfif>
			</td>
			<cfset formname="owner#q_reviewQueue.versionid#">
			<form method="post" style="margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px; page-break-before: avoid; page-break-after: avoid;" action="#request.page#" name="#formname#">
			<cfif isDefined("url.sortBy")><input type="hidden" name="sortBy" value="#url.sortBy#"></cfif>
			<cfif isDefined("url.viewall")><input type="hidden" name="viewall" value="#url.viewall#"></cfif>
			<cfif isDefined("url.viewByStatus")><input type="hidden" name="viewByStatus" value="#url.viewByStatus#"></cfif>
			<input type="Hidden" name="versionid" value="#q_reviewQueue.versionid#">
			<input type="Hidden" name="formobject" value="#q_reviewQueue.formobjectitemid#">
			<input type="Hidden" name="parentid" value="#q_reviewQueue.parentid#">
			<input type="Hidden" id="pageview" name="pageview" value="reviewqueue">
			<input type="hidden" id="#q_reviewQueue.versionid#_canPublish" name="#q_reviewQueue.versionid#_canPublish" value="#canPublish#"/>
			<input type="hidden" id="#q_reviewQueue.versionid#_canReject" name="#q_reviewQueue.versionid#_canReject" value="#canReject#"/>
			<input type="hidden" id="#q_reviewQueue.versionid#_canApprove" name="#q_reviewQueue.versionid#_canApprove" value="#canApprove#"/>
			<input type="hidden" id="#q_reviewQueue.versionid#_isOwner" name="#q_reviewQueue.versionid#_isOwner" value="#isOwner#"/>
			<input type="hidden" id="#q_reviewQueue.versionid#_isSupervisor" name="#q_reviewQueue.versionid#_isSupervisor" value="#isSupervisor#"/>
			<td bgcolor="#q_reviewQueue.colorcode#" class="versionColorCell">
			<!--- not sure why i need this variable outside loop but won't work with q_reviewQueue.versionid--->
			<cfset thisVersionStatus = q_reviewQueue.versionstatusid>
				<!--- only allow them to update status if have permissions to edit this form object--->
				<select id="versionstatusid#q_reviewQueue.versionid#" name="versionstatusid" style="font-size: 9px;" onchange="javascript:reAssign('#formname#','status');"<cfif NOT canEdit> disabled</cfif>>
					<cfloop query="q_Status">
						<option value="#q_Status.versionstatusid#" style="color: #q_Status.colorcode#; background-color: white;"<cfif thisVersionStatus eq q_Status.versionstatusid> selected</cfif>>#q_Status.status# </option>
					</cfloop>
				</select>
			</td>
			<td width="200">#Left(q_reviewQueue.label,75)#</td>
			<td class="queueRow">#q_reviewQueue.version#</td>
			<td><a href="javascript: void(0)" title="#q_reviewQueue.creatorFirstName# #q_reviewQueue.creatorLastName#" class="nottalink">#ucase(q_reviewQueue.creatorInitials)#</a></td>
			<td>
			<select name="ownerid" style="font-size: 10px;" onchange="javascript:reAssign('#formname#','owner');"<cfif NOT canChangeOwner> disabled</cfif>>
			<cfset thisOwner=q_reviewQueue.ownerInitials>
				<cfloop query="q_userNames">
					<option value="#q_userNames.usersid#" title="#q_reviewQueue.supervisorFirstName# #q_reviewQueue.supervisorLastName#"<cfif q_userNames.initials eq thisOwner> SELECTED</cfif>>#ucase(q_userNames.initials)#</option>
				</cfloop>
			</select>
			</td>
			</form>
			<td><a href="javascript: void(0)" title="#q_reviewQueue.supervisorFirstName# #q_reviewQueue.supervisorLastName#" class="nottalink">#ucase(q_reviewQueue.supervisorInitials)#</a></td>
			
			<td class="queueRow">#dateFormat(q_reviewQueue.datecreated, 'MM/DD/YY')#&nbsp;#timeFormat(q_reviewQueue.datecreated, 'h:mm tt')#</td>
			<td class="queueRow">#dateFormat(q_reviewQueue.datemodified, 'MM/DD/YY')#&nbsp;#timeFormat(q_reviewQueue.datemodified, 'h:mm tt')#</td>
		</tr>
		</cfoutput>
</cfoutput>
</table></td></tr></table>
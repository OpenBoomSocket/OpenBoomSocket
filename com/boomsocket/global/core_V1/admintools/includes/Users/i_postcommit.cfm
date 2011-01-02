<!--- i_postcommit.cfm --->
<script type="text/javascript">
function checkSection(arrayName){
	for(i=0;i<arrayName.length;i++){
		eval('document.userpermission.access'+arrayName[i]).checked = true;
		eval('document.userpermission.addEdit'+arrayName[i]).checked = true;
		eval('document.userpermission.remove'+arrayName[i]).checked = true;
	}
}
function uncheckSection(arrayName){
	for(i=0;i<arrayName.length;i++){
		eval('document.userpermission.access'+arrayName[i]).checked = false;
		eval('document.userpermission.addEdit'+arrayName[i]).checked = false;
		eval('document.userpermission.remove'+arrayName[i]).checked = false;
	}
}
</script>
<cfif isDefined("deleteinstance")>
<!--- Remove all references to this user in other tables --->
	<cfmodule template="#application.customTagPath#/dbaction.cfm"
			tablename="userpermission"
			datasource="#application.datasource#"
			action="DELETE"
			whereclause="userid IN (#deleteinstance#)">
	<cfmodule template="#application.customTagPath#/dbaction.cfm"
			tablename="supervisorRelationship"
			datasource="#application.datasource#"
			action="DELETE"
			whereclause="userid IN (#deleteinstance#)">
	<cfmodule template="#application.customTagPath#/dbaction.cfm"
			tablename="users_sections"
			datasource="#application.datasource#"
			action="DELETE"
			whereclause="userid IN (#deleteinstance#)">
	<cftransaction>
	<!--- if the site sup is in the delete list, set DP as the new site sup--->
	<cfquery datasource="#application.datasource#" name="q_getSiteSupervisor" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT TOP 1 supervisorid
		FROM sitesettings
	</cfquery>
	<cfset variables.siteSupervisorid = q_getSiteSupervisor.supervisorid>
	<cfif NOT isNumeric(q_getSiteSupervisor.supervisorid) OR ListFind(deleteinstance,q_getSiteSupervisor.supervisorid)>
		<cfquery datasource="#application.datasource#" name="q_changeSupervisors" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			UPDATE sitesettings
			SET supervisorid= 100000
		</cfquery>
		<cfset variables.siteSupervisorid = 100000>
	</cfif>
		<cfloop list="#deleteinstance#" index="i">	
			<!--- change supervisorid to the uberuser supervisorid --->
			<cfquery datasource="#application.datasource#" name="q_getSupervisedVersions" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT versionid,ownerid,supervisorid
				FROM version
				WHERE supervisorid = #i#
			</cfquery>	
			<cfquery datasource="#application.datasource#" name="q_changeSupervisors" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				UPDATE supervisorRelationship
				SET supervisorid= #variables.siteSupervisorid#
				WHERE supervisorid = #i#
			</cfquery>
			<cfloop query="q_getSupervisedVersions">
				<cfquery datasource="#application.datasource#" name="q_changeOwnership" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE version
					SET supervisorid= #variables.siteSupervisorid#
					WHERE versionid = #q_getSupervisedVersions.versionid#
				</cfquery>	
			</cfloop>
			<!--- change ownerid to their supervisorid --->
			<cfquery datasource="#application.datasource#" name="q_getOwnedVersions" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT versionid,ownerid,supervisorid
				FROM version
				WHERE ownerid = #i#
			</cfquery>	
			<cfloop query="q_getOwnedVersions">
				<!--- if they are their own supervisor or their supervisor is also being deleted, set new owner as main site supervisor --->
				<cfset variables.newOwnerid = q_getOwnedVersions.supervisorid>
				<cfif q_getOwnedVersions.supervisorid eq i OR ListFind(deleteinstance,q_getOwnedVersions.supervisorid)>
					<cfset variables.newOwnerid = variables.siteSupervisorid>
				</cfif>
				<cfquery datasource="#application.datasource#" name="q_changeOwnership" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE version
					SET ownerid= #variables.newOwnerid#
					WHERE versionid = #q_getOwnedVersions.versionid#
				</cfquery>	
			</cfloop>
			<!--- change creatorid to their supervisorid --->
			<cfquery datasource="#application.datasource#" name="q_getCreatedVersions" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT versionid,ownerid,supervisorid
				FROM version
				WHERE creatorid = #i#
			</cfquery>	
			<cfloop query="q_getCreatedVersions">
				<!--- if they are their own supervisor or their supervisor is also being deleted, set new creator as main site supervisor  --->
				<cfset variables.newCreatorid = q_getCreatedVersions.supervisorid>
				<cfif q_getCreatedVersions.supervisorid eq i OR ListFind(deleteinstance,q_getCreatedVersions.supervisorid)>
					<cfset variables.newCreatorid = variables.siteSupervisorid>
				</cfif>
				<cfquery datasource="#application.datasource#" name="q_changeOwnership" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE version
					SET creatorid= #variables.newCreatorid#
					WHERE versionid IN (#q_getCreatedVersions.versionid#)
				</cfquery>	
			</cfloop>
		</cfloop>	
	</cftransaction>
<!--- **************** THIS IS ADDING SPECIFIC USER PERMS ******************* --->
<cfelse>
	<cfparam name="mode" default="listOptions">
	<cfswitch expression="#mode#">
	<cfcase value="listOptions">
		<cfif isDefined("insertid")>
			<cfset form.usersid=insertid>
		<cfelse>
			<cfset form.usersid=instanceid>
		</cfif>
			<cfquery name="q_getFormObjects" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT		formobject.formobjectid, formobject.label, toolcategory.toolcategoryname,toolcategory.toolcategoryid
			FROM		formobject INNER JOIN toolcategory ON formobject.toolcategoryid = toolcategory.toolcategoryid
			WHERE		(formobject.formobjectid = formobject.parentid)
			ORDER BY	toolcategory.ordinal,toolcategory.toolcategoryname, formobject.label
			</cfquery>
		<form name="userpermission" method="post" action="includes/users/i_postcommit.cfm">
		<input type="hidden" name="mode" value="SavePermissions">
		<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep">
		<table cellpadding="3" cellspacing="1" border="0" style="margin:15px;" width="400">
		<tr class="columnheaderrow">
			<td>&nbsp;</td>
			<td>Access</td>
			<td>Add/Edit</td>
			<td>Delete</td>
		</tr>
			<cfset jID = 0>
			<cfoutput query="q_getFormObjects" group="toolcategoryname">
				<cfset showToolCategoryName=1>
				<cfset jID = jID + 1>
				<script type="text/javascript">
					var array#jID# = new Array();
				</script>
				<cfset jArrayIndex = 0>
<cfoutput>
	<script type="text/javascript">
		array#jID#[#jArrayIndex#] = #q_getFormObjects.formobjectid#;
	</script>
	<cfset jArrayIndex = jArrayIndex + 1>
<input type="hidden" name="objectlist" value="#q_getFormObjects.formobjectid#">
			<cfset thisAccessPermission = application.getPermissions("access", #q_getFormObjects.formobjectid#)>
			<cfset thisAddEditPermission = application.getPermissions("addEdit", #q_getFormObjects.formobjectid#)>
			<cfset thisRemovePermission = application.getPermissions("remove", #q_getFormObjects.formobjectid#)>
			<cfif thisAccessPermission EQ 1 OR session.user.accessLevel EQ 1>
				<cfif showToolCategoryName>
							<cfif q_getFormObjects.toolcategoryid EQ 100001>
								<cfif session.user.id eq 100000>
									<tr><td class="categoryrowheader" style="PADDING-BOTTOM: 2px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 2px" colspan=4><table cellpadding="0" cellspacing="0" border="0" width=100%><tr><td style="PADDING-BOTTOM: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; PADDING-TOP: 0px">#q_getFormObjects.toolcategoryname#</td><td align=right><a href="javascript:void(0);" onclick="window.status='Check All'; checkSection(array#jID#);" onmouseover="window.status='Check All'; return true;" onmouseout="window.status='Done'; return true;">Check</a> / <a href="javascript:void(0);" onclick="window.status='Uncheck All'; uncheckSection(array#jID#);" onmouseover="window.status='Uncheck All'; return true;" onmouseout="window.status='Done'; return true;">Uncheck</a></td></tr></table></td></tr>
								</cfif>
							<cfelse>
								<tr><td class="categoryrowheader" style="PADDING-BOTTOM: 2px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 2px" colspan=4><table cellpadding="0" cellspacing="0" border="0" width=100%><tr><td style="PADDING-BOTTOM: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; PADDING-TOP: 0px">#q_getFormObjects.toolcategoryname#</td><td align=right><a href="javascript:void(0);" onclick="window.status='Check All'; checkSection(array#jID#);" onmouseover="window.status='Check All'; return true;" onmouseout="window.status='Done'; return true;">Check</a> / <a href="javascript:void(0);" onclick="window.status='Uncheck All'; uncheckSection(array#jID#);" onmouseover="window.status='Uncheck All'; return true;" onmouseout="window.status='Done'; return true;">Uncheck</a></td></tr></table></td></tr>
							</cfif>
				<cfset showToolCategoryName=0>
				</cfif>
				<cfset newUserTypeID = #ListFirst(form.usertypeid,"~")#>
				<!---See if this is a new user or current user.  New users should get the permission settings of the usertype selected, 
					  current users get the permission settings that have already been set up--->
				<!---There is no userid, so get the usertype settings--->
				<cfif #LEN(form.usersid)# EQ 0>
					<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					SELECT usertypepermission.access, 
					usertypepermission.addEdit, usertypepermission.remove
					FROM  usertypepermission 
					WHERE usertypeid=#newUserTypeID# AND formobjectid=#q_getFormObjects.formobjectid#
					</cfquery>
						<cfif q_geFormObjectPermissions.RecordCount EQ 0>
							<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
								SELECT usertypepermission.access, 
								usertypepermission.addEdit, usertypepermission.remove
								FROM  usertypepermission 
								WHERE usertypeid=#newUserTypeID# AND formobjectid=#q_getFormObjects.formobjectid#
							</cfquery>				
						</cfif>
				<!---There is a userid, so NOW check to see if the usertype has changed--->	
				<cfelseif #LEN(form.usersid)# GT 0>
					<cfquery name="q_getCurrentUserTypeId" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					SELECT usertypeid
					FROM Users
					WHERE usersid=#form.usersid#
					</cfquery>
					<!---It has not changed, so get the user settings--->
					
					<cfif #newUserTypeID# EQ #q_getCurrentUserTypeId.usertypeid#>
						<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						SELECT userpermission.access, 
						userpermission.addEdit, userpermission.remove
						FROM  userpermission 
						WHERE userid=#form.usersid# AND formobjectid=#q_getFormObjects.formobjectid#
						</cfquery>
						<cfif q_geFormObjectPermissions.RecordCount EQ 0>
							<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
								SELECT usertypepermission.access, 
								usertypepermission.addEdit, usertypepermission.remove
								FROM  usertypepermission 
								WHERE usertypeid=#newUserTypeID# AND formobjectid=#q_getFormObjects.formobjectid#
							</cfquery>				
						</cfif>
					<!---It HAS changed, so get the usertype settings of the new usertype--->
					<cfelse>
						<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						SELECT usertypepermission.access, 
						usertypepermission.addEdit, usertypepermission.remove
						FROM  usertypepermission 
						WHERE usertypeid=#newUserTypeID# AND formobjectid=#q_getFormObjects.formobjectid#
						</cfquery>
					</cfif>
				</cfif>
				 <cfif q_getFormObjects.currentrow MOD 2>
				 	<cfset rowClass="evenrow">
				<cfelse>
					<cfset rowClass="oddrow">
				</cfif>
				<input type="hidden" name="objectidList" value="#q_getFormObjects.formobjectid#">
				<tr class="#rowClass#">
					<td>&nbsp;#q_getFormObjects.label#&nbsp;</td>
					<td align="center"><input type="checkbox" name="access#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.access EQ 1>checked</cfif> <cfif #session.user.accessLevel# NEQ 1 AND thisAccessPermission EQ 0>disabled</cfif>></td>
					<td align="center"><input type="checkbox" name="addEdit#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.addEdit EQ 1>checked</cfif> <cfif #session.user.accessLevel# NEQ 1 AND thisAddEditPermission EQ 0>disabled</cfif>></td>
					<td align="center"><input type="checkbox" name="remove#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.remove EQ 1>checked</cfif> <cfif #session.user.accessLevel# NEQ 1 AND thisRemovePermission EQ 0>disabled</cfif>></td>
				</tr>
			</cfif>
</cfoutput>
			</cfoutput>
			
					<cfset request.stopprocess = "postcommit">
		<tr>
			<td colspan="5" align="center"><input type="submit" value="Save User Permissions" class="submitbutton"></td>
		</tr>
		</table>
		<input type="hidden" value="postcommit" name="formstep">
		</form>
		
	</cfcase>
	<cfcase value="SavePermissions">
		<cfset thisUserID=form.usersid>
		<!---Loop through the list of formobjectids--->
		<cfset objectidList = #form.objectidList#>
		<cfset objectidArray = ListToArray(#form.objectidList#)>
		<cfloop index="i" from="1" to="#ListLen(form.objectidList)#">
			<!---Set the access, addEdit, approve, and remove for this formobjectid--->
			<cfset thisAccess = "form.access" & #objectidArray[i]#>
			<cfif isDefined(thisAccess)>
				<cfset thisAccess = #evaluate('form.access' & objectidArray[i])#>
			<cfelse>
				<cfset thisAccess = 0>
			</cfif>
			<cfset thisAddEdit = "form.addEdit" & #objectidArray[i]#>
			<cfif isDefined(thisAddEdit)>
				<cfset thisAddEdit = #evaluate('form.addEdit' & objectidArray[i])#>
			<cfelse>
				<cfset thisAddEdit = 0>
			</cfif>
			<cfset thisRemove= "form.remove" & #objectidArray[i]#>
			<cfif isDefined(thisRemove)>
				<cfset thisRemove = #evaluate('form.remove' & objectidArray[i])#>
			<cfelse>
				<cfset thisRemove = 0>
			</cfif>
			<!---Check to see if this is a new usertype or an update of an existing usertype by checking the length of the form element "usertypeid"--->
			<!---If the length is 0, it is a new usertype, so insert the values into the usertypepermission table--->
			<cfif #LEN(form.usersid)# EQ 0>
				<cfquery name="q_insertUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				INSERT INTO userpermission
				(userid, formobjectid, access, addEdit, remove)
				VALUES
				(#thisUserID#, #objectidArray[i]#, #thisAccess#, #thisAddEdit#, #thisRemove#)
				</cfquery>
			<!---the length is not 0, so it exists--->
			<cfelse>
				<!---Check to see if an entry exists for this formobjectid/usertypeid permission--->
				<cfquery name="q_checkUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT COUNT(*) as UTPCount
				FROM userpermission
				WHERE userid = #form.usersid# AND formobjectid = #objectidArray[i]#
				</cfquery>
				<!---if the count is greater than 0, update the row with the new information, otherwise a new insert is needed--->
				<!---The count is zero, insert a new record--->
				<cfif q_checkUserPermission.UTPCount EQ 0>
					<cfquery name="q_insertUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					INSERT INTO userpermission
					(userid, formobjectid, access, addEdit, remove)
					VALUES
					(#form.usersid#, #objectidArray[i]#, #thisAccess#, #thisAddEdit#, #thisRemove#)
					</cfquery>
				<!---The count is greater than zero, update the record--->
				<cfelseif q_checkUserPermission.UTPCount GT 0>
					<cfquery name="q_updatetUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE userpermission
					SET access = #thisAccess#, addEdit = #thisAddEdit#, remove = #thisRemove#
					WHERE userid = #form.usersid# AND formobjectid = #objectidArray[i]#
					</cfquery>
				</cfif>
			</cfif>	
		</cfloop>

		<!--- UPDATE rights to sections --->
		<cfquery name="q_deleteUserTypes_Sections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			DELETE FROM Users_Sections
			WHERE userid = #thisUserID#
		</cfquery>
		<cfloop list="#form.sitesectionid#" index="i">
			<cfquery name="q_insertUserTypes_Sections" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				INSERT INTO Users_Sections (userid, sitesectionid)
				VALUES (#thisUserID#, #ListFirst(i, "~")#)
			</cfquery>
		</cfloop>
		<cfset request.stopprocess = "">
		
		<!--- FORWARD USER ON TO THE SUPERVISOR TOOL --->
		<cfif NOT isDefined("instanceid") AND NOT isDefined("deleteinstance")>
			<cflocation addtoken="no" url="/admintools/index.cfm?i3CurrentTool=#application.tool.SupervisorRelationship#&SRStep=add&userid=#thisUserID#~#form.firstname#%20#form.lastname#">
		<cfelse>
			<cflocation addtoken="no" url="/admintools/index.cfm?i3CurrentTool=#session.i3currenttool#">
		</cfif>
		
		
	</cfcase>
	</cfswitch>
	
</cfif>

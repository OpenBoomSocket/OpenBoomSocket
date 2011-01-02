<!--- i_preshowform.cfm --->
<cfparam name="mode" default="selectTool">
<cfswitch expression="#mode#">
<cfcase value="selectTool">
	<cfif session.user.accessLevel EQ 1>
		<cfquery name="q_getFormObjects" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT    formobject.formobjectid, formobject.label
			FROM      formobject 
			WHERE     (formobject.formobjectid = formobject.parentid)
			ORDER BY formobject.label
		</cfquery>
	<cfelse>
		<cfquery name="q_getFormObjects" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT    formobject.formobjectid, formobject.label
			FROM      formobject INNER JOIN
					  userpermission ON formobject.formobjectid = userpermission.formobjectid
			WHERE     (formobject.formobjectid = formobject.parentid) AND 
						(userpermission.userid = #session.user.id#) AND
						(userpermission.access = 1)
			ORDER BY formobject.label
		</cfquery>
	</cfif>
	<form name="selectTool" action="#request.page#" method="post">
	<input type="hidden" name="mode" value="setPermissions">
	<table cellpadding="3" cellspacing="1" border="0" width="550" class="toolTable">
	<tr>
		<td colspan="2" class="toolheader">Admin Tool Permissions</td>
	</tr>
	<tr>
		<td class="formitemlabelreq">Admin Tool</td>
		<td class="formiteminput"><select name="formformtoolid">
		<option value="">Select-----</option>
			<cfoutput query="q_getFormObjects">
			<option value="#q_getFormObjects.formobjectid#~#q_getFormObjects.label#">#q_getFormObjects.label#</option>
			</cfoutput>
		</select>
		</td>
	</tr>
	<tr>
		<td colspan="2" align="center" class="formiteminput"><input type="submit" value="Edit Tool Permissions" class="submitbutton"></td>
	</tr>
	</table>
	</form>
</cfcase>
<cfcase value="setPermissions">
	<cfoutput>
	<!--- Where clause was >= changed to just > since we don't want them giving themselves stuff they shouldn't --->
	<cfquery name="q_getUserTypes" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT usertype.usertypeid, usertype.usertypename, roleid
	FROM usertype
	<cfif session.user.accessLevel NEQ 1>
		WHERE roleid > #session.user.accessLevel#
	</cfif>
	ORDER BY usertypename
	</cfquery>
	<p class="instructionText"><b>Assigns Tool Permissions To User Types for <i>#listLast(form.formformtoolid,"~")#</i></b></p>
	<form name="usertypepermission" method="post">
	<input type="hidden" name="mode" value="SavePermissions">
	<input type="hidden" name="formtoolid" value="#listFirst(form.formformtoolid,"~")#">
	<table cellpadding="3" cellspacing="1" border="0" width="550">
	<tr>
		<td colspan="5" class="toolheader">Admin Tool Permissions</td>
	</tr>
	<tr class="subtoolheader">
		<td>&nbsp;</td>
		<td>Access</td>
		<td>Add/Edit</td>
		<td>Delete</td>
	</tr>
	<cfloop query="q_getUserTypes">
	<tr <cfif q_getUserTypes.currentrow MOD 2>bgcolor="##cccccc"<cfelse>bgcolor="##dadada"</cfif>>
	<input type="hidden" name="userTypeIdList" value="#q_getUserTypes.usertypeid#">
	<!---Get the permission for this usertype if they have been set--->
		<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT usertypepermission.access, 
		usertypepermission.addEdit, usertypepermission.remove
		FROM  usertypepermission 
		WHERE usertypeid=#q_getUserTypes.usertypeid# AND formobjectid=#ListFirst(form.formformtoolid, "~")#
		</cfquery>
		<!---Check the recordcount, if it's equal to zero, there are no permissions set--->
		<cfif #q_geFormObjectPermissions.recordcount# EQ 0>
			<td><strong>#q_getUserTypes.usertypename#</strong></td>
			<td><input type="checkbox" name="access#q_getUserTypes.usertypeid#" value="1" <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
			<td><input type="checkbox" name="addEdit#q_getUserTypes.usertypeid#" value="1" <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
			<td><input type="checkbox" name="remove#q_getUserTypes.usertypeid#" value="1" <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
		<!---The recordcount is greater than 0, so Get permissions for this usertype--->
		<cfelseif #q_geFormObjectPermissions.recordcount# GT 0>
			<td><strong>#q_getUserTypes.usertypename#</strong></td>
			<td><input type="checkbox" name="access#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.access EQ 1>checked</cfif> <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
			<td><input type="checkbox" name="addEdit#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.addEdit EQ 1>checked</cfif> <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
			<td><input type="checkbox" name="remove#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.remove EQ 1>checked</cfif> <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>></td>
		</cfif>
	</tr>
	<tr <cfif q_getUserTypes.currentrow MOD 2>bgcolor="##cccccc"<cfelse>bgcolor="##dadada"</cfif>>
		<td>&nbsp;</td>
		<td colspan="4"><input type="checkbox" name="applyChangesToUsers#q_getUserTypes.usertypeid#" value="1" <cfif session.user.accessLevel GT 2 AND session.user.accessLevel GTE q_getUserTypes.roleid>disabled</cfif>> Apply to All Users of this Type</td>
	</tr>
	<cfif q_getUserTypes.currentrow NEQ q_getUserTypes.recordcount>
	<tr class="subtoolheader">
		<td>&nbsp;</td>
		<td>Access</td>
		<td>Add/Edit</td>
		<td>Delete</td>
	</tr>
	</cfif>
	</cfloop>
	<tr>
		<td colspan="5" align="center" class="formiteminput"><p><input type="submit" value="Save Tool Permissions" class="submitbutton"></p></td>
	</tr>
	</table>
	</form>
	</cfoutput>
</cfcase>
<cfcase value="SavePermissions">
	<!---Loop through the list of usertypeids--->
	<cfset usertypeidList = #form.userTypeIdList#>
	<cfset usertypeidArray = ListToArray(#form.userTypeIdList#)>
	<cfloop index="i" from="1" to="#ListLen(form.userTypeIdList)#">
		<!---Set the access, addEdit, approve, and remove for this usertypeid--->
		<cfset thisAccess = "form.access" & #usertypeidArray[i]#>
		<cfif isDefined(thisAccess)>
			<cfset thisAccess = #evaluate('form.access' & usertypeidArray[i])#>
		<cfelse>
			<cfset thisAccess = 0>
		</cfif>
		<cfset thisAddEdit = "form.addEdit" & #usertypeidArray[i]#>
		<cfif isDefined(thisAddEdit)>
			<cfset thisAddEdit = #evaluate('form.addEdit' & usertypeidArray[i])#>
		<cfelse>
			<cfset thisAddEdit = 0>
		</cfif>
		<cfset thisApprove = "form.approve" & #usertypeidArray[i]#>
		<cfif isDefined(thisApprove)>
			<cfset thisApprove = #evaluate('form.approve' & usertypeidArray[i])#>
		<cfelse>
			<cfset thisApprove = 0>
		</cfif>
		<cfset thisRemove= "form.remove" & #usertypeidArray[i]#>
		<cfif isDefined(thisRemove)>
			<cfset thisRemove = #evaluate('form.remove' & usertypeidArray[i])#>
		<cfelse>
			<cfset thisRemove = 0>
		</cfif>
		<cfset applyChangesToUsers= "form.applyChangesToUsers" & #usertypeidArray[i]#>
		<cfif isDefined(applyChangesToUsers)>
			<cfset applyChangesToUsers = #evaluate('form.applyChangesToUsers' & usertypeidArray[i])#>
		<cfelse>
			<cfset applyChangesToUsers = 0>
		</cfif>
		
		
		
		
		<!---Check to see if an entry exists for this formobjectid/usertypeid permission--->
		<cfquery name="q_checkUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT COUNT(*) as UTPCount
		FROM usertypepermission
		WHERE usertypeid = #usertypeidArray[i]# AND formobjectid = #ListFirst(form.formtoolid, "~")#
		</cfquery>
		<!---if the count is greater than 0, update the row with the new information, otherwise a new insert is needed--->
		<!---The count is zero, insert a new record--->
		<cfif q_checkUserTypePermission.UTPCount EQ 0>
			<cfquery name="q_insertUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			INSERT INTO usertypepermission
			(usertypeid, formobjectid, access, addEdit, approve, remove)
			VALUES
			(#usertypeidArray[i]#, #ListFirst(form.formtoolid, "~")#, #thisAccess#, #thisAddEdit#, #thisApprove#, #thisRemove#)
			</cfquery>
		<!---The count is greater than zero, update the record--->
		<cfelseif q_checkUserTypePermission.UTPCount GT 0>
			<cfquery name="q_updatetUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			UPDATE usertypepermission
			SET access = #thisAccess#, addEdit = #thisAddEdit#, approve = #thisApprove#, remove = #thisRemove#
			WHERE usertypeid = #usertypeidArray[i]# AND formobjectid = #ListFirst(form.formtoolid, "~")#
			</cfquery>
		</cfif>
	
		<!---If the applyChangesToUsers is set to yes (1), then get a list of users for this user type, loop 
		    through them and then either update or insert the change--->
		<cfif applyChangesToUsers EQ 1>
			<cfquery name="q_getUsers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT usersid
			FROM Users
			WHERE usertypeid = #usertypeidArray[i]#
			</cfquery>
			
			<!---Loop through the users and determine whether they already have permissions set--->
			
			<cfloop query="q_getUsers">
				<cfquery name="q_getUserPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT COUNT(*) AS UPCount
				FROM userpermission
				WHERE userid=#q_getUsers.usersid# AND formobjectid=#ListFirst(form.formtoolid, "~")#
				</cfquery>
				
				<!---no records, no permissions, so insert some--->
				<cfif q_getUserPermissions.UPCount EQ 0>
					<cfquery name="q_insertUserPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					INSERT INTO UserPermission
					(userid, formobjectid, access, addEdit, approve, remove)
					VALUES
					(#q_getUsers.usersid#, #ListFirst(form.formtoolid, "~")#, #thisAccess#, #thisAddEdit#, #thisApprove#, #thisRemove#)
					</cfquery>
				<!---There are records, so update them--->
				<cfelseif q_getUserPermissions.recordcount GT 0>
					<cfquery name="q_updatetUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE userpermission
					SET access = #thisAccess#, addEdit = #thisAddEdit#, approve = #thisApprove#, remove = #thisRemove#
					WHERE userid = #q_getUsers.usersid# AND formobjectid = #ListFirst(form.formtoolid, "~")#
					</cfquery>
				</cfif>
				
			</cfloop>
		</cfif>
	
	</cfloop>
	<cfset request.stopprocess = "commit">
	<cflocation url="#request.page#?formstep=showform" addtoken="No">
</cfcase>
</cfswitch>
<cfset request.stopprocess="showform">
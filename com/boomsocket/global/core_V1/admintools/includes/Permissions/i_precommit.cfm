<!--- i_precommit.cfm --->
<cfoutput>
is this thing on?
<cfparam name="mode" default="listOptions">
<cfswitch expression="#mode#">
<cfcase value="listOptions">
	<cfquery name="q_getUserTypes" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
	SELECT usertype.usertypeid, usertype.usertypename
	FROM usertype
	WHERE 1=1
	ORDER BY usertypename
	</cfquery>

	<p class="instructionText"><b>Assigns Tool Permissions To User Types for <i>#listLast(request.formtoolid,"~")#</i></b></p>
	<form name="usertypepermission" method="post">
	<input type="hidden" name="mode" value="SavePermissions">
	<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep">
	<table cellpadding="3" cellspacing="1" border="0" width="550">
	<tr>
		<td colspan="5" class="toolheader">Admin Tool Permissions</td>
	</tr>
	<tr class="subtoolheader">
		<td>&nbsp;</td>
		<td>Access</td>
		<td>Add/Edit</td>
		<td>Approve</td>
		<td>Delete</td>
	</tr>
	<cfloop query="q_getUserTypes">
	<tr <cfif q_getUserTypes.currentrow MOD 2>bgcolor="##cccccc"<cfelse>bgcolor="##dadada"</cfif>>
	<input type="hidden" name="userTypeIdList" value="#q_getUserTypes.usertypeid#">
	<!---Get the permission for this usertype if they have been set--->
		<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT usertypepermission.access, 
		usertypepermission.addEdit, usertypepermission.approve, usertypepermission.remove
		FROM  usertypepermission 
		WHERE usertypeid=#q_getUserTypes.usertypeid# AND formobjectid=#ListFirst(form.toolid, "~")#
		</cfquery>
		<!---Check the recordcount, if it's equal to zero, there are no permissions set--->
		<cfif #q_geFormObjectPermissions.recordcount# EQ 0>
			<td><strong>#q_getUserTypes.usertypename#</strong></td>
			<td><input type="checkbox" name="access#q_getUserTypes.usertypeid#" value="1"></td>
			<td><input type="checkbox" name="addEdit#q_getUserTypes.usertypeid#" value="1"></td>
			<td><input type="checkbox" name="approve#q_getUserTypes.usertypeid#" value="1"></td>
			<td><input type="checkbox" name="remove#q_getUserTypes.usertypeid#" value="1"></td>
		<!---The recordcount is greater than 0, so Get permissions for this usertype--->
		<cfelseif #q_geFormObjectPermissions.recordcount# GT 0>
			<td><strong>#q_getUserTypes.usertypename#</strong></td>
			<td><input type="checkbox" name="access#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.access EQ 1>checked</cfif>></td>
			<td><input type="checkbox" name="addEdit#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.addEdit EQ 1>checked</cfif>></td>
			<td><input type="checkbox" name="approve#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.approve EQ 1>checked</cfif>></td>
			<td><input type="checkbox" name="remove#q_getUserTypes.usertypeid#" value="1" <cfif q_geFormObjectPermissions.remove EQ 1>checked</cfif>></td>
		</cfif>
	</tr>
	<tr <cfif q_getUserTypes.currentrow MOD 2>bgcolor="##cccccc"<cfelse>bgcolor="##dadada"</cfif>>
		<td>&nbsp;</td>
		<td colspan="4"><input type="checkbox" name="applyChangesToUsers#q_getUserTypes.usertypeid#" value="1"> Apply to All Users of this Type</td>
	</tr>
	<cfif q_getUserTypes.currentrow NEQ q_getUserTypes.recordcount>
	<tr class="subtoolheader">
		<td>&nbsp;</td>
		<td>Access</td>
		<td>Add/Edit</td>
		<td>Approve</td>
		<td>Delete</td>
	</tr>
	</cfif>
	</cfloop>
	<tr>
		<td colspan="5" align="center"><p><input type="submit" value="Save Tool Permissions" class="submitbutton"></p></td>
	</tr>
	</table>
	<input type="hidden" value="commit" name="formstep">
	</form>
	<cfset request.stopprocess = "commit">
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
		hi mom
		<cfif isDefined(applyChangesToUsers)>
			the box was checked
			<cfset applyChangesToUsers = #evaluate('form.applyChangesToUsers' & usertypeidArray[i])#>
		<cfelse>
			<cfset applyChangesToUsers = 0>
		</cfif>
		
		
		
		
		<!---Check to see if an entry exists for this formobjectid/usertypeid permission--->
		<cfquery name="q_checkUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT COUNT(*) as UTPCount
		FROM usertypepermission
		WHERE usertypeid = #usertypeidArray[i]# AND formobjectid = #ListFirst(form.toolid, "~")#
		</cfquery>
		<!---if the count is greater than 0, update the row with the new information, otherwise a new insert is needed--->
		<!---The count is zero, insert a new record--->
		<cfif q_checkUserTypePermission.UTPCount EQ 0>
			<cfquery name="q_insertUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			INSERT INTO usertypepermission
			(usertypeid, formobjectid, access, addEdit, approve, remove)
			VALUES
			(#usertypeidArray[i]#, #ListFirst(form.toolid, "~")#, #thisAccess#, #thisAddEdit#, #thisApprove#, #thisRemove#)
			</cfquery>
		<!---The count is greater than zero, update the record--->
		<cfelseif q_checkUserTypePermission.UTPCount GT 0>
			<cfquery name="q_updatetUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			UPDATE usertypepermission
			SET access = #thisAccess#, addEdit = #thisAddEdit#, approve = #thisApprove#, remove = #thisRemove#
			WHERE usertypeid = #usertypeidArray[i]# AND formobjectid = #ListFirst(form.toolid, "~")#
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
				WHERE userid=#q_getUsers.usersid# AND formobjectid=#ListFirst(form.toolid, "~")#
				</cfquery>
				
				<!---no records, no permissions, so insert some--->
				<cfif q_getUserPermissions.recordcount EQ 0>
					<cfquery name="q_insertUserPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					INSERT INTO UserPermission
					(userid, formobjectid, access, addEdit, approve, remove)
					VALUES
					(#q_getUsers.usersid#, #ListFirst(form.toolid, "~")#, #thisAccess#, #thisAddEdit#, #thisApprove#, #thisRemove#)
					</cfquery>
				<!---There are records, so update them--->
				<cfelseif q_getUserPermissions.recordcount GT 0>
					<cfquery name="q_updatetUserPermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE userpermission
					SET access = #thisAccess#, addEdit = #thisAddEdit#, approve = #thisApprove#, remove = #thisRemove#
					WHERE userid = #q_getUsers.usersid# AND formobjectid = #ListFirst(form.toolid, "~")#
					</cfquery>
				</cfif>
				
			</cfloop>
		</cfif>
	
	</cfloop>
	<cfset request.stopprocess = "commit">
	<cflocation url="#request.page#?formstep=showform" addtoken="No">
</cfcase>
</cfswitch>

</cfoutput>

<!--- i_precommit.cfm --->
<script type="text/javascript">
function checkSection(arrayName){
	for(i=0;i<arrayName.length;i++){
		eval('document.usertypepermission.access'+arrayName[i]).checked = true;
		eval('document.usertypepermission.addEdit'+arrayName[i]).checked = true;
		eval('document.usertypepermission.remove'+arrayName[i]).checked = true;
	}
}
function uncheckSection(arrayName){
	for(i=0;i<arrayName.length;i++){
		eval('document.usertypepermission.access'+arrayName[i]).checked = false;
		eval('document.usertypepermission.addEdit'+arrayName[i]).checked = false;
		eval('document.usertypepermission.remove'+arrayName[i]).checked = false;
	}
}
</script>
<cfif NOT isDefined("deleteinstance")>
	<cfparam name="mode" default="listOptions">
	<cfswitch expression="#mode#">
	<cfcase value="listOptions">
		<cfquery name="q_getFormObjects" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
			SELECT		formobject.formobjectid, formobject.label, toolcategory.toolcategoryname
			FROM		formobject INNER JOIN toolcategory ON formobject.toolcategoryid = toolcategory.toolcategoryid
			WHERE		(formobject.formobjectid = formobject.parentid)
			ORDER BY	toolcategory.toolcategoryname, formobject.label
		</cfquery>
		<form name="usertypepermission" method="post">
		<input type="hidden" name="mode" value="SavePermissions">
		<cfmodule template="#application.customtagpath#/embedfields.cfm" ignore="formstep">
		<table cellpadding="3" cellspacing="1" border="0" width="550">
		<tr class="subtoolheader">
			<td class="subtoolheader">&nbsp;</td>
			<td class="subtoolheader">Access</td>
			<td class="subtoolheader">Add/Edit</td>
			<td class="subtoolheader">Delete</td>
		</tr>
			<cfset jID = 0>
			<cfoutput query="q_getFormObjects" group="toolcategoryname">
				<cfset jID = jID + 1>
				<script type="text/javascript">
					var array#jID# = new Array();
				</script>
				<cfset jArrayIndex = 0>
				<tr><td class="subtoolheader" style="PADDING-BOTTOM: 2px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 2px" colspan=4><table cellpadding="0" cellspacing="0" border="0" width=550><tr><td class="subtoolheader" style="PADDING-BOTTOM: 0px; PADDING-LEFT: 0px; PADDING-RIGHT: 0px; PADDING-TOP: 0px">#q_getFormObjects.toolcategoryname#</td><td align=right><a href="javascript:void(0);" onclick="window.status='Check All'; checkSection(array#jID#);" onmouseover="window.status='Check All'; return true;" onmouseout="window.status='Done'; return true;">Check</a> / <a href="javascript:void(0);" onclick="window.status='Uncheck All'; uncheckSection(array#jID#);" onmouseover="window.status='Uncheck All'; return true;" onmouseout="window.status='Done'; return true;">Uncheck</a></td></tr></table></td></tr>
<cfoutput>
	<script type="text/javascript">
		array#jID#[#jArrayIndex#] = #q_getFormObjects.formobjectid#;
	</script>
	<cfset jArrayIndex = jArrayIndex + 1>
		<cfquery name="q_getUsers" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
		SELECT usersid, firstname, lastname
		FROM users
		ORDER BY lastname
		</cfquery>
			<cfset thisAccessPermission = application.getPermissions("access", #q_getFormObjects.formobjectid#)>
			<cfset thisAddEditPermission = application.getPermissions("addEdit", #q_getFormObjects.formobjectid#)>
			<cfset thisRemovePermission = application.getPermissions("remove", #q_getFormObjects.formobjectid#)>
			<cfif thisAccessPermission EQ 1>
				<input type="hidden" name="objectidList" value="#q_getFormObjects.formobjectid#">
				<tr <cfif q_getFormObjects.currentrow MOD 2>bgcolor="##cccccc"<cfelse>bgcolor="##dadada"</cfif>>
				<!---Check to see if this is a new usertype or an update of an existing usertype by checking the length of the form element "usertypeid"--->
					<!---If the length is 0, it is a new usertype, so no query is needed--->
					<cfif #LEN(form.usertypeid)# EQ 0>
						<td>&nbsp;#q_getFormObjects.label#&nbsp;</td>
						<td><input type="checkbox" name="access#q_getFormObjects.formobjectid#" value="1" <cfif #session.user.accessLevel# NEQ 1 AND thisAccessPermission EQ 0>disabled</cfif>></td>
						<td><input type="checkbox" name="addEdit#q_getFormObjects.formobjectid#" value="1" <cfif #session.user.accessLevel# NEQ 1 AND thisAddEditPermission EQ 0>disabled</cfif>></td>
						<td><input type="checkbox" name="remove#q_getFormObjects.formobjectid#" value="1" <cfif #session.user.accessLevel# NEQ 1 AND thisRemovePermission EQ 0>disabled</cfif>></td>
			
				
					<!---The length is greater than 0, so Get permissions for this formobjectid--->
					<cfelseif #LEN(form.usertypeid)# GT 0>
						<cfquery name="q_geFormObjectPermissions" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
						SELECT usertypepermission.access, 
						usertypepermission.addEdit, usertypepermission.remove
						FROM  usertypepermission 
						WHERE usertypeid=#form.usertypeid# AND formobjectid=#q_getFormObjects.formobjectid#
						</cfquery>
						<td>#q_getFormObjects.label#</td>
						<td><input type="checkbox" name="access#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.access EQ 1>checked</cfif>></td>
						<td><input type="checkbox" name="addEdit#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.addEdit EQ 1>checked</cfif>></td>
						<td><input type="checkbox" name="remove#q_getFormObjects.formobjectid#" value="1" <cfif q_geFormObjectPermissions.remove EQ 1>checked</cfif>></td>
					</cfif>
				</tr>
			</cfif>
</cfoutput>
			</cfoutput>
		<tr>
			<td colspan="6" align="center"><input type="submit" value="Save UserType Permissions" class="submitbutton"></td>
		</tr>
		</table>
		<input type="hidden" value="commit" name="formstep">
		</form>
		<cfset request.stopprocess = "commit">
	</cfcase>
	<cfcase value="SavePermissions">
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
			<cfif #LEN(form.usertypeid)# EQ 0>
				<!---Get the next id from assignid--which will be the id of the usertype--->
				<cfquery name="q_getAssignId" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					SELECT ID AS usertype 
					FROM tableID
					WHERE TableName = 'usertype'
				</cfquery>
				
				<cfquery name="q_insertUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				INSERT INTO usertypepermission
				(usertypeid, formobjectid, access, addEdit, remove)
				VALUES
				(#q_getAssignId.usertype#, #objectidArray[i]#, #thisAccess#, #thisAddEdit#, #thisRemove#)
				</cfquery>
			<!---the length is not 0, so it exists--->
			<cfelse>
				<!---Check to see if an entry exists for this formobjectid/usertypeid permission--->
				<cfquery name="q_checkUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
				SELECT COUNT(*) as UTPCount
				FROM usertypepermission
				WHERE usertypeid = #form.usertypeid# AND formobjectid = #objectidArray[i]#
				</cfquery>
				<!---if the count is greater than 0, update the row with the new information, otherwise a new insert is needed--->
				<!---The count is zero, insert a new record--->
				<cfif q_checkUserTypePermission.UTPCount EQ 0>
					<cfquery name="q_insertUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					INSERT INTO usertypepermission
					(usertypeid, formobjectid, access, addEdit, remove)
					VALUES
					(#form.usertypeid#, #objectidArray[i]#, #thisAccess#, #thisAddEdit#, #thisRemove#)
					</cfquery>
				<!---The count is greater than zero, update the record--->
				<cfelseif q_checkUserTypePermission.UTPCount GT 0>
					<cfquery name="q_updatetUserTypePermission" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbPassword#">
					UPDATE usertypepermission
					SET access = #thisAccess#, addEdit = #thisAddEdit#, remove = #thisRemove#
					WHERE usertypeid = #form.usertypeid# AND formobjectid = #objectidArray[i]#
					</cfquery>
				</cfif>
			</cfif>	
		</cfloop>
		<!--- <cflocation url="#request.page#?formstep=showform" addtoken="No"> --->
		<cfset request.stopprocess="">
	</cfcase>
	</cfswitch>
</cfif>


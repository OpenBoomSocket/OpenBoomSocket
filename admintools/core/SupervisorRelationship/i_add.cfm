<cfquery name="q_getUserInfo" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT
		Users.Usersid,
		Users.firstName,
		Users.lastName
	FROM
		Users
	<cfif session.user.id NEQ 100000>
	WHERE 
		Usersid <> 100000
	</cfif>
	ORDER BY 
		Users.lastName, Users.firstName				
</cfquery>
<cfquery name="q_getToolInfo" datasource="#application.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT    formobject.formobjectid, formobject.label
		FROM      formobject INNER JOIN
				  userpermission ON formobject.formobjectid = userpermission.formobjectid
		WHERE     (formobject.formobjectid = formobject.parentid) AND 
					<cfif isDefined("url.userid")>
					(userpermission.userid = #listFirst(url.userid,"~")#)
					<cfelse>
					(userpermission.userid = #session.user.id#) 
					</cfif>
					AND
					(userpermission.access = 1) AND formobject.useWorkFlow = 1
		ORDER BY formobject.label
	</cfquery>

<cfparam name="form.supervisorid" default="#session.user.id#">
<cfparam name="form.userid" default="">
<cfparam name="form.formobject" default="">

<cfoutput>
<form action="index.cfm" method="post" enctype="application/x-www-form-urlencoded">
<input type="hidden" name="i3currenttool" value="#application.tool.SupervisorRelationship#">
<input type="hidden" name="SRstep" value="validate">

<table width="550" border="0" cellspacing="1" cellpadding="3" class="toolTable">
<cfif isDefined("request.errorMsg")>
<tr>
	<td colspan="2" class="errortext">
	#request.errorMsg#
	</td>
</tr>
</cfif>
<tr>
	<td colspan="2" class="toolheader"><strong>Supervisor Relationship</strong></td>
</tr>
		<tr>
				<td class="formitemlabelreq">Supervisor </td>
				<td class="formiteminput"><select name="supervisorid" size="1">
				<option value="">Please choose a supervisor</option>
<cfloop query="q_getUserInfo">
	<option value="#q_getUserInfo.Usersid#~#q_getUserInfo.firstName# #q_getUserInfo.lastName#"<cfif listFind(form.supervisorid,listFirst(q_getUserInfo.Usersid,"~"))> SELECTED</cfif>>#q_getUserInfo.lastName#, #q_getUserInfo.firstName#</option>
</cfloop>
</select></td>
		</tr>
		<tr>
				<td class="formitemlabelreq">Users </td>
				<td class="formiteminput">
				<cfif isDefined("url.userid")>
				#listLast(url.userid,"~")#
				<input type="Hidden" name="userid" value="#listFirst(url.userid,"~")#">
				<cfelse>
				<select name="userid" size="10" multiple>
					<cfloop query="q_getUserInfo">
						<option value="#q_getUserInfo.Usersid#~#q_getUserInfo.firstName# #q_getUserInfo.lastName#"<cfif listFind(form.userid,listFirst(q_getUserInfo.Usersid,"~"))> SELECTED</cfif>>#q_getUserInfo.lastName#, #q_getUserInfo.firstName#</option>
					</cfloop>
				</select>
				</cfif>
			</td>
		</tr>
		<tr>
				<td class="formitemlabelreq">Tools </td>
				<td class="formiteminput"><select name="formobject" size="#val((q_getToolInfo.recordcount\2+1))#" multiple>
<cfloop query="q_getToolInfo">
	<option value="#q_getToolInfo.formobjectid#~#q_getToolInfo.label#"<cfif listFind(form.formobject,listFirst(q_getToolInfo.formobjectid,"~")) OR q_getToolInfo.recordcount EQ 1> SELECTED</cfif>>#q_getToolInfo.label#</option>
</cfloop>
</select></td>
		</tr>
		
<tr>
	<td colspan="2" class="formiteminput" align="center">
	<input name="submit" type="submit" value="Create Supervisor Relationship" class="submitbutton">
	</td>
</tr>
</table>
</form>
</cfoutput>

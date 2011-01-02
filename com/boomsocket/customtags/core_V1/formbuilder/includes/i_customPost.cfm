<!--- Post a custom tool --->

<cfset request.isError=0>
<cfif NOT request.isError>
	<cfset form.toolcategoryid=listFirst(form.toolcategoryid,"~")>
	<cfset form.formenvironmentid=listFirst(form.formenvironmentid,"~")>
	<cfset form.datemodified=createODBCDateTime(now())>
	<cfif len(form.formobjectid)>
		<cfmodule template="#application.customTagPath#/dbaction.cfm"
						action="UPDATE"
						tablename="formobject"
						datasource="#application.datasource#"
						primarykeyfield="#form.formobjectid#"
						assignidfield="formobjectid">
	
	<cfelse>
		<cfset form.datecreated=createODBCDateTime(now())>
		<cfparam name="form.formEnvironmentID" default="102">
		<cfmodule template="#application.customTagPath#/dbaction.cfm"
						action="INSERT"
						tablename="formobject"
						datasource="#application.datasource#"
						assignidfield="formobjectid">
		<cfset form.formobjectid=insertid>    
		<cfset form.parentid=insertid>
		<cfmodule template="#application.customTagPath#/dbaction.cfm"
						action="UPDATE"
						tablename="formobject"
						datasource="#application.datasource#"
						primarykeyfield="#form.formobjectid#"
						assignidfield="formobjectid">
		<cfinclude template="i_getFormobject.cfm">
			<!---  try to create engine file directory --->
		<!--- see if there already is one --->
		<cfset thisFolderName=replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')>
		<cfset thisFileName=replaceNoCase(q_getform.engineDefaultName,"*",q_getform.formname,'all')>
			<cfif NOT directoryExists("#application.installpath#\#thisFolderName#")>
				<cfdirectory action="CREATE"
						 directory="#application.installpath#\#thisFolderName#">
			</cfif>
			<cfif NOT fileExists("#application.installpath#\#thisFolderName#\#thisFileName#")>
				<cffile action="WRITE"
					file="#application.installpath#\#thisFolderName#\#thisFileName#"
					output="<!--- Custom Tool: #q_getform.label# Created on #now()# --->#chr(10)##chr(13)#"
					addnewline="No">
			</cfif>
	</cfif>
	<!--- If this is an Admintool, write permissions to the administrator --->
	<cfif IsDefined('form.formobjectid') AND IsNumeric(form.formobjectid)>
		<cfquery name="q_getFormData" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT  *
			FROM   formobject INNER JOIN formEnvironment ON formobject.formEnvironmentID = formEnvironment.formEnvironmentID
			WHERE  (formobject.formobjectid = #listFirst(form.formobjectid)#)
		</cfquery>
		<cfif findNoCase("admin",q_getFormData.formenvironmentname,1)>
			<cfquery name="q_clearPerms" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE from userpermission
				WHERE formobjectid = #listFirst(q_getFormData.formobjectid)#
				AND userid=100000
			</cfquery>
			<cfquery name="q_addPerms" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				INSERT INTO userpermission (userid, formobjectid, addedit, access, remove, approve)
				VALUES (100000, #listFirst(q_getFormData.formobjectid)#, 1, 1, 1, 1)
			</cfquery>
	<!--- query for this users tool permissions --->
		<cfquery datasource="#application.datasource#" name="q_authenticate" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT Users.Usersid, userpermission.access, userpermission.addEdit, userpermission.approve, userpermission.remove, userpermission.formobjectid, Users.firstName, UserType.roleid
			FROM Users INNER JOIN userpermission ON Users.Usersid = userpermission.userid
				INNER JOIN usertype ON Users.usertypeid = UserType.usertypeid
			WHERE (Users.Usersid = 100000)
		</cfquery>
	<!--- store session structure containing all permissions for user --->
			<cfif q_authenticate.recordcount>
				<cfset user=structNew()>
				<cfset user.name=q_authenticate.firstname>
				<cfset user.id=q_authenticate.usersid>
				<cfset user.liveEdit=0>
				<cfset user.accessLevel=q_authenticate.roleid>
				<cfset tools=arrayNew(2)>
				<cfloop query="q_authenticate">
					<cfset rights=structNew()>
					<cfset rights.access=q_authenticate.access>
					<cfset rights.addedit=q_authenticate.addedit>
					<cfset rights.remove=q_authenticate.remove>
					<cfset tools[q_authenticate.currentrow][1]=q_authenticate.formobjectid>
					<cfset tools[q_authenticate.currentrow][2]=rights>
				</cfloop>
				<cfset user.tools=tools>
				<cflock scope="SESSION" timeout="5" type="EXCLUSIVE">
					<cfset session.user=user>
				</cflock>
				</cfif>
			</cfif>
			<cflocation url="#request.page#">
		<cfelse>
			<cfinclude template="i_showFormCustom.cfm">
		</cfif>
	</cfif>
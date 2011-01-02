<!--- query --->
<cfif NOT isDefined("q_getForm.recordcount")>
	<cfinclude template="i_getFormobject.cfm">
</cfif>
<!--- get all children of this form --->
<cfquery datasource="#application.datasource#" name="q_getAllChildren" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT label, formobjectid
	FROM formobject
	WHERE parentid = #formobjectid# AND formobjectid <> #formobjectid#
</cfquery>

<cfset deletelist="">
<cfif isDefined("form.confirm")>
<cfif q_getAllChildren.recordcount>
	<cfset deletelist=valuelist(q_getAllChildren.formobjectid)>
</cfif>
<cfparam name="successMsg" default="">
<cfset deletelist=listAppend(deletelist,form.formobjectid)>
<!--- check delete permissions for formobject(s) - if not authorized to delete, set to archive --->
<!--- authorized to delete --->
<cfif (IsDefined("session.manformbuilderdel")) AND (session.manformbuilderdel EQ "1")>

	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
				action="DELETE" 
				tablename="formobject"
				datasource="#application.datasource#"
				whereclause="formobjectid IN (#deletelist#)">
	<!--- delete the tool include directory and include templates --->
	<cfset thisFolderName="#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#">
	<cfif directoryExists("#application.installpath#\#thisFolderName#")>
		<cfloop list="preshowform,prevalidate,preconfirm,postconfirm,precommit,postcommit" index="i">
			<cfif fileExists("#application.installpath#\#thisFolderName#\index.cfm")>
				<cffile action="DELETE" file="#application.installpath#\#thisFolderName#\index.cfm">
			</cfif>
		</cfloop>
		<cfdirectory action="DELETE" directory="#application.installpath#\#thisFolderName#">
	</cfif>
<cfelse><!--- NOT authorized to delete --->
	<cfset form.archive=1>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					whereclause="formobjectid IN (#deletelist#)"
					assignIDfield="formobjectid">
</cfif>
<cflocation addtoken="No" url="#request.page#?successMsg=3">

<cfelse>

<cfinclude template="i_getFormobject.cfm">
	<cfoutput>
	<form action="#request.page#" method="post">
		<table width="450" border="0" align="center">
			<tr>
				<td class="toolheader" align="right">Delete Form</td>
			</tr>
			<tr>
				<td class="formiteminput">Are you sure you want to delete the form: #form.objectname#?</td>
			</tr>
			<tr>
				<td align="center" class="forminteminput">
				<input type="Hidden" name="confirm" value="1">
				<input type="Hidden" name="toolaction" value="deleteobject">
				<input type="Hidden" name="formobjectid" value="#formobjectid#">
				<input type="Submit" value="Delete Now" class="submitbutton">
				</td>
			</tr>
		</table>
	</form>
	</cfoutput>
</cfif>

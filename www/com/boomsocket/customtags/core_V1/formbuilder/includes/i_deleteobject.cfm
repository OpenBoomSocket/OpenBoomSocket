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
<cfif application.getPermissions("remove",session.i3currenttool)>
	<cfif isDefined("form.datatable") AND q_getForm.datacapture eq 1>
		<cfquery datasource="#application.datasource#" name="q_checkLock" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			SELECT lockdatatable
			FROM formobject
			WHERE formobjectid = #formobjectid#
		</cfquery>
		<cfif q_checkLock.lockdatatable EQ 0>
			<cfquery datasource="#application.datasource#" name="q_droptable" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DROP TABLE #trim(form.datatable)#
			</cfquery>
			<cfquery datasource="#application.datasource#" name="q_dropSeedObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				DELETE FROM tableID
				WHERE TableName = '#trim(form.datatable)#'
			</cfquery>
		<cfelse>
			<cfset successMsg="This data table is locked. You cannot delete it.">
		</cfif>
	</cfif>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
				action="DELETE" 
				tablename="formobject"
				datasource="#application.datasource#"
				whereclause="formobjectid IN (#deletelist#)">
   <cfif q_getform.formEnvironmentID EQ 109 OR q_getform.formEnvironmentID EQ 100>
        <cfquery name="q_checkForDH" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
            SELECT displayHandlerID
            FROM displayHandler
            WHERE formobjectID = <cfqueryparam cfsqltype="cf_sql_integer" value="#q_getform.formObjectID#">
        </cfquery>
        <cfif q_checkForDH.RecordCount EQ 1>
            <cfmodule template="#application.customTagPath#/dbaction.cfm" 
                action="DELETE" 
                tablename="displayHandler"
                datasource="#application.datasource#"
				whereclause="displayHandlerid IN (#q_checkForDH.displayHandlerID#)">
        </cfif>
   </cfif>
	<!--- Delete User Permissions associated with this object --->
	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
				action="DELETE" 
				tablename="userpermission"
				datasource="#application.datasource#"
				whereclause="formobjectid IN (#deletelist#)">
	<!--- Delete admin navigation elements to clean up after removal, this includes 
	dynamic nav items that are based on instances in the tool --->
	<cfquery name="q_getAddressItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT navitemaddressid
		FROM navitemaddress
		WHERE formobjecttableid IN (#deletelist#)
	</cfquery>
	<cfset addressdeletelist = valueList(q_getAddressItems.navitemaddressid)>
	<cfquery name="q_deleteAddressItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		DELETE FROM navitemaddress
		WHERE formobjecttableid IN (#deletelist#)
	</cfquery>
	<cfif IsDefined('addressdeletelist') AND ListLen(addressdeletelist) GTE 1>
		<cfquery name="q_deleteNavItems" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
			DELETE FROM navitem
			WHERE navitemaddressid IN (#addressdeletelist#)
		</cfquery>
	</cfif>
	<!--- reset nav based on permissions --->
	<cfset session.allNavigation = APPLICATION.navObj.getAllNavigation(usePermissions=1)>
	<cfset session.navXML_1000 = APPLICATION.navUtilObj.getNavXML(alphaordering=0,groupid=1000,q_querydata=session.allNavigation)>
	<cfset session.navData_1000 = APPLICATION.navUtilObj.buildListingNav(navDataSource=XMLParse(SESSION.navXML_1000).XMLRoot.XMLChildren,textOnly=0,classBase="adminnavlist",topOnly=0,editmode=0)>
	<!--- delete the tool include directory and include templates --->
	<cftry>
	
	<cfif directoryExists("#application.installpath#\admintools\includes\#q_getform.formname#")>
		<cfloop list="preshowform,prevalidate,preconfirm,postconfirm,precommit,postcommit" index="i">
			<cfif fileExists("#application.installpath#\admintools\includes\#q_getform.formname#\i_#i#.cfm")>
				<cffile action="DELETE" file="#application.installpath#\admintools\includes\#q_getform.formname#\i_#i#.cfm">
			</cfif>
		</cfloop>
		
		<cfdirectory action="DELETE" directory="#application.installpath#\admintools\includes\#q_getform.formname#">
	</cfif>
	<!--- delete engine and form files --->
	<!--- engine file --->
	<cfif fileExists("#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#\#replaceNoCase(q_getform.engineDefaultName,'*',q_getform.formname,'all')#")>
		<cffile action="DELETE" file="#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#\#replaceNoCase(q_getform.engineDefaultName,'*',q_getform.formname,'all')#">
	</cfif>
	<!--- form file --->
	<cfif fileExists("#application.installpath#\#replaceNoCase(q_getform.formDefaultPath,'*',q_getform.formname,'all')#\#replaceNoCase(q_getform.formDefaultName,'*',q_getform.formname,'all')#")>
		<cffile action="DELETE" file="#application.installpath#\#replaceNoCase(q_getform.formDefaultPath,'*',q_getform.formname,'all')#\#replaceNoCase(q_getform.formDefaultName,'*',q_getform.formname,'all')#">
	</cfif>
	<!--- engine directory (if admin form) --->
	<cfif q_getForm.adminonly>
		<cfdirectory action="DELETE" directory="#application.installpath#\#replaceNoCase(q_getform.engineDefaultPath,'*',q_getform.formname,'all')#">
	</cfif>
		<cfcatch><h2>ERROR</h2>
		There was a problem deleting the physical files and/or folders specified for this object.</cfcatch>
	</cftry>
<cfelse><!--- NOT authorized to delete --->
	<cfset form.archive=1>
	<cfmodule template="#application.customTagPath#/dbaction.cfm" 
					action="UPDATE" 
					tablename="formobject"
					datasource="#application.datasource#"
					whereclause="formobjectid IN (#deletelist#)"
					assignidfield="formobjectid">
</cfif>
<cflocation addtoken="No" url="#request.page#?successMsg=3">

<cfelse>

<cfquery name="q_checkTable" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT name 
	FROM sysobjects 
	WHERE xtype='u' AND name = '#trim(form.datatable)#'
</cfquery>
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
		<cfif (q_getAllChildren.recordcount)>
		<tr>
			<td class="formiteminput">The following dependant forms will be deleted as well:<br /><cfloop list="#valuelist(q_getAllChildren.label)#" index="thisForm">#thisForm#<br /></cfloop></td>
		</tr>
		</cfif>
		<cfif (q_checkTable.recordcount) AND (q_getForm.formobjectid eq q_getForm.parentid)>
			<cfif application.getPermissions("remove",session.i3currenttool)>
					<tr>
						<td class="formiteminput"><input type="Checkbox" name="datatable" value="#form.datatable#"> Delete table <strong>#form.datatable#</strong> from database.</td>
					</tr>
			</cfif>
		</cfif>
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

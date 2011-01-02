<cfparam name="request.isError" default="0">
<cfparam name="request.errorMsg" default="">

<cfif isDefined("formobjectid")>
<!--- check for dupe field in db --->
	<cfinclude template="i_getFormobject.cfm">
	<cfif q_getform.datacapture>
		<cfif (isDefined("form.edit") AND NOT len(trim(form.edit))) AND len(trim(form.fieldname))>
			<cfquery name="q_checkDupe" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
				SELECT *
				FROM #q_getForm.datatable#
			</cfquery>
			<cfif listfindnocase(q_checkDupe.columnlist,form.fieldname)>
				<cfset request.isError=1>
				<cfset request.errorMsg=request.errorMsg&"There is already a fieldname #form.fieldname#||">
			</cfif>
		</cfif>
	</cfif>
<!--- Validate grid positions passed --->
	<cfif listFirst(form.gridposlabel) GT q_getform.tablerows OR listLast(form.gridposlabel) GT q_getform.tablecolumns>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The value for 'Grid Position: Label' is a non-existant cell coordinate.||">
	</cfif>
	<cfif listFirst(form.gridposvalue) GT q_getform.tablerows OR listLast(form.gridposvalue) GT q_getform.tablecolumns>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The value for 'Grid Position: Value' is a non-existant cell coordinate.||">
	</cfif>
	<cfif isDefined("form.custominclude") AND len(form.custominclude) AND NOT fileExists("#application.installpath#\#listChangeDelims(trim(form.custominclude),'\','/')#")>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The custom include path you provided is not valid.||">
	</cfif>
	<cfif isDefined("form.submitbuttonimage") AND len(form.submitbuttonimage) AND NOT fileExists("#application.installpath#\#listChangeDelims(trim(form.submitbuttonimage),'\','/')#")>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The image path you provided is not valid.||">
	</cfif>
	<cfif isDefined("form.imagebuttonpath") AND len(form.imagebuttonpath) AND NOT fileExists("#application.installpath#\#listChangeDelims(trim(form.imagebuttonpath),'\','/')#")>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The image path you provided is not valid.||">
	</cfif>
	<cfif isDefined("form.cancelbuttonimage") AND len(form.cancelbuttonimage) AND NOT fileExists("#application.installpath#\#listChangeDelims(trim(form.cancelbuttonimage),'\','/')#")>
		<cfset request.isError=1>
		<cfset request.errorMsg=request.errorMsg&"The image path you provided is not valid.||">
	</cfif>
</cfif>
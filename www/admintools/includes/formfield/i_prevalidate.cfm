<!--- i_prevalidate.cfm --->
<cfquery name="q_checkUnique" datasource="#APPLICATION.datasource#" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formfieldname
	FROM formfield
	WHERE formfieldname = '#formfieldname#' <cfif isDefined('form.formfieldid') AND len(trim(form.formfieldid))> AND formfield.formfieldid <> # form.formfieldid#</cfif>
</cfquery>
<cfif q_checkUnique.recordcount>
	<cfset request.isError = 1>
	<cfset request.errorMsg = "#UCase(formfieldname)# already exists!<br>">
</cfif>
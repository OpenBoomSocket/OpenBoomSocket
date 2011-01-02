<cfif len(trim(formobjectid))>
	<cfinclude template="i_getFormobject.cfm">
	<cfparam name="form.formobjectid" default="#q_getform.formobjectid#">
	<cfparam name="form.label" default="#q_getform.label#">
	<cfparam name="form.toolcategoryid" default="#q_getform.toolcategoryid#">
	<cfparam name="form.formname" default="#q_getform.formname#">
	<cfparam name="form.formenvironmentid" default="#q_getform.formenvironmentid#">
</cfif>
	<cfparam name="form.formobjectid" default="">
	<cfparam name="form.label" default="">
	<cfparam name="form.toolcategoryid" default="">
	<cfparam name="form.formname" default="">
	<cfparam name="form.formenvironmentid" default="100002">
<cfoutput>

<form action="#request.page#" method="post" name="showform">
<input type="Hidden" name="toolaction" value="customPost">
<input type="Hidden" name="hideFields" value="">
<input type="Hidden" name="formobjectid" value="#formobjectid#">
<input name="externalTool" type="hidden" value="1">
<input type="Hidden" name="validatelist" value="formname,required;formname,filename;label,required;toolcategoryid,required;formenvironmentid,required;">

<table cellpadding="3" cellspacing="1" border="0">
<!--- Show errors if i_validate.cfm found any... --->
<cfif isDefined("request.isError") AND request.isError eq 1>
<tr>
	<td class="errortext" colspan="2">
<strong>Error</strong>
	<ul>
		<cfloop list="#request.errorMsg#" index="error" delimiters="||">
			<li>#error#</li>
		</cfloop>
	</ul>
	</td>
</tr>
</cfif>
<tr>
	<td class="toolheader" align="right" colspan="2">Custom Tool Registration</td>
</tr>
<cfquery datasource="#application.datasource#" name="q_getToolCategories" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT *
	FROM toolcategory
	ORDER BY toolcategoryname ASC
</cfquery>
<tr>
	<td class="formitemlabel">Tool Category:</td>
	<td class="formiteminput"><select name="toolcategoryid" size="1">
			<option value="">Choose a Category</option>
			<cfloop query="q_getToolCategories">
				<option value="#q_getToolCategories.toolcategoryid#~#q_getToolCategories.toolcategoryname#"<cfif q_getToolCategories.toolcategoryid eq form.toolcategoryid> SELECTED</cfif>>#q_getToolCategories.toolcategoryname#</option>
			</cfloop>
		</select></td>
</tr>
<cfquery datasource="#application.datasource#" name="q_getEnvironments" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formenvironmentname, formenvironmentid
	FROM formenvironment
	ORDER BY formenvironmentname ASC
</cfquery>
<tr>
	<td class="formitemlabel">Form Type:</td>
	<td class="formiteminput"><select name="formenvironmentid" size="1">
			<option value="">Choose a Type</option>
			<cfloop query="q_getEnvironments">
				<option value="#q_getEnvironments.formenvironmentid#~#q_getEnvironments.formenvironmentname#"<cfif q_getEnvironments.formenvironmentid eq form.formenvironmentid> SELECTED</cfif>>#q_getEnvironments.formenvironmentname#</option>
			</cfloop>
		</select></td>
</tr>
<tr>
	<td class="formitemlabel">Label:</td>
	<td class="formiteminput"><input name="label" type="text" size="40" value="#form.label#"></td>
</tr>
<tr>
	<td class="formitemlabel">Tool Directory Name:</td>
	<td class="formiteminput"><input name="formname" type="text" size="40" value="#form.formname#"></td>
</tr>
<cfif len(formobjectid)>
<tr>
	<td class="formitemlabel" colspan="2" align="center"><input type="Submit" class="submitbutton" value="Update Form"></td>
</tr>
<cfelse>
<tr>
	<td class="formitemlabel" colspan="2" align="center"><input type="Submit" class="submitbutton" value="Create Form"></td>
</tr>
</cfif>
</form>
<cfif len(formobjectid)>
	<form action="#request.page#" method="post">
	<input type="Hidden" name="toolaction" value="customDelete">
	<input type="Hidden" name="objectname" value="#form.label#">
	<input type="Hidden" name="formobjectid" value="#formobjectid#">
	<tr>
		<td class="formitemlabel" colspan="2" align="center"><input type="Submit" class="submitbutton" value="Delete Form"></td>
	</form>
	</tr>
</cfif>
</table>

</cfoutput>

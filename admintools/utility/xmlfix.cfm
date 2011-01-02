<cfparam name="formobjectid" default="0">
<cfif isDefined("form.formobjectid") AND isDefined("form.datadefinition") AND len(form.datadefinition)>
<cfquery datasource="#application.datasource#" name="q_getit" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	UPDATE formobject
	SET datadefinition = '#trim(form.datadefinition)#', tabledefinition = '#trim(form.tabledefinition)#'
	WHERE formobjectid = #FORM.formobjectid#
</cfquery>
</cfif>
<cfif isDefined('FORM.formobjectid')>
	<cfset formobjectid = FORM.formobjectid>
<cfelseif isDefined('URL.formobjectid')>
	<cfset formobjectid = URL.formobjectid>
</cfif>

<cfquery datasource="#application.datasource#" name="q_getFormObjects" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
	SELECT formobjectname, formobjectid, datadefinition, tabledefinition
	FROM formobject
	ORDER BY formobjectname
</cfquery>
<cfset q_getThisObject = queryNew("formobjectname,formobjectid,datadefinition,tabledefinition")>
<cfif isDefined('formobjectid') and len(trim(formobjectid))>
	<cfquery datasource="#application.datasource#" name="q_getThisObject" username="#APPLICATION.dbUserName#" password="#APPLICATION.dbpassword#">
		SELECT formobjectname, formobjectid, datadefinition, tabledefinition
		FROM formobject
		WHERE formobjectid = #trim(formobjectid)#
		ORDER BY formobjectname
	</cfquery>
</cfif>
<cfsavecontent variable="jsChangeScript">
	<cfoutput>
		<script>
			function clearFormXML(){
				document.getElementById('datadefinition').innerHTML = "";
				document.getElementById('tabledefinition').innerHTML = "";
			}
		</script>
	</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#jsChangeScript#">
<cfoutput>
<p>This tool will open with a listing of available tools in which to examine the xml structure.<br />After your selection, submitting the form will load the existing XML from the tool. After examing/editing, click submit again to save your changes.</p>
<div style="padding-bottom:15px;">
<h2 style="color:red; display:inline;">WARNING</h2><div style="display:inline;">&nbsp;If you change tools, and the datadefinition field is not empty, this tool will overwrite the existing data!&nbsp;</div><h2 style="color:red; display:inline;">WARNING</h2></div>
<div style="clear: both;"/>
<form action="#request.page#" method="post">
	<select name="formobjectid" onchange="clearFormXML()">
		<cfloop query="q_getFormObjects">
			<option value="#q_getFormObjects.formobjectid#" <cfif q_getThisObject.formobjectid EQ q_getFormObjects.formobjectid> SELECTED=selected</cfif>>#q_getFormObjects.formobjectname#</option>
		</cfloop>
	</select>
	<input type="Submit">
	<h3>Data Definition</h3>
	<textarea cols="80" rows="60" id="datadefinition" name="datadefinition">#q_getThisObject.datadefinition#</textarea>
	<h3>Table Definition</h3>
	<textarea cols="80" rows="60" id="tabledefinition" name="tabledefinition">#q_getThisObject.tabledefinition#</textarea>
	<input type="Submit">
</form>
</cfoutput>


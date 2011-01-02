<!--- i_preshowform.cfm --->
<cfparam name="deleteAction" default="false">
<cfif isDefined('instanceID')>
	<cfset thisID = instanceID>
<cfelseif IsDefined('insertID')>
	<cfset thisID = insertID>
<cfelseif IsDefined('deleteInstance')>
	<cfset thisID = deleteInstance>
	<cfset deleteAction = 'true'>
</cfif>
<cfif IsDefined('instanceid') AND IsNumeric(instanceid)>
	<cfinvoke component="#APPLICATION.cfcpath#.oneToMany" method="getLookupValues" returnvariable="FORM.fieldcategory">
		<cfinvokeargument name="tablename" value="formfield_formfieldcategory">
		<cfinvokeargument name="instanceid" value="#instanceid#">
		<cfinvokeargument name="keytable" value="formfieldcategory">
		<cfinvokeargument name="keyfield" value="formfieldid">
	</cfinvoke>
</cfif>


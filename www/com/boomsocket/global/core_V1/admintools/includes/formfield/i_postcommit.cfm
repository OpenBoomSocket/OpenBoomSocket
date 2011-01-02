<!--- i_postcommit.cfm --->
<cfparam name="deleteAction" default="false">
<cfif isDefined('instanceID')>
	<cfset thisID = instanceID>
<cfelseif IsDefined('insertID')>
	<cfset thisID = insertID>
<cfelseif IsDefined('deleteInstance')>
	<cfset thisID = deleteInstance>
	<cfset deleteAction = 'true'>
</cfif>
<cfinvoke component="#application.cfcpath#.oneToMany" method="init" returnvariable="DBsuccess">
	<cfinvokeargument name="tablename" value="formfield_formfieldcategory">
	<cfinvokeargument name="instanceid" value="#thisID#">
	<cfinvokeargument name="keyfield" value="formfieldid">
	<cfif NOT isDefined("deleteinstance")>
		<cfinvokeargument name="keylist" value="#FORM.fieldcategory#">
		<cfinvokeargument name="keytable" value="formfieldcategory">
	</cfif>
</cfinvoke>



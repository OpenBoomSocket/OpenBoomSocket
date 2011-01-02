<!--- Invokes the custom tag Form Process dynamically --->
<!--- Set up the CFC. --->
<cfcomponent
             displayname="Invoke Form Process"
             hint="This tag is used to call the formProcess custom tag which handles all aspects of data form entry, validation and capture." name="invokeFormProcess">
<cfsetting enablecfoutputonly="Yes">
    <cffunction name="getFormObject"
             access="remote"
             returntype="any"
             displayname="Get Form Object"
             hint="Queries for the form object XML and displays the form.">
	<cfargument name="formObjectID" type="numeric" required="yes">
	<cfsavecontent variable="rtn_getFormObject">
	<cfoutput>
	<cfif isDefined("application.customTagPath")>
		<cfmodule template="#application.customTagPath#/formprocess.cfm" formobjectid="#arguments.formObjectID#">
	<cfelse>
		<cfmodule template="#application.customTagPath#/formprocess.cfm" formobjectid="#arguments.formObjectID#">
	</cfif>
	</cfoutput>
	</cfsavecontent>
	<cfreturn rtn_getFormObject>
  </cffunction>
</cfcomponent>
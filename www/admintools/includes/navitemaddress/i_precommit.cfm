<!--- i_precommit.cfm --->
<cfparam name="deleteAction" default="false">
<cfif IsDefined('deleteInstance')>
	<cfset thisID = deleteInstance>
	<cfset deleteAction = 'true'>
</cfif>
<cfif deleteAction EQ False>
	<cfif IsDefined('form.navitemaddressname') AND NOT len(form.navitemaddressname) AND IsDefined('form.urlPath') AND Len(Trim(form.urlPath))>
		<cfset form.navitemaddressname = 'URL: '&form.urlPath>
	<cfelseif IsDefined('form.navitemaddressname') AND NOT len(form.navitemaddressname)>
		<cfset form.navitemaddressname = form.formobjecttableid & " | " & form.objectinstanceid>
	</cfif>
</cfif>
<!--- i_precommit.cfm --->
<cfparam name="deleteAction" default="false">
<cfif IsDefined('deleteInstance')>
	<cfset thisID = deleteInstance>
	<cfset deleteAction = 'true'>
</cfif>
<cfif deleteAction EQ False>
	<cfif IsDefined('form.urlPath') AND Len(Trim(form.urlPath))>
		<cfset form.navitemaddressname = form.urlPath>
	<cfelse>
		<cfset form.navitemaddressname = form.formobjecttableid & " | " & form.objectinstanceid>
	</cfif>
</cfif>
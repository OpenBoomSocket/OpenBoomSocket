<!--- i_precommit.cfm --->
<cfif NOT isDefined("deleteinstance")>
	<cfset assocList = form.associateFormobjectid>
	<cfset form.associateFormobjectid = listFirst('#assocList#')>
</cfif>
<!--- i_prevalidate.cfm --->
<cfif Not isDefined('deleteinstanceid')>
	<cfif NOT((len(trim(form.formobjecttableid)) GT 0 AND form.objectinstanceid GT 0) OR len(trim(form.urlpath)))>
		<cfset request.iserror = 1>
		<cfset request.errorMsg = "Must either choose a tool/instance combination or provide a URL.">
	</cfif>
</cfif>

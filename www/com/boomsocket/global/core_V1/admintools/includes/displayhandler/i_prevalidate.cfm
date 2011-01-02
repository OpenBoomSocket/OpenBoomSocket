<!--- i_prevalidate.cfm --->
<cfif len(form.displayobjectid) AND len(form.custominclude)>
	<cfset currentContainer=0>
	<cfset request.isError=1>
	<cfset request.errorMsg="You must specify either a display object or custom include to use, not both.">
</cfif>
<cfif len(form.customInclude)>
	<cfif NOT fileExists("#application.installpath#\includes\#form.customInclude#")>
		<cfset currentContainer=0>
		<cfset request.isError=1>
		<cfset request.errorMsg="The custom include file you specified does not exist in www/includes. You must first put the file in this directory before registering the Data Driven Display.">
	</cfif>
</cfif>

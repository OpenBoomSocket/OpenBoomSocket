<!--- i_prevalidate.cfm --->
<cfif NOT len(form.custominclude)>
	<cfset currentContainer=0>
	<cfset request.isError=1>
	<cfset request.errorMsg="You must specify a custom include to use.">
<cfelse >
	<cfif NOT fileExists("#application.installpath#\includes\#form.customInclude#")>
		<cfset currentContainer=0>
		<cfset request.isError=1>
		<cfset request.errorMsg="The custom include file you specified does not exist in www/includes. You must first put the file in this directory before registering the Data Driven Display.">
	</cfif>
</cfif>

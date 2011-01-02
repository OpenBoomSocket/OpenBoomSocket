<cfparam name="attributes.var_name" default="mycontents">
<cfif not thistag.HasEndTag>
	<cfset thistag.generatedcontent="">
		You must have an end Tag
	<cfabort>
</cfif>

<cfif thistag.executionmode is "end">
	<cfset "caller.#attributes.var_name#"=thistag.generatedcontent>			
	<cfset thistag.generatedcontent=''>
</cfif>